function plot_epipolar_geometry(im1, im2, v1, v2, best_inl_ix, in_front)
    % Plots two images im1, im2 (related by epipolar geometry) and points
    % (inliers with indices best_inl_ix) v1, v2, representing this epipolar
    % geometry

    subplot(2,1,1);
    image(im1); axis equal tight off; hold on;
    % inliers in this picture
    plot(v1(1,best_inl_ix), v1(2,best_inl_ix), 'or', 'markerfacecolor', 'r');
    if nargin > 5
        % outliers in this picture
        plot(v1(1,~best_inl_ix & in_front), v1(2,~best_inl_ix & in_front), 'ok', 'markerfacecolor', 'k');
        % plot lines connecting points in this picture with points in the other one
        plot([v1(1,~best_inl_ix & in_front); v2(1,~best_inl_ix & in_front)], ...
            [v1(2,~best_inl_ix & in_front); v2(2,~best_inl_ix & in_front)], '-k', 'LineWidth', 2);
    end
    plot([v1(1,best_inl_ix); v2(1,best_inl_ix)], ...
        [v1(2,best_inl_ix); v2(2,best_inl_ix)], '-r', 'LineWidth', 2);
    hold off;

    subplot(2,1,2);
    image(im2); axis equal tight off; hold on;
    % inliers in this picture
    plot(v2(1,best_inl_ix), v2(2,best_inl_ix), 'or', 'markerfacecolor', 'r');
    if nargin >5
        % outliers in this picture
        plot(v2(1,~best_inl_ix & in_front), v2(2,~best_inl_ix & in_front), 'ok', 'markerfacecolor', 'k');
        % plot lines connecting points in this picture with points in the other one
        plot([v1(1,~best_inl_ix & in_front); v2(1,~best_inl_ix & in_front)], ...
            [v1(2,~best_inl_ix & in_front); v2(2,~best_inl_ix & in_front)], '-k', 'LineWidth', 2);
    end
    plot([v1(1,best_inl_ix); v2(1,best_inl_ix)], ...
        [v1(2,best_inl_ix); v2(2,best_inl_ix)], '-r', 'LineWidth', 2);
    hold off;

end