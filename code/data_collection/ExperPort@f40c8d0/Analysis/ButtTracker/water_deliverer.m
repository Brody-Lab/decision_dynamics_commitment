function [state_name,delay,lrfieldname]=water_deliverer(protocol,ratname,sessiondate,peh)

%
% [state_name,delay]=water_deliverer(protocol,ratname,sessiondate,peh)
%   returns a string containing the name of the state or schedule wave that
%   turns on the water valve.  Also returns the time delay in valve opening
%   relative to the start of the state.  FIRST ROW SHOULD ALWAYS BE LEFT, SECOND
%   ROW SHOULD ALWAYS BE RIGHT!
%

if strcmpi(protocol,'SameDifferent') || strcmpi(protocol,'PBups')
  if isfield(peh,'waves')
    state_name={'waves', 'direct_reward'};
    delay=0;
    lrfieldname='sides';
  else
    state_name={'states','left_reward'; 'states','right_reward'};
    try
      delay=check_sphDB('reward_delay','ratname',ratname,'sessiondate',sessiondate);
    catch exception
      disp(exception.message);
      disp(['Could not obtain water reward delay for ' ratname ' on ' sessiondate ', using 0.']);
      delay=0;
    end
    lrfieldname='sides';
  end
elseif strcmpi(protocol,'SoundDiscrimination')
  state_name={'states','prereward'};
  delay=0;
  lrfieldname='sides';
elseif strcmpi(protocol,'RewardDiscounting2')
  state_name={'states','left_reward'; 'states','right_reward'};
  delay=0; 
  lrfieldname='choice';
elseif strcmpi(protocol,'ProAnti3')
  if isfield(peh,'waves')
    state_name={'waves','rew_wave'};
    delay=0;
  else
    state_name={'states','left_reward'; 'states','right_reward'};
    delay=0;
  end
  lrfieldname='sides';
else
  state_name='';
  delay=[];
  lrfieldname=[];
  warning('MATLAB:water_deliverer',...
    ['I do not recognize how the protocol named ' protocol ' opens water valves.']);
end