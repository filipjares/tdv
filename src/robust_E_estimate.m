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

% load('seek_sparse_correspondencies-output', 'im1', im2', 'im3', ...
%         'm12', 'm23', 'm31', 'pc12', 'pc23', 'pc31' ...
%         ... %, 'pts1', 'pts2', 'pts3'  ...
%         );

% addpath calibrated_p5/

%% Load calibration matrix

% load('../data/Kcalib.mat', 'K');

%%

inlier_probability = 0.6;
N = ransac_min_sample_size(0.95, inlier_probability, 5);

%%
I = eye(3);

all_u1 = K\e2p(pc12(1:2,:));
all_u2 = K\e2p(pc12(3:4,:));

minError = Inf;
bestE = [];

i = 0;
while true
    i = i + 1;
    
    % choose sample of points
    ix = i:(i+4);
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
            v1 = e2p(p2e(P1*X));
            v2 = e2p(p2e(P2*X));
            % and compute sum of reprojection errors
            err = sum(vlen(v1 - all_u1) + vlen(v2 - all_u2)); % TODO use different error function?
            
            if (err < minError)
                minError = err;
                bestE = E;
            end
        end
    end
    
    if (i > N) break; end
end

%%

E = bestE;
[R, b, P1, P2] = EutoRb(E, u1, u2);

% reprojection error
X = Pu2X(P1, P2, all_u1, all_u2);
v1 = e2p(p2e(P1*X));
v2 = e2p(p2e(P2*X));
err = vlen(v1 - all_u1) + vlen(v2 - all_u2);

inliers_ix = err < 0.06;    % FIXME: compute the threshold instead of fixed one



%%

u1 = K*all_u1;
u2 = K*all_u2;

figure(1); image(im1); hold on;
% inliers in this picture
plot(u1(1,inliers_ix), u1(2,inliers_ix), 'o', 'markerfacecolor', 'r');
% outliers in this picture
plot(u1(1,~inliers_ix), u1(2,~inliers_ix), 'ok');
hold off;

figure(2); image(im2); hold on;
% inliers in this picture
plot(u2(1,inliers_ix), u2(2,inliers_ix), 'o', 'markerfacecolor', 'r');
% outliers in this picture
plot(u2(1,~inliers_ix), u2(2,~inliers_ix), 'ok');
hold off;

show_cameras;



