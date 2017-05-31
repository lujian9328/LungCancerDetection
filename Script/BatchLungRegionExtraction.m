% Batch Lung Region Extraction Algorithm
function LungRegionExtraction
directory = '../Data/sample_preprocess/';
lreDir = '../Data/lung_region_extraction/';

tic
t1 = clock;
directoryInfo = dir(directory);
[numOfSamples, ~] = size(directoryInfo);

for ki = 200 : numOfSamples
    patientId = directoryInfo(ki).name;
    path = [directory, patientId, '/'];
    scanInfo = dir([path, '*.bmp']);
    [numOfScans, ~] = size(scanInfo);
    
    % Create folder for saving the bmp scan slices
    newPath = [lreDir, patientId, '/'];
    if exist(newPath, 'dir') == 0
        system(['mkdir ', newPath]);
    end
    
    t2 = clock;
    for pi = 1 : numOfScans
        sliceName = scanInfo(pi).name;
        image8 = imread([path, sliceName]);
        
        [width, height] = size(image8);
        
        [~,slicename,~] = fileparts(sliceName);
        
        % for b = 1 : 8
        %    Bx = double(255 * bitget(image8, b));
        %    filename = [newPath, slicename, '_b', num2str(b), '.bmp'];
        %    imwrite(Bx, filename);
        % end
        
        % [~,slicename,~] = fileparts(sliceName);
        % for b = 1 : 8
        %     Bx = imcomplement(double(255 * bitget(image8, b)));
        %     filename = [newPath, slicename, '_ib', num2str(b), '.bmp'];
        %     imwrite(Bx, filename);
        % end
        
        % Bit plane slicing
        % ------------- Select the optimal bitplane ------------- %
        B1 = logical(bitget(image8, 1));
        B2 = logical(bitget(image8, 2));
        B3 = logical(bitget(image8, 3));
        B4 = logical(bitget(image8, 4));
        B5 = logical(bitget(image8, 5));
        B6 = logical(bitget(image8, 6));
        B7 = logical(bitget(image8, 7));
        B8 = logical(bitget(image8, 8));
        
        % figure;
        % subplot(2, 4, 1);
        % imshow(B1);
        % title('Bit Plane 1');
        % subplot(2, 4, 2);
        % imshow(B2);
        % title('Bit Plane 2');
        % subplot(2, 4, 3);
        % imshow(B3);
        % title('Bit Plane 3');
        % subplot(2, 4, 4);
        % imshow(B4);
        % title('Bit Plane 4');
        % subplot(2, 4, 5);
        % imshow(B5);
        % title('Bit Plane 5');
        % subplot(2, 4, 6);
        % imshow(B6);
        % title('Bit Plane 6');
        % subplot(2, 4, 7);
        % imshow(B7);
        % title('Bit Plane 7');
        % subplot(2, 4, 8);
        % imshow(B8);
        % title('Bit Plane 8');
        
        R1 = B7 + B8;
        R2 = B7 + B6;
        R3 = ~xor(B6, B7);
        R4 = B7;
        R5 = B5 + B6;
        
        P1 = Ratio(R1);
        P2 = Ratio(R2);
        P3 = Ratio(R3);
        P4 = Ratio(R4);
        P5 = Ratio(R5);
        P = [P1, P2, P3, P4, P5];
        RI = {R1, R2, R3, R4, R5};
        RII = {};
        
        % figure;
        % subplot(3, 2, 1);
        % imshow(R1);
        % title('R1: BP7 + BP8');
        % subplot(3, 2, 2);
        % imshow(R2);
        % title('R2: BP6 + BP7');
        % subplot(3, 2, 3);
        % imshow(R3);
        % title('R3: BP6 xor BP7');
        % subplot(3, 2, 4);
        % imshow(R4);
        % title('R4: BP7');
        % subplot(3, 2, 5);
        % imshow(R5);
        % title('R5: BP5 + BP6');
        
        Threshold = 0.88;
        
        S = [];
        for i = 1 : 5
            if P(i) < Threshold
                S(end+1) = Score(RI{i});
                RII{end+1} = RI{i};
            end
        end
        
        % none of the bitplane result meets 
        % the ratio and score condition
        if isempty(S)
            continue;
        end
        
        [~, k] = min(S);
        % R = RII{k};
        
        bitplane = RII{k};
        % subplot(3, 2, 6);
        % imshow(R);
        % ------------- Select the optimal bitplane ------------- %

        % Erosion
        se = strel('sphere', 2);
        imEro = imerode(bitplane, se);
        
        % Median filter
        imMedian = medfilt2(bitplane);
        
        % Dialation
        imDil = imdilate(imMedian, se);
        
        % ------------- Outlining algorithm ------------- %
        imLungBorder = zeros(width, height);
        [B, L, N] = bwboundaries(imMedian);

        pointNum = [];
        boundSet = {};
        threshold = 270;
        for k = 1 : length(B),
            [numOfPoints, ~] = size(B{k});
            if numOfPoints < threshold
                continue;
            end
            
            % filter the region touching image boundary
            flag = 0;
            boundary = B{k};
            for q = 1 : numOfPoints
                x = boundary(q, 1);
                y = boundary(q, 2);
                if x <= 12 || y <= 12 || x >= width-12 || y >= height-12
                    flag = 1;
                    break;
                end
            end
            
            if flag == 1
                continue;
            end
            
            % filter flat region
            wt = 60;
            w1 = max(boundary(:,1)) - min(boundary(:,1));
            w2 = max(boundary(:,2)) - min(boundary(:,2));
            if w1 < wt || w2 < wt
                continue;
            end
            
            boundSet{end+1} = B{k};
            pointNum(end+1) = numOfPoints;
        end
       
        % filter the big circle contain two lung region
        flag = 0;  
        for k = 1 : numel(boundSet)
            
            min_left  =  min(boundSet{k}(:,2));
            max_right =  max(boundSet{k}(:,2));
            min_up    =  min(boundSet{k}(:,1));
            max_down  =  max(boundSet{k}(:,1));
            
            for i = 1 : numel(boundSet)
                if i == k
                    continue;
                end
                
                min_l = min(boundSet{i}(:,2));
                max_r = max(boundSet{i}(:,2));
                min_u = min(boundSet{i}(:,1));
                max_d = max(boundSet{i}(:,1));
                if min_l > min_left && max_r < max_right &&...
                        min_u > min_up && max_d < max_down
                    flag = 1;
                    break;
                end
            end
            
            if flag == 1
                ind = k;
                break;
            end
        end
        
        if flag == 1
            boundSet(ind) = [];
        end
        
        % draw the outline of the lung region
        for k = 1 : numel(boundSet)
           boundary = boundSet{k};
           [numOfPoints, ~] = size(boundary);
           for q = 1 : numOfPoints
               y = boundary(q, 2);
               x = boundary(q, 1);
               imLungBorder(x, y) = 1;
           end
        end
        
        imLungBorder = double(255 * im2bw(imLungBorder));
        imshow(imLungBorder);
        % ------------- Outlining algorithm ------------- %

        % Flood Filling Algorithm
        se = strel('sphere', 8);
        imLungRegion = im2bw(imfill(imLungBorder));
        imLungRegion = imerode(imLungRegion, se);
        se = strel('sphere', 4);
        imLungRegion = imdilate(imLungRegion, se);

        % Extract lung region
        imLungExtract = uint8(imLungRegion) .* image8;
        
        % filename = [newPath, slicename, '_bp.bmp'];
        % imwrite(bitplane, filename);
        % filename = [newPath, slicename, '_ero.bmp'];
        % imwrite(imEro, filename);
        % filename = [newPath, slicename, '_med.bmp'];
        % imwrite(imMedian, filename);
        % filename = [newPath, slicename, '_dil.bmp'];
        % imwrite(imDil, filename);
        % filename = [newPath, slicename, '_bor.bmp'];
        % imwrite(imLungBorder, filename);
        % filename = [newPath, slicename, '_ext.bmp'];
        % imwrite(imLungExtract, filename);
        
        filename = [newPath, slicename, '.bmp'];
        imwrite(imLungExtract, filename);
    end
    disp(['process ', num2str(ki-3), ' patient: ', num2str(etime(clock, t1)), ' sec']);
