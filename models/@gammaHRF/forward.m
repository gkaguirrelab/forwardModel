function [fit, hrf] = forward(obj, x)
% Forward model for the pRF search
%
% Syntax:
%   fit = obj.forward(x)
%
% Description:
%   Returns a time-series vector that is the predicted response based upon
%   the stimulus and the parameters provided in x.
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
stimAcqGroups = obj.stimAcqGroups;
stimTime = obj.stimTime;
stimDeltaT = obj.stimDeltaT;
dataAcqGroups = obj.dataAcqGroups;
dataTime = obj.dataTime;
dataDeltaT = obj.dataDeltaT;


% The neural signal is the stimulus scaled by the gain parameter.
neuralSignal =  x(4) * stimulus;

% If the stimTime variable is not empty, resample the neuralSignal to match
% the temporal support of the data.
if ~isempty(stimTime)
    neuralSignal = resamp2run(neuralSignal,stimAcqGroups,stimTime,dataAcqGroups,dataTime);
end

% Construct an HRF
gamma1 = x(1);
gamma2 = x(2);
undershootGain = x(3);
duration = x(5);

% Define a timebase at the data resolution
timebase = 0:dataDeltaT:duration;

% Create the double gamma function
g1 = gampdf(timebase,gamma1, 1);
g1 = g1./ max(g1);
g2 = gampdf(timebase, gamma2, 1);
g2 = (g2/ max(g2)) * undershootGain;
hrf = g1 - g2;

% Set to zero at onset
hrf = hrf - hrf(1);

% Normalize the kernel to have unit area, accounting for the final temporal
% resolution of the vector. Note that this is a rough approximation, as
% the HRF is coarsely sampled here. This will lead to some inaccuracy in
% the gain parameter. We accept this in exchange for greater speed.
hrf = hrf/(sum(abs(hrf)) * dataDeltaT);

% Make the hrf a column vector
hrf = hrf';

% Convolve the neural signal by the passed hrf, respecting the boundaries
% betwen the acquisitions
fit = conv2run(neuralSignal,hrf,dataAcqGroups);

% Apply the cleaning step
fit = obj.clean(fit);

end

