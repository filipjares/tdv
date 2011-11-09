function sse = ss_of_distances_from_line(l, X)

    n = l(1:2,1);
    norm_n = norm(n);
    n = n/norm_n;
    d = l(3,1)/norm_n;
    %l(1:2,1) = n;
    sse = sum((n'*X + d).^2);
    
end