function out = InitParam(module,param,varargin)
% SETPARAM
% Set PARAM values of an exper module.
% 
% STRUCT = INITPARAM(MODULE,PARAM)
% 		Initialize param to default values
%
% STRUCT = INITPARAM(MODULE,PARAM,VARGIN)
%		Initialize and then call SETPARAM with the extra arguments 
%		(see SetParam)
%
% MODULE & PARAM, are strings
%
% The parameter will have default values as follows
%
% 	default.name = param;
%	default.type = 'double';
%	default.value = 1;
%  default.range = [];
%	default.ui = '';
%	default.h = [];
%	
% ZF MAINEN, CSHL, 8/00
% 
% LHT modified 8/25/02
%
global exper

param = lower(param);
module = lower(module);

if ~ExistParam(module,param)
	% parameter does not yet exist, so we need to init it
	default.name = param;
	default.type = 'param';
	default.value = 0;
	default.range = [];
	default.list = {};
	default.format = '';
	default.ui = '';
	default.h = -1;
	default.save = 0;
    default.pref = [];
	default.trial = [];
	sp = sprintf('exper.%s.param',module);
	SetP(sp,param,default);
end

user = '';

% look for a field 'ui' which tells us to create a ui
h = [];
uifields = {};
np = nargin-2;
for n=1:2:np
    field = varargin{n};
    val = varargin{n+1};
    switch field
        case 'ui'
            h = InitParamUI(module,param,val);
            if ishandle(h)
                fp = get(h);
                uifields = fieldnames(fp);
                SetParam(module,param,field,val);          % modified by Lung-Hao Tai 08/25/2002
            end
        otherwise
    end
end

% next, set any ui properties or fields that might have been passed	
np = nargin-2;
for n=1:2:np
   field = varargin{n};
   val = varargin{n+1};
   switch field
   case 'ui'
      % already dealt with that
   case {'value'}
	  SetParam(module,param,varargin{:});
   case 'pref'
       if ~val
            a=findobj('callback','editparam','tag',param);
            set(a,'visible','off');
       end
        case 'range'                                        % modified by Lung-Hao Tai 01/03/2003
            val=sort(val);
            if ishandle(h) 
                if strcmp(get(h,'style'),'slider') & length(val)==2
                    SetParamUI(module,param,'min',val(1),'max',val(2));
                end
            end
            SetParam(module,param,lower(field),val);
            
        case {'Enable', 'enable'}
            SetParam(module,param,lower(field),val);        % modified by Lung-Hao Tai 08/25/2002
            
    %   case {uifields, 'pos'}
        case {uifields{:}, 'pos'}                           % modified by Lung-Hao Tai 08/25/2002
            if ishandle(h)
                SetParamUI(module,param,field,val);
            end
        otherwise
            SetParam(module,param,lower(field),val);        % modified by Lung-Hao Tai 08/25/2002
    end
end

% deal with preferences that have been saved
if ExistParam('control','user')
    user = getparam('control','user');
    prefstr = sprintf('%s_%s',module,param);
    if ispref(user,prefstr)
        a = getpref(user,prefstr);
        if isstruct(a)
            fields = fieldnames(a);
            n=1;
            for i=1:length(fields)
               switch fields{i}
                case {'name','type','ui','h','trial'}
                % don't restore these        
                otherwise
                    pairs{n} = fields{i};
                    pairs{n+1} = getfield(a,fields{i});
                    n=n+2;
                end
            end
            SetParam(module,param,pairs{:});
        else
            SetParam(module,param,a);
        end
    end
end



