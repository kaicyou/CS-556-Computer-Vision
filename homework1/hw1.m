clear;clc;

% STEP #1

% Scene 1
imgS1 = cell(1,8);
SURFPointsS1 = cell(1,8);
SURFFeaturesS1 = cell(1,8);
imgS1{1} = imread('Scene1/scene1.bmp');
for i=1:8
    if i>=2
        str = strcat ('Scene1/t',int2str(i-1),'.bmp');
        imgS1{i} = imread(str);
    end
    imgS1{i} = rgb2gray(imgS1{i}); 
    SURFPointsS1{i} = detectSURFFeatures(imgS1{i}, 'MetricThreshold', 500.0);
    [SURFFeaturesS1{i}, SURFPointsS1{i}] = extractFeatures(imgS1{i}, SURFPointsS1{i});
end
figure;
imshow(imgS1{1});
hold on;
plot(selectStrongest(SURFPointsS1{1}, 100));

% Scene 2
imgS2 = cell(1,4);
SURFPointsS2 = cell(1,4);
SURFFeaturesS2 = cell(1,4);
imgS2{1} = imread('Scene2/scene2.jpg');
for i=1:4
    if i>=2
        str = strcat ('Scene2/t',int2str(i-1),'.jpg');
        imgS2{i} = imread(str);
    end
    SURFPointsS2{i} = detectSURFFeatures(imgS2{i});
    [SURFFeaturesS2{i}, SURFPointsS2{i}] = extractFeatures(imgS2{i}, SURFPointsS2{i});
end
figure;
imshow(imgS2{1});
hold on;
plot(selectStrongest(SURFPointsS2{1}, 100));

% Scene 3
imgS3 = cell(1,3);
SURFPointsS3 = cell(1,3);
SURFFeaturesS3 = cell(1,3);
imgS3{1} = imread('Scene3/scene3.jpg');
for i=1:3
    if i>=2
        str = strcat ('Scene3/t',int2str(i-1),'.jpg');
        imgS3{i} = imread(str);
    end
    imgS3{i} = rgb2gray(imgS3{i}); 
    SURFPointsS3{i} = detectSURFFeatures(imgS3{i});
    [SURFFeaturesS3{i}, SURFPointsS3{i}] = extractFeatures(imgS3{i}, SURFPointsS3{i});
end
figure;
imshow(imgS3{1});
hold on;
plot(selectStrongest(SURFPointsS3{1}, 100));

% STEP #2
% Scene 1
for i = 1:7
    templatePairsS1 = matchFeatures(SURFFeaturesS1{i+1}, SURFFeaturesS1{1},'MatchThreshold',100);
    templatePointsS1 = SURFPointsS1{i+1};
    scenePointsS1 = SURFPointsS1{1};
    figure;
    showMatchedFeatures(imgS1{i+1}, imgS1{1}, templatePointsS1(templatePairsS1(:, 1), :), ...
                        scenePointsS1(templatePairsS1(:, 2), :), 'montage');
    % Get Median
    res = size(templatePairsS1);
    for m = 1:res(1)
        CoordsS1(m,:) = scenePointsS1(templatePairsS1(m,2)).Location;
    end
    CoordXS1 = CoordsS1(:, 1);
    CoordYS1 = CoordsS1(:, 2);
    MedianS1(i, :) = [median(CoordXS1), median(CoordYS1)];
end

% Scene 2
for i = 1:3
    templatePairsS2 = matchFeatures(SURFFeaturesS2{i+1}, SURFFeaturesS2{1});
    templatePointsS2 = SURFPointsS2{i+1};
    scenePointsS2 = SURFPointsS2{1};
    figure;
    showMatchedFeatures(imgS2{i+1}, imgS2{1}, templatePointsS2(templatePairsS2(:, 1), :), ...
                        scenePointsS2(templatePairsS2(:, 2), :), 'montage');
    % Get Median
    res = size(templatePairsS2);
    for m = 1:res(1)
        CoordsS2(m,:) = scenePointsS2(templatePairsS2(m,2)).Location;
    end
    CoordXS2 = CoordsS2(:, 1);
    CoordYS2 = CoordsS2(:, 2);
    MedianS2(i, :) = [median(CoordXS2), median(CoordYS2)];
end

% Scene 3
for i = 1:2
    templatePairsS3 = matchFeatures(SURFFeaturesS3{i+1}, SURFFeaturesS3{1});
    templatePointsS3 = SURFPointsS3{i+1};
    scenePointsS3 = SURFPointsS3{1};
    figure;
    showMatchedFeatures(imgS3{i+1}, imgS3{1}, templatePointsS3(templatePairsS3(:, 1), :), ...
                        scenePointsS3(templatePairsS3(:, 2), :), 'montage');
    % Get Median
    res = size(templatePairsS3);
    for m = 1:res(1)
        CoordsS3(m,:) = scenePointsS3(templatePairsS3(m,2)).Location;
    end
    CoordXS3 = CoordsS3(:, 1);
    CoordYS3 = CoordsS3(:, 2);
    MedianS3(i, :) = [median(CoordXS3), median(CoordYS3)];
end

% STEP #3
% Scene 1
SizeS1 = [90.51; 88.41; 83.49; 85.59; 84.86; 86.98; 83.45];
CenterS1 = [383 272; 214 294; 137 137; 402 204; 242 117; 418 34; 213 223];
for n = 1:10
    TPS1 = 0;
    FPS1 = 0;
    for i=1:7
        dist = sqrt((CenterS1(i,1)-MedianS1(i,1))^2+(CenterS1(i,2)-MedianS1(i,2))^2);
        if dist <= SizeS1(i) * 0.1 * n
            TPS1 = TPS1 + 1;
        else
            FPS1 = FPS1 + 1;
        end
    end
    PrecisionS1(n) = TPS1 / (TPS1 + FPS1);
    RecallS1(n) = TPS1 / 7;
end
figure;
plot(PrecisionS1, RecallS1, 'r-o');

% Scene 2
SizeS2 = [226.31; 208.04; 200.42];
CenterS2 = [350 222; 500 237; 788 246];
for n = 1:10
    TPS2 = 0;
    FPS2 = 0;
    for i=1:3
        dist = sqrt((CenterS2(i,1)-MedianS2(i,1))^2+(CenterS2(i,2)-MedianS2(i,2))^2);
        if dist <= SizeS2(i) * 0.1 * n
            TPS2 = TPS2 + 1;
        else
            FPS2 = FPS2 + 1;
        end
    end
    PrecisionS2(n) = TPS2 / (TPS2 + FPS2);
    RecallS2(n) = TPS2 / 3;
end
figure;
plot(PrecisionS2, RecallS2, 'g-*');

% Scene 3
SizeS3 = [1337.27; 1215.72];
CenterS3 = [3834 426; 1806 1633];
for n = 1:10
    TPS3 = 0;
    FPS3 = 0;
    for i=1:2
        dist = sqrt((CenterS3(i,1)-MedianS3(i,1))^2+(CenterS3(i,2)-MedianS3(i,2))^2);
        if dist <= SizeS3(i) * 0.1 * n
            TPS3 = TPS3 + 1;
        else
            FPS3 = FPS3 + 1;
        end
    end
    PrecisionS3(n) = TPS3 / (TPS3 + FPS3);
    RecallS3(n) = TPS3 / 2;
end
figure;
plot(PrecisionS3, RecallS3, 'b-+');