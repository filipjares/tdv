function X = Pu2X(P1, P2, u1, u2)

    % P = K*[R t] = K*R*[I -C] = [K*R -K*R*C] = [Q -QC] = [Q q]
    % q = -QC
    % C = -inv(Q) * q;
    
    assert(all(size(u1) == size(u2)));
    assert(size(u1,1) == 3);
    % TODO: assert Q1, Q2 are non singular...
    
    n = size(u1,2);    
    
    Q1 = P1(:,1:3);
    q1 = P1(:,4);
    C1 = -Q1\q1;
    d1 = Q1\u1;
    
    Q2 = P2(:,1:3);
    q2 = P2(:,4);
    C2 = -Q2\q2;
    d2 = Q2\u2;
    
    X = zeros(4,n);
    
    % TODO: replace this loop with matrix operation
    for i = 1:n
        X(:,i) = rays_intersection(C1, d1(:,i), C2, d2(:,i));
    end

end