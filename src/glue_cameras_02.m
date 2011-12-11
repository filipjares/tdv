
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

%% Choosing the next camera to add

% list of ('green') cameras with tentative scene-to-image correspondences
ig = corresp_get_green_cameras(corresp);
Xucount = corresp_get_Xucount(corresp, ig);
[maxXucount, max_ig_ix] = max(Xucount);
if (maxXucount < 3) % FIXME: what should be the limit?
    return
end

in = ig(max_ig_ix);
fprintf('Camera number %u is the next\n', in);
Xu = corresp_get_Xu(corresp, in);

%% Here comes the P3P RANSAC

% TODO

% Scene-to-image correspondences (points)
Xn = X(:,Xu(:,1));
corresp_count = size(Xu,1);
un = zeros(2,corresp_count);
for i = 1:size(Xu(:,2))
    un(:,i) = [images(in).pts(Xu(i,2)).x; images(in).pts(Xu(i,2)).y];
end
un = e2p(un);

%% RANSAC

THR = 2; % [px]
THR = 2*THR^2;

Nmax = Inf;

best_support = 0;
R_best = [];
t_best = [];

n = 0;
while true
    n = n + 1;
    
    % Generate hypothesis R, t
    indices = round(corresp_count*rand(3,1));   % select random indices
    while indices(1) == indices(2) || indices(2) == indices(3)
        if indices(1) == indices(2)
            indices(2) = round(corresp_count*rand(1,1));
        end
        if indices(2) == indices(3)
            indices(3) = round(corresp_count*rand(1,1));
        end
    end
    X3 = Xn(:,indices);
    u3 = un(:,indices);
    Xc = p3p_grunert(X3, K\u3);
    
    for i = 1:size(Xc,2)
        X3c = Xc{i};
        [R, t] = XX2Rt_simple(X3, X3c);
        % such that X3c = R*X3 + t
        
        P = K*[R t];
        
        % For each hypothesis R, t do:
        % - compute set of inliers and support
        
        % these points have to be verified:
        Xn;
        
        depths = depth_in_camera(Xn, P);
        in_front = (depths > 0);
        
        reprojected_points = p2e(P*Xn(:,in_front));
        original_points = p2e(un(:,in_front));
        err = sum((reprojected_points - original_points).^2);
        inl_ix = err < THR;
        support = sum(inl_ix);
        
        if support > best_support
            best_support = support;
            R_best = R;
            t_best = t;
        end

        % Update RANSAC stopping criterion w.r.t. the number of inliers
        inlier_count = support;
        inlier_probability = inlier_count/corresp_count;
        if inlier_probability == 1
            Nmax = 0;
        else
            Nmax = ransac_min_sample_size(0.95, inlier_probability, 3);
        end
        
    end

    if (n > Nmax); break; end
end

%% Vykreslit si obrazky

u22 = zeros(2,size(Xu,1));
X22 = corresp_get_Xu(corresp, 2);
for i = 1:size(Xu(:,2))
    u22(:,i) = [images(2).pts(X22(i,2)).x; images(2).pts(X22(i,2)).y];
end

figure(1);
image(images(2).img);
hold on;
for i = 1:size(u22,2)
    plot(u22(1,i), u22(2,i), 'ob', 'markerfacecolor', 'b');
end
hold off;
axis equal
figure(2)
image(images(10).img);
hold on;
for i = 1:size(un,2)
    plot(un(1,i), un(2,i), 'ob', 'markerfacecolor', 'b');
end
hold off;
axis equal














