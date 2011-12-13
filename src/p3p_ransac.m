function [R, t, best_inliers] = p3p_ransac(K, X, u)

    assert(size(X,2) == size(u,2));
    assert(size(X,1) == 4);
    assert(size(u,1) == 3);
    
    corresp_count = size(u,2);

    THR = 2; % [px]
    THR = 2*THR^2;

    Nmax = Inf;

    best_support = 0;
    best_inliers = [];
    R_best = [];
    t_best = [];

    n = 0;
    while true
        n = n + 1;

        % Generate hypothesis R, t
        indices = max([1 1 1]', round(corresp_count*rand(3,1)));   % select random indices
        while indices(1) == indices(2) || indices(2) == indices(3)
            if indices(1) == indices(2)
                indices(2) = max(1, round(corresp_count*rand(1,1)));
            end
            if indices(2) == indices(3)
                indices(3) = max(1, round(corresp_count*rand(1,1)));
            end
        end
        X3 = X(:,indices);
        u3 = u(:,indices);
        Xc = p3p_grunert(X3, K\u3);

        for i = 1:size(Xc,2)
            X3c = Xc{i};
            [R, t] = XX2Rt_simple(X3, X3c);
            % such that X3c = R*X3 + t

            P = K*[R t];

            % For each hypothesis R, t do:
            % - compute set of inliers and support

            % these points have to be verified: Xn;

            depths = depth_in_camera(X, P);
            in_front = (depths > 0);

            reprojected_points = p2e(P*X);
            original_points = p2e(u);
            err = sum((reprojected_points - original_points).^2);
            inl_ix = err < THR & in_front;
            support = sum(inl_ix);

            if support > best_support
                best_support = support;
                best_inliers = inl_ix;
                R_best = R;
                t_best = t;
            end

            % Update RANSAC stopping criterion w.r.t. the number of inliers
            inlier_count = support;
            inlier_probability = inlier_count/corresp_count;
            if inlier_probability == 1
                Nmax = 0;
            else
                Nmax = ransac_min_sample_size(0.95, inlier_probability, 3);
            end

        end

        if (n > Nmax); break; end
    end
    
    R = R_best;
    t = t_best;
    
end