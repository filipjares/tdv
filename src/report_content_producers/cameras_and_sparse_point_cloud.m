function cameras_and_sparse_point_cloud(cameras, images, X)
% Call this to generate the picture:
%
%       cd src/
%       load '../data/glue_cameras-02-output.mat'
%       addpath report_content_producers/
%       cameras_and_sparse_points_cloud(cameras, images, X)

addpath toolbox/

% prepare the camera P used to view the scene
alpha_x = 30/180*pi; c = cos(alpha_x); s = sin(alpha_x);
PRx = [[1 0 0]' [0 c s]' [0 -s c]'];
alpha_y = -20/180*pi; c = cos(alpha_y); s = sin(alpha_y);
PRy = [[c 0 -s]' [0 1 0]' [s 0 c]'];
alpha_z = -90/180*pi; c = cos(alpha_z); s = sin(alpha_z);
PRz = [[c -s 0]' [s c 0]' [0 0 1]'];
C = [-108 60 -170]';
P = PRx*PRy*PRz*[eye(3) -C]; % P(3,1:3) = 0

figure(13)

% plot the sparse 3D points cloud
eX = p2e(P*X(:,1:1:end));
plot(eX(1,:), eX(2,:), '.', 'MarkerSize', 0.5, 'color', 'b');

axis equal
set(gca, 'ydir', 'reverse');
hold on;

% (don't) plot origin, it is different from the coordinate frame of
% the P_1 camera because of Bundle Adjustment
% plot_camera_axis_direction(zeros(3,1), eye(3), P, 'O');

% coordinates of camera centers in the view of camera P
cam_positions = nan(2, length(cameras));

% plot cameras
for i=1:length(cameras)
    Pi = cameras{i};
    R = Pi(:,1:3);
    b = -R'*Pi(:,4);
    [x_offset, y_offset] = get_label_offset(i);
    
    % cameras indexation by numbers
    % plot_camera_axis_direction(b, R, P, ['P_{' num2str(i) '}'], x_offset, y_offset);
    % cameras indices by letters (report compatibility)
    plot_camera_axis_direction(b, R, P, ['P_{' images(i).figId '}'], x_offset, y_offset);
    
    cam_positions(:, i) = p2e(P*e2p(b));
end

% plot horizontal "pairs" (lines connecting cameras in the pair)
for i=[1 2 3 5 6 7 9 10 11]
    plot_camera_pair(cam_positions, i, i+1, 'blue');
end
% plot vertical "pairs" (lines connecting cameras in the pair)
for i=1:8
    if i == 2
        color = 'yellow';
    else
        color = 'blue';
    end
    plot_camera_pair(cam_positions, i, i+4, color);
end


hold off;
axis equal tight;

xlim([-0.06 0.06]);
ylim([-0.04 0.04]);

axis off
print -dpdf -r600 /tmp/cameras_and_sparse_points_cloud.pdf

end

function plot_camera_axis_direction(C, R, P, label, x_offset, y_offset)
    % Plots (camera) coordinate frame at C rotated by R with respect
    % to the world coordinate frame as seen from camera P
    %
    % C has to be specified in euclidean coordinates
    
    axis_length_factor = 2;
    
    R = axis_length_factor*R';
    
    % endpoints of "base vectors" of the coordinate frame being plotted
    X = C + R(:,1);
    Y = C + R(:,2);
    Z = C + R(:,3);
    
    c = p2e(P*e2p(C));
    x = p2e(P*e2p(X));
    y = p2e(P*e2p(Y));
    z = p2e(P*e2p(Z));
    
    % plot whole camera's coordinate frame:
    % plot([c(1) c(1) c(1); x(1) y(1) z(1)], [c(2) c(2) c(2); x(2), y(2), z(2)], 'k-', 'LineWidth', 2);
    % plot camera coordinate frame's z axis only:
    plot([c(1); z(1)], [c(2); z(2)], 'k-', 'LineWidth', 3);
    plot(c(1), c(2), 'o', 'MarkerSize', 7, 'color', 'black', 'MarkerFaceColor', 'black');
    
    % text(x(1), x(2), 'X');
    % text(y(1), y(2), 'Y');
    % text(z(1), z(2), 'Z');
    
    if nargin > 3
        if nargin <= 4
            x_offset = 0;
            y_offset = 0;
        end
        text(c(1) + x_offset, c(2) + y_offset, label, 'FontSize', 21);
    end
end

% plot "pair" of cameras (line connecting cameras in the pair)
function plot_camera_pair(cam_positions, i1, i2, color)
    plot( ...
        [cam_positions(1, i1); cam_positions(1, i2)], ...
        [cam_positions(2, i1); cam_positions(2, i2)], '-', 'LineWidth', 3, 'color', color);
end

function [x_offset, y_offset] = get_label_offset(i);
    x_offset = 0.001;
    y_offset = -0.001;
    if ismember(i, [1 5 9])
        x_offset = -0.007;
        
        if i ==  1
            y_offset = -0.001;
        else
            y_offset = 0.002;
        end
    end;
    
    if ismember(i, [6 7 8 10 11 12])
        x_offset = 0.0012;
        y_offset = 0.004;
    end
%     if ismember(i, [6 7 8])
%         y_offset = 0.005;
%     end
end