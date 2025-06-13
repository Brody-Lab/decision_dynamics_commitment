% [t] = is_reserved(str)

% Written by Carlos Brody October 2006

function [t] = is_reserved(str)
   
   t = any(strcmp(str, reserved_word_list));
   return;
   
   