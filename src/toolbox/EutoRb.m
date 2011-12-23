function [R b P1 P2] = EutoRb(E, u1, u2)
    % [R b P1 P2] = EutoRb(E, u1, u2)
    %
    % Essential matrix decomposition with chirality
    %
    % Inputs:   E      - the essential matrix (3×3)
    %           u1, u2 - corresponding image points in homogeneous
    %                    coordinates (3×n), used for chirality test
    % Outputs:  R - relative rotation (3×3) or [] if chirality test fails
    %           b - relative translation, euclidean (3×1), unit length
    %           P1, P2 - 
    %
    % The sessential matrix E is decomposed such that k*E = R * sqc( b )
    % for some k != 0

    assert(size(u1,2) == size(u2,2));
    
    [U D V] = svd(E);
    if det(U) < 0
        U = -U;
    end
    if det(V) < 0
        V = -V;
    end

    I = eye(3);
    P1 = [I zeros(3,1)];
    
    opts = [1 -1];  % possible choices of alpha, beta
    for alpha = opts
       for beta = opts;
           W = [ 0 alpha 0; -alpha 0 0; 0 0 1];
           R = U * W * V';
           b = V * [0 0 beta]';
           
           P2 = R*[I -b];
           
           X = Pu2X(P1, P2, u1, u2);
           depths1 = depth_in_camera(X, P1);
           depths2 = depth_in_camera(X, P2);
           
           all_in_front = all(depths1 > 0) & all(depths2 > 0);
           
           if all_in_front
               b = b/norm(b);   % normalize beta
               return;          % We have the right R and b
           end
       end
    end
    
    R = [];     % no solution
    b = [];
    P1 = [];
    P2 = [];
end