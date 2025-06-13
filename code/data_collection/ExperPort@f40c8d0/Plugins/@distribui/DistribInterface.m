% [x, y] = DistribInterface(obj, action, randvar_name, x, y)
%
% Puts up a GUI for getting a random number from some simple distributions.
% Can sample from the specified distribution by either calling a command or
% clicking a button.  The main actions are 'add' (create a new random var,
% and instantiate the SoloParamHandle that holds its value in the caller's
% workspace); 'get_new_sample' (sample from it) and 'get_soloparamhandles'
% (get all the SoloParamHandles that are part of the GUI for this var).
%
% EXAMPLE CALLS:
% --------------
%
%  To initialise a distribution, put up the GUI, and make a
%  SoloParamHandle, you would do:
%
%  [x, y] = DistribInterface(obj, 'add', 'myrandom', 10, 10, 'Style', ...
%                    'gaussian', 'Mu', 10, 'Sd', 3, 'Min', 0, 'Max', 20);
%
%       The above call will instantiate a SoloParamHandle named 'myrandom'
%       in your workspace; you will, by default, have read-write access to
%       it.
%
%
%  randvalue = DistribInterface(obj, 'get_new_sample', 'myrandom');
%
%
% PARAMETERS:
% -----------
%
% The first parameter, action, should be one of:
%
%  'add'     Make a GUI for a new random var. This action requires three
%            more PARAMETERS:
%
%              randvar_name    A string defining the name of the new var
%            
%              x, y            x and y position, in pixels from bottom
%                              left of current figure, at which to start
%                              putting in the GUI elements.
%         
%            This action, 'add', also takes a number of OPTIONAL PARAMETERS:
%
%              'Style'    One of the three strings 'exponential',
%                        'gaussian', or 'uniform'. Default is 'exponential'
%              'Min'      By default 0; all samples are guaranteed >= Min
%              'Max'      By default 1; all samples are guaranteed <= Max
%              'Tau'      Scale of exponential shape; only relevant if
%                         Style=='exponential'. Default value is 1. Small
%                         positive values weight the distrib towards 'Min';
%                         large values make the distrib close to uniform;
%                         small negative values weight the distrib towards
%                         'Max'.
%              'Mu'       Mean of gaussian. Only relevant if Style=='gaussian' 
%              'Sd'       St. Dev. of gaussian. Only relevant if Style=='gaussian' 
%              'TooltipString'   Default is ''; Tooltip string for title of
%                         GUI.
%
%            This action, 'add', RETURNS:  x, y  next open position on
%                         current figure.
%
% 'set' randvar_name 'Style'|'Min'|'Max'|'Tau'|'Mu'|'Sd'   value
%        
%               The 'set' action allows setting the parameters for any of
%               the distributions that have been created. The next argument
%               after 'set' must be a string, the name of the distribution
%               that was created with 'add'; the next argument must also be
%               a string, as listed above; and the last argument should be
%               the value the corresponding setting will be changed to.
%               Example calls:
%                     DistribInterface(obj, 'set', 'myvar', 'Style', 'exponential');
%                 or
%                     DistribInterface(obj, 'set', 'myvar', 'Min',   0);
%               For comments on what the different settings are, see action='add'
%               above.
%
% 'get' randvar_name 'Style'|'Min'|'Max'|'Tau'|'Mu'|'Sd'  
%
%               The 'get' action returns the setting of the parameters for any of
%               the distributions that have been created. The next argument
%               after 'get' must be a string, the name of the distribution
%               that was created with 'add'; the next argument must also be
%               a string, as listed above.
%               Example call:
%                     myvarstyle = DistribInterface(obj, 'get', 'myvar', 'Style')
%
%
% 'get_new_sample'   Return a new sample from the distribution. This action requires one
%                more PARAMETER:
%
%              randvar_name    The name of the distrib to sample fromm, as
%                         passed when 'add' was called. 
%
%                and RETURNS a scalar, the sample. The GUI will be changed
%                to reflect the new sample value.
%
%
% 'get_current_sample'   Return the current sample, without changing it. This action requires one
%                more PARAMETER:
%
%              randvar_name    The name of the distrib to sample fromm, as
%                         passed when 'add' was called. 
%
%                and RETURNS a scalar, the sample. The GUI is not changed
%                as the value of the sample hasn't changed.
%
%
% 'get_soloparamhandles'   Return all SoloParamHandles associated with a
%                distribution. This action requires one more PARAMETER:
%
%              randvar_name    The name of the distrib to sample fromm, as
%                         passed when 'add' was called. 
%
%                and RETURNS a cell vector of SoloParamHandles.
%


% Written by Carlos Brody Aug 2007


