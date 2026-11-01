%% U.S. Border Crossing Analysis and Visualization
% ENGR 1102 mini-project | Portfolio edition
% Metric: Personal Vehicles only, to avoid mixing incompatible units.
clear; clc; close all;

%% File paths and data import
projectDir = fileparts(mfilename('fullpath'));
inputFile = fullfile(projectDir, 'Border_Crossing_Entry_Data.xlsx');
outputDir = fullfile(projectDir, 'results');
if ~isfile(inputFile)
    error('Missing dataset: %s', inputFile);
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

fprintf('Reading border crossing data...\n');
T = readtable(inputFile, 'VariableNamingRule', 'preserve');
required = {'Port Name','Border','Date','Measure','Value','Latitude','Longitude'};
assert(all(ismember(required, T.Properties.VariableNames)), ...
    'Dataset is missing one or more required columns.');

% The workbook stores Date as Excel dates; handle dates and text safely.
if ~isdatetime(T.('Date'))
    if isnumeric(T.('Date'))
        T.('Date') = datetime(T.('Date'), 'ConvertFrom', 'excel');
    else
        T.('Date') = datetime(string(T.('Date')));
    end
end

% Compare a single, consistent unit across years and locations.
metric = 'Personal Vehicles';
valid = strcmp(string(T.('Measure')), metric) & ...
    ~isnat(T.('Date')) & isfinite(T.('Value')) & T.('Value') >= 0;
T = T(valid, :);
T.Year = year(T.('Date'));
T.Month = month(T.('Date'));
T.Border = string(T.('Border'));
T.PortName = string(T.('Port Name'));

fprintf('Analyzing %s across %d records.\n', metric, height(T));
monthLabels = {'Jan','Feb','Mar','Apr','May','Jun', ...
    'Jul','Aug','Sep','Oct','Nov','Dec'};

%% Figure 1: Monthly vehicle crossings by year
monthly = groupsummary(T, {'Year','Month'}, 'sum', 'Value');
years = (min(T.Year):max(T.Year))';
heatValues = nan(12, numel(years));
for k = 1:height(monthly)
    col = find(years == monthly.Year(k), 1);
    heatValues(monthly.Month(k), col) = monthly.sum_Value(k);
end
% Missing month/year combinations stay NaN, not zero.
fig1 = figure('Color','w','Position',[80 80 1250 540]);
h = heatmap(string(years), monthLabels, heatValues);
h.Title = 'U.S. Personal Vehicle Border Crossings by Month and Year';
h.XLabel = 'Year';
h.YLabel = 'Month';
h.ColorbarVisible = 'on';
h.MissingDataLabel = 'No records';
h.FontSize = 11;
h.Colormap = parula(256);
exportgraphics(fig1, fullfile(outputDir,'01_monthly_heatmap.png'), 'Resolution',300);

%% Figure 2: Monthly total crossings by border (average across years)
% Aggregate all ports within each border and month before averaging.
byYear = groupsummary(T, {'Border','Year','Month'}, 'sum', 'Value');
borders = ["US-Canada Border", "US-Mexico Border"];
comparison = nan(12, 2);
for b = 1:2
    for m = 1:12
        rows = byYear.Border == borders(b) & byYear.Month == m;
        if any(rows)
            comparison(m,b) = mean(byYear.sum_Value(rows));
        end
    end
end
fig2 = figure('Color','w','Position',[100 100 1050 550]);
bar(1:12, comparison/1e6, 'grouped');
set(gca,'XTick',1:12,'XTickLabel',monthLabels,'FontSize',11);
ylabel('Average Monthly Personal Vehicle Crossings (Millions)');
xlabel('Month');
title('Seasonal Vehicle Crossings: Canada vs. Mexico');
legend({'U.S.–Canada','U.S.–Mexico'},'Location','northoutside', ...
    'Orientation','horizontal');
grid on; box off;
exportgraphics(fig2, fullfile(outputDir,'02_border_comparison.png'), 'Resolution',300);

%% Figure 3: Geographic crossing volumes by port
% Aggregate over all available months; compare ports by their total counts.
geoValid = isfinite(T.('Latitude')) & isfinite(T.('Longitude')) & ...
    T.('Latitude') >= -90 & T.('Latitude') <= 90 & ...
    T.('Longitude') >= -180 & T.('Longitude') <= 180;
G = T(geoValid,:);
ports = groupsummary(G, {'PortName','Border','Latitude','Longitude'}, ...
    'sum', 'Value');
% Geobubble expects positive sizes; logarithm reduces extreme size disparity.
sizeData = log10(ports.sum_Value + 1);
fig3 = figure('Color','w','Position',[100 100 1150 680]);
g = geobubble(fig3, ports.Latitude, ports.Longitude, sizeData);
g.Title = 'U.S. Border Ports: Personal Vehicle Crossing Volumes';
g.Basemap = 'streets-light';
g.BubbleWidthRange = [5 32];
g.SizeLegendTitle = 'log_{10}(Crossings + 1)';
g.FontSize = 11;
% Avoid overlaying conventional axes/text on geographic coordinates:
% geobubble uses a geographic projection, not standard x/y axes.
exportgraphics(fig3, fullfile(outputDir,'03_port_bubble_map.png'), 'Resolution',300);

%% Summary table for reproducibility
portSummary = sortrows(ports, 'sum_Value', 'descend');
writetable(portSummary, fullfile(outputDir,'port_crossing_summary.csv'));
fprintf('Done. Three figures and the port summary saved in:\n%s\n', outputDir);
