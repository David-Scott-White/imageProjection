function imageData = projectROIsNew(imageData)
% David S. White
% dswhite2012@gmail.com
% Updates: 
% --------
% 2019-11-27 DSW Began writing code. Will work from data provided by
% imageProjectionGUI

% details about imageData structure

% check to see if data is loaded
if ~exist('imageData','var')
    [file,path] = uigetfile('*.mat'); 
    load([path,file]);
end

% parse initial information to make sure we process the data correctly




