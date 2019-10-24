function setbounds(obj)
% Returns bounds on the model parameters
%
% Syntax:
%   obj.setbounds()
%
% Description:
%   Bounds for the model. 1 x nParams vectors.
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
lb = nan(1,nParams);
ub = nan(1,nParams);

% The lower bounds
lb(1) = -Inf;            % gain
lb(2) = 1;              % exponent
lb(3) = 0;              % additive shift

% The upper bounds
ub(1) = Inf;             % gain
ub(2) = 3;              % exponent
ub(3) = 1000;           % additive shift

% Store the bounds
obj.lb = lb;
obj.ub = ub;

% Store the FiniteDifferenceStepSize for the model. The default behavior is
% to set the variable equal to the square root of floating point accuracy
% of the system, sqrt(eps). A vector can be supplied instead that specifies
% the "step size" for each parameter during the search. See here for more
% details:
%   https://www.mathworks.com/help/optim/ug/optimization-options-reference.html
FiniteDifferenceStepSize = nan(1,nParams);
FiniteDifferenceStepSize(1,:) = sqrt(eps);
obj.FiniteDifferenceStepSize = FiniteDifferenceStepSize;


end

