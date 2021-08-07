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
% A plot of the raw-time series fit

% Define some variables
vxs = results.meta.vxs;          % vector of analyzed vertices / voxels

% Setup a figure
fig1 = figure('visible','off');
set(fig1,'PaperOrientation','landscape');
set(fig1,'PaperUnits','normalized');
set(gcf,'Units','points','Position',[500 500 1500 300]);

% Pick the voxel with the best model fit
[~,vx]=nanmax(results.R2(vxs));

% Grab the time series
datats = data(vx,:)';
datats = obj.clean(datats);

% Flatten the dataTime matrix
[flatDataTime, dataTimeBreaks] = accumTimeMatrix(obj.dataTime,obj.dataAcqGroups,obj.dataDeltaT);

% Obtain the model fit and hrf
[modelts, hrf] = obj.forward(results.params(vxs(vx),:));

% Plot the time series
subplot(1,10,1:9)
plot(flatDataTime,datats,'-','Color',[0.75 0.75 0.75],'LineWidth',2);
hold on;
plot(flatDataTime,modelts,'-r','LineWidth',1);
xlabel('Time [seconds]');
ylabel('BOLD signal');
if results.meta.averageVoxels
    title(['Fit to average time series, n=' num2str(length(vxs)) ' vertices']);
else
    title(['Best fit time-series, CIFTI vertex ' num2str(vxs(vx))]);
end

% Add an annotation to report the R^2 fit
outString = sprintf('R^{2} = %2.2f',results.R2(vxs(vx)));
dim = [.15 .5 .3 .4];
annotation('textbox',dim,'String',outString,'FitBoxToText','on');

% If there are multiple acquisitions, place vertical lines at the breaks
if length(dataTimeBreaks) > 2
    yl = ylim();
    for ii=2:length(dataTimeBreaks)-1
    plot([dataTimeBreaks(ii) dataTimeBreaks(ii)],yl,'-k');
    end
end

% Plot the first 30 seconds of the HRF shape
subplot(1,10,10)
hrfTimeBase = 0:obj.stimDeltaT:30;
maxLength = min([length(hrfTimeBase) length(hrf)]);
plot(hrfTimeBase(1:maxLength),hrf(1:maxLength))
xlabel('Time [seconds]');
title('HRF');

% Store the figure contents in a variable
results.figures.fig1 = returnFigVar(fig1);
results.figures.fig1.format = '-dpdf';

% If averageVoxels is true, save the data, model fit, and hrf
if results.meta.averageVoxels
    results.data.datats = datats;
    results.data.modelts = modelts;
    results.data.hrf = hrf;
end


%% Figure 2
% A plot of the average time-series (if called for)
if ~isempty(obj.avgAcqIdx)
    
    % Obtain the average signal and model fit
    [metric, signal, modelFit] = obj.metric(datats, results.params(vxs(vx),:));
    
    % Setup a figure
    fig2 = figure('visible','off');
    set(fig2,'PaperOrientation','landscape');
    set(fig2,'PaperUnits','normalized');
    set(gcf,'Units','points','Position',[500 500 1500 300]);
    
    
    % Plot the time series
    plot(flatDataTime(1:length(signal)),signal,'-','Color',[0.75 0.75 0.75],'LineWidth',2);
    hold on;
    plot(flatDataTime(1:length(signal)),modelFit,'-r','LineWidth',1);
    xlabel('Time [seconds]');
    ylabel('BOLD signal');
    if results.meta.averageVoxels
        title(['Fit to average time series, n=' num2str(length(vxs)) ' vertices']);
    else
        title(['Best fit time-series, CIFTI vertex ' num2str(vxs(vx))]);
    end

    % Add an annotation to report the R^2 fit
    outString = sprintf('R^{2} = %2.2f',metric);
    dim = [.15 .5 .3 .4];
    annotation('textbox',dim,'String',outString,'FitBoxToText','on');
    
    % Store the figure contents in a variable
    results.figures.fig2 = returnFigVar(fig2);
    results.figures.fig2.format = '-dpdf';
    
    % If averageVoxels is true, save the signal and modelFit
    if results.meta.averageVoxels
        results.data.avgSignal = signal;
        results.data.avgModelFit = modelFit;
    end
    

end

end
