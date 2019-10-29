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

% Calculate the point-PDF for the parameters given the mu and covariance
% matrix for the FLOBS eigenvectors
results.log10pMVN = log10(mvnpdf(params,obj.mu,obj.C)/100);

% Add the params themselves
results.params =        params;

% Identify the color scale to be used for plotting the different components
% Identify the color scale to be used for plotting the different components
results.meta.mapField = {'eigen1','eigen2','eigen3','R2','log10pMVN'};
results.meta.mapScale = {'blueRed','blueRed','blueRed','grayRed','grayRed'};
results.meta.mapLabel = {'eigen1 [au]','eigen2 [au]','eigen3 [au]','R2','log10pMVN'};
mu = obj.mu;
sd5 = 5.*sum(obj.C);

results.meta.mapBounds = {[mu(1)-sd5(1) mu(1)+sd5(1)],[mu(2)-sd5(2) mu(2)+sd5(2)],[mu(3)-sd5(3) mu(3)+sd5(3)],[0 1],[-4 0]};


end