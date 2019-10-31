% Information and demonstration for the eventGain model
%
%


% Create a stimulus with 0.8 second temporal resolution that is a 12
% second step function
step = zeros(1,420);
step(1:15)=1;

% Now make a matrix of stimuli that are shifted versions of the step
stimulus = [];
for ii=1:14
    stimulus(ii,:) = fshift(step,30*(ii-1));
end

% Put the matrix within a cell
stimulus = {stimulus};

% Instantiate the model
tr = 0.8;
dummyData = {step};
model = eventGain(dummyData,stimulus,tr);

% Create simulated data with varying amplitudes of the events, and add some
% noise
x = model.initial;
x(1:14) = rand(14,1)*200+100;
datats = model.forward(x);
datats = datats + randn(size(datats))*range(datats)/5;
data = [];
data{1}(1,:) = datats;

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'modelClass','eventGain');

% Plot the data and the fit
figHandle = struct2handle(results.figures.fig1.hgS_070000,0,'convert');
set(figHandle,'visible','on')

