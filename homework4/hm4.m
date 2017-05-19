clear;clc;close all

%% Read images & finding boundaries
images_name = dir('original');
images = cell(1,1400);
boundaries = cell(1,1400);
for i = 3:1402
    count = 0;
    str = strcat('original\',images_name(i).name);
    images{i-2} = imread(str);
    if((i==383)||(i==386)||(i==900)||(i==1291))
        continue;
    end
    ttempbound = bwboundaries(images{i-2});
    tempbound = unique(ttempbound{1,1},'rows');
    length = size(tempbound,1);
    numPoints = 30;
    jump_step = floor(length/numPoints);
    for n = 1:numPoints
        count = count + 1;
        boundaries{i-2}(count,:) = tempbound((n-1)*jump_step+5,:);
    end
end

%boundaries{381}
tttemp = bwboundaries(images{381});
ttemp = tttemp{3};
temp = unique(ttemp,'rows');
length = size(temp,1);
jump_step = floor(length/numPoints);
count = 0;
for n = 1:numPoints
    count = count + 1;
    boundaries{381}(count,:) = temp((n-1)*jump_step+5,:);
end
%boundaries{384}
tttemp = bwboundaries(images{384});
ttemp = tttemp{3};
temp = unique(ttemp,'rows');
length = size(temp,1);
jump_step = floor(length/numPoints);
count = 0;
for n = 1:numPoints
    count = count + 1;
    boundaries{384}(count,:) = temp((n-1)*jump_step+5,:);
end
%boundaries{898}
tttemp = bwboundaries(images{898});
ttemp = tttemp{2};
temp = unique(ttemp,'rows');
length = size(temp,1);
jump_step = floor(length/numPoints);
count = 0;
for n = 1:numPoints
    count = count + 1;
    boundaries{898}(count,:) = temp((n-1)*jump_step+5,:);
end
%boundaries{1289}
tttemp = bwboundaries(images{1289});
ttemp = tttemp{3};
temp = unique(ttemp,'rows');
length = size(temp,1);
jump_step = floor(length/numPoints);
count = 0;
for n = 1:numPoints
    count = count + 1;
    boundaries{1289}(count,:) = temp((n-1)*jump_step+5,:);
end

%% beam angles
beam_angles = cell(1,1400);
for i=1:1400
        fprintf('Image %d\n',i);
    bound_num = size(boundaries{i},1);
    for k = 1:bound_num
        cnt = 0;
        for k1 = 1:(bound_num-1)
            if(k1==k)
                continue;
            end
            for k2 = (k1+1):bound_num
                if(k2==k)
                    continue;
                end
                a = norm(boundaries{i}(k2,:) - boundaries{i}(k,:));
                b = norm(boundaries{i}(k1,:) - boundaries{i}(k,:));
                c = norm(boundaries{i}(k2,:) - boundaries{i}(k1,:));
                ang1 = real(acos((a^2+b^2-c^2)/(2*a*b))/pi*180);
                ang2 = real(acos((a^2+c^2-b^2)/(2*a*c))/pi*180);
                ang3 = real(acos((c^2+b^2-a^2)/(2*c*b))/pi*180);
                cnt=cnt+1;
                angles(cnt,:) = [ang1 ang2 ang3];
            end
        end
        temp_angles = reshape(angles,[],1);
        num_angles = size(temp_angles,1);
        temp_beam_angles(k,:) = zeros(1,61);
        for n =1:num_angles
            idx = floor(temp_angles(n)/3)+1;
            temp_beam_angles(k,idx) = temp_beam_angles(k,idx) + 1;
        end
        beam_angles{i}(k,1:59) = temp_beam_angles(k,1:59);
        beam_angles{i}(k,60) = temp_beam_angles(k,60)+temp_beam_angles(k,61);
    end
end

%% Cost Matrix & DTW
Path1_all = cell(1400,1400);
Path2_all = cell(1400,1400);
d = zeros(1400,1400);
for i=1:1400
                    fprintf('Loop i=%d\n',i);
    for j=1:1400
        beam_k = beam_angles{i};
        beam_l = beam_angles{j};
        for m = 1:30
            for n = 1:30
                b_k = beam_k(m,:);
                b_l1 = beam_l(n,:);
                b_l2 = beam_l(31-n,:);
                C1(31-m,n) = sum((b_k - b_l1).^ 2);
                C2(31-m,n) = sum((b_k - b_l2).^ 2);
            end
        end
        %C1_all{i,j} = C1;
        %C2_all{i,j} = C2;
        D1(30,1) = C1(30,1);
        D2(30,1) = C2(30,1);
        for n = 2:30
            D1(30,n) = D1(30,n-1)+C1(30,n);
            D1(31-n,1) = D1(32-n,1)+C1(31-n,1);
            D2(30,n) = D2(30,n-1)+C2(30,n);
            D2(31-n,1) = D2(32-n,1)+C2(31-n,1);
        end
        for p=2:30
            for q=2:30
                D1(31-p,q) = C1(31-p,q)+ min([D1(32-p,q),D1(31-p,q-1),D1(32-p,q-1)]);
                D2(31-p,q) = C2(31-p,q)+ min([D2(32-p,q),D2(31-p,q-1),D2(32-p,q-1)]);
            end
        end
        [tmp1, y1] = min(D1(1,:));
        [tmp2, y2] = min(D2(1,:));
        Path1 = [1 y1];
        Path2 = [1 y2];
        x1 = 1;
        x2 = 1;
        while  x1 ~= 30 && y1 ~= 1 && x2 ~= 30 && y2 ~= 1
            if x1 == 30 && y1 == 1
                % do nothing
            elseif x1 == 30
                y1 = y1 - 1;
                Path1 = vertcat(Path1, [x1 y1]);
            elseif y1 == 1
                x1 = x1 + 1;
                Path1 = vertcat(Path1, [x1 y1]);
            else
                [val1, index1] = min([D1( x1 ,y1 - 1),D1(x1 + 1,y1),D1(x1 + 1,y1 - 1)]);
                switch index1
                    case 1
                        y1 = y1 - 1;
                        pos1 = [x1 y1];
                    case 2
                        x1 = x1 + 1;
                        pos1 = [x1 y1];
                    case 3
                        y1 = y1 - 1;
                        x1 = x1 + 1;
                        pos1 = [x1 y1];
                end
                Path1 = vertcat(Path1, pos1);
            end
            if x2 == 30 && y2 == 1
                % do nothing
            elseif x2 == 30
                y2 = y2 - 1;
                Path2 = vertcat(Path2, [x2 y2]);
            elseif y2 == 1
                x2 = x2 + 1;
                Path2 = vertcat(Path2, [x2 y2]);
            else
                [val2, index2] = min([D2(x2,y2 - 1),D2(x2 + 1,y2),D2(x2 + 1,y2 - 1)]);
                switch index2
                    case 1
                        y2 = y2 - 1;
                        pos2 = [x2 y2];
                    case 2
                        x2 = x2 + 1;
                        pos2 = [x2 y2];
                    case 3
                        y2 = y2 - 1;
                        x2 = x2 + 1;
                        pos2 = [x2 y2];
                end
                Path2 = vertcat(Path2, pos2);
            end
        end
        %D1_all{i,j} = D1;
        %D2_all{i,j} = D2;
        Path1_all{i,j} = Path1; % store the path of the minimum cost path A 
        Path2_all{i,j} = Path2; % store the path of the minimum cost path B 
        d(i,j) = min(tmp1,tmp2);
    end
end

%% Shape retrieval
for n = 1:1400
    objects = ceil(n/20);
    images_name(n+2).cat = objects;
end
Error_K = cell(1, 1400);
for i = 1:1400
    goal_name = images_name(i+2).cat;
    [test,index] = sort(d(i,:),'ascend');
    sort_res = [test;index];
    for K = 1:19
        error_num = 0;
        for m = 2:K+1
            test_index = sort_res(2,m);
            test_name = images_name(test_index+2).cat;
            if(test_name ~= goal_name)
                error_num = error_num + 1;
            end
        end
        Error_K{i}(K) = error_num / K;
    end
end

for o = 1:70
    for K = 1:19
        Error_o_K = 0;
        for f = 1:20
            error_index = (o-1)*20 + f;
            Error_o_K = Error_o_K + Error_K{error_index}(K);
        end
        ErrorPoints(K) = Error_o_K/20;
    end
    [minVal, minIdx] = min(ErrorPoints);
    figure
    plot(1:19, ErrorPoints(1:19),'b--*');
    hold on
    plot(minIdx, minVal, 'ro');
end

for K = 1:19
    Error_o_f_K = 0;
    for idx = 1:1400
        Error_o_f_K = Error_o_f_K + Error_K{idx}(K);
    end
    ErrorPointsP(K) = Error_o_f_K / 1400;
end
[minValP, minIdxP] = min(ErrorPointsP);
figure
plot(1:19, ErrorPointsP(1:19),'r--*');
hold on
plot(minIdxP, minValP, 'go');
