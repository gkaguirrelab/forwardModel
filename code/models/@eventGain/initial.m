function x0 = initial(obj)
% Returns initial guess for the model parameters
%
% Syntax:
%   x0 = obj.initial()
%
% Description:
%   Initial values for the prf_timeShift model. Rationale is as follows:
%       x, y :  Center of the stimulus
%       sigma:  1 or 10 pixels, depending upon obj.scale
%       gain :  Set by obj.typicalGain
%       exp  :  Locked to 0.05, following Benson et al, 2018, HCP 7T data
%       shift:  Zero HRF temporal shift      
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
typicalGain = obj.typicalGain;
nParams = obj.nParams;

% Assign the x0 variable
x0 = zeros(1,nParams);

% Assemble X0
x0(1:nParams-3) = typicalGain;              % gain
x0(nParams-2:nParams) = [0.86, 0.09, 0.01]; % FLOBS eigen1, 2, 3

end

