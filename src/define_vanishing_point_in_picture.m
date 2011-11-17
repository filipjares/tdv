function [vp, line1_h, line2_h, vp_h] = define_vanishing_point_in_picture(color)

    if nargin == 0
        color = 'b';
    end

    x = let_the_user_define_points_in_picture(2, false);
    line1 = cross(x(:,1), x(:,2));
    endpoints = get_line_intersection_with_axes_boundaries(line1);
    line1_h = line(endpoints(1,:), endpoints(2,:), 'Color', color,'LineWidth',1);
    
    x = let_the_user_define_points_in_picture(2, false);
    line2 = cross(x(:,1), x(:,2));
    endpoints = get_line_intersection_with_axes_boundaries(line2);
    line2_h = line(endpoints(1,:), endpoints(2,:), 'Color', color,'LineWidth',1);
    
    % edit_lines(gca);

    vp = cross(line1, line2);
    vp_e = p2e(vp);
    vp_h = plot(vp_e(1), vp_e(2), ['o' color], 'LineWidth', 2);

    % xdata = get(vp1_line1_handle, 'xdata')
    % ydata = get(vp1_line1_handle, 'ydata')
    
    % TODO: remove handles if not needed
    
end