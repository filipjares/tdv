function plot_coordinate_frame(C, R, P, label)
    % Plots (camera) coordinate frame at C rotated by R with respect
    % to the world coordinate frame as seen from camera P
    %
    % C has to be specified in euclidean coordinates
    
    R = R';
    
    % endpoints of "base vectors" of the coordinate frame being plotted
    X = C + R(:,1);
    Y = C + R(:,2);
    Z = C + R(:,3);
    
    c = p2e(P*e2p(C));
    x = p2e(P*e2p(X));
    y = p2e(P*e2p(Y));
    z = p2e(P*e2p(Z));
    
    plot([c(1) c(1) c(1); x(1) y(1) z(1)], [c(2) c(2) c(2); x(2), y(2), z(2)], 'k-', 'LineWidth', 2);
    
    text(x(1), x(2), 'X');
    text(y(1), y(2), 'Y');
    text(z(1), z(2), 'Z');
    
    if nargin > 3
        text(c(1), c(2), label);
    end
end