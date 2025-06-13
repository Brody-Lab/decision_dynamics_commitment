function [sp] = subsasgn(sp, stct, rhs)

% Note:
% Usually, only the GUI generates an SPH callback when it is
% activated. However, in the case of an automated session, we want a
% central controller to be able to directly change an SPH value and have
% its associated callback be called. 
% In addition to allowing the underlying SoloParam to deal with the
% "subsasgn" call, SPH now handles the special case where stct.subs is
% "value_callback" to allow for the couple value change and SPH callback.
% 

   global private_soloparam_list;
   if isa(private_soloparam_list{sp.lpos}, 'SoloParam'),
      private_soloparam_list{sp.lpos} = ...
          subsasgn(private_soloparam_list{sp.lpos}, stct, rhs);
     
      if length(stct)==1 & strcmp(stct.type,'.') & strcmp(stct.subs,'value_callback')
         % SP: Uncomment this!
         % if  ~isa(gcbo, 'SessionModel')
         % error('Only a SessionModel has the privilege of changing the
         % value directly and calling the associated callback');
         % end;
        if strcmp(get_type(sp), 'solotoggler')
            callback(sp, 'internal_cbk', 1);
        else
            callback(sp);
        end;        
      end;
   else
      error(['The SoloParamHandle you are trying to access has been ' ...
             'deleted from memory']);
   end;
   
   
   
