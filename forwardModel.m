function results = forwardModel(data,stimulus,tr,varargin)
% Non-linear model fitting of fMRI time-series data
%
% Syntax:
%  results = forwardModel(data,stimulus,tr)
%
% Description:
%   Lorem ipsum
%
% Inputs:
%   data                  - A matrix [v t] or cell array of such
%                           matricies. The fMRI time-series data across t
%                           TRs, for v vertices / voxels.
%   stimulus              - A matrix [x y t] or cell array of such
%                           matrices. 
%   tr                    - Scalar. The TR of the fMRI data in seconds.
%
% Optional key/value pairs:
%  'modelClass'           - Char vector. The name of one of the available
%                           model objects. Choices include:
%                             {'pRF','pRF_timeShift'}
%  'modelOpts'            - A cell array of key-value pairs that are passed
%                           to the model object at that time of object
%                           creation.
%  'modelPayload'         - A cell array of additional inputs that is
%                           passed to the model object. The form of the
%                           payload is defined by the model object.
%  'vxs'                  - Vector. A list of vertices/voxels to be
%                           processed.
%  'maxIter'              - Scalar. The maximum number of iterations
%                           conducted by lsqcurvefit in model fitting.
%  'verbose'              - Logical.
%
% Outputs:
%   results               - Structure
%
% Examples:
%{
    % Create a stimulus
    stimulus = [];
    stimulus{1}(1,1,:) = repmat([zeros(1,12) ones(1,12)],1,8);

    % Instantiate the "example" model
    tr = 1;
    dummyData = [];
    dummyData{1}(1,:) = zeros(1,size(stimulus{1},3));
    model = example(dummyData,stimulus,tr);

    % Create simulated data with the default params, and add some noise
    datats = model.forward(model.initial);
    datats = datats + randn(size(datats))*25;
    data = []
    data{1}(1,:) = datats;

    % Call the forwardModel
    results = forwardModel(data,stimulus,tr,'modelClass','example');

    % Plot the data and the fit
    figure
    plot(datats);
    hold on
    plot(model.forward(results.params));
%}


%% input parser
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('data',@(x)(iscell(x) || ismatrix(x)));
p.addRequired('stimulus',@(x)(iscell(x) || ismatrix(x)));
p.addRequired('tr',@isscalar);

p.addParameter('modelClass','pRF_timeShift',@ischar);
p.addParameter('modelOpts',{'typicalGain',30},@iscell);
p.addParameter('modelPayload',{},@iscell);
p.addParameter('vxs',[],@isvector);
p.addParameter('maxIter',500,@isscalar);
p.addParameter('silenceWarnings',true,@islogical);
p.addParameter('verbose',true,@islogical);

% parse
p.parse(data,stimulus,tr, varargin{:})

verbose = p.Results.verbose;
silenceWarnings = p.Results.silenceWarnings;

%% Alert the user
if verbose
    fprintf(['Fitting the ' p.Results.modelClass ' model.\n\n']);
end


%% Massage inputs and set constants
% Place the data and stimulus in a cell if not already so
if ~iscell(data)
    data = {data};
end
if ~iscell(stimulus)
    stimulus = {stimulus};
end

% Identify the row and columns of the data matrix
dimdata = 1;
totalVxs = size(data{1},dimdata);

% Define vxs (the voxel/vertex set to process)
if isempty(p.Results.vxs)
    vxs = 1:length(totalVxs);
else
    vxs = p.Results.vxs;
end


%% Set up model
% Create the model object
model = feval(p.Results.modelClass,data,stimulus,p.Results.tr,...
    'payload',p.Results.modelPayload, ...
    p.Results.modelOpts{:});

% Set model verbosity
model.verbose = verbose;

% Prep the raw data
data = model.prep(data);

% Generate seeds
seeds = model.seeds(data,vxs);


%% Fit the data

% Basic options for fmincon
basicOptions = optimoptions('fmincon','Display','off');

