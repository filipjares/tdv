function X = rays_intersection(C1, d1, C2, d2)
    % X = rays_intersection(C1, d1, C2, d2)
    %
    % Computes "points of intersection" of pairs of rays defined by camera
    % centers C1 and C2 and matrices made by direction vectors d1 and d2.
    % To each d1(:,i), d2(:,i) pair corresponds the 3D point X(:,i).
    %
    % Rays do not really have to intersect. The closest point to both rays
    % is returned.
    %
    % Inputs:   C1, C2 - 3x1 matrices representing camera centers in
    %                    euclidean coordinates (C1 is common point of all
    %                    rays defined by C1 and d1; C2 is common point of
    %                    all rays defined by C2, D2.
    %           d1, d2 - 3xn matrices of direction vectors (euclidean) or
    %                    rays in question
    %
    % Output:   X - 4xn matrix of columns corresponding to intersections
    %               of given pairs of rays.
    %
    % Expected use: C1 and C2 corresponding to two (distinct) camera
    % centers, d1 and d2 corresponding to rays that intersect in points X

    assert(all(size(d1) == size(d2)));
    n = size(d1,2);
    
    m = cross(d1, d2,1);
    
    X = ones(4,n);  % X(4,:) == 1   standard homogeneous representation
    
    for i = 1:n
        % if given rays are parallel, result is on the plane at infinity
        if norm(m(:,i)) < 100*eps
            X(:,i) = [d1; 0];
        else
           [d a b] = lines_distance(C1, d1(:,i), C2, d2(:,i));

           % result (homogeneous representation of finite point)
           X(1:3,i) = a + d*(b-a)/2;

        end
    end

end