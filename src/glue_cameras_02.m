
%% Obtain data from the previous step

% assume we have in the workspace
% what is in '../data/glue_cameras-01-output.mat'

%% Correspondences data setup

% Initialise correspondence tools with a number of cameras
corresp = corresp_init(ncams);

% Add image-to-image correspondences
for i = 1:ncams
    for j = i+1:ncams
        corresp = corresp_add_pair(corresp, i, j, m{i,j}');
    end
end

assert(all(m{i1,i2} ==corresp_get_m( corresp, i1, i2 )));

%% Initialize cameras cell array (cameras there are without K) i.e. cameras(i) = [Ri ti]

cameras = cell(ncams, 1);
cameras(i1) = P1;
cameras(i2) = P2;