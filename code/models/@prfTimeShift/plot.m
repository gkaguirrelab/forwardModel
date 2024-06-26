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
fitThresh = 0.2;


%% Figure 1 -- example time series

% Setup a figure
fig1 = figure('visible','off');
set(fig1,'PaperOrientation','landscape');
set(fig1,'PaperUnits','normalized');
set(gcf,'Units','points','Position',[500 500 750 500]);

% Pick the voxel with the best model fit
[~,vx]=max(results.R2(vxs),[],"omitnan");

% Grab the time series
datats = data(vx,:)';
datats = obj.clean(datats);

% Obtain the model fit and hrf
modelts = obj.forward(results.params(vxs(vx),:));
hrf = obj.hrf;

% Flatten the dataTime matrix
[flatDataTime, dataTimeBreaks] = accumTimeMatrix(obj.dataTime,obj.dataAcqGroups,obj.dataDeltaT);

% Plot the time series
subplot(2,5,1:4)
plot(flatDataTime,datats,'-','Color',[0.75 0.75 0.75],'LineWidth',2);
hold on;
plot(flatDataTime,modelts,'-r','LineWidth',1);
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Best fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% If there are multiple acquisitions, place vertical lines at the breaks
if length(dataTimeBreaks) > 2
    yl = ylim();
    for ii=2:length(dataTimeBreaks)-1
    plot([dataTimeBreaks(ii) dataTimeBreaks(ii)],yl,'-k');
    end
end

% Plot the HRF
subplot(2,5,5)
plot(0:obj.dataDeltaT:(length(hrf)-1)*obj.dataDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Now pick the voxel with the median model fit
medianR2 = median(results.R2(vxs),"omitnan");

% Find the vertex that has an R^2 closest to the median
[~,vx] = min( abs(results.R2(vxs) - medianR2));

% Grab a time series
datats = data(vx,:)';
datats = obj.clean(datats);

% Obtain the model fit and hrf
modelts = obj.forward(results.params(vxs(vx),:));
hrf = obj.hrf;

% Plot the time series
subplot(2,5,6:9)
plot(flatDataTime,datats,'-','Color',[0.75 0.75 0.75],'LineWidth',2);
hold on;
plot(flatDataTime,modelts,'-r','LineWidth',1);
xlabel('Time [seconds]');
ylabel('BOLD signal');
title(['Median quality fit time-series, CIFTI vertex ' num2str(vxs(vx))]);

% If there are multiple acquisitions, place vertical lines at the breaks
if length(dataTimeBreaks) > 2
    yl = ylim();
    for ii=2:length(dataTimeBreaks)-1
    plot([dataTimeBreaks(ii) dataTimeBreaks(ii)],yl,'-k');
    end
end

% Plot the hrf
subplot(2,5,10)
plot(0:obj.dataDeltaT:(length(hrf)-1)*obj.dataDeltaT,hrf)
xlabel('Time [seconds]');
title('HRF');

% Store the figure contents in a variable
results.figures.fig1 = returnFigVar(fig1);
results.figures.fig1.format = '-dpdf';



%% Figure 2 - visual field coverage

% Obj variables
res = obj.res;
pixelsPerDegree = obj.pixelsPerDegree;
lb = obj.lb;
ub = obj.ub;

% Stimulus center
rCenter = (1+res(1))/2;
cCenter = (1+res(2))/2;


fig2 = figure('visible','off');
set(fig2,'PaperOrientation','landscape');
set(fig2,'PaperUnits','normalized');
set(gcf,'Units','points','Position',[100 100 400 400]);

% Identify the vertices with fits above the threshold
goodIdx = results.R2 > fitThresh;

% Map R2 value to a gray-red plot symbol color
nColors = 201;
grayRed = [linspace(0.75,1,201)', linspace(0.75,0,201)', linspace(0.75,0,201)'];
colorTriple = grayRed(round((results.R2(goodIdx))*(nColors-1)+1),:);

h = scatter(results.cartX(goodIdx)',results.cartY(goodIdx)',50, ...
    colorTriple,'filled','o','MarkerFaceAlpha',1/8);

xlim(([lb(1) ub(1)]-rCenter)./pixelsPerDegree);
ylim(([lb(2) ub(2)]-cCenter)./pixelsPerDegree);
axis equal
xlabel('X-position (deg)');
ylabel('Y-position (deg)');
title('pRF centers and sizes in visual field degrees');

currentunits = get(gca,'Units');
set(gca, 'Units', 'Points');
axpos = get(gca,'Position');
set(gca, 'Units', currentunits);

% Calculate Marker width in points for a 2SD RF
markerWidth = (2.*results.sigma(goodIdx))./diff(xlim)*axpos(3); 
set(h, 'SizeData', markerWidth.^2)

% Get the axes on top of the markers
xl = get(gca,'XLim');
yl = get(gca,'YLim');
set(gca,'XLim',xl);
set(gca,'YLim',yl);
set(gca,'box','on')
set(gca,'Layer','top')

% Store the figure contents in a variable
results.figures.fig2 = returnFigVar(fig2);
results.figures.fig2.format = '-dpdf';



end