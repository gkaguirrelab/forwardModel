classdef glm < handle
    
    properties (Constant)
        
        % Properties of the search stages.
        nStages = 0;
        floatSet = {};
        fixSet = {};
        
        % A description of the model
        description = ...
            ['A linear fit is peformed during seed generation.\n' ...
            'No non-linear search is performed.\n'];
    end
    
    % Private properties
    properties (GetAccess=private)
        
        % The projection matrix used to regress our nuisance effects
        T
        
    end
    
    % Calling function can see, but not modify
    properties (SetAccess=private)
        
        % The number of parameters in the model
        nParams;
                
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
        
        % A cell array that contains things that the model might want
        payload
        
        % A time x 1 vector that defines the HRF convolution kernel
        hrf
        
        % The type of HRF model, including {'flobs','gamma'};
        hrfType
        
    end
    
    % These may be modified after object creation
    properties (SetAccess=public)
        
        % The number of low frequencies to be removed from each acquisition
        polyDeg
        
        % Verbosity
        verbose
        
    end
    
    methods
        
        % Constructor
        function obj = glm(data,stimulus,tr,varargin)
            
            % instantiate input parser
            p = inputParser; p.KeepUnmatched = false;
            
            % Required
            p.addRequired('data',@iscell);
            p.addRequired('stimulus',@iscell);
            p.addRequired('tr',@isscalar);
            
            p.addParameter('stimTime',{},@iscell);
            p.addParameter('payload',{},@iscell);
            p.addParameter('polyDeg',[],@isnumeric);
            p.addParameter('hrfParams',[0.86 0.09 0.01],@isvector);
            p.addParameter('verbose',true,@islogical);
            
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
            
            % Each row in the stimulus is a different stum type that will
            % be fit with its own gain parameter. Record how many there are
            nStimTypes = size(stimulus{1},1);
            
            % The number of params is the number of stim types, plus three
            % for the form of the HRF
            obj.nParams = nStimTypes+3;
                        
            % Create the stimAcqGroups variable. Concatenate the cells and
            % store in the object.
            for ii=1:length(stimulus)
                % Transpose the stimulus matrix within cells
                stimulus{ii} = stimulus{ii}';
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
            obj.polyDeg = p.Results.polyDeg;
            obj.verbose = p.Results.verbose;
            
            % Create and cache the hrf
            obj.genhrf
            
            % Create and cache the projection matrix
            obj.genprojection;            
            
        end
        
        % Required methds -- The forwardModel function expects these
        rawData = prep(obj,rawData)
        x0 = initial(obj)
        signal = clean(obj, signal)
        [c, ceq] = nonlcon(obj, x)
        fVal = objective(obj, signal, x)
        [fit, hrf] = forward(obj, x)
        metric = metric(obj, signal, x)
        seeds = seeds(obj, data, vxs)
        results = results(obj, params, metric)
        results = plot(obj, data, results)
        
        % Internal methods
        genprojection(obj)
        
        % Set methods
        function set.polyDeg(obj, value)
            obj.polyDeg = value;
            obj.genprojection;
        end
        
    end
end