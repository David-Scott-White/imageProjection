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

% note:
% adatped from findandPojectRois.m by Marcel P. Goldschen0-Ohm. 

% -------------------------------------------------------------------------
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
     maskChannel = imageData.masks.maskChannel;
    if imageData.masks.createMask
        
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
    
    % now find rois in image mask [fitting to gaussian not super useful here]
    imageROIs = findRoisInImageMask(imageMask,imageData.roiParameters.minArea,...
        imageData.roiParameters.minSpacing,0);
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
    imageWidth =size(imageStacks{1},1);
    imageHeight = size(imageStacks{1},1);
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
    removeROI = [];
    radius = imageData.roiParameters.roiRadius; 
    for q = 1:numChannels
        for r = 1:numROIs
            centroid = imageROIs(r,q).Centroid; 
            [imageROIs(r,q).pixels,imageROIs(r,q).boundingBox] ...
                = adjustPixels(centroid,radius,512,512);
            outOfBounds1 = sum(sum(imageROIs(r,q).pixels > 512));
            outOfBounds2 = sum(sum(imageROIs(r,q).pixels < 1));
            if outOfBounds1 | outOfBounds2
                removeROI = [removeROI;r]; 
            end
        end
    end
    imageROIs(removeROI,:)=[];
    numROIs = size(imageROIs,1);
        
    % for each roi, check circularity
    threshold = 0.5;
    removeROI = [];
    for q = 1:numChannels
        stopFrame = 100;
        if size(imageStacks{q},3) < 100
            stopFrame = size(imageStacks{maskChannel},3)
        end
        muImage = mean(imageStacks{q}(:,:,1:stopFrame),3);
        muImage = mat2gray(subtractBackground(muImage,3));
        if q == maskChannel
            figure;
            imshow(muImage,[]); hold on
        end
        for n = 1:numROIs
            bb = imageROIs(n,q).boundingBox;
            cropped =imcrop(muImage,bb);
            imageROIs(n,q).cropped = cropped;
            if q == maskChannel
                %                 %muImgeMask = createMask(cropped,[],0);
                %                 minValue = min(min(cropped));
                %                 maxValue = max(max(cropped));
                %                 normCropped = (cropped-minValue)./(maxValue-minValue);
                %                 muImageMask = normCropped > threshold;
                %                 roi = regionprops(muImageMask,'Circularity','Orientation');
                %                 if length(roi) > 1
                %                     removeROI = [removeROI;n];
                %                     rectangle('Position',imageROIs(n,maskChannel).boundingBox,'EdgeColor','w'); hold on
                %                 elseif ~sum(abs(roi.Orientation) == [0,45,90])
                %                     removeROI = [removeROI;n];
                %                     rectangle('Position',imageROIs(n,maskChannel).boundingBox,'EdgeColor','w'); hold on
                %                 elseif isinf(roi.Circularity)
                %                     removeROI = [removeROI;n]
                %                     rectangle('Position',imageROIs(n,maskChannel).boundingBox,'EdgeColor','g'); hold on
                %                 else
                plot(imageROIs(n,maskChannel).Centroid(1),imageROIs(n,maskChannel).Centroid(2),'b+'); hold on
                rectangle('Position',imageROIs(n,maskChannel).boundingBox,'EdgeColor','r'); hold on
                text(imageROIs(n,maskChannel).Centroid(1)+2,imageROIs(n,maskChannel).Centroid(2)+2, num2str(n), 'Fontsize', 8,...
                    'color','w'); hold on
                %
            end
            %             end
        end
    end
    % imageROIs(removeROI,:) = [];
   % numROIs = size(imageROIs,1);
    
    % average across all pixels per bound box to make intenstiy time series
    % should writing this as a funtion 
    for c = 1:numChannels
        numFrames = size(imageStacks{c},3);
        wb = waitbar(0,'Projecting ROIs.');
        for n = 1:numROIs
            imageROIs(n,c).time_series = zeros(numFrames,1);
            numPixels = size(imageROIs(n,c).pixels,1);
            if numPixels > 0
                for j = 1:numPixels
                    col = imageROIs(n,c).pixels(j,1);
                    row = imageROIs(n,c).pixels(j,2);
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
            rois(n,c).image.cropped =  imageROIs(n,c).cropped;
            
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
[saveFile, savePath] = uiputfile('*.mat','Save Data', imageData.info.filePath{1});
save([savePath,saveFile], 'data');

end
