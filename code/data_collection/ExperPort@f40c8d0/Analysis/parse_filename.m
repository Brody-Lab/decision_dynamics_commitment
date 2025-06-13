%parse_filename.m   [ratname,protocol,datestr,version,datestruct,direc] = ...
%                       parse_filename(fname)
%
% Given a standard convention filename, parses it into ratname,
% protocol, datestring, version (i.e., 'a' or 'b', etc). Also returns
% datestruct, a stricture that breaks the date down into year, month,
% day, and returns direc, the directory in portion of the filename (if
% any). 
%
% A standard convention filename has: data_protocol_ratname_datestrversion.mat
% for example:     data_@quadsampobj_Douro_060112a.mat
%

function [ratname,protocol,datestr,version,datestruct,direc] = ...
       parse_filename(fname)
   
   direc = pathonly(fname);
   fname = nopath(fname);
   
   % Chop off data_ portion
   if ~strcmp(fname(1:5), 'data_'),
      error('Standard convention filenames start with ''data_''');
   end;
   fname = fname(6:end);
   
   % Chop off .mat extension, if it is there:
   fname = noextension(fname);

   % Chop off date tail:
   [tok, revfname] = strtok(fname(end:-1:1), '_');
   tok = tok(end:-1:1);
   version = tok(end);
   datestr = tok(1:end-1);
   datestruct = struct('year',  str2num(datestr(1:2)), ...
                       'month', str2num(datestr(3:4)), ...
                       'day',   str2num(datestr(5:6)));
   
   % Chop off leading '_';
   revfname = revfname(2:end);
   
   % Get the name:
   [tok, revfname] = strtok(revfname, '_');
   ratname = tok(end:-1:1);
   
   % Chop off leading '_'; whatever remains must be the protocol
   revfname = revfname(2:end);
   protocol = revfname(end:-1:1);
   
   
   