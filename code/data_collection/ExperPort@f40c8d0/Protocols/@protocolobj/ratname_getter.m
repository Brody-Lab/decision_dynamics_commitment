function [ratname] = ratname_getter(obj)
% gets the selected ratname from the 'rpbox' window.

global exper;

ratID = exper.rpbox.param.ratlist.value;
ratlist = exper.rpbox.param.ratlist.list;

ratname = ratlist{ratID};