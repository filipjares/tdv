%% Load data obtained previously

fprintf('Loading Camera calibration matrix K.\n');
load('../data/Kcalib.mat', 'K');
fprintf('Loading image data and image-to-image correspondences.\n');
load('../data/images_and_sparse_correspondences.mat', 'images', 'm', 'pc');

addpath toolbox/
addpath calibrated_p5/

%% Choose initial camera pair (i1,i2) with most image-to-image correspodences

fprintf('Choosing the initial camera pair.\n');

ncams = length(images);

corresp_count = zeros(ncams, ncams);
max_corresp_count = -1;
i1 = -1; i2 = -1;

for i = 1:ncams
    for j = i+1:ncams
        corresp_count(i,j) = size(m{i,j},2);
	if corresp_count(i,j) > max_corresp_count
	    max_corresp_count = corresp_count(i,j);
	    i1 = i; i2 = j;
	end
    end
end

fprintf([ ...
'The camera pair with the maximum number of image-to-image correspondences' ...
'\nis the pair (%u,%u) with %u correspondences\n'], ...
	i1, i2, max_corresp_count);

%% Estimate epipolar geometry for the initial camera pair (i1,i2);

% TODO: move this to glue_cameras_02.m
fprintf('Estimating epipolar geometry of the first pair..\n');
[EE, R2, b2, P1, P2, best_inl_ix, in_front, ransac_info] = estimate_E(K, pc{i1,i2});

%% Save what we have

% save('../data/glue_cameras-01-output.mat');

%% Print table for the report

total = size(best_inl_ix, 2);

fprintf('\n\nTable for the report:\n\n');
fprintf('\\begin{table}[h]\n');
fprintf('\t\\centering\n');
fprintf('\t\\begin{tabular}{|lrr|}\n');
fprintf('\t\t\\hline\n');
fprintf('\t\tPráh RANSACu\t\t\t& %d\\,px\t\\\\\n', ransac_info.threshold);
fprintf('\t\tPočet iterací RANSACu\t\t& %d\t\\\\\n', ransac_info.iterations_count);
fprintf('\t\tPočet předběžných korespondencí (bodů)\t& %d\t& %2.1f\\,\\%%\t\\\\\n', total, 100);
fprintf('\t\tPočet bodů před oběma kamerami\t& %d\t& %2.1f\\,\\%%\t\\\\\n', sum(in_front), 100*sum(in_front)/total);
fprintf('\t\tPočet inlierů\t\t\t& %d\t& %2.1f\\,\\%%\t\\\\\n', sum(best_inl_ix), 100*sum(best_inl_ix)/total);
fprintf('\t\tPočet outlierů\t\t\t& %d\t& %2.1f\\,\\%%\t\\\\\n', total - sum(best_inl_ix), 100 - 100*sum(best_inl_ix)/total);
fprintf('\t\t\\hline\n');
fprintf('\t\\end{tabular}\n');
fprintf('\t\\caption{\n');
fprintf('\t\t}\n');
fprintf('\t\\label{tabFirstPairEEstimate}\n');
fprintf('\\end{table}\n');
