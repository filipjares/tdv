function x = let_the_user_define_points_in_picture(n, plot_points)
    %let_the_user_define_points_in_picture 
    %   let_the_user_define_points_in_picture (n, plot_points)
    %
    %   Lets the user click n times in the picture and define points in the
    %   picture. Points are returned as columns in homogenous representation.
    
    MARKER_SIZE = 10;

    if (nargin < 2)
        plot_points = false;
    end
    
    was_hold = ishold;
    if (plot_points && ~was_hold)
        hold on;
    end
    
    % Obtain user input (five points)
    x = zeros(3,n);
    x(3,:) = ones(1,n);
    for i = 1:n
        [u, v] = ginput(1);
        x(1:2,i) = [u v]';
        if (plot_points)
            plot(u, v, 'bx', 'LineWidth', 1, 'MarkerSize', MARKER_SIZE);
        end
    end
    
    if (plot_points && ~was_hold)
        hold off;
    end

end