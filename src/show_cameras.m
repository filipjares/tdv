

alpha = -30/180*pi; c = cos(alpha); s = sin(alpha);
PR = [[c 0 -s]' [0 1 0]' [s 0 c]'];
C = [-0.5 -0.5 -2]';
P = PR*[eye(3) -C]; % P(3,1:3) = 0

figure(13)
%plot_coordinate_frame(zeros(3,1), eye(3), P, 'O');
plot_coordinate_frame_3d(zeros(3,1), eye(3), 'k', 'x', 'O');
axis equal
set(gca, 'ydir', 'reverse');
hold on;

for i=1:length(cameras)
    Pi = cameras{i};
    R = Pi(:,1:3);
    b = -R'*Pi(:,4);
    %plot_coordinate_frame(b, R, P, ['P_' num2str(i)]');
    plot_coordinate_frame_3d(b, R', 'k', 'x', ['P_' num2str(i)]);
end

eX = p2e(X(:,1:10:end));
plot3(eX(1,:), eX(2,:), eX(3,:), '.k');

hold off;
axis equal tight;