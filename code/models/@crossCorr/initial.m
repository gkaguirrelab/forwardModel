function x0 = initial(obj)
% Returns initial guess for the model parameters
%
% Syntax:
%   x0 = obj.initial()
%
% Description:
%
% Inputs:
%   none
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   x0                    - 1xnParams vector.
%


% Obj variables
nParams = obj.nParams;

% Assign the x0 variable
x0 = zeros(1,nParams);

end

