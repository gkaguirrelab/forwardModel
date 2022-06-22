function fit = forward(obj, x)
% Forward model
%
% Syntax:
%   [fit, hrf] = obj.forward(x)
%
% Description:
%   Returns a time-series vector that is the predicted response to the
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
%   hrf                   - 1xn vector.
%


% Obj variables
stimulus = obj.stimulus;
stimAcqGroups = obj.stimAcqGroups;
stimTime = obj.stimTime;
stimDeltaT = obj.stimDeltaT;

% Scale the stimulus matrix by the gain parameters
fit = stimulus*x';


% Shift the fit by the number of seconds specified in x(end). The shift is
% performed after convolution as the data will be smoother in time (and
% thus subjected to less ringing artifact).
fit = shift2run(fit,x(end)/stimDeltaT,stimAcqGroups);


% If the stimTime variable is not empty, resample the fit to match the
% temporal support of the data.
if ~isempty(stimTime)
    dataAcqGroups = obj.dataAcqGroups;
    dataTime = obj.dataTime;
    fit = resamp2run(fit,stimAcqGroups,stimTime,dataAcqGroups,dataTime);
end

% Apply the cleaning step
fit = obj.clean(fit);

end


