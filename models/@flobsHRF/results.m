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

% Calculate the weighted median set of HRF params and store this

% Consider only those model fits that have a reasonable fit to the data
reasonableIdx = logical((results.R2 > 0.2) .* (results.log10pMVN > -6.5));

% Obtain the weighted median and SD parameters (presuming we actually found
% some reasonable voxels)
if sum(reasonableIdx)==0
    medianParams = nan(1,obj.nParams);
    sdMedianParams = nan(1,obj.nParams);
elseif sum(reasonableIdx)==1
    medianParams = results.params(reasonableIdx,:);
    sdMedianParams = zeros(1,obj.nParams);
else
    for ii = 1:obj.nParams
        [medianParams(ii),sdMedianParams(ii)] = ...
            wtmedian(results.params(reasonableIdx,ii),results.R2(reasonableIdx));
    end
end

% Caculate the HRF
hrf = obj.flobsbasis*medianParams';

% Store these things
results.summary.medianParams = medianParams;
results.summary.sdMedianParams = sdMedianParams;
results.summary.hrf = hrf;
results.summary.reasonableIdx = reasonableIdx;
    
% Identify the color scale to be used for plotting the different components
results.meta.mapField = {'eigen1','eigen2','eigen3','R2','log10pMVN'};
results.meta.mapScale = {'blueRed','blueRed','blueRed','grayRed','grayRed'};
results.meta.mapLabel = {'eigen1 [au]','eigen2 [au]','eigen3 [au]','R2','log10pMVN'};

% Define the bounds for the plots
mu = obj.mu;
sd15 = 15*diag(obj.C)';
results.meta.mapBounds = {[mu(1)-sd15(1) mu(1)+sd15(1)],[mu(2)-sd15(2) mu(2)+sd15(2)],[mu(3)-sd15(3) mu(3)+sd15(3)],[0 1],[-7 0]};


end