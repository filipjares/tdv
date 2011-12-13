
%% Obtain data from the previous step

% assume we have in the workspace
% what is in '../data/glue_cameras-01-output.mat'

%% Correspondences data setup

% addpath corresp/

% Initialise correspondence tools with a number of cameras
fprintf('Initialise correspondences tool\n');
corresp = corresp_init(ncams);

% Add image-to-image correspondences
for i = 1:ncams
    for j = i+1:ncams
        corresp = corresp_add_pair(corresp, i, j, m{i,j}');
    end
end

assert(all(all(m{i1,i2}' == corresp_get_m( corresp, i1, i2 ))));

%% Initialize cameras cell array (cameras there are without K) i.e. cameras(i) = [Ri ti]

cameras = cell(ncams, 1);
cameras{i1} = P1;
cameras{i2} = P2;

%% Initialisation of the Camera Cluster and the Point Cloud

u1 = K\e2p(pc{i1,i2}(1:2,:));
u2 = K\e2p(pc{i1,i2}(3:4,:));
X = Pu2X(P1, P2, u1, u2);

Xcount = sum(best_inl_ix);  % number of confirmed scene points
X = X(:,best_inl_ix);           % the confirmed scene points themselves

corresp = corresp_start(corresp, i1, i2, find(best_inl_ix), 1:Xcount);

%% Here comes the Bundle Adjustment

% TODO

%while true
    %% Choosing the next camera to add

    % list of ('green') cameras with tentative scene-to-image correspondences
    ig = corresp_get_green_cameras(corresp);
    if isempty(ig)
        fprintf('There are no other cameras with tentative scene-to-image correspondences\n');
%        break;
        return;
    end
    Xucount = corresp_get_Xucount(corresp, ig);
    [maxXucount, max_ig_ix] = max(Xucount);
    in = ig(max_ig_ix);     % the new camera index
    fprintf('Camera number %u is the next\n', in);
    if (maxXucount < 3) % FIXME: what should be the limit?
        fprintf('but it has less than 3 correspondences to the camera cloud\n');
%        break;
        return;
    end

    % Scene-to-image correspondences in the new camera
    Xu = corresp_get_Xu(corresp, in);

    %% Here comes the P3P RANSAC

    % Scene-to-image correspondences (points)
    Xn = X(:,Xu(:,1));
    un = e2p(get_image_points_coordinates(images, in, Xu(:,2)));

    %% RANSAC

    [R, t, xinl] = p3p_ransac(K, Xn, un);
    
    corresp = corresp_join_camera(corresp, in, xinl);
    cameras{in} = [R t];

    %% Here comes another Bundle adjustment

    % TODO
    
    %%
    
    % list of cameras already in the cluster neighbouring with the camera
    % with index 'in'. We will iterate through them
    ilist = corresp_get_cneighbours(corresp, in);
    ic = 2; %for ic = ilist
        
        
        % FIXME: here, I am changing contents of the m variable:, should I
        % have cleared it earlier already?
        
        % get remaining image-to-image correspondences
        mm = corresp_get_m(corresp, in, ic);
        
        % Reconstruct new scene points using the cameras in and ic and
        % image-to-image correspondences m. Sets of inliers and new scene points'
        % IDs are obtained
        Pin = K*cameras{in};
        Pic = K*cameras{ic};
        u_in = get_image_points_coordinates(images, in, mm(:,1));
        u_ic = get_image_points_coordinates(images, ic, mm(:,2));
        
        newX = Pu2X(Pin, Pic, e2p(u_in), e2p(u_ic));
        
        depths_in = depth_in_camera(newX, Pin);
        depths_ic = depth_in_camera(newX, Pic);
        in_front = (depths_in > 0 & depths_ic > 0);
        
        % reprojected points
        v_in = p2e(Pin*newX);
        v_ic = p2e(Pic*newX);
        
        THR = 2; % [px]
        THR = 2*THR^2;
        
        err = sum((v_in - u_in).^2) + sum((v_ic - u_ic).^2); 
                
        
    %end
    

%end

%% Vykreslit si obrazky

figure(1);
plot_wbs(images(ic).img, images(in).img, p2e(u_ic), p2e(u_in));













