%invokeWrapper.m   [out] = invokeWrapper(axhandle, varargin)
%
% Takes two possible actions, depending on the value of the global variable
% 'fake_rp_box':
%
%   - If fake_rp_box doesn't exist, is empty, or is not 1, then calls
%          out = invoke(axhandle, args); 
%        with args being whatever was passed to it. axhandle should be
%        an ActiveX ID as retruned by actxcontrol.
%
% fake_rp_box == 0 --> RM1 TDT boxes
% fake_rp_box == 1 --> First virtual state machine (running off timers)
% fake_rp_box == 2 --> RT Linux state machien
% fake_rp_box == 3 --> SoftSMMarkII virtual state machine (object, no timers)
% fake_rp_box == 4 --> softsm virtual state machine (old, no scheduled waves)
%

function [out] = invokeWrapper(varargin)

global fake_rp_box;
global FakeActiveXObjects;
global state_machine_server;
global sound_machine_server;


global private_hack_ignore_next_ready_to_start_trial
% See comments at top of RPBOx.m for an explanation of the above hack
% variable

if length(varargin)<1, error('Need at least one argument'); end;

% Using RM1 boxes-- act as direct gateway to invoke.m
if isempty(fake_rp_box) | fake_rp_box == 0,
   cmd = varargin{2};
   if (strcmp(cmd, 'GetMachine')),
       error(['GetMachine method unimplemented for RM1 boxes!  Please' ...
              ' run this protocol either on the new RTLinux rigs or' ...
              ' in software emulation or get rid of this call!']);
   elseif ismember(cmd, {'SetStateNames', 'ForceState0'}),
       out = 1;
       return;
   else
       argstr = []; for i=1:length(varargin)-1,
           argstr = [argstr 'varargin{' sprintf('%g', i) '}, '];
       end;
       argstr = [argstr 'varargin{' sprintf('%g', length(varargin)) '}'];
       out = eval(['invoke(' argstr ');']);
       return;
   end;
end;

% ---------- Ok, not RM1 boxes

if length(varargin) < 2,error('Need at least handle, command as args');end;
xhandle = varargin{1}; command = varargin{2};
mid = find(strcmp(FakeActiveXObjects(:,findRnum(FakeActiveXObjects, ...
                                                'xhandle')), xhandle));
if isempty(mid), 
   error('Couldn''t find the rp machine with this xhandle'); 
end;
machine = FakeActiveXObjects{mid, findRnum(FakeActiveXObjects, 'rp_machine')};

% If there is no machine defined yet:
if isempty(machine),
   switch command,
    case {'DefID' 'Halt' 'ClearCOF' 'ConnectRP2' 'ConnectRM1'},
     out = 1; return;
    case 'LoadCOF',
     switch nopath(varargin{3})
         
      case {'RP2Box.rco' 'RM1Box.rco'}
       % ------- We are making the State Machine ----------
       if fake_rp_box == 1, % Timer-based virtual State Machine
          machine = lunghao1;
          setup_lunghao1_gui(machine);
          % Look for a lunghao2 to connect to 
          allmachines = ...
              FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
                                                 'rp_machine'));
          for othermachine = allmachines',
             if isa(othermachine{1}, 'lunghao2')
                set(machine, ...
                    'aoutchange_callback', ...
                    {'lh1_to_lh2_connection_and_lh1_aout_gui', ...
                     othermachine{1}});
             end;
          end;
       elseif fake_rp_box == 2, % RT-Linux State Machine
          machine = RTLSM(state_machine_server);
          % Look for a sound machine to connect to 
