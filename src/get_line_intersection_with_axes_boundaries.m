function endpoints = get_line_intersection_with_axes_boundaries(l)

    Xs = xlim;
    Ys = ylim;
    
    X_LO = Xs(1);
    X_HI = Xs(2);
    Y_LO = Ys(1);
    Y_HI = Ys(2);
    
    % Corners:
    C = [ X_LO X_HI X_HI   X_LO; ...
          Y_LO   Y_LO Y_HI Y_HI; ...
          1   1   1   1];

    % Borders:
    borders = cross(C, C(:,[2:4, 1]), 1);
    
    % All intersections of blue and green line with border lines
    all_intersections_e  = p2e(cross(borders, l*ones(1,4)));

    % Column indices of columns containing intersections which are inside the image area
    blue_indices = fits_into_image(all_intersections_e);

    % Draw the blue line
    endpoints = all_intersections_e(:, blue_indices);

end