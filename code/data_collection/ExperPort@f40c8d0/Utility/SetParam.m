function out = SetParam(module,param,varargin)
% SETPARAM
% Set PARAM values of an exper module.
% 
% OUT = SETPARAM(MODULE,PARAM,VALUE)
% 		Sets the field 'value' to VALUE
% 	
% OUT = SETPARAM(MODULE,PARAM,FIELD,VALUE)
% 		Sets the field FIELD to VALUE
% 
% OUT = SETPARAM(MODULE,PARAM,FIELD1,VALUE1,FIELD2,VALUE2,...,FIELDN,VALUEN)
% 		Sets numerous fields using FIELD-VALUE pairs
%
% Returns 1 for success and 0 for failure.
%
% MODULE and PARAM are strings. 
% FIELD can be a cell array of field names, FIELD = {'f1','f2'},
% in which case the output is a corresponding cell array OUT = {'v1','v2'}
%
% ZF MAINEN, CSHL, 8/00
%
% CDB added comments, 1/05:
% Some fieldnames are special:
%
% -value   If a range specification exists for this param, first fits
%          the value to within this range, then adds it in to the exper
%          structure, as in exper.module.param.value = value
% 
% -list    If this belongs to a UI (user interface) menu item, the menu is remade
%          to have items corresponding to the list. All menu items callback to 
%          the function "FigHandler" if selected.
%

global exper

param = lower(param);
module = lower(module);

out = [];
uifields = {};
% make sure the module param structure has a parameter that we're interested in
sfp = sprintf('isfield(exper.%s.param,''%s'')',module,param);
if evalin('base',sfp)
    if nargin < 4
        % this case means we are passed only the value 
        % and therefore deal with the 'value' field
        sf = sprintf('exper.%s.param.%s',module,param);
        val = range_check(varargin{1},GetP(sf,'range'));
        out = SetP(sf,'value',val);
        SetUI(module,out);
    else
        sf = sprintf('exper.%s.param.%s',module,param);
        np = nargin-2;
        pr = GetP(sf);
        if ishandle(pr.h)
            uifields = fieldnames(get(pr.h));
        end
        for p=1:2:np
            field = varargin{p};
            val = varargin{p+1};
            
            % handle fields that require some processing
            switch field
            case 'value'
                val = range_check(val,GetP(sf,'range'));
                out = SetP(sf,field,val);
                SetUI(module,out);
            case 'format'
                out = SetP(sf,field,val);
                SetUI(module,out);
            case 'list'
                out = SetP(sf,field,val);
                if strcmp(GetP(sf,'ui'),'menu')
                    % We're remaking the menu-- first delete all its components
                    hc = findobj('parent',out.h);
                    if ~isempty(hc) & hc > 0, delete(hc); end
                    if ~isempty(val) 
                        SetP(sf,'range',[1 length(val)]);
                        if ishandle(out.h)
                            for x=1:length(out.list)
                                uimenu(out.h,'tag',out.name,'label',out.list{x},...
                                    'callback','FigHandler;','parent',out.h);
                            end
                        end 
                    end
                else
                    if ~isempty(val) 
                        SetP(sf,'range',[1 length(val)]);
                        SetParamUI(module,param,'string',val);
                    end
                end
            case 'range'
                % make sure the range is passed in correct order
                out = SetP(sf,'range',sort(val));
                
            case {uifields{:}, 'pos'}   % 09/22/2002 modified by Lung-Hao Tai
                % do not set values that are being passed to the ui
                if ishandle(pr.h)
                    SetParamUI(module,param,field,val);
                end
            otherwise
                out = SetP(sf,field,val);
                SetUI(module,out);
            end
        end
    end
end


% begin local functions

function val = range_check(val, range)
% val must lie between range
if ~isempty(range)
    val = min([max([val range(1)]) range(2)]);
end



function h = SetUI(module,param)
global exper

for n=1:length(param.h)
    h = param.h;
    if ishandle(h)
        if strcmp(get(h(n),'type'),'uicontrol')
            switch get(h(n),'style')
            case {'edit','disp'}
                if ~isempty(param.format)
                    switch param.format
                    case 'clock'
                        str = Sec2TimeStr(param.value);
                    case '%d'
                        str = sprintf(param.format,round(param.value));
                    otherwise
                        str = sprintf(param.format,param.value);
                    end
                    set(h(n),'string',str);
                else
                    if isstr(param.value)
                        set(h(n),'string',param.value);
                    else
                        set(h(n),'string',sprintf('%g', param.value));
                    end
                end
            case {'checkbox','slider','listbox','popupmenu','radiobutton'}
                set(h(n),'value',param.value);
            case 'togglebutton'
                set(h(n),'value',param.value);
                if param.value
                    set(h(n),'background',[0 1 0]);
                else 
                    set(h(n),'background',...
                             get(get(get(h(n),'parent'),'parent'), 'color'));
                end
            otherwise
            end
        else
            % must be a menu -- check the selected values
            hc = get(h(n),'children');
            for n=1:length(param.list)
                if any(param.value == get(hc(n),'position'))
                    set(hc(n),'checked','on');
                else
                    set(hc(n),'checked','off');
                end               
            end
        end
    end
end