end

disp('finish lung region extraction');
disp(['lre takes time: ', num2str(etime(clock, t1)), ' sec']);

    % Calculate a score for an image according its quality
    function score = Score(Im)
        
        [w, h] = size(Im);
        
        count = 0;
        all = 0;
        r2 = (h/2 - 1)^2;
        Cx = w/2; Cy = h/2;
        
        % denoi = wiener2(Im, [5, 5]);
        Edge = edge(Im, 'canny');
        
        X1 = 105; X2 = 420;
        Y1 = 100; Y2 = 210; Y3 = 310; Y4 = 420;
        % UpX = 125; DownX = 450;
        
        for x = 1 : w
            for y = 1 : h
                dist = (x - Cx)^2 + (y - Cy)^2;
                if dist > r2
                    continue;
                end
                
                all = all + 1;
                if Edge(x, y) == 1
                    if (x > X1 && x < X2 && y > Y1 && y < Y2) ||...
                            (x > X1 && x < X2 && y > Y3 && y < Y4)
                        count = count + 0.25;
                    else
                        count = count + 1;
                    end
                end
            end
        end
        
        score = count / all;
    end

    % Calculate dark percentage of an image
    function percentage = Ratio(Im)
        counter = 0;
        cAll = 0;
        radius = 240;
        r2 = radius * radius;
        
        [w, h] = size(Im);
        UpX = 110;
        DownX = 425;
        Cx = w/2; Cy = h/2;
        for x = UpX : DownX
            for y = Cy - radius : Cy + radius
                dist = (x - Cx) * (x - Cx) + (y - Cy) * (y - Cy);
                if dist > r2
                    continue;
                else
                    cAll = cAll + 1;
                    if Im(x, y) == 0
                        counter = counter + 1;
                    end
                end
            end
        end
        
        percentage = counter / cAll;
        if percentage < 0.5
            percentage = 1 - percentage;
        end
    end

end
