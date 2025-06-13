function rp = rp_machine(r)
% Creates a class 'rp_machine' object.
%
% The basic rp_machine has a halt flag (for halted or not).
% 

if nargin==0,
    rp = struct('halt', 0);
    rp = class(rp, 'rp_machine');
    return;
    
elseif isa(r, 'rp_machine'),
    rp = r;
    return;
    
else
    error('Don''t know how to handle this rp_machine creation argument');
end;    

