
alpha = -30/180*pi; c = cos(alpha); s = sin(alpha);
PR = [[c 0 -s]' [0 1 0]' [s 0 c]'];
C = [-0.5 -0.5 -2]';
P = PR*[eye(3) -C]; % P(3,1:3) = 0

figure(13)
plot_coordinate_frame(zeros(3,1), eye(3), P, 'P_1');
axis equal
set(gca, 'ydir', 'reverse');
hold on;

plot_coordinate_frame(b, R, P, 'P_2');

hold off;