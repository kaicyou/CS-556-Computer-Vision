clear all;clc;close all
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
manPairImg1L1 = {[510 89;388 150;308 188;257 214;220 230;701 462;520 425;402 396;318 381;378 618],...
                 [519 90;405 153;329 190;283 215;248 233;702 464;528 428;415 396;339 381;392 617]};
manPairImg1L2 = {[241 7;305 26;350 40;218 53;263 65;139 61;174 138;118 148;147 16;111 99],...
                 [275 16;339 33;387 45;253 62;297 72;178 70;214 146;159 154;187 26;154 106]};
manPairImg2L1 = {[113 399;151 392;201 387;203 366;127 361;87 358;41 359;11 389;113 410;119 378],...
                 [117 399;155 391;207 386;211 365;137 360;99 357;52 358;16 388;114 410;125 377]};
manPairImg2L2 = {[606 439;684 377;424 363;340 329;593 309;426 276;617 243;215 459;476 392;293 226],...
                 [623 440;706 376;448 362;362 329;619 308;455 275;647 242;231 459;496 391;323 225]};
manPairImg3L1 = {[166 170;193 156;165 217;157 281;201 187;219 145;230 192;204 246;184 304;238 187],...
                 [161 169;186 157;160 216;152 280;194 186;211 144;220 192;196 245;177 304;229 186]};
manPairImg3L2 = {[83 169;59 156;37 144;84 216;60 199;38 184;82 255;61 247;41 231;45 279],...
                 [78 170;52 157;28 146;79 217;53 202;28 187;77 257;53 250;32 234;35 283]};
manPairImg4L1 = {[11 7;36 10;14 16;32 18;14 39;32 40;41 64;22 40;42 81;22 60],...
                 [7 7;32 10;10 16;29 18;11 39;29 40;37 64;18 40;38 81;19 60]};
manPairImg4L2 = {[158 204;150 182;108 199;235 162;184 170;106 215;277 159;198 150;123 158;20 182],...
                 [162 203;153 180;112 198;236 160;186 168;111 215;276 157;196 149;124 157;23 183]};
manPairImg5L1 = {[321 75;288 78;347 72;387 68;323 36;171 48;381 159;408 192;425 121;293 96],...
                 [287 75;255 79;312 72;351 68;290 36;137 48;347 159;374 192;390 121;260 96]};
manPairImg5L2 = {[192 199;208 202;224 195;205 154;205 187;165 183;208 119;193 142;246 160;205 89],...
                 [185 196;202 200;216 194;199 153;199 186;157 181;203 118;189 139;240 159;203 86]};
manPairs = {manPairImg1L1,manPairImg1L2,manPairImg2L1,manPairImg2L2,manPairImg3L1,manPairImg3L2,...
            manPairImg4L1,manPairImg4L2,manPairImg5L1,manPairImg5L2};             
% calculate homography matrix
for m=1:10
    npoints = 10;
    x = manPairs{m}{1}(:,1);
    y = manPairs{m}{1}(:,2);
    xd = manPairs{m}{2}(:,1);
    yd = manPairs{m}{2}(:,2);
    A = zeros(2*npoints,9);
    
    for i=1:npoints
        A(2*i-1,:) = [x(i),y(i),1,0,0,0,-x(i)*xd(i),-xd(i)*y(i),-xd(i)];
        A(2*i,:) = [0,0,0,x(i),y(i),1,-x(i)*yd(i),-yd(i)*y(i),-yd(i)];
    end
    
    if npoints==4
        h = null(A);
    else
        [U,S,V] = svd(A);
        h = V(:,9);
    end
    H_0{m} = reshape(h,3,3);
end

% Get 10 N_SURF points
load hm3.mat
for m=1:10
    mm = ceil(m/2);
    z_matrix{mm} = reshape(z{mm},100,100);
    cnt = 1;
    for i = 1:100
        for j = 1:100
            if z_matrix{mm}(i,j)==1
                xiyi{mm}(cnt,:) = Coords{mm,1}(i,:);
                xjyj{mm}(cnt,:) = Coords{mm,2}(j,:);
                cnt = cnt + 1;
            end
        end
    end
    for Size = 1:cnt-1
        cal_rst{m}(Size) = sum([xjyj{mm}(Size,:),1]' - H_0{m} * [xiyi{mm}(Size,:),1]');
    end
    [cal_rst_sorted{m},Index{m}] = sort(abs(cal_rst{m}));
    xiyi_sorted{m}=xiyi{mm}(Index{m},:);
    xjyj_sorted{m}=xjyj{mm}(Index{m},:);
    selected_xiyi{m} = xiyi_sorted{m}(1:10,:);
    selected_xjyj{m} = xjyj_sorted{m}(1:10,:);
end

