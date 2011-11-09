function l_h = draw_line_into_axes(l, color, linewidth)
    % l_h = draw_line_into_axes(l)
    %
    % Draws line l into current axes and returns its handle.
    % Line l is homogenous representation of the line
    
    if nargin < 2
        color = 'g';
    end
    if nargin < 3
        linewidth = 4;
    end
    
    points = get_line_intersection_with_axes_boundaries(l);
    l_h = line(points(1,:), points(2,:), 'Color', color, 'LineWidth', linewidth);

end