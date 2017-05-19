clear;clc
% Read images
img{1,1} = imread('HW3_images/image11.png');
img{1,2} = imread('HW3_images/image12.png');
img{2,1} = imread('HW3_images/image21.png');
img{2,2} = imread('HW3_images/image22.png');
img{3,1} = imread('HW3_images/image31.png');
img{3,2} = imread('HW3_images/image32.png');
img{4,1} = imread('HW3_images/image41.png');
img{4,2} = imread('HW3_images/image42.png');
img{5,1} = imread('HW3_images/image51.png');
img{5,2} = imread('HW3_images/image52.png');

% After manually select points %
% Store points
manPairImg1 = {[356 412;223 165;152 355;46 390;517 428;140 470;850 502;361 276;495 62;962 534],...
               [375 410;258 165;185 356;89 392;530 429;173 470;857 505;384 280;507 64;992 540]};
manPairImg2 = {[349 138;382 265;526 234;184 254;74 536;684 377;604 440;65 197;532 166;310 8],...
               [387 137;410 264;554 234;212 253;73 537;707 376;627 440;98 197;567 166;333 9]};
manPairImg3 = {[34 101;48 26;139 4;233 64;21 169;62 327;177 304;239 187;123 189;237 136],...
               [22 102;20 25;113 3;213 66;11 172;57 331;173 304;229 188;120 188;226 137]};
manPairImg4 = {[239 98;108 201;279 160;151 157;36 11;96 36;241 44;291 48;54 82;61 73],...
               [233 97;113 199;278 158;151 155;33 11;97 36;234 44;282 48;50 82;55 72]};
manPairImg5 = {[386 113;152 189;66 56;78 126;113 180;278 64;171 27;312 131;205 155;254 193],...
               [351 112;117 190;30 56;42 126;78 182;243 63;136 27;278 131;200 153;237 193]};

% Estimate fundamental matrix
F_man_img{1} = estimateFundamentalMatrix(manPairImg1{1}, manPairImg1{2},'Method','Norm8Point');
F_man_img{2} = estimateFundamentalMatrix(manPairImg2{1}, manPairImg2{2},'Method','Norm8Point');
F_man_img{3} = estimateFundamentalMatrix(manPairImg3{1}, manPairImg3{2},'Method','Norm8Point');
F_man_img{4} = estimateFundamentalMatrix(manPairImg4{1}, manPairImg4{2},'Method','Norm8Point');
F_man_img{5} = estimateFundamentalMatrix(manPairImg5{1}, manPairImg5{2},'Method','Norm8Point');

% Detect 100 SURF interest points
for m=1:5
    for n=1:2
        img_gray{m,n} = rgb2gray(img{m,n});
        SURFPoints{m,n} = detectSURFFeatures(img_gray{m,n});
        [SURFFeatures{m,n}, SURFPoints{m,n}] = extractFeatures(img_gray{m,n}, SURFPoints{m,n});
        selected_Points{m,n} = selectStrongest(SURFPoints{m,n}, 100);
    end
end

% Compute w vector
for m=1:5
    for n=1:2
        Coords{m,n} = selected_Points{m,n}.Location;
    end
end
for m=1:5
    for i=1:100
        for j=1:100
            dis = sqrt((Coords{m,1}(i,1)-Coords{m,2}(j,1))^2 + (Coords{m,1}(i,2)-Coords{m,2}(j,2))^2);
            if dis < 20
                w{m}(i,j) = exp(-dis);
            else
                w{m}(i,j) = 0;
            end
        end
    end
    w_vec{m} = w{m}(:);
end

% find z with binary numbers
for m=1:5
    z_hat{m} = w_vec{m}/norm(w_vec{m});
    threashold = 1.0e-6;
    for i=1:10000
        if z_hat{m}(i)<=threashold
            z{m}(i,:) = 0;
        else
            z{m}(i,:) = 1;
        end
    end
end

% select 30 best pairs
for m=1:5
    z_matrix{m} = reshape(z{m},100,100);
    cnt = 1;
    for i = 1:100
        for j = 1:100
            if z_matrix{m}(i,j)==1
                xiyi{m}(cnt,:) = Coords{m,1}(i,:);
                xjyj{m}(cnt,:) = Coords{m,2}(j,:);
                cnt = cnt + 1;
            end
        end
    end
    for Size = 1:cnt-1
        cal_rst{m}(Size) = [xjyj{m}(Size,:),1] * F_man_img{m} * [xiyi{m}(Size,:),1]';
    end
    [cal_rst_sorted{m},Index{m}] = sort(abs(cal_rst{m}));
    xiyi_sorted{m}=xiyi{m}(Index{m},:);
    xjyj_sorted{m}=xjyj{m}(Index{m},:);
    selected_xiyi{m} = xiyi_sorted{m}(1:30,:);
    selected_xjyj{m} = xjyj_sorted{m}(1:30,:);
end

% Merge two groups of pairs, calculate F again
newPairsImg1{1} = vertcat(manPairImg1{1},selected_xiyi{1});
newPairsImg1{2} = vertcat(manPairImg1{2},selected_xjyj{1});
newPairsImg2{1} = vertcat(manPairImg2{1},selected_xiyi{2});
newPairsImg2{2} = vertcat(manPairImg2{2},selected_xjyj{2});
newPairsImg3{1} = vertcat(manPairImg3{1},selected_xiyi{3});
newPairsImg3{2} = vertcat(manPairImg3{2},selected_xjyj{3});
newPairsImg4{1} = vertcat(manPairImg4{1},selected_xiyi{4});
newPairsImg4{2} = vertcat(manPairImg4{2},selected_xjyj{4});
newPairsImg5{1} = vertcat(manPairImg5{1},selected_xiyi{5});
newPairsImg5{2} = vertcat(manPairImg5{2},selected_xjyj{5});
newPairsImg = {newPairsImg1; newPairsImg2; newPairsImg3; newPairsImg4; newPairsImg5};

