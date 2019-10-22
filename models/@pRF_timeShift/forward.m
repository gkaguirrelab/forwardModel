function fit = forward(obj, x)
% Forward model for the pRF search
%
% Syntax:
%   fit = obj.forward(x)
%
% Description:
%   Returns a time-series vector that is the predicted response to a 2D
%   stimulus, based upon the parameters provided in x.
%
% Inputs:
%   x                     - 1xnParams vector.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   fit                   - 1xtime vector.
%


% Obj variables
stimulus = obj.stimulus;
acqGroups = obj.acqGroups;
res = obj.res;
hrf = obj.hrf;
tr = obj.tr;
xx = obj.xx;
yy = obj.yy;
xLast = obj.xLast;
FiniteDifferenceStepSize = obj.FiniteDifferenceStepSize;

% Get the max stimulus dimension
resmx=max(res);

% If the change in the params that define the Gaussian are sufficiently
% similar to the last time the function was executed, load the cached
% version of gaussStim instead of re-calculating it.
if all(abs(xLast(1:3)-x(1:3)) < FiniteDifferenceStepSize(1:3))
    
    % Use the last one
    gaussStim = obj.gaussStimLast;
    
else
    
    % Gaussian at [x, y] x(1), x(2), of sigma size x(3)
    gaussWindow = makegaussian2d(resmx,x(1),x(2),x(3),x(3),xx,yy,0,0);
    
    % Normalization scalar
    gaussNorm = (2*pi*abs(x(3))^2);
    
    % Gaussian window normalized, cropped to <res>, and vectorized
    gaussVector =  vflatten(placematrix(zeros(res), gaussWindow / gaussNorm));
    
    % Dot product of the stimulus by the Gaussian window (the neural signal)
    gaussStim = stimulus*gaussVector;
    
    % Store the gaussStim
    obj.gaussStimLast = gaussStim;
    
end

% Update xLast
obj.xLast = x;

% The gaussStim subjected to a compressive non-linearity by raising to the
% x(5) exponent and then scaled by the gain parameter.
neuralSignal =  x(4) * (gaussStim).^ x(5);

% Shift the hrf by the number of seconds specified in x(6)
hrf = fshift(hrf,x(6)/tr);

% Convolve the neural signal by the passed hrf, respecting the boundaries
% betwen the acquisitions
fit = conv2run(neuralSignal,hrf,acqGroups);

% Partial the data to remove the effects that are represented in the
% regression matrix T
fit = obj.T*fit;

end

