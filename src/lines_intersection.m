function X = lines_intersection(C1, d1, C2, d2)
    % X = lines_intersection(C1, d1, C2, d2)
    %
    % Computes the "point of intersection" of two (i = 1:2) lines, each
    % defined by point on it (Ci) and tangent vector (di). Points do not
    % have to really intersect. The closest point to both lines is returned.
    %
    % All the parameters are expected to be in euclidean coordinates.
    % Result is returned in homogeneous coordinates.
    %
    % Expected use: C1 and C2 corresponding to two (distinct) camera
    % centers, d1 and d2 corresponding to rays that intersect in point X
    
    % TODO: add support for d1 and d2 being matrices (representing multiple
    % vectors)

    m = cross(d1, d2);
    
    % if given rays are parallel, result is on the plane at infinity
    if norm(m) < 100*eps
        X = [d1; 0];
    else
       [d a b] = lines_distance(C1, d1, C2, d2);
       
       % result (homogeneous representation of finite point)
       X = ones(4,1);               % X(4,1) == 1 ... result normalized
       X(1:3,1) = a + d*(b-a)/2;
        
    end
    

end