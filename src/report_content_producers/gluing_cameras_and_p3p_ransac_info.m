
CCC = zeros(info.i,1);

for i = 1:info.i
    
    j = 0;
    while (j+1 <= length(info.other_cam_new_X{i}) && ~isempty(info.other_cam_new_X{i}{j+1}));
        j = j + 1;
    end
    
    verifiedSet = [];
    wholeSet = [];
    total = 0;
    verified = 0;
    for k = 1:12
        verifiedSet = union(verifiedSet, ...
            info.corresp{i}.Xu{k}(info.corresp{i}.Xu_verified{k},1));
        wholeSet = union(wholeSet, ...
            info.corresp{i}.Xu{k}(:,1));
        % total = total + length(info.corresp{i}.Xu_verified{k});
        % verified = verified + sum(info.corresp{i}.Xu_verified{k});
    end
    
    CCC(i) = length(verifiedSet);
    fprintf('Po pridani kamery %2d: %d\t%d\t%d\n', ...
        info.cam_id(i), ...
        info.other_cam_new_X{i}{j}.allXCount, ...
        length(verifiedSet), ...
        length(wholeSet) ...
    );
end

fprintf('\n\n\n');
fprintf('Pořadí & Kamera & Počet iterací & počet předb. korespondencí & z toho procent inlierů\\\\\n')
for i = 1:info.i
    
    verifiedSet = [];
    wholeSet = [];
    total = 0;
    verified = 0;
    for k = 1:12
        verifiedSet = union(verifiedSet, ...
            info.corresp{i}.Xu{k}(info.corresp{i}.Xu_verified{k},1));
        wholeSet = union(wholeSet, ...
            info.corresp{i}.Xu{k}(:,1));
        % total = total + length(info.corresp{i}.Xu_verified{k});
        % verified = verified + sum(info.corresp{i}.Xu_verified{k});
    end
    
    fprintf('%d\t& %s\t& %d\t& %d\t& %2.1f\t& %d\t\\\\\n', i, images(info.cam_id(i)).figId, ...
        info.ransac_info{i}.iterations_count, ...
        info.ransac_info{i}.corresp_count, ...
        100*info.ransac_info{i}.best_inlier_probability, ...
        length(verifiedSet) ...
    );
end