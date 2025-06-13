
%function bdata
% connection_id=bdata
% out=bdata(sqlstr)
% out=bdata('connect',host,user,pass)
% connects to sql server via mym and maintains a connection id.
%
% See also MYM
%
%
% This bdata is compatible with mym 1.36 which returns a single struct output with each requested column as a fieldname.
% earlier versions of mym (<=1.0.9) will not work with this.
%
