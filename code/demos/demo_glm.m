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
stimulus = [];
for ii=1:14
    stimulus(ii,:) = fshift(step,30*(ii-1));
end

% Put the stimulus matrix within a cell
stimulus = {stimulus};

% Instantiate the model
tr = 0.8;
dummyData = {step};
model = glm(dummyData,stimulus,tr);

% Create simulated data with varying amplitudes of the events, and add some
% noise
x = model.initial;
x(1:14) = rand(14,1)*200+100;
datats = model.forward(x);
datats = datats + randn(size(datats))*range(datats)/5;
data = [];
data{1}(1,:) = datats;

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'modelClass','glm');

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

