function N = ransac_min_sample_size(desired_success_rate, inlier_probability, m)
    % N = ransac_min_sample_size(desired_success_rate, inlier_probability)
    %
    % Returns minimum number of iteratations of the ransac algorithm
    % to perform if we want the probability of choosing at least one
    % proposal (random sample of m points) with no outliers to be
    % desired_success_rate and the probability of point being an inlier
    % is inlier_probability
    %
    % Inputs:   desired_success_rate - wanted ransac success rate i.e.
    %                                  the proportion of cases in which you
    %                                  want the ransac to find valid result
    %           inlier_probability   - probability of single point being
    %                                  an inlier
    %           m                    - minimum number of points required
    %                                  to constitute a proposal
    %
    % Outputs:  N - minimal number ransac iterations you need to perform

    N = ceil(log(1 - desired_success_rate)/log(1-inlier_probability^m));

end