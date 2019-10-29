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
%   pp                    - 1xnParams vector.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   c, ceq                - Scalars.
%

% Keep the params within the 99% area of the multivariate normal
% distribution
pMVN = mvnpdf(x(1:3),obj.mu,obj.C)/100;

c = 0.01 - pMVN;
ceq = [];



end

