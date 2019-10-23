function fit = forward(obj, x)
% Returns the model fit given the parameters
%
% Syntax:
%   fit = obj.forward(x)
%
% Description:
%   Returns a time-series vector that is a transformation of the stimulus.
%
% Inputs:
%   x                     - [1 nParams] vector.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   fit                   - [nTRs 1] vector.
%


% Obj variables
stimulus = obj.stimulus;

% The ft is a transformed version of the stimulus.
fit =  x(1) * stimulus.^x(2) + x(3);

% Apply the cleaning step
fit = obj.clean(fit);


end

