function [obj] = gnp_alternating_blocks(varargin)
    obj = class(struct, mfilename, pokesplot, saveload, sidesplot, soundmanager); 
%   GNP_ALTERNATING_BLOCKS Summary of this function goes here
%   Detailed explanation goes here
    
    GetSoloFunctionArgs;

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~ischar(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;
if ~isstr(action), error('The action parameter must be a string'); end; %#ok<FDEPR>

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------

switch action
    
    case 'init',
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure; %janela
    name = 'gnp_alternating_blocks';
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [520 100 420 180]);
    x = 10; y = 10;
    
    %%% Construction of the GUI %%%
%     PushbuttonParam(obj, 'submit', x, y, 'position', [x y 200 60],'BackgroundColor', [0 0 1]);next_row(y);
        %set_callback(submit, {'gnp_buildmatrix', 'init'});
%     next_row(y);    next_row(y);
    NumeditParam(obj, 'post_stimulus_time', 6, x, y, 'TooltipString', 'Post stimulus time (s)', 'labelfraction', 0.55);
    next_row(y);
    DispParam(obj, 'real_stim_period_duration', 0, x, y, 'labelfraction', 0.65);
    next_row(y);
    DispParam(obj, 'number_of_cycles', 0, x, y, 'labelfraction', 0.65);
    next_row(y);
    NumeditParam(obj, 'off_time', 3, x, y, 'TooltipString', 'Stim. off time (s)', 'labelfraction', 0.65);
        set_callback(off_time, {'gnp_alternating_blocks', 'calculate_variables'});
    next_row(y);
    NumeditParam(obj, 'on_time', 3, x, y, 'TooltipString', 'Stim. on time (s)', 'labelfraction', 0.65);
        set_callback(on_time, {'gnp_alternating_blocks', 'calculate_variables'});
    next_row(y);
    NumeditParam(obj, 'stim_period_duration', 12, x, y, 'TooltipString', 'Duration of stim. period (s)', 'labelfraction', 0.55);
        set_callback(stim_period_duration, {'gnp_alternating_blocks', 'calculate_variables'});
    next_row(y);
    NumeditParam(obj, 'baseline', 6, x, y, 'TooltipString', 'Duration of baseline (s)', 'labelfraction', 0.55);
    next_row(y);
    SubheaderParam(obj, 'stimparams', 'Stimulation Parameters', x, y);
    %---------------------------------------------------------------
    % Next column
    %---------------------------------------------------------------
    next_column(x); y=10;
      
    PushbuttonParam(obj, 'build', x, y, 'position', [x y 200 20],'BackgroundColor', [0 1 0]);next_row(y);
        set_callback(build, {'nLaser', 'init'; ...
                            'gnp_buildmatrix', 'init'});
    SoloParamHandle(obj, 'laservec');
    
    NumeditParam(obj, 'fractionOn', 0.025, x, y, 'TooltipString', 'Fraction of ON time (given freq), 1-fractionOn = OFF time.');next_row(y);
        set_callback(fractionOn, {'nLaser', 'fractionOn'});
        sound_samp_rate = bSettings('get', 'SOUND', 'sound_sample_rate');
    DispParam(obj, 'samp_rate', sound_samp_rate, x, y, 'labelfraction', 0.5); next_row(y);
%     NumeditParam(obj, 'laserEnd_after', 0, x, y, 'TooltipString', 'End LASER Pulse after Trial...');next_row(y);
%     NumeditParam(obj, 'laserStart_after', 0, x, y, 'TooltipString', 'Start LASER Pulse after Trial...');next_row(y);
    SoloParamHandle(obj, 'len', 'value', 1);
    DispParam(obj, 'len', value(len), x, y, 'TooltipString', 'Pulse Length in seconds.');next_row(y);
    NumeditParam(obj, 'onTime', 0.005, x, y, 'TooltipString', 'UP time in sec. of pulse (given freq).');next_row(y);
         set_callback(onTime, {'nLaser', 'onTime'});
    NumeditParam(obj, 'amp', 0.5, x, y, 'TooltipString', 'Pulse Amplitude between 0 & 1.');next_row(y);
    NumeditParam(obj, 'freq', 5, x, y, 'TooltipString', 'Pulse Frequency in Hz.');next_row(y);
        set_callback(freq, {'nLaser', 'freq'});
    SubheaderParam(obj, 'laserMenu', 'LASER Options', x, y);next_row(y);
    
    DeclareGlobals(obj, 'rw_args', {'laservec', 'onTime', 'fractionOn', 'amp', 'len', 'freq', 'samp_rate'});%, 'laserStart_after', 'laserEnd_after'
    
    DeclareGlobals(obj, 'rw_args', {'post_stimulus_time', 'real_stim_period_duration', 'number_of_cycles', ...
        'stim_period_duration', 'off_time', 'on_time', 'baseline'});
    
    gnp_alternating_blocks(obj, 'calculate_variables');
    
    case 'calculate_variables',
    number_of_cycles.value = floor(value(stim_period_duration) / (value(on_time) + value(off_time)));
    real_stim_period_duration.value = value(number_of_cycles) * (value(on_time) + value(off_time));

    case 'update'
        
    case 'close'
    delete(value(myfig));
    
  otherwise,
    warning('Unknown action! "%s"\n', action); %#ok<WNTAG>
end;
return;