function pcpath = server2pc(PNIserverpath)
% Convert an absolute path on PNI's server to a path accessible locally
validateattributes(PNIserverpath, {'char'}, {'row'})
pcpath = strrep(PNIserverpath, '/mnt/cup/labs/brody/', 'X:\');
pcpath = strrep(pcpath, '/mnt/cup/people/zhihaol/brody/', 'V:\');
pcpath = strrep(pcpath, '/', '\');