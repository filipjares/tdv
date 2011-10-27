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

% number of points along the line
N = 20;

% Line definition
X = [300 400]';     % point on a line
u = [1 -1]';        % vector tangent to the line

%% Computations

u = u/norm(u);      % normalize the u vector
n = [-u(2) u(1)]';  % vector normal to the line
d = -X'*n;          % distance of the line from the origin
% TODO: sign of d

l = [n; d];         % homogeneous representation of the line

endpoints = get_line_intersection_with_axes_boundaries(l);
A = endpoints(:,1);
B = endpoints(:,2);
end_to_end = B - A;

t = rand(N,1);

Xs = zeros(2,N);    % uniformly distributed set of points on the line;
for i = 1:length(t)
    Xs(:,i) = A + t(i)*end_to_end;
end


%% Plot the situation

figure(1);
clf;
set(gca, 'ydir', 'reverse');
axis equal;
set(gca, 'xlim', [X_LO X_HI]);
set(gca, 'ylim', [Y_LO Y_HI]);
hold on;

line(endpoints(1,:), endpoints(2,:), 'Color', 'g');
plot(Xs(1,:), Xs(2,:), 'ob', 'MarkerSize', 5, 'Linewidth', 2);

hold off;