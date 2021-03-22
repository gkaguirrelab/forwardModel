function seeds = seeds(obj,data,vxs)
% Generate parameter seeds for the non-linear search
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

% Obj variables
stimulus = obj.stimulus;
nParams = obj.nParams;

% Generate default seeds
x0 = obj.initial;
seedMatrix = repmat(x0,totalVxs,1);

% Generate the regression matrix, which is the forward model output for
% each stimulus, assuming the typical gain.
X = zeros(size(obj.dataTime,1),size(stimulus,2));
for ss = 1:size(stimulus,2)
    xp = x0;
    xp(1:size(stimulus,2))=0;
    xp(ss) = x0(ss);
    X(:,ss) = forward(obj, xp);
end

% Silence warnings that may occur during the regression
warningState = warning;
warning('off','MATLAB:rankDeficientMatrix');


% Loop over voxels/vertices and find a first guess for the amplitude params
% using linear regression
for ii = 1:length(vxs)
    
    % Get this time series
    datats=catcell(2,cellfun(@(x) subscript(squish(x,1),{vxs(ii) ':'}),data,'UniformOutput',0))';
    
    % Apply the model cleaning step, which may include regression of
    % nuisance components
    datats = obj.clean(datats);
    
    % Perform the regression
    beta = X\datats;
    
    % Store these params in the seed
    seedMatrix(vxs(ii),1:nParams-3) = beta;
    
end    

% Restore the warning state
warning(warningState);

% Put the seed matrix in a cell
seeds = {seedMatrix};

end


