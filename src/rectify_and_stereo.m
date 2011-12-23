%function rectify_and_stereo(i1, i2)
i1 = 2;
i2 = 6;
addpath toolbox/
addpath rectify/
addpath gcs/

fprintf('Loading data from previous steps ...\n');
load ('../data/glue_cameras-02-output.mat', 'K', 'cameras', 'X');
images = initialize_empty_images_structure();

P1 = K*cameras{i1};
P2 = K*cameras{i2};

fprintf('Loading images %s) and %s).\n', images(i1).figId, images(i2).figId);
images(i1).img=imread(images(i1).filename);
images(i2).img=imread(images(i2).filename);

F = cameras2F(P1,P2);

fprintf('Computing rectifying homographies and rectifying images...\n');
[H1, H2, im1r, im2r] = rectify(F, images(i1).img, images(i2).img);

im1r = im1r(1:2:end, 1:2:end);
im2r = im2r(1:2:end, 1:2:end);

H1 = diag([0.5 0.5 1])*H1;
H2 = diag([0.5 0.5 1])*H2;

fprintf('Computing disparity map of the pair...\n');
D = gcs(im1r, im2r, []);
P1r = H1*P1;
P2r = H2*P2;

%%

pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
save(['../data/rectify_and_stereo_pair-', pair_str, '.mat']);

%%

ok = ~isnan(D);

u1 = ones(3,sum(sum(ok)));
u2 = ones(3,sum(sum(ok)));

n = 0;
for i = 1:size(im1r, 1)
	pts_in_row = sum(ok(i,:));
	col_ix = find(ok(i,:));
	u1(1:2, (n+1):(n+pts_in_row)) = [i*ones(1,pts_in_row); col_ix];
	u2(1:2, (n+1):(n+pts_in_row)) = [i*ones(1,pts_in_row); col_ix - D(i,col_ix) ];
	n = n + pts_in_row;
end

%%
tic;
X2 = Pu2X(P1r, P2r, u1, u2);
XX = X2(:,1:10:end);
toc
%%
% save(['../data/points_from_stereo_pair_', pair_str, '.mat'], 'XX', 'P1r', 'P2r', 'H1', 'H2', 'P1', 'P2', 'F', 'i1', 'i2');
% export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '.wrl'], {P1, P2}, XX);

% export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '-both_results.wrl'], {P1, P2}, [X, XX], [ [1 0 0]'*ones(1,size(X,2)), [0 1 0]'*ones(1,size(XX,2)) ]);

save('../data/rectify_and_stereo-output.mat');

%% Display rectified images

% figure(1); imshow(im1r);
% figure(2); imshow(im2r);
% 
% assert(size(im1r,1) == size(im2r,1));
% umax = max(size(im1r,2), size(im2r,2));
% 
% j = 1000;
% figure(1); h1 = line([1, umax], [j, j]);
% figure(2); h2 = line([1, umax], [j, j]);


%end