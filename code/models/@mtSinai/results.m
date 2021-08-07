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



% Map metric to a results structure
results.R2 = metric;

% Add the R2 map
results.meta.mapField{1} = 'R2';
results.meta.mapScale{1} = 'grayRed';
results.meta.mapLabel{1} = 'R^2';
results.meta.mapBounds{1} = [0 0.25];

% Add the params themselves
results.params = params;


end