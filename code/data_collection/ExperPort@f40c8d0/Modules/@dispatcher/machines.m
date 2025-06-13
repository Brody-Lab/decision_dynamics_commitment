function [ret] = MachinesSection(obj, varargin)

global fake_rp_box;
GetSoloFunctionArgs;

if nargin < 2, return; end;

action = varargin{1};

switch action,
  case 'init'
    
    % --- Setting up the state machine:
    SoloParamHandle(obj, 'state_machine');
    if     fake_rp_box==2,   state_machine.value = RTLSM( state_machine_server);
    elseif fake_rp_box==20,  state_machine.value = RTLSM2(state_machine_server); % <~> line added to head branch 2008.June.25
    elseif fake_rp_box==3,   state_machine.value = SoftSMMarkII;
    else
      error('Sorry, can only work with fake_rp_box (from mystartup.m) equal to 2 or 3');
    end;

  
    % --- Setting up the sound server:
    SoloParamHandle(obj, 'sound_machine');
    if     fake_rp_box==2,   sound_machine.value = RTLSoundMachine(sound_machine_server);
    elseif fake_rp_box==3,   sound_machine.value = softsound;
    else
      error('Sorry, can only work with fake_rp_box (from mystartup.m) equal to 2 or 3');
    end;
    
    Initialize(value(state_machine));
    Initialize(value(sound_machine));
    
    % --- connect StateMachine and SoundMachine if necessary:
    if fake_rp_box == 3,
      SetTrigoutCallback(value(state_machine), @playsound, value(sound_machine));
    end;
    
  case {'get_sound_machine' 'getsoundmachine'},   % --- get_sound_machine ----
    ret = value(sound_machine);
    
  case {'get_state_machine' 'getstatemachine'},   % --- get_state_machine ----
    ret = value(state_machine);
    
  case 'send_statenames', % ----- send_state_names ----
    theStruct = varargin{2};
    if(isa(theStruct,'SoloParamHandle')), theStruct = value(theStruct); end;
    if (~isa(theStruct, 'struct')), error('Expected struct for state names!'); end;
    mapping = [fieldnames(theStruct) struct2cell(theStruct)];
    SetStateNames(value(state_machine), mapping);

  otherwise,

end;
