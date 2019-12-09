function mask = createMaskManual(filePath, imageStack); 
%% manually make an image mask 
% David White
% dswhite2012gmail.com 
% updated: 
% 2019-12-05


% if ~exist('filePath','var')
%     [loadFile,loadPath] = uigetfile('*.tif'); 
%     filePath = [loadPath,loadFile]; 
%     imageStack = loadTiffStack([filePath]); 
% end

% init maskData structure; will be updated with callback
maskData = struct;
%maskData.filePath = [filePath]; 
%maskData.imageStack = imageStack; 

% make figure; 
gui = figure('Name', 'Manual Mask Creation', 'NumberTitle','off'); 

% Load data text button
button_loadImage = uicontrol(gui,'Style','pushbutton','Position',[20 390 100 25],'units', 'normalized',...
    'String','Load Data','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @loadImage_callback);
                      

text_filePath = uicontrol(gui,'Style','edit','Position',[130 390 150 25],'units', 'normalized',...
    'String','Load Data','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @loadImage_callback);

% current file path 
text_filePath = uicontrol(gui,'Style','edit','Position',[20 390 150 20],...
                           'String','Load Data','HorizontalAlignment','left',...
                           'FontName','Helvetica','FontSize',12, 'Callback', @loadImage_callback);



     % call backs                  
    function [gui, maskData] = loadImage_callback(gui, event, maskData)
        [file,path] = uigetfile('*.tif'); 
        maskData.filePath = [path,file]; 
        maskData.originalImage = loadTiffStack([path,file]); 
    end

    function [gui, maskData] = filePah_callback(gui, event, maskData)
        gui.text_filePath.value = 'woah'
    end

end