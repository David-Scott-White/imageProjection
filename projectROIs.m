function data = projectROIs(imageData)
% David S. White
% dswhite2012@gmail.com
% Updates:
% --------
% 2019-11-27 DSW Began writing code. Will work from data provided by
% imageProjectionGUI

% overview:

% input

% output

% to do: 
% if no align masks, still need to refit to image stack with gaussian 
% if two or more channels 

% -------------------------------------------------------------------------
% load data
if ~exist('imageData','var')
    [loadFile,loadPath] = uigetfile('*.mat');
    load([loadPath,loadFile]);
end
    
%  create output structure; formated for DISCO v2.0.0
data = struct;
data.rois = [];
data.roiCounts = [];
data.names = imageData.info.channelNames;

numStacks = imageData.info.numStacks;
numChannels = imageData.info.numChannels;
for i = 1:numStacks
    % allocate space
    imageStacks = cell(numChannels,1);
    imageAlign = cell(numChannels,1);
    imageMask = [];
    
    % load image stacks
    for n = 1:numChannels
        imageStacks{n,1} = loadTiffStack(fullfile(imageData.stacks.path{n},...
            imageData.stacks.files{n}{i,1}));
    end
    
    % load alignment images
    if imageData.align.alignImages
        for n = 1:numChannels
            imageAlign{n,1} = loadTiffStack(fullfile(imageData.align.path{n},...
                imageData.align.files{n}{i,1}));
        end
    end
    
    % create or load image mask; background subtraction built in
    % need option for manually creating image mask
    if imageData.masks.createMask
        maskChannel = imageData.masks.maskChannel;
        
        % temp until function edit
        % create mask needs to be auto and manual 
        % in both cases, need to save the new as uint16 tif
        disp('Creating Image Mask...')
        imageMask = createMask(imageStacks{maskChannel,1},[],1);
        maskFile = fullfile(imageData.stacks.path{maskChannel},...
            imageData.stacks.files{maskChannel}{i,1});
        maskName = [maskFile(1:end-4),'_mask.tif'];
        disp(['Saving Mask: ', newline, maskName]);
        imwrite(uint16(imageMask), maskName, 'Compression', 'none','WriteMode', "append");
        
    else
        imageMask = loadTiffStack(fullfile(imageData.masks.path,imageData.masks.files{i}));
    end
    
    % perform background substraction
    % currently not recommended to use this, the SNR is actually lower 
    % havent tried this again with the new code for projecting image
    % pixels..
    % should check with just bleach step data
    for n=1:numChannels
        if imageData.background.applyToChannels(n)
            disp('Subtracting Background...')
            % imageStacks{n,1} = subtractBackground(imageStacks{n,1},imageData.background.diskRadius);
            imageStacks{n,1} = subtractBackground(imageStacks{n,1},2);
            disp('Background Subtraction Completed.')
            %imshow(mean(imageStacks{n,1}(:,:,1:10),3),[])
        end
    end
    
    % now find rois in image mask [fitting to gaussian not super useful here]
    imageROIs = findRoisInImageMask(imageMask,imageData.roiParameters.minArea,...
        imageData.roiParameters.minSpacing,1);
    numROIs = size(imageROIs,1);
    
    % duplicate structure for each channel
    for c = 2:numChannels
        imageROIs = [imageROIs, imageROIs(:,1)];
    end
    
    % alignment
    if imageData.align.alignImages
        % do image alignment with cp_select
        % align everything to mask channel as a reference.
        toAlign = 1:numChannels;
        toAlign(maskChannel) = [];
        % align images using the cpselect function. 2 images at a time.
        for c = 1:length(toAlign) % can write option to preselect points
            switch imageData.align.method
                case 'manual'
                    [movingPoints,fixedPoints] = cpselect(mat2gray(imageAlign{toAlign(c),1}),...
                        mat2gray(imageAlign{maskChannel,1}),'Wait',true);
                    % center the points? 
                    
                    
                    
                    % determine geometric transform between points
                    tform = fitgeotrans(movingPoints,fixedPoints,'NonreflectiveSimilarity'); 
                
                case 'auto'
                    [optimizer, metric] = imregconfig('multimodal');
                    tform = imregtform(imageAlign{maskChannel,1},...
                        imageAlign{toAlign(c),1},'affine',optimizer,metric);
            end
            % apply geometric transform to identificed centroids
            for r = 1:numROIs
                % centroid = imageROIs(r,toAlign(c)).Centroid;
                centroid = imageROIs(r,maskChannel).Centroid;
                [x,y] = transformPointsForward(tform,centroid(1),centroid(2));
                imageROIs(r,toAlign(c)).Centroid = [x,y];
            end
            % currently refine to alignment image rather than mean of stack
            % need to update this function...
            gaussArea= round(imageData.roiParameters.gaussRefineArea^0.5); 
            fitTol = imageData.roiParameters.gaussFitTol; 
            gaussROIs = fitRoisTo2dGaussians(imageAlign{toAlign(c),1},...
                imageROIs(:,2), [gaussArea, gaussArea], fitTol, 0);
            % store Center as centroid [new to edit fitRoisTo2DGaussians]
            for r = 1:numROIs
                imageROIs(r,toAlign(c)).Centroid = gaussROIs(r).Center;
            end
            % lets compare
            % should have option to change input values to refit if needed
            %figure
            %imshow(imageAlign{toAlign(c),1},[]); hold on
            %centroids = vertcat(imageROIs(:,1).Centroid); % old
            %plot(centroids(:,1), centroids(:,2), 'r+');
            %centroids = vertcat(imageROIs(:,2).Centroid); % new
            %plot(centroids(:,1), centroids(:,2), 'b+');
        end
        
    elseif ~imageData.align.alignImages & numChannels > 1
        % manually shift the pixels
        for c = 2:numChannels
            new_positions =  manualShiftPixels(imageStacks{c},vertcat(imageROIs(:,1).Centroid));
            for n = 1:size(new_positions,1)
                imageROIs(n,c).Centroid = new_positions(n,:); % assign new values
            end
        end
    end
    
    % adjust pixels based on radius around the centroid.
    imageWidth =size(imageStacks{i},1);
    imageHeight = size(imageStacks{i},1);
    keepROIs = ones(numROIs,1); % only keep rois within image bounds
    for c=1:numChannels
        for n = 1:numROIs
            imageROIs(n,c).radius = imageData.roiParameters.roiRadius;
            [imageROIs(n,c).pixels, imageROIs(n,c).pixelIndices] = ...
                findRoiPixels(imageROIs(n,c).Centroid, imageROIs(n,c).radius, imageWidth, imageHeight);
            % if pixels are empty, remove the roi
            if isempty(imageROIs(n,c).pixels)
                keepROIs(n) = 0;
            end
        end
    end
    imageROIs = imageROIs(find(keepROIs>0),:);
    numROIs = size(imageROIs,1);
    
    % remake bounding box at center
    % needs updating 
    for q = 1:3
        figure
        imshow(imageAlign{q},[]); hold on
        for r = 1:numROIs
            centroid = imageROIs(r,q).Centroid; 
            [pixels,bb] = adjustPixels(centroid,3,512,512);
            % imshow(mean(imageStacks{1}(:,:,1),3),[])
            % imshow(imageMask,[]); hold on
            imageROIs(r,q).pixels = pixels; 
            imageROIs(r,q).boundingBox  = bb;
            plot(centroid(1),centroid(2),'b+');
            rectangle('Position',bb,'EdgeColor','r');
        end
    end

        
    % average across all pixels per bound box to make intenstiy time series
    % should writing this as a funtion 
    for c = 1:numChannels
        numFrames = size(imageStacks{c},3);
        wb = waitbar(0,'Projecting ROIs.');
        for n = 1:numROIs
            imageROIs(n,c).time_series = zeros(numFrames,1);
            pixels = imageROIs(n,c).pixels;
            numPixels = size(pixels,1);
            if numPixels > 0
                for j = 1:numPixels
                    col = pixels(j,1);
                    row = pixels(j,2);
                    imageROIs(n,c).time_series = imageROIs(n,c).time_series + double(squeeze(imageStacks{c}(row,col,:)));
                end
                imageROIs(n,c).time_series = imageROIs(n,c).time_series./numPixels;
            end
            % Increment waitbar.
            waitbar(double(n)/length(imageROIs(n,c)),wb);
        end
        close(wb);
    end
    
    % done processing time series. Store in structure;
    % still need to save roi images!
    rois = [];
    for c = 1:numChannels
        for n = 1:numROIs
            % image info
            rois(n,c).image.file = imageData.stacks.files{c}{i,1};
            rois(n,c).image.frameRateHz = imageData.info.frameRateHz;
            rois(n,c).image.size = size(imageStacks{c}(:,:,1));
            
            % rois(n,c).image.roiImage = crop();
            
            % roi info
            rois(n,c).image.centroid = imageROIs(n,c).Centroid;
            rois(n,c).image.pixels = imageROIs(n,c).pixels;
            rois(n,c).time_series = imageROIs(n,c).time_series;
        end
    end
    % concat
    data.rois = [data.rois; rois];
    data.roiCounts =  [data.roiCounts; numROIs];
end

% save the data 
[saveFile, savePath] = uiputfile('*.mat','Save Data', loadPath);
save([savePath,saveFile], 'data');

end
