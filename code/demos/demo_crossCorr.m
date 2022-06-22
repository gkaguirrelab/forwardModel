%% crossCorr
%
% This model is used to calculate the correlation of BOLD fMRI signals
% from one region with another. Consequently, there is no application of
% HRF convolution to the "stimulus", although the model includes a time-
% shift parameter to adjust lag between regions.


% Simulate three acquisitions, each with 150 TRs of 0.8 seconds each.
nTRs = 150;
stimulus = [];
for ii=1:3
    thisAcqStim = zeros(3,nTRs);
    thisAcqStim(ii,:) = rand(1,nTRs);
    stimulus{ii} = thisAcqStim;
end

% Instantiate the model
tr = 0.8;
dummyData = {zeros(1,nTRs),zeros(1,nTRs),zeros(1,nTRs)};
model = crossCorr(dummyData,stimulus,tr);

% Create simulated data with varying amplitudes of the events, and add some
% noise
x = model.initial;
x(1:3) = rand(3,1).*10;
x(4) = -2;
datats = model.forward(x);
datats = datats + randn(size(datats))*range(datats)/5;

% Package the simulated time-series vector as a data input to the model in
% cell arrays
data = mat2cell(datats,diff([0:nTRs:numel(datats)-1,numel(datats)]))';
data = cellfun(@(x) x',data,'UniformOutput',false);

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'modelClass','crossCorr');

% Show the results figures
figFields = fieldnames(results.figures);
if ~isempty(figFields)
    for ii = 1:length(figFields)
        figHandle = struct2handle(results.figures.(figFields{ii}).hgS_070000,0,'convert');
        set(figHandle,'visible','on')
    end
end

