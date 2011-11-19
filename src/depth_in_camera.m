function depth = depth_in_camera(X, P)
    % depth = depth_in_camera(X, P)
    %
    % Computes depth of point X with respect to finite camera given by
    % camera matrix P.  Based on result 6.1 in [H&Z (2nd ed.), p. 162].
    
    M = P(:,1:3);
    w = P(3,:)*X;
    detM = det(M);
    
    if (abs(detM) < 1000*eps)
        error('Can only compute depth of point with respect to FINITE camera');
    end
    
    depth = sign(detM)*w / X(4,1) / norm(M(3,:));

end