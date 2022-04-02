function [metric, signal, modelFit] = metric(obj, signal, x)
% Evaluates the match between a signal and a model fit
%
% Syntax:
%   [metric, signal, modelFit] = metric(obj, signal, x)
%
% Description:
%   Given a time series signal and the parameters of the forward model,
%   returns a metric that describes how well the two match.
%
% Inputs:
%   signal                - 1 x time vector. The data to be fit.
%   x                     - 1 x nParams vector of parameter values.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   metric                - Scalar.
%

% Filter the signal to remove the confound event (if one is present)
stimLabels = obj.stimLabels;
confoundStimLabel = obj.confoundStimLabel;
if ~isempty(confoundStimLabel)
    idx = startsWith(stimLabels,confoundStimLabel);
    if any(idx)
        % Obtain the modeled confound effect
        xSub = x;
        xSub(~idx)=0;
        signal = signal - obj.forward(xSub);

        % Remove the confound event from the model going forward
        x(idx)=0;
    end
end

% Obtain the model fit
modelFit = obj.forward(x);

% Average across acquisition repetitions
avgAcqIdx = obj.avgAcqIdx;
if ~isempty(avgAcqIdx)
    avgSignal = zeros(length(avgAcqIdx{1}),1);
    avgModelFit = zeros(length(avgAcqIdx{1}),1);
    for ii = 1:length(avgAcqIdx)
        avgSignal = avgSignal + signal(avgAcqIdx{ii});
        avgModelFit = avgModelFit + modelFit(avgAcqIdx{ii});
    end
    signal = avgSignal ./ length(avgAcqIdx);
    modelFit = avgModelFit ./ length(avgAcqIdx);
end

% Implement an R^2 metric
metric = calccorrelation(signal, modelFit)^2;

end

