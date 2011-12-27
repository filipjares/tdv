
addpath toolbox/

fprintf('Loading data from previous steps ...\n');
fprintf('\trectify & stereo output\n');
load ('../data/rectify_and_stereo-output.mat');
fprintf('\tcorresp\n');
load('../data/corresp.mat', 'corresp');
fprintf('\timages.pts for i1 and i2\n');
S = load('../data/images.mat', 'images');
images(i1).pts = S.images(i1).pts;
images(i2).pts = S.images(i2).pts;
clear S;

%%
fprintf('Finding correspondences\n');
ix = zeros(2,0); % indices of points in image of camera i1 and i2

i = 0; j = 0;
k = 0;
for i = 1:size(corresp.Xu{i1},1)
    x1 = corresp.Xu{i1}(i,1);
    j = find(corresp.Xu{i2}(:,1) == x1, 1, 'first'); % index in Xu{i2}
    
    if ~isempty(j)
        k = k + 1;
        ix(:,k) = [corresp.Xu{i1}(i,2); corresp.Xu{i2}(j,2)];
    end
end

u1 = get_image_points_coordinates(images, i1, ix(1,:));
u2 = get_image_points_coordinates(images, i2, ix(2,:));
%%
fprintf('Displaying them\n');
figure(1);
imagesc(images(i1).img);
title(['Kamera ' num2str(i1)])
hold on;
skip = 10;
k = 0;
for i = 1:skip:size(u1,2)
    k = k + 1;
    plot(u1(1,i), u1(2,i), 'o', 'markersize', 8, 'markerfacecolor', color_hash(k));
end
hold off;
figure(2);
imagesc(images(i2).img);
title(['Kamera ' num2str(i2)])
hold on
k = 0;
for i = 1:skip:size(u2,2)
    k = k + 1;
    plot(u2(1,i), u2(2,i), 'o', 'markersize', 8, 'markerfacecolor', color_hash(k));
end
hold off;

%%

u1r = p2e(H1 * e2p(u1));
u2r = p2e(H2 * e2p(u2));
d = (u1r(1,:) - u2r(1,:));

%%

D2 = D;
for i = 1:skip:size(u1r,2)
    x = round(u1r(1,i));
    y = round(u1r(2,i));
    D2(y + [-10:10], x + [-10:10]) = d(i);
end

CX = Pu2X(P1r, P2r, u1r, u2r);

figure(3);
imagesc(D2);
colormap('jet');
set(gca, 'clim', [-70 -20]);
colorbar;
axis image;
title(['Camera ' num2str(i1) ' rectified']);

%%

figure(4);
imagesc(D);
colormap('jet');
set(gca, 'clim', [-70 -20]);
colorbar;
axis image;
title(['Camera ' num2str(i1) ' rectified']);
hold on;
k = 0;
for i = 1:skip:size(u1r,2)
    k = k + 1;
    x = round(u1r(1,i));
    y = round(u1r(2,i));
    plot(x, y, 'o', 'markersize', 8, 'markerfacecolor', color_hash(k));
end