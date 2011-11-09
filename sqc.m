function S = sqc(x)
    % returns skew symmetric matrix (3×3) for cross product with vector x

    S = [ 0    -x(3)  x(2); ...
          x(3)  0    -x(1); ...
         -x(2)  x(1)  0];
end