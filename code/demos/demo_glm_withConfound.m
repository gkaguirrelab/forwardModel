%% glm
%
% This model implements a standard linear regression based upon the design
% matrix provided in the stimulus variable, convolved with a fixed,
% specified hrf.
%
% A typical application would be an fMRI experiment with multiple stimulus
% events or blocks, for which a non-linear parameter search would be
% prohibitively slow.


% Create a stimulus with 0.8 second temporal resolution that is a 12 second
% step function
step = zeros(1,420);
step(1:15)=1;

% Now make a matrix of stimuli that are shifted versions of the step
stimMatrix = [];
for ii=1:14
    stimMatrix(ii,:) = fshift(step,30*(ii-1));
end

% Add a 15th event which is an intermittent delta function
stimMatrix(end+1,:) = int8(rand(1,420)>0.95);

% Instantiate the model
tr = 0.8;
dummyData = {step};
model = glm(dummyData,{stimMatrix},tr);

% Create simulated data with varying amplitudes of the events
x = model.initial;
x(1:15) = rand(15,1)*200+100;

% Create a few replications with a random attention event confound, and add some noise
data = [];
stimulus = [];
for aa = 1:4
    datats = model.forward(x);
    idxA = aa-1;
    idxB = 4-aa;
    stimulus{aa} = [ zeros(idxA*15,420*(idxA~=0)); stimMatrix; zeros(idxB*15,420*(idxB~=0))  ];
    data{aa}(1,:) = datats + randn(size(datats))*(max(datats)-min(datats))/2;
end

% Create the stimLabels
stimLabels = [];
confoundStimLabel = 'attention';
for ii=1:14
    stimLabels{ii} = sprintf('event_%d',ii);
end
stimLabels{end+1} = confoundStimLabel;
stimLabels = [stimLabels stimLabels stimLabels stimLabels];

% Define the avgAcqIdx
avgAcqIdx = {[1:420], [421:840], [841:1260], [1261:1680]};

% Assemble the modelOpts
modelOpts = {'stimLabels',stimLabels,'confoundStimLabel',confoundStimLabel,'avgAcqIdx',avgAcqIdx};

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'modelClass','glm', ...
    'modelOpts',modelOpts);

% Plot the simulated vs. recovered parameters
figure
plot([x x x x],results.params,'xr');
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

