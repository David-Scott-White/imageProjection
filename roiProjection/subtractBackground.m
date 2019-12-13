function newImage = subtractBackground(originalImage,radius,show); 
% David S. White
% dswhite2012@gmail.com
% Updates: 
% ---------
% 2019-11-17 DSW began writing function. 
% 
% overview: 
%
% input variables 
% 
% output variables

% imtophat is not doing a great job with background substraction. This may
% be due to a flat structuring element (disk) and may do better with "ball"
% but that took way tooo long to be pratical and still gave poor results. 

% need to write in a wait bar like the load tiff stack one... 
newImage = originalImage;
numFrames = size(originalImage,3);
% check for nhood
% se = [0,1,1,0; 1,1,1,1; 1,1,1,1; 0,1,1,0]; % structuring element
se = strel('disk', radius);
for i = 1:numFrames
    newImage(:,:,i) = imtophat(originalImage(:,:,i),se);
end

end