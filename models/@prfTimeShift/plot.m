function results = plot(obj, data, results)
% Creates figures and saves the figure content in the results structure
%
% Syntax:
%   results = plot(data, results)
%
% Description:
%   Adds a field to results that contains figures, along with instructions
%   on how to display the figure.
%
% Inputs:
%   data                  - 
%   results               - Structure, with fields for each of the
%                           parameters, the metric, and some meta data.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   results               - Structure, with fields for each of the
%                           parameters, the metric, and some meta data.
%


% Plot the data with the best fit

% Define some variables
vxs = results.meta.vxs;          % vector of analyzed vertices / voxels
fitThresh = 0.20;                   % R^2 threshold to display

% Pick the voxel with the best model fit
[~,vx]=nanmax(results.R2(vxs));

% Grab a time series
datats = data(vx,:)';
datats = model.clean(datats);

% Obtain the model fit
modelts = model.forward(results.params(vxs(vx),:));

% Visualize the model fit
fig1 = figure('visible','off');
set(fig1,'PaperOrientation','landscape');
set(fig1,'PaperUnits','normalized');
set(fig1,'PaperPosition', [0 0 1 1]);

hold on;
set(gcf,'Units','points','Position',[100 100 1000 100]);
plot(datats,'r-');
plot(modelts,'b-');
xlabel('Time (TRs)');
ylabel('BOLD signal');
ax = axis;
axis([.5 size(datats,1)+.5 ax(3:4)]);
title(['Time-series data, CIFTI vertex ' num2str(vx)]);




end