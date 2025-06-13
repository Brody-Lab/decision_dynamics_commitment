function err=insert_struct(tablename, D)
% insert_struct(tablename,S)
% This function is a helper for inserting rows into the database.
% Input:
%   tablename       The fully qualified table name where you want to insert a row. e.g. ratinfo.mass
%   D               A structure where the fieldnames correspond to columns in the table, and the values correspond
%                   to the data you want to insert.  e.g. if you were inserting a row into ratinfo.mass then D 
%                   would look like:  
%                       D.mass=290;
%                       D.date='2013-3-19'
%                       D.ratname='B044'
%                       D.tech='BBS'
%                       D.timeval='13:00'
%
% e.g. insert_struct(ratinfo.mass,D)


if numel(D)>1
    for nx=1:numel(D)
    err(nx)=insert_struct(tablename, D(nx));
    end
    
else

fn=fieldnames(D(1));

field_str=sprintf('%s,',fn{:});
field_str=field_str(1:end-1);

sql1=['insert into ' tablename ' ( ' field_str ') values '];


form_str='(';
val_str=',';
for dx=1:numel(D)
    for fx=1:numel(fn)
        val=D.(fn{fx});
        if isempty(val) 
            ph='NULL';
            vh='';
        elseif isscalar(val) && ~isstruct(val) && ~iscell(val) && isnan(val)
            ph='NULL';
            vh='';
        elseif isstruct(val) || iscell(val)
            ph='"{M}"';
            vh=sprintf('D.(fn{%d}),',fx);
        elseif ischar(val) || isscalar(val)
            ph='"{S}"';
           vh=sprintf('D.(fn{%d}),',fx);
        else
            ph='"{M}"';
            vh=sprintf('D.(fn{%d}),',fx);
        end
        form_str=[form_str ph ','];
        val_str=[val_str vh];
    end
end
form_str=[form_str(1:end-1)  ')'];
val_str=[val_str(1:end-1)  ')'];
            
SQL=['bdata(''' sql1 form_str '''' val_str];
try
eval(SQL);
err=0;
catch me 
    showerror(me);
    err=1;
end

end