classdef pRF_timeShift < handle
    
    properties (Constant)
        
        % The identity of the dimensions of the data variable
        dimdata = 1;
        dimtime = 2;
        
        % THe number of parameters in the model
        nParams = 6;
        
        % The model is executed as a two stage search. The float and fix
        % sets describe which parameters are adjusted during each stage.
        % During the first stage, the x and y position and gain parameters
        % are adjusted to best fit the data, while the remaining parameters
        % are fixed at their initial (x0) values. The results of this first
        % stage are fed to the second stage, during which all parameters
        % are adjusted except for the compressive non-linearity, which is
        % set to a fixed value in this implementation.
        nStages = 2;
        floatSet = {[1 2 4],[1 2 3 4 6]};
        fixSet = {[3 5 6],[5]};
        
        % A description of the model
        description = ...
            ['A pRF mapping approach that assumes a circular symmetric \n' ...
             'Gaussian receptive field and a fixed, compressive non- \n' ...
             'linearity. The model adjusts the time-to-peak of the HRF \n',...
             'and thus requires that the stimulus play in forward and \n',...
             'time-reversed directions. A two-stage non-linear search \n', ...
             'is performed, fist across pRF center and gain, and then \n', ...
             'across the entire parameter set. \n'];
    end
    
    % Private properties
    properties (GetAccess=private)
        % Pre-computed properties of the 2D Gaussian used in obj.forward
        xx
        yy
        
        % A time x 1 vector that defines the HRF convolution kernel
        hrf
        
        % The projection matrix used to regress our nuisance effects
        T
        
        % The last calculation of the gaussStim.
        gaussStimLast
        
        % The last set of params
        xLast
    end
    
    % Fixed after object creation
    properties (SetAccess=private)

        % The stimulus vector, concatenated across acquisitions and squished across x y. Thus it
        % will have the dimensions [totalTRs x*y]
        stimulus
        
        % A vector of the length totalTRs x 1 that has an index value to
        % indicate which acquisition (1, 2, 3 ...) this TR is from.
        acqGroups
        
        % 1x2 vector with the original [x y] dimensions
        res
        
        % TR of the data in seconds
        tr
        
        % A cell array that contains things that the model might want
        payload
        
        % The number of acquisitions
        nAcqs
        
        % A vector with the number of TRs in each acquisition.
        nTRsPerAcq
        
    end
    
    % These may be modified after object creation
    properties (SetAccess=public)
        
        % 1x4 vector that defines the parameters of an HRF
        hrfParams
        
        % The number of low frequencies to be removed from each acquisition
        polyDeg
        
        % Typical amplitude of the BOLD fMRI response in the data
        typicalGain

        % The size of sigma produced for initial params
        seedScale
        
        % The lower and upper bounds for the model
        lb
        ub
        
        % A vector, equal in length to the number of parameters, that
        % specifies the smallest step size that fmincon will take for each
        % parameter. This threshold is also used to determine if, in a call
        % to obj.forward, the gaussvector needs to be re-calculated, or if
        % the prior value can be used.
        FiniteDifferenceStepSize
                
        % Verbosity
        verbose
        
        % The number of pixels in the stimulus specification per degree of
        % visual angle
        pixelsPerDegree
        
        % The magnification (or minification) of the screen caused by
        % artificial lenses.
        screenMagnification
    end
    
    methods

        % Constructor
        function obj = pRF_timeShift(data,stimulus,tr,varargin)
                        
            % instantiate input parser
            p = inputParser; p.KeepUnmatched = false;
            
            % Required
            p.addRequired('data',@iscell);
            p.addRequired('stimulus',@iscell);
            p.addRequired('tr',@isscalar);
            
            p.addParameter('payload',{},@iscell);
            p.addParameter('hrfParams',[4 10 7 20],@isvector);
            p.addParameter('polyDeg',[],@isscalar);
            p.addParameter('typicalGain',30,@isscalar);
            p.addParameter('seedScale','medium',@ischar);
            p.addParameter('verbose',true,@islogical);
            p.addParameter('pixelsPerDegree',5.18,@isscalar);
            p.addParameter('screenMagnification',1,@isscalar);
        
            % parse
            p.parse(data, stimulus, tr, varargin{:})
            
            % Derive properties from the data variable and then clear
            obj.nAcqs = length(data);
            obj.nTRsPerAcq = cellfun(@(x) size(x,2),data);
            clear data
            
            % Obtain the dimensions of the stimulus frames and store
            res = [size(stimulus{1},1) size(stimulus{1},2)];
            obj.res = res;
            
            % Vectorize the stimuli. Create a vector to represent run
            % breaks. Concatenate and store in the object.
            for ii=1:length(stimulus)
                stimulus{ii} = squish(stimulus{ii},2)';
                acqGroups{ii} = ii*ones(size(stimulus{ii},1),1);
            end
            obj.stimulus = catcell(1,stimulus);
            obj.acqGroups = catcell(1,acqGroups);
            clear stimulus acqGroups
            
            % Distribute other params to obj properties
            obj.tr = tr;
            obj.payload = p.Results.payload;
            obj.hrfParams = p.Results.hrfParams;
            obj.polyDeg = p.Results.polyDeg;
            obj.typicalGain = p.Results.typicalGain;
            obj.seedScale = 'medium';
            obj.verbose = p.Results.verbose;
            obj.pixelsPerDegree = p.Results.pixelsPerDegree;
            obj.screenMagnification = p.Results.screenMagnification;

            % Set the bounds and minParamDelta
            obj.setbounds;
            
            % Initialize xLast with values slightly different from the
            % initial
            obj.xLast = obj.initial*1.01;

            % Call the forward model with initial params, thus forcing the
            % gaussStim to be created and stored
            obj.forward(obj.initial);
            
            % Create and cache the hrf
            obj.genhrf
            
            % Create and cache the projection matrix
            obj.genprojection;
            
            % Create and cache the 2D Gaussian in a private property
            [~,obj.xx,obj.yy] = makegaussian2d(max(res),2,2,2,2);
            
        end
        
        % Set methods
        function set.hrfParams(obj, value)
            obj.hrfParams = value;
            obj.genhrf;
        end

        function set.polyDeg(obj, value)
            obj.polyDeg = value;
            obj.genprojection;
        end
        
        % Methods
        rawData = prep(obj,rawData)
        genprojection(obj)
        x0 = initial(obj)
        setbounds(obj)
        signal = clean(obj, signal)
        [c, ceq] = nonlcon(obj, x)
        fit = forward(obj, x)
        metric = metric(obj, signal, x)
        seeds = seeds(obj, data, vxs)
        results = results(obj, params, metric)
    end
end