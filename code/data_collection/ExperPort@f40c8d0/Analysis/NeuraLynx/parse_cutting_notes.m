function S=parse_cutting_notes(cn)

S=[];
if isempty(cn)
    %keyboard
    return
end

cn=cn(cn~=0);

cn=double(cn);
cn(end+1)=10;
firsttt=regexpi(char(cn)','tt','once');
cn=cn(firsttt:end);
lns=find(cn==10);
start_line=1;
current_tt=0;
cell_idx=1;
for lx=1:numel(lns)
    current_line=upper(char(cn(start_line:lns(lx)))');
    start_line=lns(lx)+1;
    ttplace=regexpi(current_line,'TT[^a-z]');
    if ttplace
        [current_tt,b,b,ttind]=sscanf(current_line(ttplace:end),'TT%d');
        current_line=current_line((ttind+1):end);
    end
    
    clustplace=regexp(current_line, '[0-9]','once');
    if clustplace
        
        [current_clust,b,b,clind]=sscanf(current_line(clustplace:end),'%d');
        current_line=current_line((clind+1):end);
        S(cell_idx).TT=current_tt;
        S(cell_idx).SC=current_clust;
        
        S(cell_idx).cutting_comment=current_line;
        
        issingle=regexpi(current_line,'single|nice|good');
        ismulti=regexpi(current_line,'multi|cutoff');
        
        if ~isempty(issingle) && isempty(ismulti)
            S(cell_idx).single=1;
        else
            S(cell_idx).single=0;
        end   
        cell_idx=cell_idx+1;
   
    else
        % make sure there wasn't an omission
        issingle=regexpi(current_line,'single|nice|good');
        isnothing=regexpi(current_line,'nothing');
        
        if ~isempty(issingle) && isempty(isnothing)
            fprintf(1,'%s\n',current_line);
            keyboard
        end
        % if there is no number on this line it is not informative, skip
    end
    
    
    
    
end
