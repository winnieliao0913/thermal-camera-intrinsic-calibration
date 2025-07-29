function [centroids_ordered] = reorderCentroids(centroids, boardSize)
%This function takes all the points of a checkerboard pattern and returns
%them so they are ordered in rows from top left to top right and then from
%left to right along each row.

%Sort centroids by their x value;
centroids = sortrows(centroids,1);

%First fit a polygon to the centroids
[polyx, polyy] = minboundparallelogram(centroids(:,1),centroids(:,2));
polyxy = [polyx polyy polyx+polyy];
polyxy = unique(polyxy,'rows');

%Sort by sum of x & y: top-left is first and bottom right is last
polyxy = sortrows(polyxy,3);

%Sort middle two values by X
%Now order is top-left, bottom left, top right, bottom right
polyxy(2:3,:) = sortrows(polyxy(2:3,:),1);

% Find angle between top-left and top-right, and between bottom left and
% bottom right, and take the average.
d1 = polyxy(3,1:2) - polyxy(1,1:2);
%d2 = polyxy(4,1:2) - polyxy(2,1:2);
rot_angle = atan2d(d1(2),d1(1));
%angle2 = atan2d(d2(2),d2(1));
[centroids_rot(:,1), centroids_rot(:,2)] = rot(centroids(:,1),centroids(:,2), -rot_angle);
ordered_idx = [];
idxs_left = 1:height(centroids);
points_done_so_far = 0;
centroids_rot_temp = centroids_rot;  % Using these to keep track of values that have already been used changing values to a high number after they've been used to make it easier to keep track of indexing
centroids_rot_temp(:,2) = 500-centroids_rot_temp(:,2); % Flipping image along Y axis
for i = 1:10
    if rem(i,2) == 0
        %even rows
        numpts = 17;
    else
        %odd_rows
        numpts = 16;
    end
    % Get the lowest numpts values in the Y axis
    [sorted_vals, sorted_idxs] = sort(centroids_rot_temp(:,2));
    row_idxs = sorted_idxs(1:numpts);
    centroids_rot_temp(row_idxs,2) = 1000; % Replace values with a high number
    
    % Sort row_idxs by their X values
    [sorted_vals, sorted_idxs_X] = sort(centroids_rot(row_idxs,1),'ascend');
    row_idxs = row_idxs(sorted_idxs_X);
    
    %this_row_idxs = points_done_so_far +1: points_done_so_far + numpts;
    ordered_idx = [ordered_idx; row_idxs];

    %points_done_so_far = points_done_so_far + numpts;
end
1;
centroids = centroids(ordered_idx, :);

%Next find the points on the left and right columns
%[left_dist, varargout] = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(1:2,1),polyxy(1:2,2));
%[right_dist, varargout] = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(3:4,1),polyxy(3:4,2));

%left_row_idx = find(left_dist < 12);     %Could alternatively sort and find min 12 values
%right_row_idx = find(right_dist < 12);
%[~, left_row_idx] = mink(left_dist, 10);
%[~, right_row_idx] = mink(right_dist, 10);

%if length(left_row_idx) ~=boardSize(1) | length(right_row_idx)~=boardSize(1)
    %Didn't find the right number of points
%    centroids_ordered =[];
%    return
%end

