function draw_line_into_axes(l)
    
    points = get_line_intersection_with_axes_boundaries(l);
    line(points(1,:), points(2,:), 'Color', 'g');

end