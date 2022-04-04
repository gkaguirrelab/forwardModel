%% GLM model making use of stimTime key-value

% This model implements a standard linear regression based upon the design
% matrix provided in the stimulus variable, convolved with a fixed,
% specified hrf.
%
% This example includes the wrinkle that the temporal resolution of the
% stimulus is different from that of the data


% This is the duration of the data, which is 420 TRs of 0.8 seconds each
tr = 0.8;
nTRs = 420;
totalTime = nTRs * tr;

% define a stimulus that has different temporal support
dT = 0.25;
stimTime = ((1:totalTime / dT) - 1) * dT;

% create stim regression matrix
sIdx = 1;
nStim = totalTime / 24.0;
stimulus = zeros(nStim, length(stimTime));
for idx = 1:nStim
    idxStart = (idx - 1) * 24 / dT + 1;
    idxEnd = ((idx - 1) * 24 + 12) / dT;
    
    stimulus(sIdx, idxStart:idxEnd) = 1.0;
    sIdx = sIdx + 1;
end

% Place these into cell arrays with the correct row / column arrangement
stimTime = {stimTime'};
stimulus = {stimulus};

% Instantiate the model. To do so, we need to create a data vector that is
% the proper length.
dummyData = {zeros(1,nTRs)};
model = glm(dummyData, stimulus, tr, 'stimTime', stimTime);

% Create simulated data with varying amplitudes of the events, and add some
% noise
x = model.initial;
x(1:14) = rand(14,1)*200+100;
datats = model.forward(x);
datats = datats + randn(size(datats))*range(datats)/5;

% Package the simulated time-series vector as a data input to the model
data = [];
data{1}(1,:) = datats;

% Call the forwardModel for fitting
results = forwardModel(data, stimulus, tr, ...
    'modelClass', 'glm', 'stimTime', stimTime);

% Plot the simulated vs. recovered parameters
figure
plot(x(1:14),results.params(1:14),'xr');
xlim([0 500]);
ylim([0 500]);
xlabel('simulated')
ylabel('recovered')
axis square
refline(1,0);

% Show the results figures
figFields = fieldnames(results.figures);
if ~isempty(figFields)
    for ii = 1:length(figFields)
        figHandle = struct2handle(results.figures.(figFields{ii}).hgS_070000,0,'convert');
        set(figHandle,'visible','on')
    end
end
