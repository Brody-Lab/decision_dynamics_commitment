function [odd_sess]=fill_cell_table_with_notes(sessid,cn)
if nargin<2
[cn,sessid]=bdata('select cutting_notes,sessid from phys_sess');
end
odd_sess=[];
for cx=1:numel(cn)
    
    S=parse_cutting_notes(cn{cx});
    if isempty(S)
       odd_sess(end+1)=sessid(cx);
           fprintf(1,'No cutting notes for session %d\n',sessid(cx));
    else
    for sx=1:numel(S)
        sqlstr='update cells set cutting_comment="{S}", single="{S}" where sessid="{S}" and sc_num="{S}" and cluster_in_file="{S}"';
        mym(bdata,sqlstr,S(sx).cutting_comment, S(sx).single, sessid(cx), S(sx).TT-1, S(sx).SC);
    end
    fprintf(1,'Done session %d\n',sessid(cx));
    end
end

        
        
    

