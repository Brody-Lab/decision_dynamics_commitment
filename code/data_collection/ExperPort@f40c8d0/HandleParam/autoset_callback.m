function [] = autoset_callback(ob);
%
% This function gets called when a right button is pressed on a GUI
% SoloParamHandle
%    
   
seltype = get(gcbf, 'SelectionType');

if strcmp(computer, 'MACI'), proceed = strcmp(seltype, 'alt');
else                         proceed = strcmp(seltype, 'alt');
end;
     

if ~proceed, return; end;
     
obj = get(gcbo, 'UserData');
obj = SoloParamHandle(obj);

% Only respond if the SPH is Enabled, otherwise ignore the buttonpress
if ~strcmp(get(get_ghandle(obj), 'Enable'), 'off'),
  autoset_dialog(obj);
end;
     
