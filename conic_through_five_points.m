
% This script displays window and lets the user select four points
% in the plane. Then it shows conic that intersects all the given points.

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
grid on;
axis equal;
hold on;

A = zeros(5,6);
point_count = 5;

x = let_the_user_define_points_in_picture(point_count, true);

x_e = p2e(x);
for i = 1:point_count
    u = x_e(1,i);
    v = x_e(2,i);
    A(i,:) = [u^2 u*v v^2 u v 1];
end

% compute conic parameters:
c = null(A);
if(size(c,2) > 1)
    disp('Display of some of the inifinitely many solutions not implemented.');
else
    syms u v;
    f = c(1)*u^2 + c(2)*u*v + c(3)*v^2 + c(4)*u + c(5)*v + c(6);
    ezplot(f, [0 800]);
    colormap([0 0 1]);
end

hold off;