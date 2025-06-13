function [f_method] = get_method_fieldnames(saved, method)
% When given the contents of a protocol's datafile (e.g. "saved" or "saved_history"), 
% returns all available fieldnames for the specified method

f = fieldnames(saved);

len = length(method);

f_method = find(strncmp(f, method, len));
f_method = f(f_method);
f_method = sort(f_method);
