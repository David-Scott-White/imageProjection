function [tiffStack,info] = loadTiffStack(pathToFile,loadMesssage)
%%
% Author: Marcel Goldschen-Ohm
% Email: marcel.goldschen@gmail.com
%
% Load a TIFF image stack from file into a (width x height x frames) array.
% e.g. tiffStack = loadTiffStack('path/to/myImageStack.tif');
%
% Calling loadTiffStack() without a file argument will popup a file
% selection gui.

%% Defaults.
tiffStack = [];
info = [];

%% Popup file selection dialog if file not given.
if ~exist('pathToFile','var') || isempty(pathToFile)
    % Get filename if it was not already given.
    if ~exist('loadMesssage','var') || isempty(loadMesssage)
        loadMesssage = 'Load TIFF stack.';
    end
    [file,path] = uigetfile('*.tif',loadMesssage);
    if isequal(file,0)
        errordlg('ERROR: loadTiffStack requires a valid TIFF file.');
        return
    end
    pathToFile = [path file];
    fileName = file;
else
    seps = strfind(pathToFile,filesep);
    fileName = pathToFile(seps(end)+1:end);
end

%% File label (displayed in waitbar).
% Convert '_' to ' '.
fileLabel = fileName;
idx = strfind(fileName,'_');
for k = 1:length(idx)
    fileLabel(idx(k)) = ' ';
end

%% Start timer.
tic

%% Get some info about TIFF file.
info = imfinfo(pathToFile);
numFrames = numel(info);
if numFrames == 0
    errordlg('ERROR: Zero frames detected in image stack.');
    return
end
width = info(1).Width;
height = info(1).Height;
bpp = info(1).BitDepth;
colorType = info(1).ColorType;
if isempty(find([8 16 32] == bpp,1))
    errordlg(['ERROR: Unsupported image bit depth: ' num2str(bpp) ' (only 8, 16 and 32 bpp supported)']);
    return
end
if ~strcmp(colorType,'grayscale')
    errordlg(['ERROR: Unsupported image format: ' colorType ' (only grayscale supported)']);
    return
end
fmt = sprintf('uint%g', bpp);
infoStr = sprintf('%gx%gx%g@%g', width, height, numFrames, bpp);
disp('Loading TIFF stack...');
disp(['--> File: ' pathToFile]);
disp(['--> Info: ' infoStr]);

%% Allocate memory for entire image stack.
rows = height;
cols = width;
tiffStack = zeros(rows,cols,numFrames,fmt);

%% Load stack one frame at a time.
% !!! Updating waitbar is expensive, so do it sparingly.
wb = waitbar(0,[fileLabel ' (' infoStr ')']);
oneTenthOfTotalFrames = floor(double(numFrames)/10);
% avoid warnings from 'Tiff'
warning('off','all')
tiffLink = Tiff(pathToFile, 'r');
warning('on','all')
for frame = 1:numFrames
    tiffLink.setDirectory(frame);
    tiffStack(:,:,frame) = tiffLink.read();
    if mod(frame, oneTenthOfTotalFrames) == 0
        waitbar(double(frame)/numFrames,wb);
    end
end
tiffLink.close();
close(wb);

%% Check for additional files belonging to this stack.
% e.g. myFile.tif, myFile-file002.tif, myFile-file003.tif, ...
if strcmp(pathToFile(end-11:end-7),'-file')
    fileNum = str2double(pathToFile(end-6:end-4));
    pathToNextFile = [pathToFile(1:end-7) num2str(fileNum+1,'%03u') '.tif'];
else
    pathToNextFile = [pathToFile(1:end-4) '-file002.tif'];
end
if exist(pathToNextFile,'file') == 2
    nextStack = loadTiffStack(pathToNextFile);
    tiffStack = cat(3,tiffStack,nextStack);
end

%% Elapsed time.
time_s = toc;
disp(['--> Elasped Time: ', num2str(time_s), ' seconds.']);
disp('... Finished loading TIFF stack.');

end
