
%% Depth in camera function:

clear all;
P = [eye(3), zeros(3,1)];

X = [0 0 1 1]';
assert(depth_in_camera(X,P) == 1);
X = [10 10 10 10]';
assert(depth_in_camera(X,P) == 1);
X = [10 10 10 -10]';
assert(depth_in_camera(X,P) == -1);

P(3,3) = 0;
err = false;
try
    d = depth_in_camera(X,P);
catch
    err = true;
end

if ~err
    error('The depth_in_camera function should throw an error for infinite camera');
end

%% Lines distance function:

clear all;

v0 = [0 0 0]';
EPS = 100*eps;

[d, a, b] = lines_distance([-1 -1 0]', [1 1 0]', [1 -1 0]', [1 -1 0]');
assert(d == 0 && all(a == v0) && all(b == v0));
[d, a, b] = lines_distance([-1 -1 0]', [1 1 0]', [1 -1 1]', [1 -1 0]');
assert(d == 1 && all(a == v0) && all(b == [0 0 1]'));
[d, a, b] = lines_distance([-1 -1 0]', [1 1 0]', [1 -1 1]', [1 1 0]');
assert(abs(d - sqrt(3)) < EPS && all(isnan(a)) && all(isnan(b)));



