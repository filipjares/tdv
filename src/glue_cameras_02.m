
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
    corresp_count = size(Xu,1);
    un = zeros(2,corresp_count);
    for i = 1:corresp_count
        un(:,i) = [images(in).pts(Xu(i,2)).x; images(in).pts(Xu(i,2)).y];
    end
    un = e2p(un);

    %% RANSAC

    [R, t, xinl] = p3p_ransac(K, Xn, un);
    
    corresp = corresp_join_camera(corresp, in, xinl);
    cameras{in} = [R t];

    %% Here comes another Bundle adjustment

    % TODO
    
    %%
    
    ilist = corresp_get_cneighbours(corresp, in);
    

%end

%% Vykreslit si obrazky

% u22 = zeros(2,size(Xu,1));
% X22 = corresp_get_Xu(corresp, 2);
% for i = 1:size(Xu(:,2))
%     u22(:,i) = [images(2).pts(X22(i,2)).x; images(2).pts(X22(i,2)).y];
% end
% 
% figure(1);
% image(images(2).img);
% hold on;
% for i = 1:size(u22,2)
%     plot(u22(1,i), u22(2,i), 'ob', 'markerfacecolor', 'b');
% end
% hold off;
% axis equal
% figure(2)
% image(images(10).img);
% hold on;
% for i = 1:size(un,2)
%     plot(un(1,i), un(2,i), 'ob', 'markerfacecolor', 'b');
% end
% hold off;
% axis equal














