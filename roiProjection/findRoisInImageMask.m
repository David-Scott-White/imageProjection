function rois = findRoisInImageMask(binaryMask,minRoiArea,minRoiSeparation,visualize)
%%
% Author: Marcel Goldschen-Ohm
% Email: marcel.goldschen@gmail.com
%
% Find ROIs in a binary mask using regionprops.
% Optionally specify a minumum area and separation distance between ROIs.

%% Make sure mask is binary.
binaryMask = (binaryMask > 0); 

%% Find ROI properties.
rois = regionprops(binaryMask,'Centroid','Area','BoundingBox','PixelIdxList','PixelList');

%% Remove ROIs that are too small.
areas = vertcat(rois.Area);
badRois = find(areas < minRoiArea);
if ~isempty(badRois)
    rois(badRois) = [];
end

%% Remove ROIs that are too close together.
if length(rois) < 500
    badRois = [];
    for i = 1:length(rois)
        for j = 1:length(rois)
            if (i ~= j) && isempty(find(badRois == i, 1)) && isempty(find(badRois == j, 1))
                xi = rois(i).Centroid(1);
                yi = rois(i).Centroid(2);
                xj = rois(j).Centroid(1);
                yj = rois(j).Centroid(2);
                interRoiDistance = sqrt((xi-xj)^2 + (yi-yj)^2);
                if interRoiDistance < minRoiSeparation
                    % Decide wether to throw out ROI i or j.
                    if rois(i).Area >= rois(j).Area
                        badRois(end+1) = j;
                    else
                        badRois(end+1) = i;
                    end
                end
            end
        end
    end
    if ~isempty(badRois)
        rois(badRois) = [];
    end
end

%% Plot mask with ROIs marked.
if visualize
figure;
imshow(binaryMask);
hold on;
centroids = vertcat(rois.Centroid);
plot(centroids(:,1), centroids(:,2), 'r+');
end

end
