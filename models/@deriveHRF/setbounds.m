function setbounds(obj)
% Sets the bounds on the model parameters
%
% Syntax:
%   obj.setbounds()
%
% Description:
%   Bounds for the deriveHRF model. 
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
lb = nan(1,nParams);
ub = nan(1,nParams);

% The lower bounds
lb(1) = 3;              % gamma1 (seconds)
lb(2) = 8;              % gamma2 (seconds)
lb(3) = 2;              % gammaScale
lb(4) = 0;              % gain (amplitude) of response
lb(5) = 16;             % duration (seconds)

% The upper bounds
ub(1) = 8;              % gamma1 (seconds)
ub(2) = 15;             % gamma2 (seconds)
ub(3) = 50;             % gammaScale
ub(4) = Inf;            % gain (amplitude) of response
ub(5) = 40;             % duration (seconds)

% Store the bounds in the object
obj.lb = lb;
obj.ub = ub;

% Store the FiniteDifferenceStepSize for the model. See here for more
% details:
%   https://www.mathworks.com/help/optim/ug/optimization-options-reference.html
FiniteDifferenceStepSize = nan(1,nParams);
FiniteDifferenceStepSize(1,:) = sqrt(eps);
obj.FiniteDifferenceStepSize = FiniteDifferenceStepSize;

end

