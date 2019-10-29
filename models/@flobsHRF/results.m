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
results.eigen1 =        params(:,1);
results.eigen2 =        params(:,2);
results.eigen3 =        params(:,3);
results.R2 =            metric;

% Add the params themselves
results.params =        params;

% Identify the color scale to be used for plotting the different components
% Identify the color scale to be used for plotting the different components
results.meta.mapField = {'eigen1','eigen2','eigen3','R2'};
results.meta.mapScale = {'blueRed','blueRed','blueRed','grayRed'};
results.meta.mapLabel = {'eigen1 [au]','eigen2 [au]','eigen3 [au]','R2'};
mu = obj.mu;
sd2 = 4.*sum(obj.C);

results.meta.mapBounds = {[mu(1)-sd2(1) mu(1)+sd2(1)],[mu(2)-sd2(2) mu(2)+sd2(2)],[mu(3)-sd2(3) mu(3)+sd2(3)],[0 1]};


end