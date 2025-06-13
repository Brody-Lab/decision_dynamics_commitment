% function [helper_var_handles, helper_var_names] = get_current_helper_var_handles(obj)
%
% returns a cell array of handles for all the helper vars extant in the
% current training stage. If a second output argument is asked for, returns
% a cell array of strings, same size as helper_var_handles, with the
% corresponding name (not fullname) of the helper var SPHs

function [my__hvh, my__hvn] = get_current_helper_var_handles(obj)

	GetSoloFunctionArgs('func_owner', get_owner(obj), 'func_name', 'SessionModel');  
	private__handlenames = get_helper_vars(obj);
	
    my__hvh = {}; my__hvn = {};
	if isempty(private__handlenames),
		return;
	end;

    for i=1:numel(private__handlenames),
      try 
        my__hvh = [my__hvh ; {eval(private__handlenames{i})}]; %#ok<AGROW>
        my__hvn = [my__hvn ; private__handlenames(i)];         %#ok<AGROW>
      catch %#ok<CTCH>
      end;
    end;
    