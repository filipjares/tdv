function sse = ss_of_distances_from_line(l, X)

    sse = sum(distances_of_points_from_line(l,X).^2);
    
end