function [Hs, Ha, Hp] = decomposeHomography(H)
    % Homography decomposition.
    %
    % [Hs, Ha, Hp] = decomposeHomography(H)
    %
    % Decomposes hompography H into product of similarity Hs, affinity Ha
    % and "essential" projective transformation Hp. In other words it finds
    % "essential" transformations Hs, Ha and Hp such that H == Hs*Ha*Hp.

    assert(rank(H) == 3);
    assert(H(3,3) > eps);
    
    t = H(1:2,3)/H(3,3);
    vec = H(3,1:2)';
    v = H(3,3);
    A = H(1:2,1:2);
    sRK = A - t*vec';
    [R, K2] = qr(sRK);
    s = sqrt(det(K2));
    K = K2/s;

    assert(norm([s*R*K + t*vec', v*t; vec', v] - H) < 1e-10);
    
    Hs = [s*R, t;       0, 0, 1];
    Ha = [K, [0 0]';    0, 0, 1];
    Hp = [eye(2), [0 0]'; vec', v];
   
end