function FigHandler
% FIGHANDLER
% Works hard for all the modules!
global exper

if ~isempty(gcbf)						
	module = get(gcbf,'tag');
	name = get(gcbo,'tag');
%	value = [];
	if strcmp(get(gcbo,'type'),'uicontrol')
		switch get(gcbo,'style')
		case 'edit'
			if isa(GetParam(module,name,'value'),'numeric');
				value = str2num(get(gcbo,'string'));
			else
				value = get(gcbo,'string');
			end
		case 'pushbutton'
			% do nothing
		otherwise
			value = get(gcbo,'value');
		end
	else
		value = get(gcbo,'position');
	end
	
	% first we set the parameter 
	if exist('value')==1                 %10/13/2003 Lung-Hao Tai modified for pushbutton
		SetParam(module,name,value);
	end

	% then we call the appropriate action in the module
	% (which may or may not exist)
	CallModule(module,name);
end
	