% $$$           allmachines = ...
% $$$               FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
% $$$                                                  'rp_machine'));
% $$$           for othermachine = allmachines',
% $$$              if isa(othermachine{1}, 'RTLSoundMachine')
% $$$                 machine = ...
% $$$                  SetTrigoutCallback(machine,@playsound,othermachine{1});
% $$$              end;
% $$$           end;

          
       elseif fake_rp_box == 3, % SoftSMMarkII
         machine = SoftSMMarkII;
          % Look for a sound machine to connect to 
          allmachines = ...
              FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
                                                 'rp_machine'));
          for othermachine = allmachines',
             if isa(othermachine{1}, 'softsound')
                machine = ...
                    SetTrigoutCallback(machine,@playsound,othermachine{1});
             end;
          end;
       elseif fake_rp_box == 4, % softsm
         machine = softsm;
          % Look for a sound machine to connect to 
          allmachines = ...
              FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
                                                 'rp_machine'));
          for othermachine = allmachines',
             if isa(othermachine{1}, 'softsound')
                machine = ...
                    SetTrigoutCallback(machine,@playsound,othermachine{1});
             end;
          end;
       end;
       
       
      case {'2SoundRP2_2.rco' '2SoundRM1_2.rco'}
       % ------- We are making the Sound Machine (old) ----------
       if fake_rp_box == 1,
          machine = lunghao2;
          % Look for a lunghao1 to connect to 
          allmachines = ...
              FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
                                                 'rp_machine'));
          for othermachine = allmachines',
             if isa(othermachine{1}, 'lunghao1')
                set(othermachine{1}, ...
                    'aoutchange_callback', ...
                    {'lh1_to_lh2_connection_and_lh1_aout_gui', machine});
             end;
          end;
       elseif fake_rp_box == 2,
          error('Configure me for RT Linux!!');
       elseif fake_rp_box==3,
          error(['Shouldn''t be here!! Your state machine only takes' ...
                 '3StereoSoundRM1.rco']);
       elseif fake_rp_box==4,
          error(['Shouldn''t be here!! Your state machine only takes' ...
                 '3StereoSoundRM1.rco']);
       end;
       
      case {'3StereoSoundRM1.rco'}
       % ------- We are making the Sound Machine (new) ----------
       if fake_rp_box == 1,
          machine = lunghao2b;
          % Look for a lunghao1 to connect to 
          allmachines = ...
              FakeActiveXObjects(2:end, findRnum(FakeActiveXObjects, ...
                                                 'rp_machine'));
          for othermachine = allmachines',
             if isa(othermachine{1}, 'lunghao1')
                set(othermachine{1}, ...
                    'aoutchange_callback', ...
                    {'lh1_to_lh2_connection_and_lh1_aout_gui', machine});
             end;
          end;
       elseif fake_rp_box == 2,
          machine = RTLSoundMachine(sound_machine_server);
         % machine = SetSampleRate(machine, 200000);
          % Look for a state machine to connect to 
% $$$           rnum = findRnum(FakeActiveXObjects, 'rp_machine');
% $$$           allmachines = FakeActiveXObjects(2:end, rnum);
% $$$           for i=1:length(allmachines),
% $$$              if isa(allmachines{i}, 'RTLSM')
% $$$                 allmachines{i} = ...
% $$$                    SetTrigoutCallback(allmachines{i},@playsound,machine);
% $$$                 FakeActiveXObjects{i+1,rnum} = allmachines{i};
% $$$              end;
% $$$           end;
       
       elseif fake_rp_box==3 | fake_rp_box==4, %state machine is object-based
          machine = softsound;
          if (fake_rp_box == 3),
              % in SoftSMMarkII we allow all trigs in the range
              % [-127,127]
              machine = SetAllowedTrigs(machine, [ -127:127 ]);
          end;
          % Look for a state machine to connect to 
          rnum = findRnum(FakeActiveXObjects, 'rp_machine');
          allmachines = FakeActiveXObjects(2:end, rnum);
          for i=1:length(allmachines),
             if (isa(allmachines{i}, 'softsm') | isa(allmachines{i}, 'SoftSMMarkII')),
                allmachines{i} = ...
                    SetTrigoutCallback(allmachines{i},@playsound,machine);
                FakeActiveXObjects{i+1,rnum} = allmachines{i};
             end;
          end;
       end;
      otherwise
       error(['FakeRP: Don''t know how to LoadCOF a virtual ' ...
              nopath(varargin{3})]);
     end;
     FakeActiveXObjects{mid,findRnum(FakeActiveXObjects,'rp_machine')} =...
         machine;
     out=1; return;
     
    otherwise
     error(['Fake RP: Don''t know how to execute ' command ...
            ' on an empty machine']);
   end;
end;


% -------------------------------------------------------------
% 
%   OK -- now to the alternative section, where we are called
%   when there already *is* a machine.
%
% -------------------------------------------------------------

