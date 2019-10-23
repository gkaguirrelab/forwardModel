function [fit, hrf] = forward(obj, x)
% Forward model for the derive hrf search
%
% Syntax:
%   fit = obj.forward(x)
%
% Description:
%   Returns a time-series vector that is a square-wave vector of neural
%   activity as defined by the stimulus, subject to convolution by an HRF
%   that is defined by the params.
%
%   The HRF is a 6-parameter, double gamma HRF, described as model "IV" in:
%
%       Shan, Zuyao Y., et al. "Modeling of the hemodynamic responses in
%       block design fMRI studies." Journal of Cerebral Blood Flow &
%       Metabolism 34.2 (2014): 316-324.
%
% Inputs:
%   x                     - [1 nParams] vector.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   fit                   - [nTRs 1] vector.
%   hrf                   - [duration 1] vector.
%


% Obj variables
stimulus = obj.stimulus;
acqGroups = obj.acqGroups;
tr = obj.tr;
duration = obj.duration;

% THe neural signal is the stimulus, scaled by the gain.
neuralSignal =  x(6) * stimulus;

% Define the timebase in TRs
timebase = 0:tr:ceil(duration/tr);

% Create the double gamma function
hrf = ((timebase.^(x(2)-1) .* (x(3).^x(2)) .* exp(-x(3).*timebase) ) ./ gamma(x(2)));
hrf = hrf + x(1) .* ((timebase.^(x(4)-1) .* (x(5).^x(4)) .* exp(-x(5).*timebase) ) ./ gamma(x(4)));

% Set to zero at onset
hrf = hrf - hrf(1);

% Normalize the kernel to have unit area. Transpose the vector so that it
% is time x 1
hrf = (hrf/sum(abs(hrf)))';

% Convolve the neural signal by the passed hrf, respecting the boundaries
% betwen the acquisitions
fit = conv2run(neuralSignal,hrf,acqGroups);

% Apply the cleaning step
fit = obj.clean(fit);


end

