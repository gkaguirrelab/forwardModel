classdef prfTimeShift < handle
    
    properties (Constant)
                
        % The number of parameters in the model
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
        
        % The projection matrix used to regress our nuisance effects
        T
        
        % The last calculation of the gaussStim.
        gaussStimLast
        
        % The last set of params
        xLast
    end
    
    % Calling function can see, but not modify
    properties (SetAccess=private)
        
        % A vector of the length totalTRs x 1 that has an index value to
        % indicate which acquisition (1, 2, 3 ...) a data time
        % sample is from.
        dataAcqGroups
        
        % A vector of length totalTRs x 1 and in units of seconds that
        % defines the temporal support of the data relative to the time of
        % onset of the first TR of each acquisition.
        dataTime
        
        % TR of the data in seconds
        dataDeltaT        
        
        % The stimulus vector, concatenated across acquisitions and
        % squished across x y. Thus it will have the dimensions:
        %	[totalST x*y]
        stimulus
        
        % A vector of length totalST x 1 that has an index value to
        % indicate which acquisition (1, 2, 3 ...) a stimulus time
        % sample is from.
        stimAcqGroups
        
        % A vector of length totalST x 1 and in units of seconds that
        % defines the temporal support of stimulus relative to the time of
        % onset of the first TR of each acquisition. If set to empty, the
        % stimTime is assumed to be equal to the dataTime.
        stimTime

        % The temporal resolution of the stimuli in seconds.
        stimDeltaT

        % 1x2 vector with the original [x y] dimensions
        res        
        
        % A cell array that contains things that the model might want
        payload

        % A time x 1 vector that defines the HRF convolution kernel
        hrf        

    end
    
    % These may be modified after object creation
    properties (SetAccess=public)
        
        % 1x3 vector that defines the parameters of an HRF
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
        function obj = prfTimeShift(data,stimulus,tr,varargin)
                        
            % instantiate input parser
            p = inputParser; p.KeepUnmatched = false;
            
            % Required
            p.addRequired('data',@iscell);
            p.addRequired('stimulus',@iscell);
            p.addRequired('tr',@isscalar);
            
            p.addParameter('stimTime',{},@iscell);
            p.addParameter('payload',{},@iscell);
            p.addParameter('hrfParams',[0.86 0.09 0.01],@isvector);
            p.addParameter('polyDeg',[],@isnumeric);
            p.addParameter('typicalGain',300,@isscalar);
            p.addParameter('seedScale','medium',@ischar);
            p.addParameter('verbose',true,@islogical);
            p.addParameter('pixelsPerDegree',5.18,@isscalar);
            p.addParameter('screenMagnification',1,@isscalar);
        
            % parse
            p.parse(data, stimulus, tr, varargin{:})
            
            % Create the dataTime and dataAcqGroups variables
            % Concatenate and store in the object.
            for ii=1:length(data)                
                dataAcqGroups{ii} = ii*ones(size(data{ii},2),1);
                dataTime{ii} = 0:tr:tr*(size(data{ii},2)-1);
            end
            obj.dataAcqGroups = catcell(1,dataAcqGroups);
            obj.dataTime = catcell(1,dataTime);
            obj.dataDeltaT = tr;            
            clear data            
            
            % Obtain the dimensions of the stimulus frames and store
            res = [size(stimulus{1},1) size(stimulus{1},2)];
            obj.res = res;

            % Vectorize the stimuli. Create the stimAcqGroups variable.
            % Concatenate and store in the object.
            for ii=1:length(stimulus)
                stimulus{ii} = squish(stimulus{ii},2)';
                stimAcqGroups{ii} = ii*ones(size(stimulus{ii},1),1);
            end
            obj.stimulus = catcell(1,stimulus);
            obj.stimAcqGroups = catcell(1,stimAcqGroups);
            
            % Construct and / or check stimTime
            if isempty(p.Results.stimTime)
                % If stimTime is empty, check to make sure that the length
                % of the data and stimulus matrices in the time domain
                % match
                if length(obj.stimAcqGroups) ~= length(obj.dataAcqGroups)
                    error('forwardModelObj:timeMismatch','The stimuli and data have mismatched temporal support and no stimTime has been passed.');
                end
                % Set stimTime to empty
                obj.stimTime = [];
                % The temporal resolution of the stimuli is the same as the
                % temporal resolution of the data
                obj.stimDeltaT = tr;
            else
                % We have a stimTime variable.
                stimTime = p.Results.stimTime;
                % Make sure that all of the stimTime vectors are regularly
                % sampled (within 3 decimal precision)
                regularityCheck = cellfun(@(x) length(unique(round(diff(x),3))),stimTime);
                if any(regularityCheck ~= 1)
                    error('forwardModelObj:timeMismatch','One or more stimTime vectors are not regularly sampled');
                end
                % Make sure that the deltaT of the stimTime vectors all
                % match, and store this value
                deltaTs = cellfun(@(x) x(2)-x(1),stimTime);
                if length(unique(deltaTs)) ~= 1
                    error('forwardModelObj:timeMismatch','The stimTime vectors do not have the same temporal resolution');
                end
                obj.stimDeltaT = deltaTs(1);
                % Concatenate and store the stimTime vector
                obj.stimTime = catcell(1,stimTime);
                % Check to make sure that the length of the stimTime vector
                % matches the length of the stimAcqGroups
                if length(obj.stimTime) ~= length(obj.stimAcqGroups)
                    error('forwardModelObj:timeMismatch','The stimTime vectors are not equal in length to the stimuli');
                end
            end
            
            % Done with these big variables
            clear data stimulus stimTime acqGroups
            
            % Distribute other params to obj properties
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
        
        % Required methds -- The forwardModel function expects these
        rawData = prep(obj,rawData)
        x0 = initial(obj)
        signal = clean(obj, signal)
        [c, ceq] = nonlcon(obj, x)
        fVal = objective(obj, signal, x)
        fit = forward(obj, x)
        metric = metric(obj, signal, x)
        seeds = seeds(obj, data, vxs)
        results = results(obj, params, metric)
        results = plot(obj, data, results)           
        
        % Internal methods
        setbounds(obj)
        genprojection(obj)
        genhrf(obj)
        
        % Set methods
        function set.hrfParams(obj, value)
            obj.hrfParams = value;
            obj.genhrf;
        end

        function set.polyDeg(obj, value)
            obj.polyDeg = value;
            obj.genprojection;
        end
        
    end
end