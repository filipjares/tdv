
%% Obtain data from the previous step

% assume we have in the workspace
% what is in '../data/glue_cameras-01-output.mat'
load('../data/glue_cameras-01-output.mat');

%% Correspondences data setup

addpath toolbox/
addpath corresp/
addpath p3p/
addpath ba/

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

% FIXME: It is not necessary to keep the contents of m and pc variables...

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
colors = [1 1 1]' * ones(1,size(X,2)); % point from initial camera pair in white

u = cell(ncams, 1);
for i = 1:ncams
    u{i} = get_image_points_coordinates(images, i);
end

info.init_corresp = corresp;  % copy for reference (for the report)
corresp = corresp_start(corresp, i1, i2, find(best_inl_ix), 1:Xcount);

%% Here comes the Bundle Adjustment

[Rt_new, X_new] = RtXun_ba({cameras{corresp.camsel}}, K, p2e(X), {u{corresp.camsel}}, {corresp.Xu{corresp.camsel}});

X = e2p(X_new);
cam_ix = find(corresp.camsel);
for i = 1:length(Rt_new)
    cameras{cam_ix(i)} = Rt_new{i};
end

% for the report
info.i = 0; % camera counter
info.cam_id = nan(10,1); % 1st col: camera id, 2nd col: inliner count
info.ransac_info = cell(10,1);
info.other_cam_new_X = cell(10,1);
info.tentative_verification = cell(10,1);
info.corresp = cell(10,1);

while true
    %% Choosing the next camera to add

    % list of ('green') cameras with tentative scene-to-image correspondences
    ig = corresp_get_green_cameras(corresp);
    if isempty(ig)
        fprintf('There are no other cameras with tentative scene-to-image correspondences\n');
        break;
%        return;
    end
    Xucount = corresp_get_Xucount(corresp, ig);
    [maxXucount, max_ig_ix] = max(Xucount);
    in = ig(max_ig_ix);     % the new camera index
    fprintf('Camera number %u is the next\n', in);
    if (maxXucount < 3) % FIXME: what should be the limit?
        fprintf('but it has less than 3 correspondences to the camera cloud\n');
        break;
%       return;
    end

    % Scene-to-image correspondences in the new camera
    Xu = corresp_get_Xu(corresp, in);

    % Scene-to-image correspondences (points)
    Xn = X(:,Xu(:,1));
    un = e2p(get_image_points_coordinates(images, in, Xu(:,2)));

    %% RANSAC

    [R, t, xinl, ransac_info] = p3p_ransac(K, Xn, un);
    info.i = info.i + 1;
    info.cam_id(info.i) = in;
    info.ransac_info{info.i} = ransac_info;
    info.other_cam_i = 0; % temp. counter
    info.other_cam_new_X{info.i} = cell(11,1);
    info.tentative_verification{info.i} = cell(12,1);
    
    corresp = corresp_join_camera(corresp, in, xinl);
    cameras{in} = [R t];

    %% Here comes another Bundle adjustment

    [Rt_new, X_new] = RtXun_ba({cameras{corresp.camsel}}, K, p2e(X), {u{corresp.camsel}}, {corresp.Xu{corresp.camsel}});

    X = e2p(X_new);
    cam_ix = find(corresp.camsel);
    for i = 1:length(Rt_new)
        cameras{cam_ix(i)} = Rt_new{i};
    end
    
    %% Reconstruct new Scene points from Image-to-Image correspondences between
    %  the newly added camera and cameras that are already in the cluster
            
    THR = 2; % threshold, [px]
    THR = 2*THR^2;
    
    Pin = K*cameras{in};
    
    % list of cameras already in the cluster neighbouring with the camera
    % with index 'in'. We will iterate through them
    ilist = corresp_get_cneighbours(corresp, in);
    for ic = ilist
        % get remaining image-to-image correspondences
        mm = corresp_get_m(corresp, in, ic);
        
        % Reconstruct new scene points using the cameras in and ic and
        % image-to-image correspondences m. Sets of inliers and new scene points'
        % IDs are obtained
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
        
        err = sum((v_in - u_in).^2) + sum((v_ic - u_ic).^2);
        inl_ix = find(err < THR & in_front);
        
        firstUnusedId = size(X,2) + 1;
        inliers_count = length(inl_ix);
        new_xid = firstUnusedId:(firstUnusedId + inliers_count - 1);
        Xcount = Xcount + inliers_count;    % TODO: this variable is not necessary
        X = [X, newX(:,inl_ix)];
        colors = [colors, color_hash(in)' * ones(1,inliers_count)];
        assert(length(X) == Xcount);
        
        corresp = corresp_new_x(corresp, in, ic, inl_ix, new_xid);
        
        info.other_cam_i = info.other_cam_i + 1;
        info.other_cam_new_X{info.i};
        info.other_cam_new_X{info.i}{info.other_cam_i}.otherCamId = ic;
        info.other_cam_new_X{info.i}{info.other_cam_i}.newXCount = size(newX,2);
        info.other_cam_new_X{info.i}{info.other_cam_i}.newXInlCount = inliers_count;
        info.other_cam_new_X{info.i}{info.other_cam_i}.allXCount = Xcount;
    end
   
    
    %% Verification of Tentative Scene-to-Image Correspondences in the Cluster.
    
    % list of all cameras in the cluster
    ilist = corresp_get_selected_cameras(corresp);
    
    info.other_cam_i = 0;

    for ic = ilist
        [Xu Xu_verified] = corresp_get_Xu(corresp, ic);
        Xu_tentative = find(~Xu_verified);

        % Verify (by reprojection error) scene-to-image correspondences in
        % Xu_tentative. A subset of good points is obtained
        
        % FIXME: it is not necessary to check this, all that were added were in
        % front of all cameras. Or Weren't they?
        % in_front = depth_in_camera(X(:,Xu(Xu_tentative,1)), Pic) > 0;
        Pic = K*cameras{ic};
        
        % image points and projections of space points - their 
        u_ic = get_image_points_coordinates(images, ic, Xu(Xu_tentative,2));
        X_ic = X(:,Xu(Xu_tentative,1));
        v_ic = p2e(Pic*X_ic);
        
        err = sum((v_ic - u_ic).^2);
        inl_ix = find(err < THR/2);     % & in_front

        corr_ok = Xu_tentative(inl_ix); % The subset of good points - there is no one here
        corresp = corresp_verify_x(corresp, ic, corr_ok);
        
        info.other_cam_i = info.other_cam_i + 1;
        info.tentative_verification{info.i}{info.other_cam_i}.camId = ic;
        info.tentative_verification{info.i}{info.other_cam_i}.tentativeXCount = length(Xu_tentative);
        info.tentative_verification{info.i}{info.other_cam_i}.tentativeXInl = length(inl_ix);
    end
    
    info.corresp{info.i} = corresp;
    
    % That's all for this new camera:
    corresp = corresp_finalize_camera(corresp);

end

%% Save workspace & Export do VRML

% save('../data/glue_cameras-02-output.mat');
% export_to_vrml('out.wrl', cameras, X);

save('../data/info-glue_cameras-02.mat', 'info');












