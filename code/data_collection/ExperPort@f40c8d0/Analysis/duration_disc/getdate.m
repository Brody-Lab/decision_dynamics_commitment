function [dstr] = getdate(doffset,varargin)
% given an offset of number of days, returns the date
% today is 0; yesterday is -1, tomorrow is +1, etc.,


n = now;
n = n + doffset;

v = datevec(n);
yy=int2str(v(1)); yy = yy(3:4);
mm = int2str(v(2)); if v(2) < 10, mm = ['0' mm];end;
dd = int2str(v(3)); if v(3) < 10, dd = ['0' dd]; end;
dstr = [yy mm dd 'a'];
fprintf(1, 'File date is: %s\n', dstr);
 