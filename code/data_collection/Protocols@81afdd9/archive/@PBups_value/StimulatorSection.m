% @PBups/StimulatorSection.m
% Bing, April 2011

% [x, y] = YOUR_SECTION_NAME(obj, action, varargin)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function [x, y] = StimulatorSection(obj, action, varargin)
   
GetSoloFunctionArgs;

switch action
%% init    
  case 'init',
      x = varargin{1};
      y = varargin{2};
      
      % Save the figure and the position in the figure where we are going
      % to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      NumeditParam(obj, 'stim_pre', 1, x, y, 'position', [x y 100 20], ...
          'TooltipString', 'the duration (in sec) of the stimulator preamble');
      NumeditParam(obj, 'stim_dur', 2, x, y, 'position', [x+100 y 100 20], ...
          'TooltipString', 'the sustain duration (in sec) of the stimulator');
      set_callback(stim_pre, {mfilename 'stim_pre'});
      next_row(y);
      
      NumeditParam(obj, 'stimulator_frac', 0, x, y, ...
          'TooltipString', sprintf(['\nthe fraction of trials for which a stim is triggered.' ...
                                    '\n currently, stim is triggered at cpoke1 with a preamble' ...
                                    '\n of stim_pre and sustains for stim_dur.' ...
                                    '\n WARNING: it is highly advisable to turn on NEW TRIAL ON VIOL' ...
                                    '\n in StimulusSection to avoid possible prolonged, repeated zapping!']));
      set_callback(stimulator_frac, {mfilename, 'stimulator_frac'});
      next_row(y);
      
      NumeditParam(obj, 'nStims', 1, x, y, ...
          'TooltipString', sprintf(['\nIn the current version, is enforced to be 1,' ...
                                    '\nand must be the LASER channel;' ...
                                    '\nIf the LASER DIO line is not available on this rig,' ...
                                    '\nthen stimulator_frac is set to zero (0).']));
      set_callback(nStims,   {mfilename, 'check_stim_channels'});

      next_row(y);
      
      DispParam(obj, 'ThisStim', 0, x, y, ...
          'TooltipString', sprintf('the stimulator channale active on this trial.\n'));
      
      next_row(y);
      SubheaderParam(obj, 'title', 'StimulatorSection', x, y);
      
      SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'nStims'; 'ThisStim'; 'stim_pre'; 'stim_dur'});
      
      SoloFunctionAddVars('SidesSection', 'ro_args', ...
          {'ThisStim'});
      
      
      feval(mfilename, obj, 'check_stim_channels');


%% next_trial
  case 'next_trial',      

	  % determine if the next trial will be accompanied by a stim DIOLINE
	  % returns which stim, if any
	  
      if n_done_trials == 0 || value(ThisStim) > 0, 
          % don't stimulate on first trial or if the previous trial was a
          % stimulated trial
          x = 0;
      elseif value(stimulator_frac) < eps,
          x = 0;
      else
          if rand(1) < value(stimulator_frac),
              x = ceil(rand(1)*value(nStims));
          else
              x = 0;
          end;
      end;
      
      ThisStim.value = x;
      
      
      
	  
%% check_stim_channels
  case 'stimulator_frac'
      if value(stimulator_frac) > 1, stimulator_frac.value = 1;
      elseif value(stimulator_frac) < 0, stimulator_frac.value = 0;
      end;
      
%% stim_pre     
  case 'stim_pre'
      if value(stim_pre) < 0,
          stim_pre.value = 0;
      end;
      
%% check_stim_channels
  case 'check_stim_channels'
      nStims.value = 1;
      enable(stimulator_frac);
      enable(stim_pre);
      enable(stim_dur);
      
      % HACK ALERT: right now we'll accomodate only a single stim channel,
      % the 'LASER' channel
      channel = bSettings('get', 'DIOLINES', 'LASER');
      if isnan(channel),
          stimulator_frac.value = 0;
          disable(stimulator_frac);
          disable(stim_pre);
          disable(stim_dur);
      end;
      
%       for i = 1:value(nStims),
%           s = sprintf('stim%i', i);  
%           channel = bSettings('get', 'DIOLINES', s);
%           if isnan(channel),
%               stimulator_frac.value = 0;
%               disable(stimulator_frac);
%           end;
%       end;



      
%% close
  case 'close',
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);    


%% end_session
  case 'end_session',
        

%% reinit
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); f = my_gui_info(3);

    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    figure(f);
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;
