%% Toolbox path

addpath ../
addpath ../toolbox/
addpath ../calibrated_p5/

%% Remove radial distortion of input pictures

% addpath rd_undistort
% load('../../data/Kcalib.mat', 'rd');
% rddirundistort(rd, '../pictures/sb', '../linear_pictures/sb');

%% Load correspondencies

% using following pictures:
% '../linear_pictures/sb/IMG_5954.JPG'
% '../linear_pictures/sb/IMG_5961.JPG'
% '../linear_pictures/sb/IMG_5955.JPG'

% Load data:
% clear all;
% load seek_sparse_correspondencies-output.mat

load('../../data/images_and_sparse_correspondences.mat', 'images', 'm', 'pc');

%% Load calibration matrix

load('../../data/Kcalib.mat', 'K');

%% Estimate the epipolar geometry

% choose simply first two cameras
i1 = 2;
i2 = 6;
pc = pc{i1,i2};

% The useful work is done in this function
[E, R, b, P1, P2, best_inl_ix, in_front] = estimate_E(K, pc);

% FIXME:
%  - rename all_u1 to something better

all_u1 = K\e2p(pc(1:2,:));
all_u2 = K\e2p(pc(3:4,:));
im1 = images(i1).img;
im2 = images(i2).img;

%%

v1 = K*all_u1;
v2 = K*all_u2;

plot_epipolar_geometry(im1, im2, v1, v2, best_inl_ix, in_front);

%%

F = K'\E/K;

xxx = best_inl_ix & in_front;

epipolar_ix = xxx(1,1:10);
v1 = v1(:,epipolar_ix);
v2 = v2(:,epipolar_ix);

V1 = p2e(v1);
V2 = p2e(v2);

%%

subplot(2,1,1); hold on;
lines = F'*v2;
for i = 1:size(lines,2)
    l = lines(:,i);
    plot(V1(1,i), V1(2,i), 'x', 'color', color_hash(i), 'MarkerSize', 20, 'markerfacecolor', color_hash(i), 'LineWidth', 4);
    draw_line_into_axes(l, color_hash(i), 5);
end
hold off;

subplot(2,1,2); hold on;
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

X = Pu2X(P1, P2, all_u1, all_u2);

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

%%

% Obarvene body, stejne jako v predchozim bloku
export_to_vrml('out.wrl', {P1, P2}, X(:,ok), colors/255);

% Vsechny body
% export_to_vrml('../data/EpipolarGeometry-TwoCameras-AllPoints.wrl', {P1, P2}, X);

% Jenom inliery (tj. jsou zaroven pred kamerami)
% export_to_vrml('../data/EpipolarGeometry-TwoCameras-InliersInFrontOfCameras.wrl', {P1, P2}, X(:,best_inl_ix));


