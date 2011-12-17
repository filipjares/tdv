
fprintf('Loading data from previous steps ...\n');
load ('../data/glue_cameras-02-output.mat', 'K', 'cameras');
images = initialize_empty_images_structure();

addpath rectify/
addpath gcs/

i1 = 6;
i2 = 7;

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



