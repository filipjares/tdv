function n = p2e(m)
    n = zeros(size(m,1) - 1, size(m,2));
    % TODO: prepsat bez cyklu
    for i = 1:size(m,1)-1
        n(i,:) = m(i,:)./m(end,:);
    end
end