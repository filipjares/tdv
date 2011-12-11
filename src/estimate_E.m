function [E, R, b, P1, P2, best_inl_ix, in_front] = estimate_E(K, pc)
    % Robust ML Estimate
    %
    % [E, R, b, P1, P2, best_inl_ix, in_front] = estimate_E(K, pc, ...
    %
    % Input:    K  - camera calibration matrix (of both cameras)
    %           pc - camera correspondences as returned by wbs/wbs_match_descriptions.m
    % 
    
    % FIXME:
    %   - do I have to use both
    %       - best_ix and best_inl_ix?
    %   	- pc and all_u1 ...?
    %       - in_front (probably yes)
    %   - determine inlier_probability dynamically
    %   - will I return everything? R, b, P1, P2?
    %   - rename all_u1 to something better, avoid using several variables
    %     for the same purpose
    %   - improve random sample choice
    
    inlier_probability = 0.6;
    m = 5;  % min. number of image points correspondences determining E matrix
    N = ransac_min_sample_size(0.95, inlier_probability, m);

    % Use all (mis)matching points
    all_u1 = K\e2p(pc(1:2,:));
    all_u2 = K\e2p(pc(3:4,:));

    best_support = -1;
    best_inl_ix = [];
    best_ix = [];
    bestE = [];

    THR = 2; % [px]
    THR = 2*THR^2;

    i = 0;
    while true
        % choose sample of points
        % ix = (i*m+1):(i*m+5);
        ix = (i+1):(i+5);
        u1 = all_u1(:,ix);
        u2 = all_u2(:,ix);

        % each sample usually gives multiple Essential matrix candidates
        Evec = calibrated_fivepoint(u1, u2);
        % E matrix candidates are stored as columns of Evec
        for j = 1:size(Evec,2)
            % we try all of them but...
            E = reshape(Evec(:,j), 3, 3)';
            % only use such candidates (E matrices) that have all the points
            % corresponding to pairs in (u1,u2) in front of both cameras; we
            % decompose such E matrix to camera pair P1, P2
            [~, ~, P1, P2] = EutoRb(E, u1, u2);
            if ~isempty(P1)
                % we reproject all points forth and back
                X = Pu2X(P1, P2, all_u1, all_u2);

                depths1 = depth_in_camera(X, P1);
                depths2 = depth_in_camera(X, P2);
                in_front = (depths1 > 0 & depths2 > 0);

                % TODO: points visibility
                v1 = e2p(p2e(K*P1*X));
                v2 = e2p(p2e(K*P2*X));
                % and compute sum of reprojection errors
                % FIXME: here I should better use euclidean not projective
                % coordinates to compute reprojection errors
                err = sum((v1 - e2p(pc(1:2,:))).^2) + sum((v2 - e2p(pc(3:4,:))).^2); % TODO use different error function?
                inl_ix = err < THR & in_front;
                support = sum(inl_ix);

                if (support > best_support)
                    best_support = support;
                    bestE = E;
                    best_inl_ix = inl_ix;
                    best_ix = ix;
                end
            end
        end

        i = i + 1;
        if (i > N); break; end
    end

    E = bestE;
    u1 = all_u1(:,best_ix);
    u2 = all_u2(:,best_ix);
    [R, b, P1, P2] = EutoRb(E, u1, u2);

    % reprojection error
    % X = Pu2X(P1, P2, all_u1, all_u2);

    % depths1 = depth_in_camera(X, P1);
    % depths2 = depth_in_camera(X, P2);
    % in_front = (depths1 > 0 & depths2 > 0);

    % smazat
    % v1 = e2p(p2e(P1*X));
    % v2 = e2p(p2e(P2*X));
    % err = vlen(v1 - all_u1) + vlen(v2 - all_u2); % TODO: FIXME

    % inliers_ix = err < mean(err); % FIXME: compute the threshold instead of fixed one




end