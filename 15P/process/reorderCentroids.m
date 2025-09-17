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

%Next find the points on the left and right columns
[left_dist, varargout] = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(1:2,1),polyxy(1:2,2));
[right_dist, varargout] = p_poly_dist(centroids(:,1),centroids(:,2),polyxy(3:4,1),polyxy(3:4,2));

%left_row_idx = find(left_dist < 12);     %Could alternatively sort and find min 12 values
right_row_idx = find(right_dist < 12);
[~, left_row_idx] = mink(left_dist, 10);
[~, right_row_idx] = mink(right_dist, 10);

if length(left_row_idx) ~=boardSize(1) | length(right_row_idx)~=boardSize(1)
    %Didn't find the right number of points
    centroids_ordered =[];
    return
end

%Now sort left and right rows by y coordinate of centroids
left_row_idx = sortrows([left_row_idx centroids(left_row_idx,2)],2);
right_row_idx = sortrows([right_row_idx centroids(right_row_idx,2)],2);

%Note: there is a noticeable jitter between the black and white squares.
%May want to do a cross correlation to offset this.

%Now cycle through rows and put centroids in order
ordered_idx = [];
%figure;
for i = 1:boardSize(1)
    %Find distance to this row
    [row_dist, varargout] =  p_poly_dist(centroids(:,1),centroids(:,2),...
        [centroids(left_row_idx(i),1),centroids(right_row_idx(i),1)],...
        [centroids(left_row_idx(i),2),centroids(right_row_idx(i),2)]);
    row_idx = find(row_dist < 7);
    ordered_idx = [ordered_idx; row_idx];
    %hold on; plot(centroids(row_idx(:,1),1),centroids(row_idx(:,1),2),'ro-');
end
centroids_ordered = centroids(ordered_idx,:);