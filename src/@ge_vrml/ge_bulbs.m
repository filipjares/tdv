function ge = ge_bulbs(ge, pts)

    for i = 1:size(pts,2)
        bulb(ge.fh, pts(:,i), [1;1;0.25], 0.05);
    end

end