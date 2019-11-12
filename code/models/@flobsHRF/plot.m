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

% Flatten the dataTime matrix
[flatDataTime, dataTimeBreaks] = accumTimeMatrix(obj.dataTime, obj.dataDeltaT);

% Obtain the model fit and hrf
modelts = obj.forward(results.params(vxs(vx),:));
b = modelts\datats;
modelts = modelts*b;
hrf = obj.flobsbasis*results.params(vxs(vx),:)';

% Plot the time series
subplot(2,5,1:4)
plot(flatDataTime,datats,'r-');
hold on;
plot(flatDataTime,modelts,'b-');
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Best fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% If there are multiple acquisitions, place vertical lines at the breaks
if length(dataTimeBreaks) > 1
    yl = ylim();
    for ii=1:length(dataTimeBreaks)-1
    plot([dataTimeBreaks(ii) dataTimeBreaks(ii)],yl,'-k');
    end
end

% Plot the HRF
subplot(2,5,5)
plot(0:obj.stimDeltaT:(length(hrf)-1)*obj.stimDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Now pick the voxel with the median model fit
medianR2 = nanmedian(results.R2(vxs));

% Find the vertex that has an R^2 closest to the median
[~,vx] = min( abs(results.R2(vxs) - medianR2));

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
plot(flatDataTime,datats,'r-');
hold on;
plot(flatDataTime,modelts,'b-');
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Median quality fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% If there are multiple acquisitions, place vertical lines at the breaks
if length(dataTimeBreaks) > 1
    yl = ylim();
    for ii=1:length(dataTimeBreaks)-1
    plot([dataTimeBreaks(ii) dataTimeBreaks(ii)],yl,'-k');
    end
end

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

    plot(0:obj.stimDeltaT:(length(results.summary.hrf)-1)*obj.stimDeltaT,results.summary.hrf)
    xlabel('Time [seconds]');
    title('HRF from weighted median parameters across reasonable voxels');
    
    % Add the parameters in a text box
    dim = [0.5 0.5 0.3 0.3];
    str = sprintf([...
        '        [ eigen1, eigen2, eigen3 ]\n'...
        'median: [ %2.4f, %2.4f, %2.4f ]\n' ...
        'SD:     [ %2.4f, %2.4f, %2.4f ]\n', ...
        'n = %d voxels/vertices'], ...
        results.summary.medianParams,results.summary.sdMedianParams,sum(results.summary.reasonableIdx));
    annotation('textbox',dim,'String',str,'FitBoxToText','on', ...
        'FontName','FixedWidth','HorizontalAlignment','left');
    
    % Store the figure contents in a variable
    results.figures.fig2 = returnFigVar(fig2);
    results.figures.fig2.format = '-dpdf';

    %% Figure 3 -- Distribution of eigenvalues
    fig3 = figure('visible','off');
    set(fig3,'PaperOrientation','landscape');
    set(fig3,'PaperUnits','normalized');
    set(gcf,'Units','points','Position',[500 500 750 500]);
    
    % Plot the cloud of values
    plot3(results.eigen1(results.summary.reasonableIdx),...
        results.eigen2(results.summary.reasonableIdx),...
        results.eigen3(results.summary.reasonableIdx),'.k');
    hold on

    % Add the median
    h = plot3(results.summary.medianParams(1),results.summary.medianParams(2),results.summary.medianParams(3),'or','MarkerSize',10);
    set(h, 'MarkerFaceColor','r'); 
    grid
    xlabel('eigen 1'); ylabel('eigen 2');zlabel('eigen 3');

    % Store the figure contents in a variable
    results.figures.fig3 = returnFigVar(fig3);
    results.figures.fig3.format = '-dpdf';

end



end