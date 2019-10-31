function [c, ceq] = nonlcon(obj, x)
% Non-linear constraint for the forward model fit
%
% Syntax:
%   [c, ceq] = obj.nonlcon(x)
%
% Description:
%   Returns the inequality and equality constraints of the forward model at
%   x. The fmincon optimization will attempt to achieve:
%       c(x)  <= 0
%       ceq(x) = 0
%
% Inputs:
%   x                     - 1xnParams vector.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   c, ceq                - Scalars.
%

% Keep the HRF params within the multivariate normal distribution, but with
% very generous probability bounds (e.g., accept a voxel with a fit that
% has a 10^-7 value in the multivariate normal PDF. This is because we view
% the parameters on the MVN to be somewhat idiosyncratic to the temporal
% profile and scanning parameters used in the acquisition of the canonical
% FLOBS data.
nParams = obj.nParams;

pMVN = mvnpdf(x(nParams-2:nParams),obj.mu,obj.C)/100;
c = -log10(pMVN)-7;

% The HRF form must be positive
area = sum(obj.flobsbasis*x(nParams-2:nParams)');
ceq = double(~(area>0));


end