% % distance from all points to left/right edges
% [left_dist, ~]  = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(1:2,1),polyxy(1:2,2));
% [right_dist, ~] = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(3:4,1),polyxy(3:4,2));
% 
% % Define separate Y bins for left and right edges
% y_left_top    = polyxy(1,2);
% y_left_bottom = polyxy(2,2);
% y_right_top    = polyxy(3,2);
% y_right_bottom = polyxy(4,2);
% 
% left_y_bins  = linspace(y_left_top, y_left_bottom, boardSize(1)+1);  % top to bottom
% right_y_bins = linspace(y_right_top, y_right_bottom, boardSize(1)+1);
% 
% left_row_idx = zeros(boardSize(1), 1);
% right_row_idx = zeros(boardSize(1), 1);
% 
% % Loop by row: separately select left/right points
% for i = 1:boardSize(1)
%     % LEFT side bin
%     in_left_bin = (centroids(:,2) >= left_y_bins(i)) & (centroids(:,2) < left_y_bins(i+1));
%     % margin = 2; % pixels of vertical tolerance
%     % in_left_bin = (centroids(:,2) >= left_y_bins(i) + margin) & (centroids(:,2) <  left_y_bins(i+1) + margin);
%     left_bin_pts = centroids(in_left_bin, :);
%     left_bin_indices = find(in_left_bin);
% 
%     if isempty(left_bin_pts)
%         warning('No points in LEFT Y-bin row %d.', i);
%         centroids_ordered = [];
%         return;
%     end
% 
%     [~, min_left_idx] = min(left_dist(left_bin_indices));
%     left_row_idx(i) = left_bin_indices(min_left_idx);
% 
%     % RIGHT side bin
%     in_right_bin = (centroids(:,2) >= right_y_bins(i)) & (centroids(:,2) < right_y_bins(i+1));
%     % in_right_bin = (centroids(:,2) >= right_y_bins(i) + margin) & (centroids(:,2) <  right_y_bins(i+1) + margin);
%     right_bin_pts = centroids(in_right_bin, :);
%     right_bin_indices = find(in_right_bin);
% 
%     if isempty(right_bin_pts)
%         warning('No points in RIGHT Y-bin row %d.', i);
%         centroids_ordered = [];
%         return;
%     end
% 
%     [~, min_right_idx] = min(right_dist(right_bin_indices));
%     right_row_idx(i) = right_bin_indices(min_right_idx);
% end

%for debugging: visualize 10 closest to the left edge (red), 10 closest to the right edge (blue), and left and right edge lines
figure;
hold on;
axis equal;
grid on;

% Plot all detected checkerboard corner points
plot(centroids(:,1), centroids(:,2), 'ko-', 'MarkerFaceColor', 'k');
%plot(centroids(:,1), centroids(:,2), 'ko', 'MarkerFaceColor', 'k');
title('Left column (red) vs Right column (blue) candidates');
xlabel('X'); ylabel('Y');

% Plot the 10 closest points to the left edge in red
%plot(centroids(left_row_idx,1), centroids(left_row_idx,2), 'ro', 'MarkerSize', 10, 'LineWidth', 1.5);

% Plot the 10 closest points to the right edge in blue
%plot(centroids(right_row_idx,1), centroids(right_row_idx,2), 'bo', 'MarkerSize', 10, 'LineWidth', 1.5);

% Add index numbers next to each centroid for reference
for i = 1:length(centroids)
    text(centroids(i,1)+2, centroids(i,2), num2str(i), 'FontSize', 8);
end

% Make sure 'polyxy' has already been defined correctly in the script
plot(polyxy(1:2,1), polyxy(1:2,2), 'r-', 'LineWidth', 2); % left edge
plot(polyxy(3:4,1), polyxy(3:4,2), 'b-', 'LineWidth', 2); % right edge

% legend('All centroids','Left column candidates','Right column candidates','Left edge','Right edge');


%Now sort left and right rows by y coordinate of centroids
%left_row_idx = sortrows([left_row_idx centroids(left_row_idx,2)],2);
%right_row_idx = sortrows([right_row_idx centroids(right_row_idx,2)],2);

%Note: there is a noticeable jitter between the black and white squares.
%May want to do a cross correlation to offset this.

%Now cycle through rows and put centroids in order
%ordered_idx = [];
%figure;
%for i = 1:boardSize(1)
    %Find distance to this row
%    [row_dist, varargout] =  p_poly_dist(centroids(:,1),centroids(:,2),...
%        [centroids(left_row_idx(i),1),centroids(right_row_idx(i),1)],...
%        [centroids(left_row_idx(i),2),centroids(right_row_idx(i),2)]);
%    row_idx = find(row_dist < 7);
%    ordered_idx = [ordered_idx; row_idx];
    %hold on; plot(centroids(row_idx(:,1),1),centroids(row_idx(:,1),2),'ro-');
%end
fprintf('[DEBUG] Reordered %d points out of %d\n', length(ordered_idx), size(centroids,1));
centroids_ordered = centroids; %(ordered_idx,:);
