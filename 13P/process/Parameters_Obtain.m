clc
clear
run World_Points.m;
%%
folderPath = 'Result\ResultData'; % Update the file path
csvFiles = dir(fullfile(folderPath, '*.csv'));

% Initialize an empty 3D array
%ImagePoints = zeros(165, 2, 10); % Assuming there are 10 files, each containing 165 points
ImagePoints = zeros(165,2,1); % Appending depending on data quality
% Read each file and populate the array
good_frames = 0;
for k = 1:length(csvFiles)
    % Get the file name
    fileName = fullfile(folderPath, csvFiles(k).name);
    
    % Read the CSV file, assuming the points are stored in the x and y columns
    data = readtable(fileName);
    
    % Extract the x and y coordinates (assuming they are in the first two columns)
    points = table2array(data(:, 1:2)); % Extract the first two columns as points
    
    % Check the number of points
    if size(points, 1) ~= 165
        error('File %s does not contain 165 points.', csvFiles(k).name);
    end
    
    sortedPoints = reorderCentroids2(points(:,1:2), [10,33]);
    if height(sortedPoints) ~=165
        continue
    end
    good_frames = good_frames +1;
    % Store the points in the k-th layer of the 3D array
    
    ImagePoints(:, :, good_frames) = double(sortedPoints); % Ensure conversion to double type

    % Display the sorted points
    % disp(ImagePoints(:, :, k));
    
    % Display the file name
    fprintf('Read: %s\n', csvFiles(k).name);
end
%good_frames = [18,17, 13,11,10];
%ImagePoints = ImagePoints(:,:,good_frames);
fprintf('Total valid frames with 165 points and successful sorting: %d\n', good_frames);

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Check if x and y in Image Points match in World Points
% Draw worldPoints
figure;
scatter(worldPoints(:, 1), worldPoints(:, 2), 'r');
title('World Points');
for i = 1:height(worldPoints)
    text(worldPoints(i,1), worldPoints(i,2), num2str(i), 'FontSize', 8);
end
hold on;

% Draw the first ImagePoints
figure;
scatter(ImagePoints(:, 1, 1), ImagePoints(:, 2, 1), 'b');
%legend('World Points', 'Image Points');
for i = 1:height(ImagePoints)
    text(ImagePoints(i,1,1), ImagePoints(i,2,1), num2str(i), 'FontSize', 8);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% Camera Parameter Estimation
[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(ImagePoints, worldPoints);
showReprojectionErrors(cameraParams);
figure;
showExtrinsics(cameraParams);
save("cameraParams.mat","cameraParams")