function unixpath = windows2cup(windowspath)
% Convert the path to a mounted network location in my local Windows machine to a Unix path in the PNI fileserver
    unixpath = windowspath;
    unixpath = strrep(unixpath, 'V:\', '/mnt/cup/people/zhihaol/');
    unixpath = strrep(unixpath, 'X:\', '/mnt/cup/labs/brody/');
    unixpath = strrep(unixpath, '\', '/');
end