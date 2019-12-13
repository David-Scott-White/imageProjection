function new_positions = manualShiftPixels(imageStack,orginal_positions)
% Manually shift the pixels in X Y to find the centers of ROIs in
% imageStack

% David S. White
% dswhite2012@gmail.com

% 2019-05-15
user_decision = 0;

% should update to dynamically do this in a GUI rather than in figure

figure; hold on
set(gca,'fontsize',16)
while ~user_decision
    cla; % clear the figure;
    imshow(mean(imageStack,3),[]); hold on; 
    plot(orginal_positions(:,1),orginal_positions(:,2),'w+'); hold on; 
    legend('Original Location');
    
    off_set = []; % make sure an answer is given
    while isempty(off_set)
        % input prompt to shift pixels in [X,Y]
        prompt = 'Set X and Y off set as [X,Y]: ';
        off_set = input(prompt);
    end
    new_positions =  orginal_positions + off_set;
    
    % Plot new positions on figure;
    plot(new_positions(:,1),new_positions(:,2),'r+');
    legend('Original Location', 'New Location');
    
    user_decision = [];
    while isempty(user_decision)
        % accept the new positons (Boolean)?
        prompt = 'Accept new positions (1) or try again (0)?: ';
        user_decision = input(prompt);
    end
end
close all; 
end