function count = fwriteu16(fname, A)
%FWRITEU16 Append bytes to a file.
%   COUNT = FWRITEU16(FNAME, A) appends the values in the uint16
%   array A to the file specified by the string FNAME, returning
%   the count of words successfully written.
%   Z. F. Mainen
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2005/09/25 15:17:33 $

error('Missing MEX-file WRITEU16');
