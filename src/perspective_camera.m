
% Object (House) vertices definition:
z = 4;
X1 = e2p([ ...
      -0.5  0.5 0.5 -0.5 -0.5 -0.3 -0.3 -0.2 -0.2  0  0.5; ...
      -0.5 -0.5 0.5  0.5 -0.5 -0.7 -0.9 -0.9 -0.8 -1 -0.5; ...
       z    z   z    z    z    z    z    z    z  z    z ]);
X2 = X1;
X2(3,:) = X1(3,:)+0.5;

% The internal camera matrix
K = [ 1000    0 500; ...
         0 1000 500; ...
         0    0   1 ];

% All the cameras (there will be N of them)
N = 6; Ps = zeros(3, 4, N);

% Cameras definition:
% P1:
    Ps(:,:,1) = K*[eye(3) zeros(3,1)];
% P2:
    C = [0; -1; 0];
    Ps(:,:,2) = K*[eye(3) -1*C];
% P3:
    C = [0; 0.5; 0];
    Ps(:,:,3) = K*[eye(3) -1*C];
% P4:
    alpha = 0.5; c = cos(alpha); s = sin(alpha);
    R = [ ...
        1  0  0; ...
        0  c -s; ...
        0  s  c];
    C = [0;-3;0.5];
    Ps(:,:,4) = K*R*[eye(3) -1*C];
% P5:
    C = [0;-5;4.2];
    alpha = pi/2; c = cos(alpha); s = sin(alpha);
    R = [ ...
        1  0  0; ...
        0  c -s; ...
        0  s  c];
    Ps(:,:,5) = K*R*[eye(3) -1*C];
% P6:
    C = [-1.5;-3;1.5];
    alpha = -0.5; c = cos(alpha); s = sin(alpha);
    Ry = [ ...
        c  0  s; ...
        0  1  0; ...
       -s  0  c];
    alpha = 0.8; c = cos(alpha); s = sin(alpha);
    Rx = [ ...
        1  0  0; ...
        0  c -s; ...
        0  s  c];
    R = Rx*Ry;
    Ps(:,:,6) = K*R*[eye(3) -1*C];

% define indices of points to be emphasized
ix = [1 2 3 4 13];

% For each camera display its image    
for i = 1:N
    P = Ps(:,:,i); % Current camera

    % Compute projections of the object vertices
    x1 = p2e(P*X1);
    x2 = p2e(P*X2);

    % Prepare the figure and draw the image
    figure(i);
    plot(x1(1,:), x1(2,:), 'r-', 'linewidth', 2); % Front side of the house in red
    hold on;
    plot(x2(1,:), x2(2,:), 'b-', 'linewidth', 2); % Back side of the house in blue
    plot([x1(1,:); x2(1,:)], [x1(2,:); x2(2,:)], 'k-', 'linewidth', 2); % Lines connecting front and back side
    set(gca, 'ydir', 'reverse');
    axis equal;
    
    % plot emphasized points
    x = [x1 x2];
    points{i} = x(:,ix);
    for j = ix
        h = plot(x(1,j), x(2,j), 'markerfacecolor', color_hash(j), 'markersize', 7, 'marker', 'o');
    end
    
    hold off;
end