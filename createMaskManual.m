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
maskData.file = 'this is just a demo to see if it works'; 
maskData.path = []; 
maskData.imageStack = []; 
maskData.imageMask = []; 
maskData.imageMean = []; 

% -------------------------------------------------------------------------
% Draw the Figure
% -------------------------------------------------------------------------
% Make Figure; 
mmGUI = figure('Name', 'Mask Maker', 'NumberTitle','off','MenuBar',...
    'None', 'units', 'normalized','Position',[0.2,0.75,0.6,0.6]);

% UI menu
uiMenu = uimenu(mmGUI,'Text','File');
uiMenu_load = uimenu(uiMenu,'Text','Load Data');
uiMenu_load = uimenu(uiMenu,'Text','Save Data');
uiMenu_zap = uimenu(uiMenu,'Text','ZAP Home','Separator','on');
% Current File Loaded
imageText1 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.02 .90, .05, .04],...
    'String','Image: ','HorizontalAlignment','left','FontName','Helvetica','FontSize',12);
imageText2 = uicontrol(mmGUI,'Style','text','units','normalized','Position',[.07 .90, .4, .04],...
    'String',maskData.file,'HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Background','w', 'Callback',@callback_imageText2);
% Image Panel
pImage = uipanel(mmGUI,'Title','Image Properties','FontSize',12,'units','normalized',...
    'Position', [.02,.52,.45,.35]);

bgMask = uibuttongroup(mmGUI,'Title','Mask Generation','Fontname','Helvetica',...
    'FontSize',12,'units','normalized','Position',[.3, .68, .15, .15]);
r1 = uicontrol(bgMask,'Style','radiobutton','String','Manual','units',...
    'normalized','Position',[0.05, .6, .5, .2],'FontName','Helvetica','FontSize',12)
r2 = uicontrol(bgMask,'Style','radiobutton','String','Auto','units',...
    'normalized','Position',[0.05, .3, .5, .2],'FontName','Helvetica','FontSize',12)


end