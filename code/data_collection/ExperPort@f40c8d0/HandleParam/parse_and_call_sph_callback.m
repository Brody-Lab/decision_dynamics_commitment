function [] = parse_and_call_sph_callback(obj, owner, sph_name, cbck)
%        [] = parse_and_call_sph_callback(obj, owner, sph_name, cbck)
%
% Given an empty object, the name of an owner of an SPH, the name of the
% SPH owned by that object class, and a callback cell or string, parses
% the callback cell/string and tries to call the appropriate callback for
% that object.
%
% [This file is intended to be the central callback parsing
% file. Currently, GUI callbacks call this file; and loading of ui param
% values calls this file; and autosetting also calls this file, but
% indirectly, because it goes through the GUI callback routine.]
%
%   
% The callback parsing rules are:    
%
% If cbck is empty, check to see whether a method with sph_name exists
%    for the object; if so, call it.   
%
% Else each row of callback is interpreted as a callback
% instruction. For each of these, the first element is interpreted as
% the name of the method. Any further existing columns are interpreted
% as arguments to be passed to the method. Each row results in a method
% call. 
%
% If there are more than 2 columns (i.e., more than 1 arg): 
%    Default is to call the object's method with all args;
%    If the first arg is 'super', then the value of SPH
%       named 'super' is extracted from the owner's SPHs, and that value
%       is used as the object with which a method is called. 
%    If the first arg is 'obj', then the default behavior
%       ensues, but that first arg is not passed to the method
%

   if ~isempty(cbck), 
      % We're going to call the functions in sequence.
      if ischar(cbck), cbck = {cbck}; end; 
      for i=1:size(cbck,1), 
         if     size(cbck,2)==1, feval(cbck{i,1}, obj); 
         elseif size(cbck,2)==2, feval(cbck{i,1}, obj, cbck{i,2});
         else
            if strcmp(cbck{i,2}, 'super')  % use fn of superclass, not owner's
               super = get_sphandle('name', 'super', 'owner', owner);
               super = super{1}; 
               feval(cbck{i,1}, value(super), cbck{i,3:end});
            elseif strcmp(cbck{i,2}, 'obj')                       
               feval(cbck{i,1}, obj, cbck{i,3:end});
            else                       
               feval(cbck{i,1}, obj, cbck{i,2:end});
            end;
         end;
      end;
   
   elseif exist([owner filesep sph_name '.m'], 'file'),
      % Empty callback -- check to see whether a function exists,
      % and if so, call it.
      feval(sph_name, obj);
   end;
   
   