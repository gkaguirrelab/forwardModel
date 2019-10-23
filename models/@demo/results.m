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
results.gain =            params(:,1);
results.exponent =        params(:,2);
results.shift =           params(:,3);
results.R2 =              metric;

% Add the params themselves
results.params =        params;

% Identify the color scale to be used for plotting the different components
% Identify the color scale to be used for plotting the different components
lb = obj.lb; ub = obj.ub;
results.meta.mapField = {'gain','exponent','shift','R2'};
results.meta.mapScale = {'linearJet','logJet','grayRed'};
results.meta.mapLabel = {'gain [au]','exponent [au]','shift [au]','R2'};
results.meta.mapBounds = {[lb(1) ub(1)],[lb(2) ub(2)],[lb(3) ub(3)],[0 1]};


end