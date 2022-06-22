function setbounds(obj)
% Sets the bounds on the model parameters
%
% Syntax:
%   obj.setbounds()
%
% Description:
%
%   These are specified as 1 x nParams vectors.
%
% Inputs:
%   none
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   none
%

% Obj variables
nParams = obj.nParams;

% Define outputs
lb = zeros(1,nParams);
ub = inf(1,nParams);

% Allow a time shift of ±4 seconds
lb(end) = -4;
ub(end) = 4;

% Store the bounds in the object
obj.lb = lb;
obj.ub = ub;


end

