
fprintf('Loading data from previous steps ...\n');
load ('../data/glue_cameras-02-output.mat', 'K', 'cameras');
images = initialize_empty_images_structure();

addpath rectify/
addpath gcs/

i1 = 5;
i2 = 6;

P1 = K*cameras{i1};
P2 = K*cameras{i2};

fprintf('Loading images %s) and %s).\n', images(i1).figId, images(i2).figId);
im1=imread(images(i1).filename);
im2=imread(images(i2).filename);

F = cameras2F(P1,P2);

fprintf('Computing rectifying homographies and rectifying images...\n');
[H1, H2, im1r, im2r] = rectify(F, im1, im2);

fprintf('Computing disparity map of the pair...\n');
D = gcs(im1r, im2r, []);
P1r = H1*P1;
P2r = H2*P2;

%%

pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
% save(['../data/rectify_and_stereo_pair-', pair_str, '.mat']);

%%

ok = ~isnan(D);

u1 = ones(3,sum(sum(ok)));
u2 = ones(3,sum(sum(ok)));

n = 0;
for i = 1:size(im1r, 1)
	pts_in_row = sum(ok(i,:));
	col_ix = find(ok(i,:));
	u1(1:2, (n+1):(n+pts_in_row)) = [i*ones(1,pts_in_row); col_ix];
	u2(1:2, (n+1):(n+pts_in_row)) = [i*ones(1,pts_in_row); col_ix + D(i,col_ix) ];
	n = n + pts_in_row;
end

X = Pu2X(P1r, P2r, u1, u2);

save(['../data/points_from_stereo_pair_', pair_str, '.mat'], 'X', 'P1r', 'P2r', 'H1', 'H2', 'P1', 'P2', 'F', 'i1', 'i2');
export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '.wrl'], {P1, P2}, X);

