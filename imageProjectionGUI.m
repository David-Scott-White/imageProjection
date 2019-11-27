function userData = imageProjectionGUI()
% David S. White
% dswhite2012@gmail.com
% 
% GUI for co-localization image processing.
% -----------------------------------------
% updates: 
% ---------
% 2019-11-26 DSW began writing code

% input data: none, simply run the function and follow the GUI
% output data: data structure of user data to load into imageProjection.m 

% set defaults into a data structure 
userData.minRoiArea = 2;
userData.minRoiSeparation = 5;
userData.roiRadius = 2.5;
userData.enableGaussian = 0;
userData.gaussianSearchArea = 16;
userData.path = []; 
userData.alignmentFiles = {};
userData.maskFiles = {};
userData.stackFiles = {};
userData.projectROIs = 0;

% initizalize Window using UI controls 
dspyinfo = get(0,'screensize');
d = dialog('Position',[0.5*(dspyinfo(3)-1000) 0.5*(dspyinfo(4)-500) 1000 500],'Name','Projection parameters');
         
         
text_filepath = uicontrol(d,'Style','text','Position',[10 230 150 20],...
                           'String','File path','HorizontalAlignment','left');


end