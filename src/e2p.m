function u = e2p(m)
    u = ones(size(m,1) + 1, size(m,2));
    u(1:size(m,1), 1:size(m,2)) = m;
end