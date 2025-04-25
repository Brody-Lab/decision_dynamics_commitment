function windowspath = cup2windows(unixpath)
% Convert the path to a mounted network location in my local Windows machine to a Unix path in the PNI fileserver
    windowspath = unixpath;
    windowspath = strrep(windowspath, '/mnt/cup/people/zhihaol/', 'V:\');
    windowspath = strrep(windowspath, '/mnt/cup/labs/brody/', 'X:\');
    windowspath = strrep(windowspath, '/', '\');
end