
function tms=extract_event(peh,str,s)

pp_flag=0;

if nargin<3
    sx=strfind(str,'(');
    if ~isempty(sx)
        % Using pokesplot style syntax, like cpoke1(end,1)
        pp_flag=1;
        sstate=str(1:sx-1);
    else
        s=1;
        
    end
end




if strcmpi(str, 'L') || strcmpi(str, 'R') || strcmpi(str, 'C'),
    tms = [];
    for ti = 1:numel(peh)
        if isfield(peh(ti).pokes,str)
            tms = [tms; peh(ti).pokes.(str)(:,s)];
        end
    end
else
    tms=zeros(numel(peh),1)+nan;
    if pp_flag==0
        for ti=1:numel(peh)
            if isfield(peh(ti).states,str)
                tms(ti)=peh(ti).states.(str)(s);
            end
        end
    else
        for ti=1:numel(peh)
            if isfield(peh(ti).states,sstate)
                try
                    tms(ti)=eval(['peh(ti).states.' str]);
                catch
                    
                end
            end
        end
    end
    
end