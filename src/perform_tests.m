
%% Depth in camera function:

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
