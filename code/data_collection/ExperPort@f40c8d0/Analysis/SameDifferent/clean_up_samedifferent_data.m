function clean_up_samedifferent_data

[sessid, pd]=bdata('select sessid, protocol_data from sessions where protocol="SameDifferent"');

for sx=1:numel(sessid)
    try
    this_pd=pd{sx};
        fn=fieldnames(this_pd);
    
    n_trials=numel(this_pd.hits);
    
    for fx=1:numel(fn)
        
        if range([numel(this_pd.(fn{fx})), n_trials])<2
            
        this_pd.(fn{fx})=this_pd.(fn{fx})(1:n_trials);
        end
    end
    mym(bdata,'update sessions set protocol_data="{M}" where sessi
    fprintf(1,'Session %d processes\n',sessid(sx));
    catch
        fprintf(2,'Session %d failed\n',sessid(sx))
    end
end

    
    
