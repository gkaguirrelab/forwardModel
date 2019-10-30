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
modelts = obj.forward(results.params(vxs(vx),:));
b = modelts\datats;
modelts = modelts*b;
hrf = obj.flobsbasis*results.params(vxs(vx),:)';

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
modelts = obj.forward(results.params(vxs(vx),:));
b = modelts\datats;
modelts = modelts*b;
hrf = obj.flobsbasis*results.params(vxs(vx),:)';

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


% Only create these if VXS is a subset of the total data,
if length(vxs) < size(results.params,1)

    
    %% Figure 2 -- Weighted mean HRF
    fig2 = figure('visible','off');
    set(fig2,'PaperOrientation','landscape');
    set(fig2,'PaperUnits','normalized');
    set(gcf,'Units','points','Position',[500 500 750 500]);
    
    % Consider only those model fits that have a reasonable fit to the data
    goodIdx = logical((results.R2 > 0.2) .* (results.log10pMVN > -6.5));
    
    % Obtain the weighted median and SD parameters
    for ii = 1:obj.nParams
        [xMedian(ii),xSD(ii)] = ...
            wtmedian(results.params(goodIdx,ii),results.R2(goodIdx));
    end
    
    % Plot the HRF
    hrf = obj.flobsbasis*xMedian';

    plot(0:obj.stimDeltaT:(length(hrf)-1)*obj.stimDeltaT,hrf)
    xlabel('Time [seconds]');
    title('HRF from weighted median parameters across reasonable voxels');
    
    % Add the parameters in a text box
    dim = [0.5 0.5 0.3 0.3];
    str = sprintf([...
        '        [ eigen1, eigen2, eigen3 ]\n'...
        'median: [ %2.4f, %2.4f, %2.4f ]\n' ...
        'SD:     [ %2.4f, %2.4f, %2.4f ]\n', ...
        'n = %d voxels/vertices'], ...
        xMedian,xSD,sum(goodIdx));
    annotation('textbox',dim,'String',str,'FitBoxToText','on', ...
        'FontName','FixedWidth','HorizontalAlignment','left');
    
    % Store the figure contents in a variable
    results.figures.fig2 = returnFigVar(fig2);
    results.figures.fig2.format = '-dpdf';

    %% Figure 3 -- Distribution of eigenvalues
    fig3 = figure('visible','on');
    set(fig3,'PaperOrientation','landscape');
    set(fig3,'PaperUnits','normalized');
    set(gcf,'Units','points','Position',[500 500 750 500]);
    
    % Plot the cloud of values
    plot3(results.eigen1(goodIdx),results.eigen2(goodIdx),results.eigen3(goodIdx),'.k');
    hold on

    % Add the median
    plot3(xMedian(1),xMedian(2),xMedian(3),'or');
    
    xlabel('eigen 1'); ylabel('eigen 2');zlabel('eigen 3');

    % Store the figure contents in a variable
    results.figures.fig3 = returnFigVar(fig3);
    results.figures.fig3.format = '-dpdf';

end



end