
%% Depth in camera function:

clear all;
P = [eye(3), zeros(3,1)];   % camera
Xs = zeros(4,3);            % multiple points ("list" of vectors)
ds = zeros(1,3);            % and their depths to test the depth_in_camera
                            %     for multiple points

X = [0 0 1 1]';
Xs(:,1) = X;
d = depth_in_camera(X,P);
ds(1,1) = d;
assert(d == 1);

X = [10 10 10 10]';
Xs(:,2) = X;
d = depth_in_camera(X,P);
ds(1,2) = d;
assert(d == 1);

X = [10 10 10 -10]';
Xs(:,3) = X;
d = depth_in_camera(X,P);
ds(1,3) = d;
assert(d == -1);

% test for multiple points argument
assert(all(depth_in_camera(Xs, P) == ds));

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

%% Lines intersection function:

clear all;

K = 100;
EPS = eps*10^4;

for i = 1:5
    
    % generate random data
    rdata = -K + 2*K*rand(3,102);
    C1 = rdata(:,1);
    C2 = rdata(:,2);
    Xo = rdata(:,3:end);
    
    % unnormalized ray vectors:
    d1 = Xo - C1*ones(1,size(Xo,2));
    d2 = Xo - C2*ones(1,size(Xo,2));
    
    Xo = e2p(Xo);     % Xo to homogeneous coordinates
    
    X = rays_intersection(C1, d1, C2, d2);
    diff = vlen(X-Xo);
    if max(diff) > EPS
        error('Error in rays_intersection.m: difference too high');
        % error('[%e %e %e %e] differs from original [%e %e %e %e] by %e', ...
        %     X(1), X(2), X(3), X(4), ...
        %     Xo(1), Xo(2), Xo(3), Xo(4), ...
        %     diff);
    end
    
    % normalized ray vectors
    d1 = d1./ (ones(3,1)*vlen(d1));
    d2 = d2./ (ones(3,1)*vlen(d2));
    
    X = rays_intersection(C1, d1, C2, d2);
    diff = vlen(X-Xo);
    if max(diff) > EPS
        error('Error in rays_intersection.m: difference too high');
        % s = sprintf('[%e %e %e %e] differs from original [%e %e %e %e] by %e', ...
        %     X(1), X(2), X(3), X(4), ...
        %     Xo(1), Xo(2), Xo(3), Xo(4), ...
        %     diff);
        % disp(s);
    end
    
end