function [varargout] = DistribInterface(obj, action, tname, x,y , varargin)

GetSoloFunctionArgs(obj);

switch action,

  % --------------  CASE ADD --------------
  
  case 'add'  
    pairs = { ...
      'Min'           0               ; ...
      'Max'           1               ; ...
      'Style'         'exponential'   ; ...
      'Tau'		        1               ; ...
      'Mu'            0               ; ...
      'Sd'            1               ; ...
      'TooltipString' ''              ; ...
      }; parseargs(varargin, pairs);

    if nargin < 5, error('Action ''add'' also requires tname, x, y, as parameters'); end;

    NumeditParam(obj, [tname '_Min'], Min, x, y, 'label','Min', 'TooltipString', ' Min in s',   'position', [x y 70 20],    'labelfraction', 0.4);
    NumeditParam(obj, [tname '_Max'], Max, x, y, 'label','Max', 'TooltipString', ' Max in s.  For binomial the max is the max without.  I.E. if max was five then you would be gauranteed a single one every five trials.',   'position', [x+72 y 70 20], 'labelfraction', 0.4); next_row(y);
    NumeditParam(obj, [tname '_Tau'], Tau, x, y, 'label','Tau', 'TooltipString', ' Tau in s',   'position', [x y 70 20],    'labelfraction', 0.4);
    NumeditParam(obj, [tname '_Mu'],  Mu,  x, y, 'label','Mean','TooltipString', ' Mean in s',  'position', [x y 70 20],    'labelfraction', 0.4);
    NumeditParam(obj, [tname '_Sd'],  Sd,  x, y, 'label','Sd',  'TooltipString', ' S.Dev. in s','position', [x+72 y 70 20], 'labelfraction', 0.4); next_row(y);
    make_invisible({eval([tname '_Mu']) ; eval([tname '_Sd'])});

    % The actual value-containing SoloParamHandle:
    DispParam(obj, tname,  Min,    x, y, 'label','',  'TooltipString', ' current sample',       'position', [x y 80 20],    'labelfraction', 0.05);
    SoloFunctionAddVars(determine_partfuncname, 'rw_args', tname);
    assignin('caller', tname, eval(tname));
    
    PushbuttonParam(obj, [tname '_Resample'],  x, y, 'label','Resample','TooltipString', ' click to get new sample','position', [x+82 y 60 20]); next_row(y);
    set_callback(eval([tname '_Resample']), {mfilename, 'sample', tname});
    MenuParam(obj, [tname '_Style'], {'uniform', 'exponential', 'gaussian','binomial'}, Style, x, y, 'label', 'Style', 'labelfraction', 0.3, 'TooltipString', ' form of distribution from which samples are taken', ...
      'position', [x y 142 22]); y=y+24;
    set_callback(eval([tname '_Style']), {mfilename, 'Style', tname});

    SubheaderParam(obj, [tname '_Title'], ['Randnum: ' tname], x, y, 'position', [x y 150 20], 'TooltipString', TooltipString); next_row(y);

    set_callback(eval([tname '_Tau']), {mfilename, 'Tau', tname});
    set_callback(eval([tname '_Sd']),  {mfilename, 'Sd',  tname});
    set_callback(eval([tname '_Min']), {mfilename, 'Min',  tname});
    set_callback(eval([tname '_Max']), {mfilename, 'Max',  tname});
    set_callback(eval([tname '_Mu']), {mfilename, 'Mu',  tname});
    
    
    callback(eval([tname '_Min'])); callback(eval([tname '_Max'])); 
    callback(eval([tname '_Sd']));  callback(eval([tname '_Style']));
    callback(eval([tname '_Mu']));

    varargout{1} = x;
    varargout{2} = y;

    return;

    
    %% ---------  CASE SET ------

  case 'set',
	  % Let's put all the args in the varargin list:
	  varargin = [{x y} varargin];
	  
	  % Now pick them off in pairs:
	  sphs={};
	  while ~isempty(varargin),
		  if length(varargin)<2,
			  error('DISTRIBUI:BadArgs', 'In "set", need name-value pairs to know what to set');
		  end;
		  param = varargin{1}; newvalue = varargin{2}; varargin = varargin(3:end);
		  
		  
		  try
			  sph = eval([tname '_' param]);
		  catch
			  warning('DISTRIBUI:Not_found', 'Couldn''t find parameter named %s, nothing changed', [tname '_' param]);
			  return;
		  end;
		  sph.value = newvalue;
	 	  sphs{end+1}=sph; 
	  end
	  
	  for sx=1:numel(sphs)
		  callback(sphs{sx})
	  end
		
    

    %% ---------  CASE GET ------

  case 'get',
    param = x; 

    try
      sph = eval([tname '_' param]);
      varargout{1} = value(sph);
    catch
      warning('DISTRIBUI:Not_found', 'Couldn''t find parameter named %s, returning NaN', [tname '_' param]);
      varargout{1} = NaN;
    end;
    
    
    %% ---------  LIMIT-CHECKING: ------

  case 'Sd',  param = eval([tname '_Sd']);  if param < 0, param.value = 0; end;
  case 'Min', min   = eval([tname '_Min']); max = eval([tname '_Max']); if min > max, min.value = value(max); fprintf(1,'In DistribInterface you can not set the min to be greater than the max\n'); end;
  case 'Max', min   = eval([tname '_Min']); max = eval([tname '_Max']); if max < min, max.value = value(min); fprintf(1,'In DistribInterface you can not set the max to be less than the min\n');end;
  case 'Mu', 
        style=value(eval([tname '_Style']));
        mu   = eval([tname '_Mu']);
        if strcmpi(style,'binomial');
            if mu<0
                mu.value=0;
            elseif mu>1
                mu.value=1;
            end
        end
        
               
        
    
    %% ------------ CASE SAMPLE ---------

  case 'sample',
    switch value(eval([tname '_Style'])),
       case 'binomial',
        mu = eval([tname '_Mu']);
        max = eval([tname '_Max']);
         
        sample = eval(tname);
        
        
        past_samp=cell2mat(get_history(sample));
        
        if numel(past_samp)>max && all(past_samp(end-(max-1):end)==0)
            sample.value=1;
        else
            sample.value = double(rand(1)<=mu);
        end
        
        
      case 'exponential',
        max = eval([tname '_Max']); min = eval([tname '_Min']); sample = eval(tname);
        tau = eval([tname '_Tau']);
        if tau == 0, sample.value = value(min);
        else         sample.value = min - tau*log(1 - rand(1)*(1 - exp(-(max - min)/tau)));
        end;
        
      case 'uniform',
        max = eval([tname '_Max']); min = eval([tname '_Min']); sample = eval(tname);
        sample.value = rand(1)*(max-min)+min;
        
        
      case 'gaussian',
        max = eval([tname '_Max']); min = eval([tname '_Min']); sample = eval(tname);
        mu  = eval([tname '_Mu']);  sd  = eval([tname '_Sd']); 
        if sd == 0, sample.value = value(mu); else sample.value = randn(1)*sd + mu; end;
        if sample < min, sample.value = value(min); end;
        if sample > max, sample.value = value(max); end;
    end;
    

    %% ------------ CASE GET_NEW_SAMPLE ---------

  case 'get_new_sample',
    if nargin < 3, error('Action ''get_new_sample'' requires additional parameter, name'); end;
    
    feval(mfilename, obj, 'sample', tname);
    sample = eval(tname);
    varargout{1} = value(sample);
    

    %% ------------ CASE GET_CURRENT_SAMPLE ---------

  case 'get_current_sample',
    if nargin < 3, error('Action ''get_current_sample'' requires additional parameter, name'); end;
    
    sample = eval(tname);
    varargout{1} = value(sample);

    
    %% ------------ CASE STYLE ---------
        
  case 'Style',
    style = eval([tname '_Style']);
    switch value(style),
      case 'binomial',
        make_visible({eval([tname '_Mu'])});
        make_invisible({eval([tname '_Tau']) ; eval([tname '_Sd']);eval([tname '_Min'])});     
      case 'exponential',
        make_visible({eval([tname '_Tau'])});
        make_invisible({eval([tname '_Mu']) ; eval([tname '_Sd'])});
      case 'uniform',
        make_invisible({eval([tname '_Mu']) ; eval([tname '_Sd']) ; eval([tname '_Tau'])});
      case 'gaussian',
        make_visible({eval([tname '_Mu']) ; eval([tname '_Sd'])});
        make_invisible({eval([tname '_Tau'])});
      otherwise
        warning('%s: Don''t know Style %s, switching to ''exponential''', mfilename, value(style)); %#ok<WNTAG>
        style.value = 'exponential'; callback(style);
    end;
    callback(eval([tname '_Resample']));
    
    
    % ------------ CASE GET_SOLOPARAMHANDLES ---------
    % Users should be able to get access to SPHs without knowing
    % about get_sphandle. 

  case 'get_soloparamhandles',
    if nargin < 3,
      error('Need the distrib name to return all the SoloParamHandles');
    end;
    
    sp = get_sphandle('owner', ['@' class(obj)], 'fullname', ['^' mfilename '_' tname '_']);
    varargout(1) = {sp};
      
      
  case 'reinit',       % ---------- CASE REINIT -------------
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    
    % feval(mfilename, obj, 'init');
end;

return;


