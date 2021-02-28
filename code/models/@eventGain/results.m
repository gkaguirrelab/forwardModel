function results = results(obj, params, metric)
% Packages the model outputs into a results structure
%
% Syntax:
%   results = obj.results(params)
%
% Description:
%   The output of the model is a matrix of parameters fits at each voxel /
%   vertex. This routine performs post-processing of the parameter values
%   and arranges them in a human-readable structure for output.
%
% Inputs:
%   params                - A [v nParams] matrix of parameter values, where
%                           v is the number of voxels/vertices in data.
%   metric                - A [1 v] vector of the metric of the fit at each
%                           voxel or vertex.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   results               - Structure, with fields for each of the
%                           parameters, the metric, and some metat data.
%



% Map params and metric to a results structure
results.R2 = metric;

% Add the params themselves
results.params = params;

% Get the stimLabels
stimLabels = obj.stimLabels;

% Save each beta value to a separate field
nParams = obj.nParams;
for pp = 1:nParams-3
    results.meta.mapField{pp} = stimLabels{pp};
    results.meta.mapScale{pp} = 'blueRed';
    results.meta.mapLabel{pp} = stimLabels{pp};
    results.meta.mapBounds{pp} = [min(params(:)) max(params(:))];
    results.(stimLabels{pp}) = params(:,pp);
end

% Add the R2 map
results.meta.mapField{nParams-2} = 'R2';
results.meta.mapScale{nParams-2} = 'grayRed';
results.meta.mapLabel{nParams-2} = 'R^2';
results.meta.mapBounds{nParams-2} = [0 1];


end