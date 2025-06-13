% <~> function: lookup_system
%     Given a system name or index, returns its index or name,
%       respectively. This is the name/index pairing used in the Brody lab
%       mysql database.
%     e.g.
%       lookup_system('runrats') == 1
%       lookup_system(1)         == 'runrats'
%       lookup_system('rpbox')   == 0
%       lookup_system(0)         == 'rpbox'
%     
%     Matching is case-insensitive.
%
%     Currently:
%       0       RPBox
%       1       RunRats (or Dispatcher)
%
function [o errID errmsg] = lookup_system(sys)
errID = 0; errmsg = '';
if ischar(sys), sys = lower(sys); end;
switch(sys)
    case 'rpbox',       o = 0;
    case 0,             o = 'rpbox';
    case 'runrats',     o = 1;
    case 'dispatcher',  o = 1;
    case 1,             o = 'runrats';
    otherwise,
        if ~ischar(sys), sys = int2str(sys); end;
        o = NaN; errID = 1; errmsg = ['Error in wiki schedule interpretation. System ("' sys '") not recognized.'];
        return;
end; %     end of switch system

end     %     end of function lookup_system
