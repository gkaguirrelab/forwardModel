%% demo_mtSinai
%
% The model simultaneously fits the shape of the HRF (using the FLOBS
% components), and the neural amplitude parameters for a conventional
% linear model. The model minimizes the L2 norm of the model fit.
%
% The model accepts several key-values, which are used to create a nuanced
% metric value. While this is not used in fitting the model, this output
% may be useful in subsequent analyses. These key-values are:
%
%   stimLabels    - A cell array of char vectors, one for each row of the
%                   stimulus matrix.
%   confoundStimLabel - A char vector that matches a particular stimLabel.
%                   This stimulus condition will be considered a
%                   "confound", and its effects removed in calculating the
%                   metric.
%   avgAcqIdx - A cell array of vectors, all of the same length, with a
%                   total length equal to the length of the data. This
%                   vector controls how the data and model time-series from
%                   various acquisitions may be averaged together. Consider
%                   an experiment that has 6 acquisitions of length 100,
%                   consisting of 3 repetitions of the same stimulus
%                   sequence (with each sequence split over two
%                   acquisitions). To average these time-series together,
%                   one would pass {[1:200],[201:400],[401:600]};
%
% These key-values are used to compute an R-squared metric. First, the
% effect of the confoundStimLabel is partialed from the timeSeries data,
% and this effect is excluded from the model. Then, the timeSeries data and
% the model are averaged following the avgAcqIdx function. Finally, the
% square of the correlation between the resulting timeSeries and model is
% obtained and stored. While the metric is not used for model fitting, it
% is available as a way of evaluating the overall explanatory power of the
% model, without the influence of the confound stimulus label.
%
% In the context of the temporal sensitivity experiment, this model was
% used to remove the effect of an attention event when judging the
% explanatory power of the time-series model fit.
%
% This model was used to analyze the temporal sensitivity data collected at
% the Mt Sinai 7T scanner, and reported in Patterson et al,. 2022.
%


% Simulate an experiment with 7 conditions (6 plus an "baseline"). A given
% acquisition presents 4 trials of each of the 7 conditions in random
% order, with each trial being a 12 second step function.
events = repmat(1:7,1,4);
events = events(randperm(28));

% Now make a matrix of stimuli that are shifted versions of the step. Leave
% an 8th row for the attention event
stimMat = zeros(8,420);
for ii=1:28
    stimMat(events(ii),(ii-1)*15+1:ii*15) = 1;
end

% Put two copies of the stimulus matrix in a cell array, after adding an
% attention even at different points in the two acquisitions
attentionVector = zeros(1,420);
attentionVector(randsample(1:420,5))=1;
stimMat(8,:)=attentionVector;
stimulus = {stimMat};
attentionVector = zeros(1,420);
attentionVector(randsample(1:420,5))=1;
stimMat(8,:)=attentionVector;
stimulus = [stimulus, {stimMat} ];

% Define some amplitudes for the neural responses to the events. This
% includes a zero-response baseline, growing amplitudes of responses to the
% 6 stimulus conditions, and a big, additional response to the attention
% task.
eventAmplitudes = [0 0.25:.25:1.5 2];

% Create some nuisance variables that are random noise
nuisanceVars{1} = rand(1,420); nuisanceVars{2} = rand(1,420);
nuisanceVars{1} = nuisanceVars{1} - mean(nuisanceVars{1});
nuisanceVars{2} = nuisanceVars{2} - mean(nuisanceVars{2});

% Define the modelOpts for the model
stimLabels = {'baseline','stimA','stimB','stimC','stimD','stimE','stimF','attention'};
confoundStimLabel = 'attention';
avgAcqIdx = {[1:420],[421:840]};
modelOpts = {'stimLabels',stimLabels,...
    'confoundStimLabel',confoundStimLabel,...
    'avgAcqIdx',avgAcqIdx,...
    'nuisanceVars',nuisanceVars};

% Instantiate the model. Need to include some "dummy data".
tr = 0.8;
dummyData = {attentionVector,attentionVector};
model = mtSinai(dummyData,stimulus,tr,...
    modelOpts{:});

% Create simulated data with varying amplitudes of the events, and add some
% noise
x = model.initial;
x(1:8) = eventAmplitudes;
datats = model.forward(x);
datats = datats + randn(size(datats))*range(datats)/10;
data = [];
data{1}(1,:) = datats(1:420);
data{2}(1,:) = datats(421:840);

% Call the forwardModel
results = forwardModel(data,stimulus,tr,...
    'modelClass','mtSinai',...
    'modelOpts',modelOpts);

% Plot the simulated vs. recovered parameters relative to baseline
figure
plot(x(1:8)-x(1),results.params(1:8)-x(1),'xr');
xlim([-1 4]);
ylim([-1 4]);
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

