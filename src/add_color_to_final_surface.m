
addpath ply_color/

% load cameras and the picture used to obtain colors of points
images = initialize_empty_images_structure();
load ('../data/glue_cameras-02-output.mat', 'K', 'cameras');
img_ix = 6;
color_image = imread(images(img_ix).filename);
P = K*cameras{img_ix};

% read the surface
[tri, pts] = plyread('psr.ply','tri');
%%

u = round(p2e(P*e2p(pts')));
col = 255*ones(length(pts),3);
%%
for i = 1:length(pts)
    if (u(1,i) > 0 && u(1,i) <= size(color_image, 2) ...
                && u(2,i) > 0 && u(2,i) <= size(color_image, 1))
        c = color_image(u(2,i), u(1,i), :);
        col(i,:) = [c(1), c(2), c(3)];
    end
end

%%

% save the result with color
plywritetricol(tri,pts,col,'psr_col.ply');