function [] = close(obj)

GetSoloFunctionArgs;

CurrentTrialPokesSubsection(obj, 'delete');
SessionDefinition(obj, 'delete');
delete(value(myfig));

if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
    Close(value(olf_meter));
end

flush_solo(['@' class(obj)]);
clear functions;

disp('Session finished!');