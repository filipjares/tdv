
%% Script producing table of descriptors count and overview of  "best" and "worst" pair for each picture

disp('Loading output of the sparse correspondences computation');
disp('This may take a while...');
load('../../data/images_and_sparse_correspondences.mat', 'images', 'm');
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

%% Prepare the table

ids     = cellstr([images([1:12]).figId]');
min_ids = cellstr([images(nmin_i).figId]');
max_ids = cellstr([images(nmax_i).figId]');
table = [ids num2cell(np) min_ids num2cell(nmin') max_ids num2cell(nmax')];
heading = {'obrázek', 'počet bodů', ...
            'obr. s nejmenším počtem korespondencí', 'počet', ...
            'obr. s největším počtem korespondencí', 'počet'};
        
%% Output of the table

fprintf('\n\nTable for the report:\n\n');
fprintf('\\begin{table}[h]\n');
fprintf('\t\\centering\n');
fprintf('\t\\begin{tabular}{|c|c|cccc|}\n');
fprintf('\t\t\\hline\n');
% fprintf('%s & %s & %s & %s & %s & %s \\\\\n', heading{:});
fprintf('\t\t$i$ & $N_i$ & $j$ & $n_{ij}$ & $k$ & $n_{ik}$ \\\\\n');
fprintf('\t\t\\hline\n');
for i = 1:size(table,1)
    fprintf('\t\t%s & %d & %s & %d & %s & %d \\\\\n', table{i,:});
end
fprintf('\t\t\\hline\n');
fprintf('\t\\end{tabular}\n');
fprintf('\t\\caption{Přehled výsledků \\emph{WBS Matcheru}: počet význačných bodů $N_i$ v jednotlivých\n');
fprintf('\t\tobrázcích $i$ a páry s nejmenším $(i,j)$ resp. největším $(i,k)$ počtem předběžných\n');
fprintf('\t\tkorespondencí. Ve sloupci $n_{ij}$ je uveden počet předběžných korespondencí v páru\n');
fprintf('\t\t$(i,j)$ a ve sloupci $n_{ik}$ počet předběžných korespondencí v páru $(i,k)$.\n');
fprintf('\t\tHodnoty $i$, $j$, $k$ odpovídají popiskám kamer na \\figref{figUsporadaniKamer} resp.\n');
fprintf('\t\tpopiskám vstupních obrázků na \\figref{figFotografie}}\n');
fprintf('\t\\label{tabWbsFeatures}\n');
fprintf('\\end{table}\n');

%% matrix with "labels" and correspondence count
fprintf('\n\n');
fprintf('Overview of count of correspondences for individual picture pairs:\n\n');
disp([num2cell(' abcdefghijkl'); [num2cell('abcdefghijkl')' num2cell(n)] ]);