if fake_rp_box==1,
   command = varargin{2};
   callstr = [command '(machine']; for i=3:length(varargin)-1,
      callstr = [callstr ', varargin{' sprintf('%g', i) '} '];
   end;
   if length(varargin)>=3, 
      callstr=[callstr ', varargin{' sprintf('%g', length(varargin)) '});'];
   else callstr = [callstr ');'];
   end;
   % callstr,
   switch command
    case {'GetTagVal' 'ReadTagVEX' 'ReadTagVex', 'SetTagVal', 'WriteTagV'},
     out = eval(callstr);
    otherwise
     eval(callstr);
   end;
   return;
end;   
   

% Are we a softsound?
if ismember(class(machine), {'softsound', 'RTLSoundMachine'}),
   command = varargin{2};

   switch command,
    case {'DefStatus', 'ConnectRP2', 'ConnectRM1', 'ClearCOF', 'LoadCOF'},
     out = 1; machine = Initialize(machine);
     
    case {'Halt', 'Run'}
     out = 1; 
     
    case 'SetSampleRate',
     value = varargin{3};
     out = 1; machine = SetSampleRate(machine, value);
          
    case 'WriteTagV',
     tagname = varargin{3}; startpt = varargin{4}; value = varargin{5};
     switch tagname,
      case 'datain1',  machine = LoadSound(machine, 1, value, 'both');      
      case 'datain1a', machine = LoadSound(machine, 1, value, 'left');
      case 'datain1b', machine = LoadSound(machine, 1, value, 'right');
      case 'datain2',  machine = LoadSound(machine, 2, value);
      case 'datain3',  machine = LoadSound(machine, 4, value);
      otherwise,
       error(['Don''t yet know how to WriteTagV to ' tagname ' into a ' ...
              class(machine)]);
     end;
     out = 1;
     
    case 'SetTagVal',
     tagname = varargin{3}; value = varargin{4};
     switch tagname,
      case 'datalngth1'; out = 1;
      case 'datalngth2'; out = 1;
      case 'datalngth3'; out = 1;
      otherwise,
       error(['Don''t know how to SetTagVal to ' tagname ' into a ' ...
              class(machine)]);
     end;

    case 'GetMachine',
     out = machine;

    case 'SetMachine',
     if (isa(varargin{3}, class(machine))),
       machine = varargin{3};
     else
       error(['SetMachine called with invalid type: ''' ... 
              class(varargin{3}) ''' as the machine to set!']);
     end;
     out = 1;

    otherwise,
     error(['Don''t yet know how to send command ' command ' into a ' ...
              class(machine)]);
   end;
   FakeActiveXObjects{mid, findRnum(FakeActiveXObjects, 'rp_machine')} =...
       machine;
   return;
end;
     
% Are we a softsm?
if ismember(class(machine), {'softsm', 'RTLSM', 'SoftSMMarkII'}),
   command = varargin{2};
   switch command,
    case {'DefStatus' 'ConnectRP2' 'ConnectRM1' 'ClearCOF' 'LoadCOF' ...
          'Initialize'},
     out = 1; machine = Initialize(machine);

    case 'Close',
      out = 1; Close(machine);
    case 'Halt',
     out = 1; machine = Halt(machine);
    case 'Run',
     out = 1; machine = Run(machine);
    case 'ForceState0',
     out = 1; 
     try
        machine=ForceState0(machine);
     catch
         warning('Force State 0 called with empty matrix?');
     end;
    case 'FlushQueue',
     out = 1; 
     if (isa(machine,  'softsm') | isa(machine, 'SoftSMMarkII')), 
        machine=FlushQueue(machine);  
     end;
     
    case 'SetTagVal', tagname = varargin{3}; value = varargin{4};
     switch tagname, 
      case 'Bits_HighVal',
        machine = BypassDout(machine, value);
       
      case 'AOBits_HighVal',
        binvalue = dec2bin(value);
        binvalue = binvalue(end:-1:1); % Put bit 1 at the beginning
        for i=1:length(binvalue),
           if binvalue(i) == '1', Trigger(machine, 2^(i-1)); end;
        end;           
        out = 1; 
      
      otherwise,
       error('Don''t know this SetTagVal tagname');
     end;
     
    case 'GetTagVal', tagname = varargin{3};
     switch tagname,
      case 'State',        out = GetState(machine);
      case 'EventCounter', 
        % Hack for double event generation for backwards compatibility
        % with the TDT boxes-- yuck:
        out = 2*GetEventCounter(machine);  

      case 'Clock',        out = GetTime(machine);
      otherwise,
       error('Don''t know this GetTagVal tagname');
     end;
     
    case 'ReadTagVex', tagname = varargin{3}; 
     start    = varargin{4}; 
     howmany  = varargin{5};
     switch tagname
      case 'Event',
        out = GetEvents(machine, start/2+1, start/2+howmany/2);
        % numcols_in_matrix = size(GetInputEvents(machine), 1) + 4 + HasScheduledWaves(machine);
        % Hack for double event generation for backwards compatibility
        % with the TDT boxes-- yuck:
        outa = out(:,1)*(2.^7) + out(:,2);
        outb = out(:,4)*(2.^7);
        out = [outa' ; outb']; out = out(:);
      
      case 'EventTime',
        out = GetEvents(machine, start/2+1, start/2+howmany/2);
        % Hack for double event generation for backwards compatibility
        % with the TDT boxes-- yuck:
        out = out(:,3);
        out = [out' ; out']; out = out(:);
        
      otherwise,
       error('Don''t know this ReadTagVex tagname');
     end;
     
    case 'WriteTagV', tagname = varargin{3}; value = varargin{4};
     switch tagname,
      case 'StateMatrix', machine = SetStateMatrix(machine, value);
       
      otherwise,
       error('Don''t know this WriteTagV tagname');
     end;
     
    case 'SoftTrg', trignum = varargin{3};
     switch trignum,
      case 1,  machine = ForceTimeUp(machine);
      case 2,  % ignore it for now
      case 3,  machine = Run(machine);
      case 4,  machine = Halt(machine);
      case 5,  % ignore for now-- timed Douts
      case 6,  % ignore for now-- allows DoutBypass
      case 7,  % ignore for now-- disallows DoutBypass
      case 8,  % ignore for now-- allows AoutBypass
      case 9,  % ignore for now-- disallows AoutBypass
      case 10, 
        if ~isempty(private_hack_ignore_next_ready_to_start_trial)  &&  ...
            private_hack_ignore_next_ready_to_start_trial == 1,
          % fprintf(1, 'Ignoring doing RforT, %s\n', datestr(now));
        else
          if     isa(machine, 'softsm'), machine = SetPCReadyFlag(machine);
          else   machine = ReadyToStartTrial(machine);
            % fprintf(1, 'invokewrapper Just did RforT, %s\n', datestr(now));
          end;
        end;
        private_hack_ignore_next_ready_to_start_trial = 0;
      otherwise, error('Don''t know this SoftTrg number');
     end;
     
    case 'SetStateNames',
     if (isa(machine, 'SoftSMMarkII')),
       machine = SetStateNames(machine, varargin{3});
     end;
     out = 1;
     
    case 'GetMachine',
     out = machine;
     
    case 'SetMachine',
     if (isa(varargin{3}, class(machine))),
       machine = varargin{3};
     else
       error(['SetMachine called with invalid type: ''' ... 
              class(varargin{3}) ''' as the machine to set!']);
     end;
     out = 1;
     
    otherwise,
     error('Don''t know this command');
   end;
   
   FakeActiveXObjects{mid, findRnum(FakeActiveXObjects, 'rp_machine')} =...
       machine;
   return;
end;


if fake_rp_box==2 & ...
       ~ismember(class(machine), {'softsm', 'RTLSM', 'SoftSMMarkII'}),
   argstr = []; for i=1:length(varargin)-1,
      argstr = [argstr 'varargin{' sprintf('%g', i) '}, '];
   end;
   argstr = [argstr 'varargin{' sprintf('%g', length(varargin)) '}'];
   out = (['invoke(' argstr ');']);
   return;
   
end;    

return;      



% ---------------

function [id] = findRnum(cellname, str)
    id = find(strcmp(cellname(1,:), str));
    return;
    
