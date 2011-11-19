function color = color_hash(i)

    % different colors
    cl = [ 1   0   0; ...
           0 0.8   0; ...
           1   1   0; ...
           0   0   0; ...
           0   0.5 0.5; ...
           0   0   1; ...
           1   0   1; ...
          .5   0   .5; ...
           1   .5  0; ...
         ]; 
     
     color = cl(mod(i-1, size(cl,1))+1,:);

end