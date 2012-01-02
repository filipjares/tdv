function [XX, c, pos, D_no_border] = rectify_and_stereo(i1, i2, P1, P2, im1, im2)

F = cameras2F(P1,P2);

fprintf('Computing rectifying homographies and rectifying images...\n');
[H1, H2, im1r, im2r] = rectify(F, im1, im2);

im1r = im1r(1:2:end, 1:2:end);
im2r = im2r(1:2:end, 1:2:end);

H1 = diag([0.5 0.5 1])*H1;
H2 = diag([0.5 0.5 1])*H2;

fprintf('Computing disparity map of the pair...\n');
D = gcs(im1r, im2r, []);
P1r = H1*P1;
P2r = H2*P2;

%% 

fprintf('Computing image point coordinates and colors...\n');

% Size of border used to avoid reconstructing near-border artifacts
BORDER = 50;
HEIGHT = size(im1, 1);
WIDTH = size(im1, 2);

ok = ~isnan(D);     % valid disparities

% prepare arrays for points and their colors
u1 = ones(3,sum(sum(ok)));  % point coordinates in the first (rectified) picture
u2 = ones(3,sum(sum(ok)));  % point coordinates in the second (rectified) picture
c = zeros(3,sum(sum(ok)));  % colors of these points
pos = zeros(2,sum(sum(ok))); % coordinates of points XX in the first picture
D_no_border = nan(size(im1,1), size(im1,2));

n = 0;
for i = 1:size(im1r, 1)
    pts_in_row = sum(ok(i,:));  % valid disparities count in current row
    if (pts_in_row == 0)
        continue;
    end
    
    col_ix = find(ok(i,:));     % indices of points with valid disparities
    
    % coordinates of points in current row in 1st pic (having valid disparities)
    u1_in_row = [col_ix; i*ones(1,pts_in_row); ones(1,pts_in_row)];
    
    % coordinates of these points in original picture (before rectification)
    u1_orig = round(p2e(H1\u1_in_row));
    % indices of points with valid disparities having sufficient distance from the border
    inside_border = find(u1_orig(1,:) > BORDER & u1_orig(1,:) < WIDTH - BORDER ...
            & u1_orig(2,:) > BORDER & u1_orig(2,:) < HEIGHT - BORDER);
    
    ok_pts_in_row = size(inside_border,2);  % useful points count
    
    if (ok_pts_in_row == 0)
        continue;
    end
    
    new_points_ix = (n+1):(n+ok_pts_in_row); % indices of useful points
	
    % coordinates
    u1(:, new_points_ix) = u1_in_row(:, inside_border);
    u2(1:2, new_points_ix) = [col_ix(inside_border) - D(i,col_ix(inside_border)); i*ones(1,ok_pts_in_row)];
    pos(:, new_points_ix) = u1_orig(:,inside_border);
    
    % colors
    for j = 1:ok_pts_in_row
        c(:,new_points_ix(j)) = im1(u1_orig(2,inside_border(j)), u1_orig(1,inside_border(j)), :);
        D_no_border(u1_orig(2,inside_border(j)), u1_orig(1,inside_border(j))) = D(i,col_ix(inside_border(j)));
    end    
	n = n + ok_pts_in_row;
end

u1 = u1(:,1:n);
u2 = u2(:,1:n);
c  =  c(:,1:n);
pos  = pos(:,1:n);

%% Reconstruct 3D points

fprintf('Computing space points (reprojections)...\n');
XX = Pu2X(P1r, P2r, u1, u2);

%% Save

fprintf('Writing data...\n');
pair_str = [num2str(i1, '%02u') '-' num2str(i2, '%02u')];
% fprintf('\t... Disparity map\n');
imwrite(im1, ['../data/disparity_pair_', pair_str, '-im1.png'], 'png');
imwrite(D_no_border, ['../data/disparity_pair_', pair_str, '-im1-D.png'], 'png');
imwrite(D_no_border, colormap('hot'), ['../data/disparity_pair_', pair_str, '-im1-D-c.png'], 'png');
imwrite(im1r, ['../data/disparity_pair_', pair_str, '-im1r.png'], 'png');
imwrite(D, ['../data/disparity_pair_', pair_str, '-im1r-D.png'], 'png');
imwrite(D, colormap('hot'), ['../data/disparity_pair_', pair_str, '-im1r-D-c.png'], 'png');
% fprintf('\t... Data\n');
% save(['../data/points_from_stereo_pair_', pair_str, '.mat'], 'XX', 'P1r', 'P2r', 'H1', 'H2', 'P1', 'P2', 'F', 'i1', 'i2', 'X', 'c');
% fprintf('\t... VRML\n');
% export_to_vrml(['../data/points_from_stereo_pair_', pair_str, '-color.wrl'], {P1, P2}, XX, c/255);

end