F_cal_img{1} = estimateFundamentalMatrix(newPairsImg1{1}, newPairsImg1{2});
F_cal_img{2} = estimateFundamentalMatrix(newPairsImg2{1}, newPairsImg2{2});
F_cal_img{3} = estimateFundamentalMatrix(newPairsImg3{1}, newPairsImg3{2});
F_cal_img{4} = estimateFundamentalMatrix(newPairsImg4{1}, newPairsImg4{2});
F_cal_img{5} = estimateFundamentalMatrix(newPairsImg5{1}, newPairsImg5{2});

% First group of points & epilolars
for m = 1:5
    plotPoint = [newPairsImg{m}{1}(1,1) newPairsImg{m}{1}(1,2)];
    plotLine1 = epipolarLine(F_man_img{m}',plotPoint);
    plotLine2 = epipolarLine(F_cal_img{m}',plotPoint);
    points1 = lineToBorderPoints(plotLine1, size(img{m,2}));
    points2 = lineToBorderPoints(plotLine2, size(img{m,2}));
    figure
    subplot(1,2,1);
    imshow(img{m,1});
    hold on
    plot(plotPoint(1), plotPoint(2),'g*');
    subplot(1,2,2);
    imshow(img{m,2});
    hold on
    line(points1(:, [1,3])', points1(:, [2,4])','Color',[1.,0.,0.],'LineWidth',1.5);
    line(points2(:, [1,3])', points2(:, [2,4])','Color',[0.,1.,1.],'LineWidth',1.5);
    annotation(gcf,'textbox','String',{'Result Images for Step #3'},'FontSize',12,'Position',[0.325 0.85 0.5 0.05],'edgecolor',get(gcf,'color'));
end

% Second group of points & epilolars
for m = 1:5
    plotPoint = [newPairsImg{m}{2}(8,1) newPairsImg{m}{2}(8,2)];
    plotLine1 = epipolarLine(F_man_img{m}',plotPoint);
    plotLine2 = epipolarLine(F_cal_img{m}',plotPoint);
    points1 = lineToBorderPoints(plotLine1, size(img{m,1}));
    points2 = lineToBorderPoints(plotLine2, size(img{m,1}));
    figure
    subplot(1,2,2);
    imshow(img{m,2});
    hold on
    plot(plotPoint(1), plotPoint(2),'g*');
    subplot(1,2,1);
    imshow(img{m,1});
    hold on
    line(points1(:, [1,3])', points1(:, [2,4])','Color',[1.,0.,0.],'LineWidth',1.5);
    line(points2(:, [1,3])', points2(:, [2,4])','Color',[0.,1.,1.],'LineWidth',1.5);
    annotation(gcf,'textbox','String',{'Result Images for Step #4'},'FontSize',12,'Position',[0.325 0.85 0.5 0.05],'edgecolor',get(gcf,'color'));
end

% Plot epipoles
for m=1:5
    % {m,1} for manual
    [V,D] = eig(F_man_img{m});
    min_val=min([D(1,1),D(2,2),D(3,3)]);
    [row,col]=find(D==min_val);
    e_1_hat = V(:,col);
    e_1{m,1} = e_1_hat/e_1_hat(3,:);
    [V,D] = eig(F_man_img{m}');
    min_val=min([D(1,1),D(2,2),D(3,3)]);
    [row,col]=find(D==min_val);
    e_2_hat = V(:,col);
    e_2{m,1} = e_2_hat/e_2_hat(3,:);
    % {m,2} for calculate
    [V,D] = eig(F_cal_img{m});
    min_val=min([D(1,1),D(2,2),D(3,3)]);
    [row,col]=find(D==min_val);
    e_1_hat = V(:,col);
    e_1{m,2} = e_1_hat/e_1_hat(3,:);
    [V,D] = eig(F_cal_img{m}');
    min_val=min([D(1,1),D(2,2),D(3,3)]);
    [row,col]=find(D==min_val);
    e_2_hat = V(:,col);
    e_2{m,2} = e_2_hat/e_2_hat(3,:);
    
% [isIn, epipole] = isEpipoleInImage(F_man_img{m}, size(img{1,1}));
% 
%     e_1{m,1} = [epipole(1), epipole(2)];
% 
% [isIn, epipole] = isEpipoleInImage(F_man_img{m}', size(img{1,1}));
% 
%     e_2{m,1} = [epipole(1), epipole(2)];
% 
%     
% [isIn, epipole] = isEpipoleInImage(F_cal_img{m}, size(img{1,1}));
% 
%     e_1{m,2} = [epipole(1), epipole(2)];
% 
%     
% [isIn, epipole] = isEpipoleInImage(F_cal_img{m}', size(img{1,1}));
% 
%     e_2{m,2} = [epipole(1), epipole(2)];


    figure
    subplot(1,2,1);
    imshow(img{m,1});
    hold on
    plot(e_1{m,1}(1), e_1{m,1}(2),'go');
    plot(e_1{m,2}(1), e_1{m,2}(2),'r*');
    subplot(1,2,2);
    imshow(img{m,2});
    hold on
    plot(e_2{m,1}(1), e_2{m,1}(2),'go');
    plot(e_2{m,2}(1), e_2{m,2}(2),'r*');
    annotation(gcf,'textbox','String',{'Result Images for Step #5'},'FontSize',12,'Position',[0.325 0.85 0.5 0.05],'edgecolor',get(gcf,'color'));
end