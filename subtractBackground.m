function newImage = subtractBackground(originalImage,method,varagin); 
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
%
newImage = originalImage;
numFrames = size(originalImage,3);
switch method
    case 'White Top Hat'
        % check for nhood
        se = [0,1,1,0; 1,1,1,1; 1,1,1,1; 0,1,1,0]; % structuring element
        for i = 1:numFrames
            newImage(:,:,i) = imtophat(originalImage(:,:,i),se);
        end
        
end
end