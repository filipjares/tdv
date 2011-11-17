function l = get_line_from_picture(handle)

    u = get(handle, 'xdata');
    v = get(handle, 'ydata');
    endpoints = [u; v; 1 1];
    
    l = cross(endpoints(:,1), endpoints(:,2));

end