% Calculate new H
newPairsImg1L1{1} = vertcat(manPairImg1L1{1},selected_xiyi{1});
newPairsImg1L1{2} = vertcat(manPairImg1L1{2},selected_xjyj{1});
newPairsImg1L2{1} = vertcat(manPairImg1L2{1},selected_xiyi{2});
newPairsImg1L2{2} = vertcat(manPairImg1L2{2},selected_xjyj{2});
newPairsImg2L1{1} = vertcat(manPairImg2L1{1},selected_xiyi{3});
newPairsImg2L1{2} = vertcat(manPairImg2L1{2},selected_xjyj{3});
newPairsImg2L2{1} = vertcat(manPairImg2L2{1},selected_xiyi{4});
newPairsImg2L2{2} = vertcat(manPairImg2L2{2},selected_xjyj{4});
newPairsImg3L1{1} = vertcat(manPairImg3L1{1},selected_xiyi{5});
newPairsImg3L1{2} = vertcat(manPairImg3L1{2},selected_xjyj{5});
newPairsImg3L2{1} = vertcat(manPairImg3L2{1},selected_xiyi{6});
newPairsImg3L2{2} = vertcat(manPairImg3L2{2},selected_xjyj{6});
newPairsImg4L1{1} = vertcat(manPairImg4L1{1},selected_xiyi{7});
newPairsImg4L1{2} = vertcat(manPairImg4L1{2},selected_xjyj{7});
newPairsImg4L2{1} = vertcat(manPairImg4L2{1},selected_xiyi{8});
newPairsImg4L2{2} = vertcat(manPairImg4L2{2},selected_xjyj{8});
newPairsImg5L1{1} = vertcat(manPairImg5L1{1},selected_xiyi{9});
newPairsImg5L1{2} = vertcat(manPairImg5L1{2},selected_xjyj{9});
newPairsImg5L2{1} = vertcat(manPairImg5L2{1},selected_xiyi{10});
newPairsImg5L2{2} = vertcat(manPairImg5L2{2},selected_xjyj{10});
newPairs = {newPairsImg1L1;newPairsImg1L2;newPairsImg2L1;newPairsImg2L2;...
            newPairsImg3L1;newPairsImg3L2;newPairsImg4L1;newPairsImg4L2;...
            newPairsImg5L1;newPairsImg5L2};

for m=1:10
    npoints = 20;
    x = newPairs{m}{1}(:,1);
    y = newPairs{m}{1}(:,2);
    xd = newPairs{m}{2}(:,1);
    yd = newPairs{m}{2}(:,2);
    A = zeros(2*npoints,9);
    
    for i=1:npoints
        A(2*i-1,:) = [x(i),y(i),1,0,0,0,-x(i)*xd(i),-xd(i)*y(i),-xd(i)];
        A(2*i,:) = [0,0,0,x(i),y(i),1,-x(i)*yd(i),-yd(i)*y(i),-yd(i)];
    end
    
    if npoints==4
        h = null(A);
    else
        [U,S,V] = svd(A);
        h = V(:,9);
    end
    H{m} = reshape(h,3,3);
end

% The new function should be:
% max [w'-f'-h1.*y1-h2.*y2]*z  s.t. ||z||_2 = 1, z:[0,1]^(100*100)
% w' is the w from hw3
% f' = [...xi*F*xj...]'
% h1 = [..0..H1*[x,y,1]'..0..]
% h2 = [..0..H2*[x,y,1]'..0..]
% y1 = [..0..1..0..] (1 at larger value)
% y2 = [..0..1..0..] (1 at larger value)

% calculate new z
for m=1:5
    threashold = 0.0045;
    cnt=1;
    H1 = H{m*2-1};
    H2 = H{m*2};
    for i=1:100
        for j=1:100
            f(cnt)=[Coords{m,1}(i,:),1]*F_cal_img{m}*[Coords{m,2}(j,:),1]';
            h1(cnt) = sum(H1*[Coords{m,1}(i,:),1]' + H1*[Coords{m,2}(j,:),1]');
            h2(cnt) = sum(H2*[Coords{m,1}(i,:),1]' + H2*[Coords{m,2}(j,:),1]');
            if h1(cnt) < 0.5
                y1(cnt) = 1;
            else
                y1(cnt) = 0;
            end
            if h2(cnt) < 0.5
                y2(cnt) = 1;
            else
                y2(cnt) = 0;
            end
            cnt = cnt + 1;
        end
    end
    temp = w_vec{m}-f'-(h1.*y1)'-(h2.*y2)';
    temp_z{m} = temp/norm(temp);
    for i=1:10000
        if temp_z{m}(i)<=threashold
            new_z{m}(i,:) = 1;
        else
            new_z{m}(i,:) = 0;
        end
    end
end

% Compare new z with z
for m=1:5
    for n=1:10000
        if (new_z{m}(n)==1) && (z{m}(n)==1)
            Compare_Result{m}(n) = 1;
        else
            Compare_Result{m}(n) = 0;
        end
    end
    SamePoints{m} = find(Compare_Result{m}==1);
end