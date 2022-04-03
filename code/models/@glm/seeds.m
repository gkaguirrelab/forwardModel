function seeds = seeds(obj,data,vxs)
% Obtain the model fit using linear regression
%
% Syntax:
%   seeds = obj.seeds(data,vxs)
%
% Description:
%   Generates a set of seed parameters for each voxel/vertex in vxs.
%
% Inputs:
%   data                  - A matrix [v t] or cell array of such
%                           matricies. The fMRI time-series data across t
%                           TRs, for v vertices / voxels. The data should
%                           have bassed through the prep stage.
%   vxs                   - Vector. A list of vertices/voxels to be
%                           processed.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   seeds                 - Cell array. Each cell contains a matrix of
%                           [v nParams] and is one of the seed sets.
%

% Derived vars
totalVxs = size(data{1},1);
nVxs = length(vxs);

% Obj variables
stimulus = obj.stimulus;
stimAcqGroups = obj.stimAcqGroups;
stimTime = obj.stimTime;
verbose = obj.verbose;
hrf = obj.hrf;

% Pre-allocate the variables
x0 = obj.initial;
seedMatrix = repmat(x0,totalVxs,1);

% Generate the regression matrix, which is the stimulus convolved with the
% HRF
X = stimulus;
for ss = 1:size(stimulus,2)
    X(:,ss) = conv2run(stimulus(:,ss),hrf,stimAcqGroups);
end

% If the stimTime variable is not empty, resample X to match the temporal
% support of the data.
if ~isempty(stimTime)
    dataAcqGroups = obj.dataAcqGroups;
    dataTime = obj.dataTime;
    resampX = [];
    for ss = 1:size(X,2)
        resampX(:,ss) = resamp2run(X(:,ss),stimAcqGroups,stimTime,dataAcqGroups,dataTime);
    end
    X = resampX;
end

% Apply the cleaning step
for ss = 1:size(stimulus,2)
    X(:,ss) = obj.clean(X(:,ss));
end

% Store the warning state
warningState = warning;

% Alert the user and prepare a progress bar
if verbose
    if nVxs==1
        fprintf('Fitting the GLM in one voxel.\n');
    else
        fprintf(['Fitting the GLM over ' num2str(nVxs) ' vertices.\n']);
    end
    
    % If we are in deployed code, issue infrequent progress bar updates, as
    % each updated accumulates in the log.
    if isdeployed
        UpdateRate = 1/60;
        fprintf(['Updates every ' num2str(1/UpdateRate) ' seconds.\n']);
    else
        UpdateRate = 5;
    end
    % Define a directory where the progress bar update files are kept
    progLog = tempdir();
    % Instantiate the progress bar object with the 'Parallel' switch set to
    % true and save the aux files in a system temporary directory.
    pbarObj = ProgressBar(nVxs, ...
        'IsParallel', true, ...
        'WorkerDirectory', progLog, ...
        'Title', 'glm', ...
        'UpdateRate', UpdateRate ...
        );
    pbarObj.setup([], [], []);
    
    % Start a timer so that we can log total computation time
    tic
end


% Loop over voxels/vertices and obtain the regression parameters
parfor ii = 1:nVxs
    
    % Silence warnings. This must be done inside the par loop to apply to
    % each worker.
    warning('off','MATLAB:rankDeficientMatrix');

    % Update progress bar
    if verbose
        updateParallel([], progLog);
    end
    
    % Get this time series
    datats=catcell(2,cellfun(@(x) subscript(squish(x,1),{vxs(ii) ':'}),data,'UniformOutput',0))';
    
    % Apply the model cleaning step, which may include regression of
    % nuisance components
    datats = obj.clean(datats);
    
    % Perform the regression
    beta = X\datats;
    
    % Store these params in the loop variable
    loop_beta(ii,:) = beta;
    
end    

% Place the loop vaiable into the seed matrix
seedMatrix(vxs,:) = loop_beta;

% Report completion of loop
if verbose
    pbarObj.release();
    toc
    fprintf('\n');
end

% Restore the warning state. It shouldn't be changed at the main execution
% level since warnings were silenced within the worker pool, but restoring
% here to be safe.
warning(warningState);

% Put the seed matrix in a cell
seeds = {seedMatrix};

end


