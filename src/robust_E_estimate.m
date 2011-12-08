%% Remove radial distortion of input pictures

% addpath rd_undistort
% load('../data/Kcalib.mat', 'rd');
% rddirundistort(rd, 'pictures/sb', 'linear_pictures/sb');

%% Load correspondencies

% using following pictures:
% 'linear_pictures/sb/IMG_5954.JPG'
% 'linear_pictures/sb/IMG_5961.JPG'
% 'linear_pictures/sb/IMG_5955.JPG'

% Load data:
% clear all;
% load seek_sparse_correspondencies-output.mat

% load('seek_sparse_correspondencies-output', 'im1', 'im2', 'im3', ...
%         'm12', 'm23', 'm31', 'pc12', 'pc23', 'pc31' ...
%         , 'pts1', 'pts2', 'pts3'  ...
%         );
% 
% addpath calibrated_p5/

%% Load calibration matrix

% load('../data/Kcalib.mat', 'K');

%%

inlier_probability = 0.6;
m = 5;  % min. number of image points correspondences determining E matrix
N = ransac_min_sample_size(0.95, inlier_probability, m);

%%
I = eye(3);

% Use all (mis)matching points
all_u1 = K\e2p(pc12(1:2,:));
all_u2 = K\e2p(pc12(3:4,:));

% Use only those points that are consistent in all three pictures
% all_u1 = [[pts1.x] ; [pts1.y]];
% all_u2 = [[pts2.x] ; [pts2.y]];
% all_u1 = K\e2p(all_u1(:,results(1,:)));
% all_u2 = K\e2p(all_u2(:,results(2,:)));

best_support = -1;
best_inl_ix = [];
best_ix = [];
bestE = [];

THR = 2; % [px]
THR = 2*THR^2;

i = 0;
while true
    % choose sample of points
    % ix = (i*m+1):(i*m+5);
    ix = (i+1):(i+5);
    u1 = all_u1(:,ix);
    u2 = all_u2(:,ix);
    
    % each sample usually gives multiple Essential matrix candidates
    Evec = calibrated_fivepoint(u1, u2);
    % E matrix candidates are stored as columns of Evec
    for j = 1:size(Evec,2)
        % we try all of them but...
        E = reshape(Evec(:,j), 3, 3)';
        % only use such candidates (E matrices) that have all the points
        % corresponding to pairs in (u1,u2) in front of both cameras; we
        % decompose such E matrix to camera pair P1, P2
        [~, ~, P1, P2] = EutoRb(E, u1, u2);
        if ~isempty(P1)
            % we reproject all points forth and back
            X = Pu2X(P1, P2, all_u1, all_u2);
            
            depths1 = depth_in_camera(X, P1);
            depths2 = depth_in_camera(X, P2);
            in_front = (depths1 > 0 & depths2 > 0);
            
            % TODO: points visibility
            v1 = e2p(p2e(K*P1*X));
            v2 = e2p(p2e(K*P2*X));
            % and compute sum of reprojection errors
            err = sum((v1 - e2p(pc12(1:2,:))).^2) + sum((v2 - e2p(pc12(3:4,:))).^2); % TODO use different error function?
            inl_ix = err < THR & in_front;
            support = sum(inl_ix);
            
            if (support > best_support)
                best_support = support;
                bestE = E;
                best_inl_ix = inl_ix;
                best_ix = ix;
            end
        end
    end
    
    i = i + 1;
    if (i > N) break; end
end

%%

E = bestE;
u1 = all_u1(:,best_ix);
u2 = all_u2(:,best_ix);
[R, b, P1, P2] = EutoRb(E, u1, u2);

% reprojection error
X = Pu2X(P1, P2, all_u1, all_u2);

depths1 = depth_in_camera(X, P1);
depths2 = depth_in_camera(X, P2);
in_front = (depths1 > 0 & depths2 > 0);

v1 = e2p(p2e(P1*X));
v2 = e2p(p2e(P2*X));
err = vlen(v1 - all_u1) + vlen(v2 - all_u2); % TODO: FIXME

