
% When the calibration matrix K has form of
%
%        [ f, 0, u ]
%    K = [ 0, f, v ]
%        [ 0, 0, 1 ],
%
% then the matrix omega = inv(K*K') is symmetric and has form of
%
%                        [ omega11,       0, omega31 ]     1    [  1,    0,    -u              ]
%    omega = inv(K*K') = [       0, omega11, omega32 ] = ------ [  0     1,    -v              ]
%                        [ omega31, omega32, omega33 ]    f^2   [ -u,   -v,    f^2 + u^2 + v^2 ].
%
% when vp1 = [u1 v1 w1]' and vp2 = [u2 v2 w2]' are homogenous vectors
% representing two vanishing points of lines which are perpendicular in the scene
% following is true:
%
%       vp1' * omega * vp2 == 0
%
% That is
%
%                     [ omega11,       0, omega31 ]   [ u2 ]
%       [u1 v1 w1] *  [       0, omega11, omega32 ] * [ v2 ] == 0
%                     [ omega31, omega32, omega33 ]   [ w2 ]
%
% u1*u2*omega11 + u2*w1*omega31 + v1*v2*omega11 + v2*w1+omega32 + u1*w2*omega31 + v1*v2*omega32 + w1*w2*omega33 == 0
%
% This is linear equation that can be written for any pair of vanishing
% points which represent perpendicular directions in the scene (assuming
% square pixels of the camera and no skew)
%
% We need to determine fields of the omega matrix. We will therefore
% setup vector w containing the fields:
%
%       w = [omega11, omega31, omega32, omega33]';
%
% We will set up set of three equations and solve the system:
%
%       A*w == 0
%
% When we know the w, we will fill in the omega matrix and get the K
% using cholesky decomposition (we will also need to "normalize" the K 
% matrix; K(3,3) has to be 1)

USER_INPUT = true;

%% Remove the radial distortion

% addpath rd_undistort
% rddirundistort(rd, 'pictures', 'linear_pictures');

%% Display the image

figure(1);
clf;
im = imread('linear_pictures/cube-three_vanishing_points.jpg');
%im = imread('linear_pictures/sachovnice.jpg');
%im = imread('linear_pictures/img_5884.jpg');
image(im);
axis equal;
hold on;

%% Get the lines defining the vanishing points

if (USER_INPUT)
    % Either let the user input the lines
    [vanishing_point_1, vp1_l1, vp1_l2, vp1_h] = define_vanishing_point_in_picture('r');
    [vanishing_point_2, vp2_l1, vp2_l2, vp2_h] = define_vanishing_point_in_picture('g');
    [vanishing_point_3, vp3_l1, vp3_l2, vp3_h] = define_vanishing_point_in_picture('b');
else
    % or use this written definition
    p1 = [699 602 1]';
    p2 = [1659 236 1]';
    p3 = [1531 1337 1]';
    p4 = [2583 749 1]';

    p6 = [1570 2326 1]';
    p7 = [2375 1738 1]';

    ppp = [p1 p2 p3 p4 p6 p7];
    plot(ppp(1,:), ppp(2,:), 'xk');

    l1 = cross(p1, p2);
    l2 = cross(p3, p4);
    vanishing_point_1 = cross(l1, l2);

    l1 = cross(p1, p3);
    l2 = cross(p4, p2);
    vanishing_point_2 = cross(l1, l2);

    l1 = cross(p3, p6);
    l2 = cross(p4, p7);
    vanishing_point_3 = cross(l1, l2);

    vp_e = p2e(vanishing_point_1);
    plot(vp_e(1), vp_e(2), 'ok');
    vp_e = p2e(vanishing_point_2);
    plot(vp_e(1), vp_e(2), 'ok');
    vp_e = p2e(vanishing_point_3);
    plot(vp_e(1), vp_e(2), 'ok');
end

hold off;
axis tight;

%% Attempts to let the user edit the lines

% l1 = get_line_from_picture(vp1_l1);
% l2 = get_line_from_picture(vp1_l2);
% vanishing_point_1 = cross(l1, l2);
% vp_e = p2e(vanishing_point_1);
% plot(vp_e(1), vp_e(2), 'ok');
% 
% l1 = get_line_from_picture(vp2_l1);
% l2 = get_line_from_picture(vp2_l2);
% vanishing_point_2 = cross(l1, l2);
% vp_e = p2e(vanishing_point_2);
% plot(vp_e(1), vp_e(2), 'ok');
% 
% l1 = get_line_from_picture(vp3_l1);
% l2 = get_line_from_picture(vp3_l2);
% vanishing_point_3 = cross(l1, l2);
% vp_e = p2e(vanishing_point_3);
% plot(vp_e(1), vp_e(2), 'ok');

%% 

vps = [vanishing_point_1 vanishing_point_2 vanishing_point_3];
vps = e2p(p2e(vps));
A = zeros(3,4);

% combinations of pairs of vanishing points:
permutation = [2 3 1];
for i = 1:3
    vp1 = vps(:, i);              u1 = vp1(1); v1 = vp1(2); w1 = vp1(3);
    vp2 = vps(:, permutation(i)); u2 = vp2(1); v2 = vp2(2); w2 = vp2(3);
    A(i,:) = [u1*u2 + v1*v2, u2*w1 + u1*w2, v2*w1 + v1*w2, w1*w2];
end

w = null(A);

omega = [ ...
    w(1), 0,    w(2); ...
    0,    w(1), w(3); ...
    w(2), w(3), w(4)];

K = inv(chol(omega));
K = K/K(3,3)            % normalize
