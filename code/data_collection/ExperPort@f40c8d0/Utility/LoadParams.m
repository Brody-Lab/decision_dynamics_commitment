function out = LoadParams(module)
global exper
% LOADPARAMS
% Make UI's reflect current values of param structure.
% Useful after loading a new exper.
%
% ZF MAINEN, CSHL, 2/01
%


module = lower(module);

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);

fig = findobj('type','figure','tag',module','parent',0);
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
    param = fields{i};
    
    % find an already existing figure handle for this parameter
    h=findobj('parent',fig,'tag',param);
    edit = strcmp(get(h,'callback'),'editparam');
    for n=1:length(h)
        if ~isempty(h(n)) & ~edit(n)
            %SetP(sfs,'h',h(n));
            SetParam(module,param,'h',h(n));
            
            list = GetP(sfs,'list');
            if ~isempty(list)
                SetParam(module,param,'list',GetParam(module,param,'list'));
            end       
            SetParam(module,param,'value',GetParam(module,param,'value'));
        end
    end
end    