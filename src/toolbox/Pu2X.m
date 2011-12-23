function X = Pu2X(P1, P2, u1, u2)
  
    assert(all(size(u1) == size(u2)));
    if (size(u1, 1) == 3)
        u1 = p2e(u1);
        u2 = p2e(u2);
    end
    if (size(u1, 1) ~= 2)
        error('u1 and u2 have to be matrices of euclidean (2xn) or homogenous (3xn) points.');
    end
    
    n = size(u1,2);    
    
    % Konstatni cast matice A
    C = [P1(1,:); P1(2,:); P2(1,:); P2(2,:)];
    
    X = zeros(4,n);
    for i = 1:n
        A = [u1(:,i) * P1(3,:); u2(:,i) * P2(3,:)] - C;
        [~,~,V] = svd(A);
        X(:,i) = V(:,end);
    end

end