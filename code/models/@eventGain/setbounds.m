function setbounds(obj)
% Sets the bounds on the model parameters
%
% Syntax:
%   obj.setbounds()
%
% Description:
%   Bounds for the prf_timeShift model. Rationale is as follows:
%       x, y :  Stimulus edges +-50%
%       sigma:  1/2 stimulus width
%       gain :  Positive values only
%       exp  :  Locked to 0.05, following Benson et al, 2018, HCP 7T data
%       shift:  HRF temporal shift +- 3 seconds.       
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

% The gain parameters are unbounded
lb(1:nParams-3) = -Inf;             % gain
ub(1:nParams-3) = Inf;              % gain

% The HRF shape parameters vary by model type
switch obj.hrfType
    case 'flobs'
        
        % Object properties associated with the FLOBS eigenvectors
        mu = obj.mu;
        C = obj.C;
        
        % Set bounds at +-10SDs of the norm distributions of the FLOBS
        % parameters
        sd15 = 15*diag(C)';
        
        lb(nParams-2:nParams) = mu-sd15;	% FLOBS eigen1, 2, 3
        ub(nParams-2:nParams) = mu+sd15;	% FLOBS eigen1, 2, 3

    case 'gamma'
        lb(nParams-2:nParams) = [2 6 0];	% Gamma1,2, and undershoot gain
        ub(nParams-2:nParams) = [8 12 2];	% Gamma1,2, and undershoot gain

    otherwise
        error('Not a valid hrfType')
end

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

