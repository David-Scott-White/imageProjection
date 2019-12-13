function mask = createMask(imageStack,options,show);
% David S. White
% dswhite2012@gmail.com
% updated:
% -------
% 2019-11-18 DSW started writing code using imbinarize

nFrames = size(imageStack,3);
if nFrames < 100
    muImage = mean(imageStack(:,:,1:end),3);
    % will probably need to open up a manual adjustment
    % but works for bright field images 
else
    muImage = mean(imageStack(:,:,1:100),3);
end
% subtract background,  normalize, and make binary mask
% note: background substraction helps with thresholding!
muImage = mat2gray(subtractBackground(muImage,3));
% need to write options here..
mask = imbinarize(muImage,'global');
if show
    figure;
    imshowpair(muImage, mask,'montage');
end
