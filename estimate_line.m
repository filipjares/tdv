%% Task 0-3 assignment
% 
%    1. Let the image area has an extent [1, 1] to [800, 600].
%    2. Chose a planar line in general position, suitably inside the image.
%    3. Randomly generate a set of 800 points belonging to the line. The points are polluted by an isotropic gaussian noise with σ=3 [px]
%    4. Randomly generate an additional set of 200 outlying points, uniformly distributed over the image area.
%    5. Mix all the points together.
%    6. Use the set of all points for (non-robust) ML estimation of the line. Use numeric optimisation (fminsearch)).
%    7. Use the set of all points for robust ML estimation of the line. Use ransac to separate inliers and outliersf and than numeric optimisation on the inliers.
%    8. Plot the whole situation:
%           * Original line
%           * Points
%           * Line found by non-robust ML estimation.
%           * Line found by robust ML estimation.
%% Definitions

% Image boundaries
X_LO = 1;
X_HI = 800;
Y_LO = 1;
Y_HI = 600;

N = 800;            % number of inliners (points along the line)
No = 200;           % number of outliers

% Line definition
X = [300 400]';     % point on a line
u = [2 3]';        % vector tangent to the line

sigma = 3;          % [px]

%% Prepare the plot

figure(1);
clf;
set(gca, 'ydir', 'reverse');
axis equal;
set(gca, 'xlim', [X_LO X_HI]);
set(gca, 'ylim', [Y_LO Y_HI]);
hold on;

%% Computations

u = u/norm(u);      % normalize the u vector
n = [-u(2) u(1)]';  % vector normal to the line
d = -X'*n;          % distance of the line from the origin
% TODO: sign of d

l_orig = [n; d];    % homogeneous representation of the line

endpoints = get_line_intersection_with_axes_boundaries(l_orig);
A = endpoints(:,1);
B = endpoints(:,2);
end_to_end = B - A;

t = rand(N,1);

Xl = zeros(2,N);    % uniformly distributed set of points on the line;
for i = 1:length(t)
    Xl(:,i) = A + t(i)*end_to_end;
end

errors = sigma.*randn(2,N);

Xerr = Xl + errors; % points on the line polluted by an isotropic gaussian noise

R = [...            % random set of outliers
    X_LO*zeros(1,No)+(X_HI-X_LO)*rand(1,No); ...
    Y_LO*zeros(1,No)+(Y_HI-Y_LO)*rand(1,No)];

% All the data (both inliers and outliers):
X = sortrows([Xerr R]')';

%% Plot the situation

line(endpoints(1,:), endpoints(2,:), 'Color', 'g');                 % the line
% plot(Xl(1,:), Xl(2,:), 'og', 'MarkerSize', 5, 'Linewidth', 1);    % points lying exactly on the line
plot(Xerr(1,:), Xerr(2,:), 'ob', 'MarkerSize', 5, 'Linewidth', 1);  % inliners
plot(R(1,:), R(2,:), 'or', 'MarkerSize', 5, 'Linewidth', 1);        % outliers
% plot(X(1,:), X(2,:), 'xk', 'MarkerSize', 4, 'Linewidth', 1);      % all points mixed

%% Non-robust Estimation

estimate = fminsearch(@(line) ss_of_distances_from_line(line, X), [1 0 0]', optimset('MaxFunEvals', 1000000));
estimate(1:2,1) = estimate(1:2,1)/norm(estimate(1:2,1));

% Plot the result:
draw_line_into_axes(estimate);

%% Robust Estimation

quit = false;
while (~quit)

% Randomly select two points (a and b) from X and create line l connecting them
rand_ix = sort(ceil(1+(size(X,2)-1)*rand(2,1)));    % select to indices of two points randomly
a = X(:,rand_ix(1));
b = X(:,rand_ix(2));
l = cross(e2p(a),e2p(b));
 
% Visualise:
a_h = plot(a(1), a(2), 'ro', 'MarkerSize', 10, 'LineWidth', 4);
b_h = plot(b(1), b(2), 'ro', 'MarkerSize', 10, 'LineWidth', 4);
l_h = draw_line_into_axes(l, 'r', 3);

dists = distances_of_points_from_line(l,X); % distances of all points from the proposal line
err = sum(dists.^2);                        % sum of squares of distances

THRESHOLD = 100;
support = sum(dists < THRESHOLD)

pause;

% Remove points

delete(a_h);
delete(b_h);
delete(l_h);

end

%%

hold off;