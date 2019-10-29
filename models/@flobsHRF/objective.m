function fVal = objective(obj, signal, x)
% Evaluates the match between a signal and a model fit
%
% Syntax:
%   fVal = obj.objective(signal, x)
%
% Description:
%   Given a time series signal and the parameters of the forward model,
%   returns the objective function to be minimized. In some applications,
%   this could just be the negative of obj.metric.
%
% Inputs:
%   signal                - 1 x time vector. The data to be fit.
%   x                     - 1 x nParams vector of parameter values.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   fVal                  - Scalar.
%

% This df is a regularization to allow some value for improvement in the
% correlation.
df = 12;

% The r^2 of the signal with the fit
rsquared = calccorrelation(signal, obj.forward(x));

% The probability of these parameters from the multivariate normal
pPrior = mvnpdf(x(1:3),obj.mu,obj.C)/100;

pPrior = sqrt(pPrior);

% Implement an L2 norm
fVal = 1-(rsquared*pPrior);

end

