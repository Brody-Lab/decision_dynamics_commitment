function state = umcheck(uimenu_handle)
%UMCHECK  Check the "checked" status of uimenu object.
%  UMCHECK(U) returns 1 if the status is 'on' and 0
%  if the status is 'off'.
%
% See also UMTOGGLE

%  Author: Z. Mainen 6-3-02
%  Copyleft Z.F. Mainen 2002

state = strcmp(get(uimenu_handle,'checked'),'on');