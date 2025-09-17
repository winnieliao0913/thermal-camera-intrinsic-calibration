% Following istructions from this page: 
% https://www.mathworks.com/help/images/detect-and-measure-circular-objects-in-an-image.html
close all
clc

% Gather images
% Recommend conducting the detections individually
% Because false positives or negatives could impact subsequent parameter estimation
d = dir('10.png'); % Change it to the name of your graph

% Determine how many images were found
N_images = numel(d);

% Create Result folders
mkdir('Result\ResultData');
mkdir('Result\ResultImage');

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
for i = 1:N_images
    % Read image
    im1 = imread(d(i).name);
    name = d(i).name;

    % Convert to grayscale
    img = im2gray(im1);
    % img = imbinarize(img);

    % Specify region
    % Redo if any false positives or negatives arise
    % Ensure that 165 points are detected
    fig = figure(i);
    imshow(img);
    fig.WindowState = "maximized";

    title('Specify Region, end by pressing "Enter"');
    
    h = drawpolygon;
    position = h.Position;
    % disp(position)
 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % Create polygon mask
    [rows, cols] = size(img);
    mask = poly2mask(position(:,1), position(:,2), rows, cols);
    
    % Get Color from vertices of polygon
    % Initialize RGB matrix
    RGB_values = zeros(3, size(position, 1));
    
    % Get average gray scale
    for j = 1:size(position, 1)
        [c, r, RGB] = impixel(img, position(j, 1), position(j, 2));
        RGB_values(:,j) = RGB;
    end
    averageScale = mean(RGB_values(1,:));

    % Turn region out of mask gray, define the scale (0-256, 0=black, 256=white)
    img(~mask) = averageScale*0.9;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % Increase image resolution by 2x to improve circle detection
    img2 = imresize(img,2);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % Set sensitivity (0.0 to 1.0, normally around 0.85)
    sens = 0.88;
    % Set EdgeThreshold (0.0 to 1.0, normally around 0.15)
    edge = 0.18;
    % Set Type of detection ("bright" or "dark", dark circles or bright circles compare to background)
    Type = "bright";

    % Determine the radii of circle
    fig = figure(i);
    imshow(img2);
    title('Measure the diameter, hold your mouse until the line spans the full width of the circle');
    fig.WindowState = "maximized";


    d = drawline;
    
    pos = d.Position;
    diffPos = diff(pos);
    r = hypot(diffPos(1),diffPos(2))/2;
    fprintf("r = %6.2f \n",r)

    % Try to detect centers, searching for range of radii 
    [centers_pre,radii_pre,metric_pre] = imfindcircles(img2,[floor(0.25*r) ceil(1.75*r)],ObjectPolarity=Type,Sensitivity=0.85);
    if length(centers_pre)==0
        fprintf("No circle detected in image: %s \n",name)
        continue
    end
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    tic
    % Clibrated detection
    new_r = mean(radii_pre);

    centers_dark = [];
    radii_dark = [];
    centers_bright = [];
    radii_bright = [];
    metric_dark =[]
    metric_bright = []

    % % find darker circles
    % [centers_dark,radii_dark,metric_dark] = imfindcircles(img2,[floor(0.4*new_r) ceil(1.6*new_r)],ObjectPolarity="dark",Sensitivity=sens,Method="TwoStage",EdgeThreshold=edge);
    % if length(centers_dark)==0
    %     fprintf("No circle detected in calibration detection: %s \n,, increase Sensitivity or lower EdgeThreshold",name)
    %     continue
    % end

    % find brighter circles
    [centers_bright,radii_bright,metric_bright] = imfindcircles(img2,[floor(0.5*new_r) ceil(1.5*new_r)],ObjectPolarity=Type,Sensitivity=sens,Method="TwoStage",EdgeThreshold=edge);
    if length(centers_bright)==0
        fprintf("No circle detected in calibration detection: %s \n increase Sensitivity or lower EdgeThreshold",name)
        continue
    end

    % all circles
    centers = [centers_dark;centers_bright];
    radii = [radii_dark;radii_bright];
    metric = [metric_dark;metric_bright]

    fprintf("Calibrated r =%5.2f \n",new_r)
    fprintf('Sensitivity =%5.2f \nEdgeThreshold= %5.2f \n%d circles detected \n', ...
        sens,edge,length(centers))

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    % % Plot with new image
    % figure(i); imshow(img2); 
    % hold on; plot(centers(:,1), centers(:,2),'*y')
    % title(string(d(i).name));

    % Plot original image
    result_Image = figure(i); 
    imshow(im1);
    hold on; 
    plot(centers(:,1)./2, centers(:,2)./2,'*y');
    viscircles(centers_dark./2,radii_dark./2,Color = "r",LineWidth=1.5);
    viscircles(centers_bright./2,radii_bright./2,Color = "b",LineWidth=1.5);
    hold off;
    result_Image.WindowState = "maximized";
    result_Image = gca;
    
    % Export Result Image

    resultname = join(["Result\ResultImage\Detected",name]);
    exportgraphics(result_Image,resultname);
    fprintf("%s saved successfully\n",resultname)

    % Export Data {X,Y,Radii}
    if contains(name,'.') 
        name = strrep(name,'.','');
    end
    result_Data = [centers./2,radii./2];
    resultDataName = join(["Result\ResultData\DetectedCircles",name,'.csv']);
    csvwrite(resultDataName,result_Data);


    fprintf("%s saved successfully\n",resultDataName)

    
end
toc


