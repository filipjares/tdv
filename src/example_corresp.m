% Example presented in the paper:
% http://cmp.felk.cvut.cz/cmp/courses/TDV/2010W/labs/gluing_correspondences.pdf

%% Paths

addpath corresp/
% addpath toolbox/

%% 2.2.1 Data Setup

% Initialise correspondence tools with a number of cameras
corresp = corresp_init(5);

% Set up
corresp = corresp_add_pair(corresp, 1, 2, [4 1; 5 1; 3 3; 2 2]);
corresp = corresp_add_pair(corresp, 2, 3, [3 3; 3 4]);
corresp = corresp_add_pair(corresp, 1, 3, [1 1; 4 2; 6 1; 7 2]);
corresp = corresp_add_pair(corresp, 1, 4, [4 3; 4 4]);
corresp = corresp_add_pair(corresp, 2, 4, [1 3; 3 4; 4 5]);
corresp = corresp_add_pair(corresp, 3, 4, [1 3; 5 5]);
corresp = corresp_add_pair(corresp, 1, 5, [1 1]);

%% 2.2.2 Initialisation of Camera Cluster and Point Cloud

i1 = 1; i2 = 2;     % initial camera pair
% Get image-to-image correspondences for initial camera pair
m12 = corresp_get_m(corresp, i1, i2);
% Obtain set of inliers... and determine inliers indices
inl = [1 3];        % indices of inliers within m12;
xid = ['A', 'B'];   % IDs of the reconstructed scene points
corresp = corresp_start(corresp, i1, i2, inl, xid);

%% 2.2.4 Attaching New Camera into the Cluster

% list of cameras with tentative scene-to-image correspondences
ig = corresp_get_green_cameras(corresp);
Xucount = corresp_get_Xucount(corresp, ig);
i = 3; % select camera to be attached next, e.g. based on the Xucount
Xu = corresp_get_Xu(corresp, i); % get scene-to-image correspondences

% Obtain the i-th camera pose (R, t) and a set of inliers using the
% scene-to-image correspondences in Xu

xinl = [1 2];   % obtained inliers - indices to Xu{i}
corresp = corresp_join_camera(corresp, i, xinl);

%% 2.2.6 Reconstructing New Points

% i = 3; already set
% List of cameras in the cluster that are related to the attached camera
% by some image-to-image correspondences:
ilist = corresp_get_cneighbours(corresp, i);

% loop goes here...

  ic = 1; % a camera in the neighbourhood (must be iterated through ilist)
  m = corresp_get_m(corresp, i, ic); % get remaining image-to-image correspondences

  % Reconstruct new scene points using the cameras i and ic and
  % image-to-image correspondences m. Sets of inliers and new scene points'
  % IDs are obtained
  
  inl = [1];    % Obtained inliers-indices to m
  xid = ['C'];  % scene points' Ids
  corresp = corresp_new_x(corresp, i, ic, inl, xid);

%% 2.2.8 Verificatio of Tentative Scene-to-Image Correspondences in the Cluster

ilist = corresp_get_selected_cameras(corresp); % list of all cameras in the cluster

% loop goes here...

  ic = 1; % a camera in the cluster (must be iterated through ilist)
  [Xu Xu_verified] = corresp_get_Xu(corresp, ic);
  Xu_tentative = find(~Xu_verified);
  
  % Verify (by reprojection error) scene-to-image correspondences in
  % Xu_tentative. A subset of good points is obtained
  
  corr_ok = []; % The subset of good points - there is no one here
  corresp = corresp_verify_x(corresp, ic, corr_ok);
  
%% 2.2.10 Finalize New Camera

corresp = corresp_finalize_camera(corresp);






