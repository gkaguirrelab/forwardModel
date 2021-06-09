function metric = metric(obj, signal, x)
% Evaluates the match between a signal and a model fit
%
% Syntax:
%   metric = obj.metric(signal, x)
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

% Filter the signal to remove the attention task (if one is present)
stimLabels = obj.stimLabels;
confoundStimLabel = obj.confoundStimLabel;
idx = strcmp(confoundStimLabel,stimLabels);
if any(idx)
    % Obtain the modeled attention effect
    xSub = x;
    xSub(~idx)=0;
    confoundModel = obj.forward(xSub);
    
    % Remove these effects from the signal
    [~,~,signal] = regress(signal,confoundModel);
    
    % Remove the attention task from the model going forward
    x(idx)=0;
end

% Obtain the model fit
modelFit = obj.forward(x);

% Average across acquisition repetitions


% Implement an R^2 metric
metric = calccorrelation(signal, modelFit)^2;

end

