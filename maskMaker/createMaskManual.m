function maskMaker(); 
%% Mask Maker App (uicontrols)
% Author: David White
% Contact: dswhite2012gmail.com 
% License: GPLv3.0
% Updated: 
% 2019-12-05

% -------------------------------------------------------------------------
% Init empty maskData structure; 
% -------------------------------------------------------------------------
maskData = struct; 
maskData.file = []; 
maskData.path = []; 
maskData.imageStack = []; 
maskData.imageMask = []; 
maskData.imageMean = []; 

% -------------------------------------------------------------------------
% Draw the Figure
% -------------------------------------------------------------------------
% Make Figure; 
appWidth = 1000;
appHeight = 750; 
screenSize = get(0,'ScreenSize'); % in pixels
centerX = round(screenSize(3)/2 - appWidth/2);
centerY = round(screenSize(4)/2 - appHeight/2);

% main window
mmGUI = figure('Name', 'Mask Maker', 'NumberTitle','off','MenuBar',...
    'None', 'units', 'pixels','Position',[centerX,centerY,appWidth,appHeight], 'Resize','on');

% UI menu: 
uiMenu = uimenu(mmGUI,'Text','File');
uiMenu_load = uimenu(uiMenu,'Text','Load Data');
uiMenu_load = uimenu(uiMenu,'Text','Save Data');
uiMenu_zap = uimenu(uiMenu,'Text','ZAP Home','Separator','on');

% draw all components: 








% 
% % UI menu
% uiMenu = uimenu(mmGUI,'Text','File');
% uiMenu_load = uimenu(uiMenu,'Text','Load Data');
% uiMenu_load = uimenu(uiMenu,'Text','Save Data');
% uiMenu_zap = uimenu(uiMenu,'Text','ZAP Home','Separator','on');
% % Current File Loaded
% imageText1 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.02 .90, .05, .04],...
%     'String','Image: ','HorizontalAlignment','left','FontName','Helvetica','FontSize',12);
% imageText2 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.07 .90, .4, .04],...
%     'String',maskData.file,'HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
%     'Background','w', 'Callback',@callback_imageText2);
% % Parameters Panel
% pParameters = uipanel(mmGUI,'Title','Parameters','FontName','Helvetica','FontSize',12,'units','normalized',...
%     'Position', [.02,.57,.4,.30]);
% pAverage = uipanel(mmGUI,'Title', 'Average Frames','FontName','Helvetica','FontSize',12,'units','normalized',...
%      'Position', [.04,0.68,.15,.15]);
% frameText1 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.05 .75, .04, .04],...
%     'String','Start: ','HorizontalAlignment','left','FontName','Helvetica','FontSize',12);
% frameEdit1 = uicontrol(mmGUI,'Style','edit','units','normalized','Position',[.09 .75, .08, .04],...
%     'String','1','HorizontalAlignment','right','FontName','Helvetica','FontSize',12);
% frameText2 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.05 .7, .04, .04],...
%     'String','Stop: ','HorizontalAlignment','left','FontName','Helvetica','FontSize',12);
% frameEdit2 = uicontrol(mmGUI,'Style','edit','units','normalized','Position',[.090 .7, .08, .04],...
%     'String','10','HorizontalAlignment','right','FontName','Helvetica','FontSize',12);
% % subtract background
% bsCheck = uicontrol(mmGUI,'Style','checkbox','units','normalized','Position',[.05 .62, .3, .05],...
%     'String','Subtract Background','HorizontalAlignment','right','FontName','Helvetica','FontSize',12);
% % mask creation panel
% bgMask = uibuttongroup(mmGUI,'Title','Mask Creation','Fontname','Helvetica',...
%     'FontSize',12,'units','normalized','Position',[.22, .68, .15, .15]);
% r1 = uicontrol(bgMask,'Style','radiobutton','String','Manual','units',...
%     'normalized','Position',[0.05, .6, .5, .2],'FontName','Helvetica','FontSize',12);
% r2 = uicontrol(bgMask,'Style','radiobutton','String','Auto','units',...
%     'normalized','Position',[0.05, .2, .5, .2],'FontName','Helvetica','FontSize',12);
% % update figure button 
% updateButton = uicontrol(mmGUI,'Style','pushbutton','units','normalized','Position',[.22 .62, .15, .05],...
%     'String','Update Preview','HorizontalAlignment','Center','FontName','Helvetica','FontSize',12);

% histogram axes
axesHist = 0


end