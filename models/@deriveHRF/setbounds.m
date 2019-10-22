function setbounds(obj)
% Returns bounds on the model parameters
%
% Syntax:
%   obj.setbounds()
%
% Description:
%   Bounds for the deiveHRF model. 1 x nParams vectors.
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
lb(1) = -1;             % Aratio
lb(2) = 2;              % alpha1
lb(3) = 0.5;            % beta1
lb(4) = 6;              % alpha2
lb(5) = 0;              % beta2                    
lb(6) = 0;              % gain (amplitude) of response

% The upper bounds
ub(1) = 1;              % Aratio
ub(2) = 10;             % alpha1
ub(3) = 2;              % beta1
ub(4) = 25;             % alpha2
ub(5) = 1.5;            % beta2
ub(6) = Inf;            % gain (amplitude) of response

% Store the bounds
obj.lb = lb;
obj.ub = ub;

% Store the FiniteDifferenceStepSize for the model. See here for more
% details:
%   https://www.mathworks.com/help/optim/ug/optimization-options-reference.html
FiniteDifferenceStepSize = sqrt(eps);
obj.FiniteDifferenceStepSize = FiniteDifferenceStepSize;


end