% inliers_ix = err < mean(err); % FIXME: compute the threshold instead of fixed one

%%

v1 = K*all_u1;
v2 = K*all_u2;

figure(1); image(im1); axis equal tight off; hold on;
% inliers in this picture
plot(v1(1,best_inl_ix), v1(2,best_inl_ix), 'or', 'markerfacecolor', 'r');
% outliers in this picture
plot(v1(1,~best_inl_ix & in_front), v1(2,~best_inl_ix & in_front), 'ok', 'markerfacecolor', 'k');
% plot lines connecting points in this picture with points in the other one
plot([v1(1,~best_inl_ix & in_front); v2(1,~best_inl_ix & in_front)], ...
    [v1(2,~best_inl_ix & in_front); v2(2,~best_inl_ix & in_front)], '-k', 'LineWidth', 2);
plot([v1(1,best_inl_ix); v2(1,best_inl_ix)], ...
    [v1(2,best_inl_ix); v2(2,best_inl_ix)], '-r', 'LineWidth', 2);
hold off;

figure(2); image(im2); axis equal tight off; hold on;
% inliers in this picture
plot(v2(1,best_inl_ix), v2(2,best_inl_ix), 'or', 'markerfacecolor', 'r');
% outliers in this picture
plot(v2(1,~best_inl_ix & in_front), v2(2,~best_inl_ix & in_front), 'ok', 'markerfacecolor', 'k');
% plot lines connecting points in this picture with points in the other one
plot([v1(1,~best_inl_ix & in_front); v2(1,~best_inl_ix & in_front)], ...
    [v1(2,~best_inl_ix & in_front); v2(2,~best_inl_ix & in_front)], '-k', 'LineWidth', 2);
plot([v1(1,best_inl_ix); v2(1,best_inl_ix)], ...
    [v1(2,best_inl_ix); v2(2,best_inl_ix)], '-r', 'LineWidth', 2);
hold off;

%%

F = K'\E/K;

xxx = best_inl_ix & in_front

epipolar_ix = xxx(1,1:10);
v1 = v1(:,epipolar_ix);
v2 = v2(:,epipolar_ix);

V1 = p2e(v1);
V2 = p2e(v2);

%%

figure(1); hold on;
lines = F'*v2;
for i = 1:size(lines,2)
    l = lines(:,i);
    plot(V1(1,i), V1(2,i), 'x', 'color', color_hash(i), 'MarkerSize', 20, 'markerfacecolor', color_hash(i), 'LineWidth', 4);
    draw_line_into_axes(l, color_hash(i), 5);
end
hold off;

figure(2); hold on;
lines = F*v1;
for i = 1:size(lines,2)
    l = lines(:,i);
    plot(V2(1,i), V2(2,i), 'x', 'color', color_hash(i), 'MarkerSize', 20, 'markerfacecolor', color_hash(i), 'LineWidth', 4);
    draw_line_into_axes(l, color_hash(i), 5);
end
hold off;

% show_cameras;

%%

figure(3)
clf; hold on;

depths1 = depth_in_camera(X, P1);
depths2 = depth_in_camera(X, P2);

in_front = (depths1 > 0 & depths2 > 0);
x1 = round(p2e(K*P1*X));
ok = (x1(1,:) <= 3264 & x1(1,:) >= 1 & x1(2,:) <= 2448 & x1(2,:) >= 1 & in_front);
ok_ix = find(ok);
x1 = x1(:,ok);
colors = zeros(3,sum(ok));
for i = 1:sum(ok)
    ix = ok_ix(i);
    colors(:,i) = im1(x1(2,i), x1(1,i), :);
    c = colors(:,i);
    plot3(X(1,ix), X(2,ix), X(3,ix), 'o', 'color', c'/255, 'markerfacecolor', c'/255, 'markersize', 4);
end

hold off;

%plot3(X(1,:), X(2,:), X(3,:), '.');



