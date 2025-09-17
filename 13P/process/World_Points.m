% clc
% clear
worldPoints = [];
squareSize = 30; % Actual spacing between circles (in cm)

k=0;
while k<5
    i=0;
    while i<16
        worldPoints = [worldPoints;[(i+0.5)*(squareSize),2*k*30]];
        worldPoints = [worldPoints;[i*(squareSize),(2*k+1)*30]];
        i = i+1;
    end
    worldPoints = [worldPoints;[(i)*squareSize,(2*k+1)*30]];
    k = k+1;
end

% Convert to table for easier sorting
worldPoints = array2table(worldPoints, 'VariableNames', {'X', 'Y'});

% Sort points first by Y (ascending), then by X (ascending)
worldPoints = sortrows(worldPoints, {'Y', 'X'});

% Convert back to array
worldPoints = table2array(worldPoints);

% % Convert to table for saving
% worldPointsTable = array2table(worldPoints, 'VariableNames', {'X', 'Y'});
% 
% % Save to CSV
% writetable(worldPointsTable, 'world_points.csv');
% 
% % Display message
% disp('World points saved to world_points.csv');

% figure()
% scatter(worldPoints(:,1),worldPoints(:,2),800,'.')
% set(gca,'YDir','reverse','XAxisLocation','top')
