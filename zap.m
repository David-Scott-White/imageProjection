function zap();
% -------------------------------------------------------------------------
% Zero-mode waveguide (ZMW) Analysis Platform (ZAP)
% -------------------------------------------------------------------------
% Author: David S. White
% Contact: dswhite2012@gmail.com
% License: GPLv3.0

% updates: 
% 2019-12-10 DSW wrote the figure

% comments:
% should normalize the position

% -------------------------------------------------------------------------
% launch the ZAP app
zapApp = figure('Name', 'ZAP', 'NumberTitle','off','MenuBar','None', 'Position',[600,300,300,400]);

% Welcome Text
welcomeText1 = uicontrol(zapApp,'Style','text','Position',[25 340 250 50],'units', 'normalized',...
    'String','Welcome to Z.A.P.!','HorizontalAlignment','center','FontName','Helvetica','FontSize',18);
welcomeText2 = uicontrol(zapApp,'Style','text','Position',[25 310 250 50],'units', 'normalized',...
    'String','ZMW Analysis Platform','HorizontalAlignment','center','FontName','Helvetica','FontSize',12);

% Routines:
% 1. mask Maker
button_maskMaker = uicontrol(zapApp,'Style','pushbutton','Position',[25 280 250 50],'units', 'normalized',...
    'String','Mask Maker','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @launch_maskMaker);

% 2. Image Projection
button_roiProjection = uicontrol(zapApp,'Style','pushbutton','Position',[25 230 250 50],'units', 'normalized',...
    'String','Image Processing','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @launch_roiProjection);

% 3. Trajectory Navigation and DISC
button_roiViewer = uicontrol(zapApp,'Style','pushbutton','Position',[25 180 250 50],'units', 'normalized',...
    'String','Trajectory Viewer & DISC','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @launch_roiViewer);

% 3. Analysis
button_analysis = uicontrol(zapApp,'Style','pushbutton','Position',[25 130 250 50],'units', 'normalized',...
    'String','Analysis','HorizontalAlignment','left','FontName','Helvetica','FontSize',12,...
    'Callback', @launch_analysis);

% Closeing Text
closingText1 = uicontrol(zapApp,'Style','text','Position',[25 20 250 50],'units', 'normalized',...
    'String','version 0.0.1','HorizontalAlignment','center','FontName','Helvetica','FontSize',10);
closingText2 = uicontrol(zapApp,'Style','text','Position',[25 0 250 50],'units', 'normalized',...
    'String','David S. White','HorizontalAlignment','center','FontName','Helvetica','FontSize',10);

% Callbacks.
    function launch_maskMaker(obj,event)
        close(findobj('Name','ZAP'));
        maskMaker;
    end

    function launch_roiProjection(obj,event)
        close(findobj('Name','ZAP'));
        projectionGUI;
    end

    function launch_roiViewer(obj,event)
        %close(findobj('Name','ZAP'));
         errordlg('Error getting DISCO to work...');
        % DISCO
    end

    function launch_analysis(obj,event)
        % close(findobj('Name','ZAP'));
        errordlg('Sorry! Analysis tab is still under development');
    end



end
