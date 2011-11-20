function [d, pA0, pB0] = lines_distance(pA, a, pB, b)
    % [d, pA0, pB0] = find_lines_distance(pA, a, pB, b)
    %
    % Returns distance between two lines and returns points on each line
    % that is the closest one to the other line. All the parameters and
    % results are in euclidean coordinates
    %
    % Input:    pA  - point on line A
    %           a   - tangent vector of the line A
    %           pB  - point on line B
    %           b   - tangent vector of the line B
    % Output:   d   - distance between lines
    %           pA0 - point on line A that is the closest one to the line B
    %           pB0 - point on line B that is the closest one to the line A

    pAB = pB - pA;
    m = cross(b, a);
    
    if (norm(m) < 100*eps)
        % lines are paralell
        d = sqrt(pAB'*pAB - (pAB'*a/norm(a))^2);
        pA0 = [NaN NaN NaN]';
        pB0 = [NaN NaN NaN]';
    else
        % lines are skew or intersect
        m2 = m'*m;
        r = cross(pAB, m)/m2;

        tA = r'*b;
        tB = r'*a;

        pA0 = pA + tA*a;
        pB0 = pB + tB*b;
        d = abs(pAB'*m)/sqrt(m2);
    end

end