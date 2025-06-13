%rp_machine.m   machine = make_rp_machine('lunghao1' | 'lunghao2')
%
% THIS IS AN OBSOLETE FUNCTION -- IGNORE
%
% Creates and returns a virtual RP Box object. The machine will be one
% of two types, depending on the first argument passed. A 'lunghao1' is
% a machine following the Feb 8 2004 state machine system. A 'lunghao2'
% is a sound-producing machine, connected to the first via the analog port.
% Virtual analog port, of course.
%
function rp_machine = make_rp_machine(machine_type)

switch machine_type,
    case 'lunghao1',
        rp_machine = make_lunghao1_machine;
        return;
        
    case 'lunghao2'
        rp_machine = make_lunghao2_machine;
        return;
        
    otherwise,
        error(['Don''t know how to make a ' machine_type ' RP machine']);
end;
return;


function rp_machine = make_lunghao1_machine;
% Make an RP box state machine 

rp_machine = struct(...
    'StateMatrix'     [], ...
    'TimDurMatrix'    [], ...
    'DIO_out'         [], ...
    'AO_out'          [], ...
    'state',          0,  ...
    'eventcounter',   0, ...
    'event',          zeros(1,100000), ....
    'eventtime',      zeros(1, 100000), ...
    'clock',          cputime);

return;


function rp_machine = make_lunghao2_machine;
% Make a sound-producing RP Box machine

return;

