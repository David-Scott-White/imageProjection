function mask = createMask(imageStack,options,show);
% David S. White
% dswhite2012@gmail.com
% updated:
% -------
% 2019-11-18 DSW started writing code; built in Matlab mask

nFrames = size(imageStack,3);
if nFrames < 100
    muImage = mean(imageStack(:,:,1:end),3);
else
    muImage = mean(imageStack(:,:,1:100),3);
end
% subtract background,  normalize, and make binary mask
% note: background substraction helps with thresholding!
muImage = mat2gray(subtractBackground(muImage,'White Top Hat'));
% need to write options here..
mask = imbinarize(muImage,'global');
if show
    figure;
    imshowpair(muImage, mask,'montage');
end
