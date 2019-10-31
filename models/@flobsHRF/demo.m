%% flobsHRF
%
% This model simulataneously estimates the shape of the HRF using a basis
% set of HRF eigenvectors (the FLOBS basis set).
%
% A typical application would be to derive the HRF from a set of fMRI data
% that had two stimulus conditions (off an on), arranged in some temporal
% order (blocked or "event related").


% Create a stimulus with 0.8 second temporal resolution that is a 12 second
% boxcar
boxcar = repmat([zeros(1,15) ones(1,15)],1,8);

% Put the stimulus within a cell
tmp(1,1,:) = boxcar;
stimulus = {tmp};

% Instantiate the model
tr = 0.8;
dummyData = {boxcar};
model = flobsHRF(dummyData,stimulus,tr);

% Create simulated data with varying amplitudes of the events, and add some
% noise
datats = model.forward(model.initial);
datats = datats + randn(size(datats))*range(datats)/5;
data = [];
data{1}(1,:) = datats;

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'modelClass','flobsHRF');

% Show the results figures
figFields = fieldnames(results.figures);
if ~isempty(figFields)
    for ii = 1:length(figFields)
        figHandle = struct2handle(results.figures.(figFields{ii}).hgS_070000,0,'convert');
        set(figHandle,'visible','on')
    end
end

