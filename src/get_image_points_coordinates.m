function u = get_image_points_coordinates(images, cam_ix, pt_indices)
    % Return image points in camera cam_ix with point indices pt_indices
    % 
    % Input: images   - the images cell array containing images, points, ...
    %        cam_ix   - index of camera we are interested in
    %        pt_indices - indices of point in the cam_ix picture
    %
    % Ouptut: u - 2xn matrix containing euclidean coordinates of image points

	u = zeros(2,length(pt_indices));
    for i = 1:length(pt_indices)
        u(:,i) = [images(cam_ix).pts(pt_indices(i)).x; ...
                  images(cam_ix).pts(pt_indices(i)).y];
    end

end