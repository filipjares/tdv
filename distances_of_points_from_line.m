function distances = distances_of_points_from_line(l, X)

    N = size(X,2);
    
    n = l(1:2,1);
    norm_n = norm(n);
    n = n/norm_n;
    d = l(3,1)/norm_n;
    distances = abs(n'*X + d*ones(1,N));

end