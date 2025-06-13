function [foundit] = is_in_path(mydir)
% returns true if mydir is in the Matlab path; else, returns false

p = path;
idx = strfind(p,':');

foundit=0;

cdir = p(1:idx-1);
if strcmpi(mydir, cdir)
    foundit=1;
    return;
end;
    
for pos = 2:length(idx)
    cdir = p(idx(pos-1)+1:idx(pos)-1);
  % fprintf(1,'%s\n',cdir);
if strcmpi(mydir, cdir)
    foundit=1;
    return;
end;

end;