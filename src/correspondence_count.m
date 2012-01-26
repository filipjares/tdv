
disp('Loading output ofthe sparse correspondences computation');
disp('This may take a while...');
load('../data/images_and_sparse_correspondences.mat', 'images', 'm');
disp('Now doing the computations');

%% Create matrix n such that n(i,j) == number of correspondences between image i and j
n = nan(size(m));
for i=1:12; for j=i+1:12; n(i,j) = size(m{i,j},2); end; end;

%% Create vector np such that np(i) == number of descriptors/points of interest in image i
np = nan(12,1);
for i=1:12; np(i) = size(images(i).pts, 2); end;


%% For each image i, find the other image j such that
%  among all the pairs (i, k) for any k, the pair (i,j) has minimum/maximum
%  count of correspondences

% find minimum/maximum for each row/column in matrix n
[nminr, nminr_i] = min(n');
[nminc, nminc_i] = min(n);
[nmaxr, nmaxr_i] = max(n');
[nmaxc, nmaxc_i] = max(n);

assert(all(size(nminr) == size(nminc)));
assert(all(size(nmaxr) == size(nmaxc)));

% compute nmin and nmin_i
nmin = nan(size(nminr)); nmin_i = nan(size(nminr));
% minimum for each row/column into nmin
r_ix = nminr <= nminc;      % because of NaNs in the input ...
nmin(r_ix) = nminr(r_ix); nmin_i(r_ix) = nminr_i(r_ix);
c_ix = nminr > nminc;       % ... c_ix is not a negation of r_ix
nmin(c_ix) = nminc(c_ix); nmin_i(c_ix) = nminc_i(c_ix);
% if isnan(a) and ~isnan(b) hold then neither a <= b nor a > b is true, therefore:
r_nonnan_ix = ~isnan(nminr) &  isnan(nminc);
c_nonnan_ix =  isnan(nminr) & ~isnan(nminc);
nmin(r_nonnan_ix) = nminr(r_nonnan_ix); nmin_i(r_nonnan_ix) = nminr_i(r_nonnan_ix);
nmin(c_nonnan_ix) = nminc(c_nonnan_ix); nmin_i(c_nonnan_ix) = nminc_i(c_nonnan_ix);

% compute nmax and nmax_i
nmax = nan(size(nmaxc)); nmax_i = nan(size(nmaxc));
% maximum for each row/column into nmax
r_ix = nmaxr >= nmaxc;      % because of NaNs in the input ...
nmax(r_ix) = nmaxr(r_ix); nmax_i(r_ix) = nmaxr_i(r_ix);
c_ix = nmaxr < nmaxc;       % ... c_ix is not a negation of r_ix
nmax(c_ix) = nmaxc(c_ix); nmax_i(c_ix) = nmaxc_i(c_ix);
% if isnan(a) and ~isnan(b) hold then neither a <= b nor a > b is true, therefore:
r_nonnan_ix = ~isnan(nmaxr) &  isnan(nmaxc);
c_nonnan_ix =  isnan(nmaxr) & ~isnan(nmaxc);
nmax(r_nonnan_ix) = nmaxr(r_nonnan_ix); nmax_i(r_nonnan_ix) = nmaxr_i(r_nonnan_ix);
nmax(c_nonnan_ix) = nmaxc(c_nonnan_ix); nmax_i(c_nonnan_ix) = nmaxc_i(c_nonnan_ix);

%%

ids     = cellstr([ [images([1:12]).figId]' repmat(')', 12, 1) ]);
min_ids = cellstr([ [images(nmin_i).figId]' repmat(')', 12, 1) ]);
max_ids = cellstr([ [images(nmax_i).figId]' repmat(')', 12, 1) ]);
table = [ids num2cell(np) min_ids num2cell(nmin') max_ids num2cell(nmax')];
heading = {'obrázek', 'počet bodů', ...
            'obr. s nejmenším počtem korespondencí', 'počet', ...
            'obr. s největším počtem korespondencí', 'počet'};
%%
% the table
fprintf('\n\n%s & %s & %s & %s & %s & %s \\\\\n', heading{:});
%%
for i = 1:size(table,1)
    fprintf('%s & %d & %s & %d & %s & %d \\\\\n', table{i,:});
end
%%
% matrix with "labels"
disp(' ');
[num2cell(' abcdefghijkl'); [num2cell('abcdefghijkl')' num2cell(n)] ]

