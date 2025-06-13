function a = freadu16(name,offset,numwords)
%FREAD8 Read bytes from a file into an int8 array.
%   A = FREADU16(FNAME, OFFSET, NUMWORDS) reads NUMWORDS from the
%   file FNAME starting at OFFSET.  A is returned as a uint16
%   column array.  Note that the length of A is the number of
%   words successfully read, which may be less than NUMBYTES.
%
%   OFFSET defaults to 0.  If NUMWORDS is not specified, FREADU16
%   reads from OFFSET to the end of the file.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2005/09/25 15:17:31 $

error('Missing MEX-file FREADU16');
