%% Use perspective_camera script

cameras = [4 6];
perspective_camera;

%% Selected points in two pictures and relevant cameras

u1 = e2p(points{6});
u2 = e2p(points{4});

P1 = Ps(:,:,6);
P2 = Ps(:,:,4);

C1 = null(P1);
C2 = null(P2);

%% Overall scene view

C = [1.5;-3;-4];
alpha = 0.05; c = cos(alpha); s = sin(alpha);
Ry = [ ...
    c  0  s; ...
    0  1  0; ...
   -s  0  c];
alpha = 0.8; c = cos(alpha); s = sin(alpha);
Rx = [ ...
    1  0  0; ...
    0  c -s; ...
    0  s  c];
R = Rx*Ry;
P = K*R*[eye(3) -1*C];

x1 = p2e(P*X1);
x2 = p2e(P*X2);

figure(7);

% house
plot(x1(1,:), x1(2,:), 'r-', 'linewidth', 2); % Front side of the house in red
hold on;
plot(x2(1,:), x2(2,:), 'b-', 'linewidth', 2); % Back side of the house in blue
plot([x1(1,:); x2(1,:)], [x1(2,:); x2(2,:)], 'k-', 'linewidth', 2); % Lines connecting front and back side

% camera centers
c = p2e(P*[C1 C2]);
plot(c(1,:), c(2,:), 'LineStyle', 'none', 'markerfacecolor', 'r', 'markersize', 7, 'marker', 'o');

% world coordinate frame and P1, P2 coordinate frames:
plot_coordinate_frame([0 0 0]', eye(3), P, 'O');
plot_coordinate_frame(p2e(C1), K\P1(:,1:3), P, 'C1');
plot_coordinate_frame(p2e(C2), K\P2(:,1:3), P, 'C2');

% origin
o = p2e(P(:,4));
plot(o(1,:), o(2,:), 'markerfacecolor', 'b', 'markersize', 7, 'marker', 'o');

% to resize the plot slightly to make the C1, C2 fit into the picture
plot(c(1,1), c(2,1) -100, 'LineStyle', 'none');

d1 = P1(:,1:3)\u1;
d2 = P2(:,1:3)\u2;

% normalize
d1 = d1 ./ (ones(3,1)*vlen(d1));
d2 = d2 ./ (ones(3,1)*vlen(d2));

%%

D1 = e2p(p2e(C1)*ones(1,size(d1,2)) + d1);
D2 = e2p(p2e(C2)*ones(1,size(d2,2)) + d2);

i1 = p2e(P*D1);
i2 = p2e(P*D2);

CC1 = p2e(P*C1);
CC2 = p2e(P*C2);

plot([CC1(1)*ones(1,size(i1,2)); i1(1,:)], [CC1(2)*ones(1,size(i1,2)); i1(2,:)], '-b');
plot([CC2(1)*ones(1,size(i2,2)); i2(1,:)], [CC2(2)*ones(1,size(i2,2)); i2(2,:)], '-b');

X = rays_intersection(p2e(C1), d1, p2e(C2), d2);
xs = p2e(P*X);
for j = 1:size(xs,2);
    plot(xs(1,j), xs(2,j), 'markerfacecolor', color_hash(j), 'markersize', 7, 'marker', 'o');
end

set(gca, 'ydir', 'reverse');
axis equal;
hold off;

