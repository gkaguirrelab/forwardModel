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

%% Figure 1

% Define some variables
vxs = results.meta.vxs;          % vector of analyzed vertices / voxels

% Setup a figure
fig1 = figure('visible','off');
set(fig1,'PaperOrientation','landscape');
set(fig1,'PaperUnits','normalized');
set(gcf,'Units','points','Position',[500 500 750 500]);

% Pick the voxel with the best model fit
[~,vx]=nanmax(results.R2(vxs));

% Grab the time series
datats = data(vx,:)';
datats = obj.clean(datats);

% Obtain the model fit and hrf
[modelts, hrf] = obj.forward(results.params(vxs(vx),:));

% Plot the time series
subplot(2,5,1:4)
plot(obj.dataTime,datats,'r-');
hold on;
plot(obj.dataTime,modelts,'b-');
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Best fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% Plot the HRF
subplot(2,5,5)
plot(0:obj.dataDeltaT:(length(hrf)-1)*obj.dataDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Store the figure contents in a variable
results.figures.fig1 = returnFigVar(fig1);
results.figures.fig1.format = '-dpdf';

end