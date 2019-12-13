function [pixels,boundingBox] = adjustPixels(centroid,radius,imageHeight,imageWidth)
% David S. white
% dswhite2012@gmail.com
% 2019-12-02

% compute pixels of bounding box aroun the center at the defined radius.
tlx = round(centroid(1)-radius); % top left x
tly = round(centroid(2)-radius); % top left y % bounding box in region props format
px = tlx:(tlx+radius*2); % pixles in x 
py = tly:(tly+radius*2); % pixels in y 
pixels = []; 
for x =1:length(px)
    for y = 1:length(py)
        pixels = [pixels; [px(x),py(y)]];
    end
end
boundingBox = [tlx-0.5,tly-0.5,length(px),length(py)];   