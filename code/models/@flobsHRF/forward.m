function fit = forward(obj, x)
% Forward model
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
flobsStim = obj.flobsStim;
stimAcqGroups = obj.stimAcqGroups;
stimTime = obj.stimTime;
dataAcqGroups = obj.dataAcqGroups;
dataTime = obj.dataTime;

% The fit is the FLOBS basis set, scaled by the first three parameters, and
% summed
fit = flobsStim*x';

% If the stimTime variable is not empty, resample the fit to match
% the temporal support of the data.
if ~isempty(stimTime)
    fit = resamp2run(fit,stimAcqGroups,stimTime,dataAcqGroups,dataTime);
end

% Apply the cleaning step
fit = obj.clean(fit);

end

