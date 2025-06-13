function a = fread8(name,offset,numbytes)
%FREAD8 Read bytes from a file into an int8 array.
%   A = FREAD8(FNAME, OFFSET, NUMBYTES) reads NUMBYTES from the
%   file FNAME starting at OFFSET.  A is returned as a uint8
%   column array.  Note that the length of A is the number of
%   bytes successfully read, which may be less than NUMBYTES.
%
%   OFFSET defaults to 0.  If NUMBYTES is not specified, FREADU8
%   reads from OFFSET to the end of the file.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2005/09/25 15:17:31 $

error('Missing MEX-file FREAD8');
