%% demo_prfTimeShift
%
% A pRF mapping approach that assumes a circular symmetric Gaussian
% receptive field and a fixed, compressive non-linearity. The model adjusts
% the time-to-peak of the HRF and thus requires that the stimulus play in
% forward and time-reversed directions. A two-stage non-linear search is
% performed, first across pRF center and gain, and then across the entire
% parameter set

% Load the pRF stimulus and stimTime files
stimFileName = fullfile(fileparts(mfilename('fullpath')),'pRFStimulus_108x108x450.mat');
load(stimFileName,'stimulus','stimTime');

% Place the stimulus and stimTime variables in cells
stimulus = {stimulus};
stimTime = {stimTime};

% Define the TR and create some dummy data
tr = 0.8; % temporal resolution of the data in seconds
nTRs = 420;
dummyData = {zeros(1,nTRs)};

% Define the modelOpts for the model
modelOpts = {'pixelsPerDegree',5.1751,'polyDeg',5,'screenMagnification',1.0'};

% Instantiate the model
model = prfTimeShift(dummyData,stimulus,tr,'stimTime',stimTime,modelOpts{:});

% Define the model parameters for the simulation
x = model.initial;
x(1:3) = [ 20 60 5 ]; % x, y, and sigma (in units of pixels)

% Create simulated data for a voxel
datats = model.forward(x);

% Add some noise, and place this simulated time series back into data 
datats = datats + randn(size(datats))*range(datats)/5;
data = [];
data{1}(1,:) = datats;

% Call the forwardModel
results = forwardModel(data,stimulus,tr,'stimTime',stimTime,'modelClass','prfTimeShift','modelOpts',modelOpts);

% Show the results figures
figFields = fieldnames(results.figures);
if ~isempty(figFields)
    for ii = 1:length(figFields)
        figHandle = struct2handle(results.figures.(figFields{ii}).hgS_070000,0,'convert');
        set(figHandle,'visible','on')
    end
end

