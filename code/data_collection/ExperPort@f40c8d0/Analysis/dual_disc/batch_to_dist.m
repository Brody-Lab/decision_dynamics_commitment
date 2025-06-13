function [files_inc, to] = batch_to_dist(r,ignore)

files_inc = cell(0,0);f_ctr = 1;
to = [];
for k=1:rows(r)
    if sum(strcmp(ignore, r{k,1})) == 0
        files_inc{f_ctr} = r{k,1}; f_ctr = f_ctr+1;
        agg = r{k,3};
        if isempty(to), to = deal(agg); 
        else
            f = fieldnames(agg);
            for ctr = 1:rows(f)
                eval(['to.' f{ctr} '= to.' f{ctr} ' + agg.' f{ctr} ';']);
            end;
        end;                            
    end;        
end;