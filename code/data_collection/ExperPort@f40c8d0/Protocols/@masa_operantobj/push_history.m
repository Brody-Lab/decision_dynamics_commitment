function [] = push_history(obj)


% This code is good for all protocol objects.

    push_history(['@' class(obj)]);
    
    return;
    