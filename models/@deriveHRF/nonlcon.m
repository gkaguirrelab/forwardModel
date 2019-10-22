function [c, ceq] = nonlcon(obj, x)
% Non-linear constraint for the forward model fit
%
% Syntax:
%   [c, ceq] = obj.nonlcon(x)
%
% Description:
%   Returns the inequality and equality constraints of the forward model at
%   pp. The fmincon optimization will attempt to achieve:
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

% Non-linear constraint not used in this model
c = [];
ceq = [];



end

