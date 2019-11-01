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

%% Figure 1 -- Representative time-series
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
plot(0:obj.stimDeltaT:(length(hrf)-1)*obj.stimDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Now pick the voxel with the median model fit
vx=find( results.R2(vxs)==nanmedian(results.R2(vxs)) );

% Grab a time series
datats = data(vx,:)';
datats = obj.clean(datats);

% Obtain the model fit and hrf
[modelts, hrf] = obj.forward(results.params(vxs(vx),:));

% Plot the time series
subplot(2,5,6:9)
plot(obj.dataTime,datats,'r-');
hold on;
plot(obj.dataTime,modelts,'b-');
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Median quality fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% Plot the hrf
subplot(2,5,10)
plot(0:obj.stimDeltaT:(length(hrf)-1)*obj.stimDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Store the figure contents in a variable
results.figures.fig1 = returnFigVar(fig1);
results.figures.fig1.format = '-dpdf';


%% Figure 2 -- Weighted mean HRF
% Only create this if VXS is a subset of the total data,
if length(vxs) < size(results.params,1)
    fig2 = figure('visible','off');
    set(fig2,'PaperOrientation','landscape');
    set(fig2,'PaperUnits','normalized');
    set(gcf,'Units','points','Position',[500 500 750 500]);
    
    % Obtain the weighted mean parameters
    xMean = sum(results.params(vxs,:).*results.R2(vxs),1)./sum(results.R2(vxs));
    [~, hrf] = model.forward(xMean);
    
    % Plot the HRF
    plot(0:obj.stimDeltaT:(length(hrf)-1)*obj.stimDeltaT,hrf)
    xlabel('Time [seconds]');
    title('HRF from weighted mean parameters across voxels');
    
    % Add the parameters in a text box
    dim = [0.5 0.5 0.3 0.3];
    str = sprintf('gamma1, gamma2, undershootGain = \n  [ %2.2f, %2.2f, %2.2f ]',xMean(1:3));
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    % Store the figure contents in a variable
    results.figures.fig2 = returnFigVar(fig2);
    results.figures.fig2.format = '-dpdf';

end



end