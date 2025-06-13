function [r,forder] = struct2array(s)
% vertically concatenates data from struct s according to the order
% "forder" of fieldnames
% expects data in each field to be a row array (ie have 1 row)

forder=fieldnames(s);
r=[];
for k=1:length(forder)
    d=eval(['s.' forder{k} ';']);
    if rows(d) > 1
        error('each field''s data should be a row array');
    end;
    r=vertcat(r, d);    
end;