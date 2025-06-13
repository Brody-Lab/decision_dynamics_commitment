function [ratname,datestr,expname]=extract_stringsfrommoviename(moviename)

%
% [ratname,datestr,expname]=extract_stringsfrommoviename(moviename)
%
% given string moviename in the format */EXPNAME_RATNAME_DATE*.* (where * is
% a wildcard) this function will return the experimenter name, ratname, and
% datestring.  If moviename is a complete path, this function will look for
% the character '/' to remove it from the front.  The datestring is
% returned with '-' between the year, month, and day, i.e. YYYY-MM-DD.
%

inds=findstr('/',moviename);
if ~isempty(inds), moviename=moviename( (inds(end)+1):end ); end

inds=findstr('_',moviename);
expname=moviename(1:(inds(1)-1));
ratname=moviename((inds(1)+1):(inds(2)-1));
datestr=[moviename((inds(2)+1):(inds(2)+4)) '-' ...
         moviename((inds(2)+5):(inds(2)+6)) '-' ...
         moviename((inds(2)+7):(inds(2)+8))];