% Pre-compute functions that will asemble the parameters in the different
% model stages, and create different option sets
for bb = 1:model.nStages
	order = [model.floatSet{bb} model.fixSet{bb}];
	[~,sortOrder]=sort(order);
	xSort{bb} = @(x) x(sortOrder);
    stageOptions = basicOptions;
    stageOptions.FiniteDifferenceStepSize = ...
        model.FiniteDifferenceStepSize(model.floatSet{bb});
    options{bb} = stageOptions;
end

% Obtain the model bounds
lb = model.lb; ub = model.ub;

% Alert the user
if verbose
    tic
    fprintf(['Fitting non-linear model over ' num2str(length(vxs)) ' vertices:\n']);
    fprintf('| 0                      50                   100%% |\n');
    fprintf('.\n');
end

% Store the warning state
warningState = warning;

% Loop through the voxels/vertices in vxs
parfor ii=1:length(vxs)
    
    % Silence warnings if so instructed. This must be done inside the
    % parloop to apply to each worker.
    if silenceWarnings
        warning('off','MATLAB:singularMatrix');
        warning('off','MATLAB:nearlySingularMatrix');
        warning('off','MATLAB:illConditionedMatrix');
    end

    % Update progress bar
    if verbose && mod(ii,round(length(vxs)/50))==0
        fprintf('\b.\n');
    end

    % Squeeze the data from a cell array into a single concatenated time
    % series for the selected voxel/vertex
    datats = cell2mat(cellfun(@(x) x(vxs(ii),:),data,'UniformOutput',0))';
    
    % Apply the model cleaning step, which may include regression of
    % nuisance components.
    datats = model.clean(datats);
    
    % Pre-allocate the seed search result variables to keep par happy
    seedParams = nan(length(seeds),model.nParams);
    seedMetric = nan(length(seeds),1);
    
    % Loop over seed sets
    for ss = 1:length(seeds)
        seed = seeds{ss}(vxs(ii),:);
        x0 = seed;

        % Loop over model stages
        for bb = 1:model.nStages
            
            % Get the params in the fix and float set for this stage
            fixSet = model.fixSet{bb};
            floatSet = model.floatSet{bb};
            
            % Call the non-linear fit function
            myObj = @(x) norm(datats - model.forward(xSort{bb}([x x0(fixSet)])));
            x = fmincon(myObj,x0(floatSet),[],[],[],[], ...
                lb(floatSet),ub(floatSet), ...
                model.nonlcon, options{bb});
            
            % Update the x0 guess with the searched params
            x0(model.floatSet{bb}) = x;
        end
        
        % Store the final params
        seedParams(ss,:) = x0;
        
        % Evaluate the model metric
        seedMetric(ss) = model.metric(datats,x0);
    end
    
    % Save the best result across seeds
    [~,bestSeedIdx]=max(seedMetric);
    parParams(ii,:) = seedParams(bestSeedIdx,:);
    parMetric(ii) = seedMetric(bestSeedIdx);
    
end

% report completion of loop
if verbose
    toc
    fprintf('\n');
end

% Restore the warning state. It shouldn't be changed up here at the main
% execution level since warnings were silenced withihn the worker pool, but
% restoring here to be safe.
warning(warningState);

% Map the par variables into full variables
params = nan(totalVxs,model.nParams);
params(vxs,:) = parParams;
clear parParams
metric = nan(totalVxs,1);
metric(vxs) = parMetric;
clear parMetric;


%% Prepare the results variable
results = model.results(params, metric);

% Add the model information
results.model.class = p.Results.modelClass;
results.model.inputs = {stimulus, p.Results.tr};
results.model.opts =  p.Results.modelOpts;
results.model.payload =  p.Results.modelPayload;

% Store the calling options
results.meta.vxs = p.Results.vxs;
results.meta.tr = p.Results.tr;
results.meta.maxIter = p.Results.maxIter;

end
