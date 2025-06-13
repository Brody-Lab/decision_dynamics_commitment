function [s] = SoloParamHandle(varargin)


      global private_soloparam_list

   if nargin==1 && isa(varargin{1}, 'SoloParamHandle'),
      s = varargin{1};
      return;
   
   elseif nargin==1 && numel(varargin{1})==1 && ...
          isnumeric(varargin{1}), % Is it an integer id? Translate into handle

      id = varargin{1};
      if id<1 || id > length(private_soloparam_list),
         error('id cannot be turned into an existing handle');
      end;
      if ~isa(private_soloparam_list{id}, 'SoloParam'),
         error('id cannot be turned into an existing handle');
      end;
      
      s = struct( ...
          'lpos',           id           ...
          );            
      s = class(s, 'SoloParamHandle');   
      return;
   
   else
      % Check for correct args
      if nargin < 2, 
         error(['First arg must be an object or the string ''base'', ' ...
                'second arg must be a string, the param_name']); 
      end;
      if ~isobject(varargin{1}) && ...
           ~(ischar(varargin{1}) && strcmp(varargin{1}, 'base')),
         error('First arg must be an object or the string ''base''');
      end;      
      if ~ischar(varargin{2}) || ~isvector(varargin{2}),
         error('Second arg must be a string, the param_name'); 
      end;
      if ischar(varargin{1}), param_owner = 'base';
      else                   param_owner = ['@' class(varargin{1})];
      end;
      
      param_name  = varargin{2}; varargin = varargin(3:end);
      if rem(length(varargin),2) ~= 0,
         error(['After name, there must be an even number of args (name-' ...
                'value pairs)']);
      end;

      % Set defaults
      type = []; %#ok<NASGU>
      pairs = { ...
          'value'            []       ; ...
          'type'             ''       ; ...
          'param_owner'      param_owner       ; ...
          'param_funcowner'  ''       ; ...
          'labelpos'         'right'  ; ...
          'default_reset_value'  []   ; ...
      }; parse_knownargs(varargin, pairs);
      
      % if isempty(param_owner),     param_owner     =determine_owner; end;
      if isempty(param_funcowner), param_funcowner =determine_fullfuncname;end; %#ok<NODEF>
      
      if isempty(private_soloparam_list), private_soloparam_list = {}; end;
      lpos = length(private_soloparam_list)+1;
      
      varargin = [{'param_name' param_name 'param_owner' param_owner ...
                   'param_fullname' [param_funcowner '_' param_name] ...
                   'listpos' lpos} varargin]; 

      private_soloparam_list = ...
          [private_soloparam_list ; {SoloParam(varargin)}];
            
      
      s = struct( ...
          'lpos',           lpos           ...
          );            
      s = class(s, 'SoloParamHandle');   
      s = set_default_reset_value(s, default_reset_value);
      
      assignin('caller', param_name, s);
      SoloFunctionAddRWArgs(param_owner, param_funcowner, s);
      
      flist=get_funclist(param_owner);      
      % The session model automatically gets read-write access to every SPH
      % owned by this protocol
      if ~isempty(find(strcmp(flist(:,1),'SessionModel')))
          % qualify the variable name before adding it          
          private_soloparam_list{s.lpos}.name = [param_funcowner '_' param_name];          
          SoloFunctionAddRWArgs(param_owner, 'SessionModel', s);
          
          private_soloparam_list{s.lpos}.name = param_name;
      end;
   end;
   
