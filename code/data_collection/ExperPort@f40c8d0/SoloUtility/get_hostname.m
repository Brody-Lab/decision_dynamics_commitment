% [hname] = get_hostname   
% 
% First tries to use bdata to find the hostname 

function [hname] = get_hostname
   [ip,ma,hname]=get_network_info;
   