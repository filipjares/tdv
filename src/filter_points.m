function ix = filter_points(X3D, pos, cameras)

    % volani: filter_points(Xvert{2}, pos{13}, cameras);

    % 3 points defining a plane of ground
    groundPlane = [3181 559; 3183 1964; 2978 1010]';

    % two points next to each other
    % plane = [2955 1026; 2955 1027]';

    % 3 points defining plane of door
    doorPlane = [1543 1726; 1704 956; 2585 975]';

    % 3 planes defining plane of text above the door
    % plane = [98 2111; 805 1573; 249 954]';

    X = e2p(p2e(X3D));

    % l = length(X);
    % X = [X ones(4,numel(-5:0.25:5)^3)];
    % 
    % for i = -5:0.25:5
    %     for j = -5:0.25:5
    %         for k = 5:0.25:15
    %             l = l + 1;
    %             X(:,l) = [i j k 1]';
    %         end
    %     end
    % end
    
    c = ones(3,size(X,2));

    groundPts = getPts(groundPlane, X3D, pos);
    doorPts = getPts(doorPlane, X3D, pos);
    
    % export_to_vrml('/tmp/pts-sparse.wrl', cameras, X(:,1:100:end), c(:,1:100:end), doorPts);
    
    n = null(doorPts');

    n1 = n;
    n1(4) = n(4) - 0.1;
    n2 = n;
    n2(4) = n(4) + 0.016;
    w1 = n1'*X;
    w2 = n2'*X;
    door_ix = w1 < 0 & w2 > 0;    % dvere
    
    n = null(groundPts');
    w = n'*X;
    ground_ix = abs(w) < 0.014;  % zem
    
    c(:,door_ix) = [1 0 0]'*ones(1,sum(door_ix,2));
    c(:,ground_ix) = [0 1 0]'*ones(1,sum(ground_ix,2));
    export_to_vrml('/tmp/pts-sparse-cropped.wrl', cameras, X, c, doorPts);

    block_ix = ...
        X(1,:) > -5.1  & X(1,:) < 5.2   &...
        X(2,:) > -5    & X(2,:) < 5     &...
        X(3,:) >  9.5  & X(3,:) < 14;
    
    ix = (door_ix | ground_ix) & block_ix;
    
end

function Pts = getPts(im1_pts, X, pos)

    Pts = nan(4,size(im1_pts,2));

    for i = 1:size(im1_pts,2);
        k = find(pos(1,:) == im1_pts(1,i) & pos(2,:) == im1_pts(2,i));
        Pts(:,i) = X(:,k);
    end
end
