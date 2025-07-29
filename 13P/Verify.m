clc
clear all
folderPath = 'Result\ResultData'; % Change this to your own file path
csvFiles = dir(fullfile(folderPath, '*.csv'));

run World_Points.m

% Create a new graphic window
figure;

% Set the number of subplots
numPlots = length(csvFiles) + 1;

% Loop through each csv file and draw scatterplots
for k = 1:length(csvFiles)
    % Get file name
    fileName = fullfile(folderPath, csvFiles(k).name);
    
    % Read data
    data = readtable(fileName);
    data = data(:, 1:2); % Only read the first two rows
    x = table2array(data(:, 1));
    y = table2array(data(:, 2));
    
    % Draw scatterplots and set the sizes of the points
    subplot(3, 4, k);
    scatter(x, y, 200, '.'); % set sizes of the points as 200
    title(sprintf('Detected Circles %d', k));
    axis equal; % Keep axes proportional
end

% Finally, plot worldPoints
subplot(3, 4, numPlots);
scatter(worldPoints(:, 1), worldPoints(:, 2), 200, '.'); % Set point sizes
title('World Points');
axis equal; % Keep axes proportional

% Adjust the spacing between subplots
sgtitle('Detected Circles and World Points'); % Add overall title
set(gcf, 'Position', [100, 100, 1000, 700]); % Set the size of the figure window (larger)


% Save the figure as a PNG file with 1200 DPI resolution
exportgraphics(gcf, 'Result\output.png', 'Resolution', 1200);
