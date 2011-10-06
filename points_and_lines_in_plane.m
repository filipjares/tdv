
% Corner indexes are shown in their neighbourhood.
%
%                           border_top
%             1                                   2
%                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                %                             %
%                %                             %
%                %                             %
%                %                             %
%   border_left  %                             %  border_right
%                %                             %
%                %                             %
%                %                             %
%                %                             %
%                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          4                                      3
%                          border_bottom
%

MARKER_SIZE = 10;

X_LO = 1;
X_HI = 800;
Y_LO = 1;
Y_HI = 600;


% Corners:
C = [ X_LO X_HI X_HI   X_LO; ...
	  Y_LO   Y_LO Y_HI Y_HI; ...
	  1   1   1   1];

% Borders:
borders = cross(C, C(:,[2:4, 1]), 1);
border_top    = borders(:,1);
border_right  = borders(:,2);
border_bottom = borders(:,3);
border_left   = borders(:,4);

% Plot borders:
figure(1);
plot(0,0);
set(gca, 'ydir', 'reverse');
line(C(1,[1 2 3 4 1]), C(2,[1 2 3 4 1]), 'Color', 'k','LineWidth',4);
hold on;

% Obtain user input (four points)
x = let_the_user_define_points_in_picture(4, false);
x_e = p2e(x); % to inhomogenous representation

plot(x_e(1,1:2), x_e(2,1:2), 'bo', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);
plot(x_e(1,3:4), x_e(2,3:4), 'go', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);

% Blue line connects first pair of points, green one connects second pair
blue_line  = cross(x(:,1), x(:,2));
green_line = cross(x(:,3), x(:,4));

% All intersections of blue and green line with border lines
all_blue_x_e  = p2e(cross(borders, blue_line*ones(1,4)));
all_green_x_e = p2e(cross(borders, green_line*ones(1,4)));

% Column indices of columns containing intersections which are inside the image area
blue_indices = fits_into_image(all_blue_x_e);
green_indices = fits_into_image(all_green_x_e);

% Draw the blue line
blue_endpoints = all_blue_x_e(:, find(blue_indices));
line(blue_endpoints(1,:), blue_endpoints(2,:), 'Color', 'b','LineWidth',2);

% Draw the green line
green_endpoints = all_green_x_e(:, find(green_indices));
line(green_endpoints(1,:), green_endpoints(2,:), 'Color', 'g','LineWidth',2);

% Intersection of blue and green line
m_e = p2e(cross(blue_line, green_line));
if all(fits_into_image(m_e))
    plot(m_e(1,1), m_e(2,1), 'ro', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);
end

hold off;

%% Image of the scene with homography applied

figure(2);
plot(0,0);
set(gca, 'ydir', 'reverse');

% The homography
H = [1     0.1   0; ...
     0.1   1     0; ...
     0.004 0.002 1 ];

% Borders
C = p2e(H*C);
line(C(1,[1 2 3 4 1]), C(2,[1 2 3 4 1]), 'Color', 'k','LineWidth',4);
hold on;

% Chosen points
x_e = p2e(H*x);
plot(x_e(1,1:2), x_e(2,1:2), 'bo', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);
plot(x_e(1,3:4), x_e(2,3:4), 'go', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);

% Blue and green lines connetcting point pairs
blue_endpoints = p2e(H*e2p(blue_endpoints));
line(blue_endpoints(1,:), blue_endpoints(2,:), 'Color', 'b','LineWidth',2);
green_endpoints = p2e(H*e2p(green_endpoints));
line(green_endpoints(1,:), green_endpoints(2,:), 'Color', 'g','LineWidth',2);

% Blue and green line intersection
if all(fits_into_image(m_e))
    m_e = p2e(H*e2p(m_e));
    plot(m_e(1,1), m_e(2,1), 'ro', 'LineWidth', 4, 'MarkerSize', MARKER_SIZE);
end

hold off;