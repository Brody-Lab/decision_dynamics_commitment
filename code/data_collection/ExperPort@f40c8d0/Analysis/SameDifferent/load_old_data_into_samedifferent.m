function load_old_data_into_samedifferent




curdir=pwd;

datadir=bSettings('get','GENERAL', 'Main_Data_Directory');
if isempty(datadir) || any(isnan(datadir))
    datadir=[filesep 'ratter'];
end

done=bdata('select sessid from solodata.samedifferent');
[all_sd,data_files,experimenters,ratnames,sessiondates]=bdata('select sessid,data_file,experimenter,ratname,sessiondate from sessions where protocol="samedifferent" order by experimenter');
[bad_sess]=bdata('select sessid from udata.sesstag where tag="not_in_cvs" and ignore_tag=0');

[sess_todo, ix]=setdiff(all_sd, [done; bad_sess]);



if isempty(sess_todo)
    return;
end
experimenters=experimenters(ix);
ratnames=ratnames(ix);
data_files=data_files(ix);
sessiondates=sessiondates(ix);

[experimenters,ix]=sort(experimenters);
ratnames=ratnames(ix);
data_files=data_files(ix);
sessiondates=sessiondates(ix);
sess_todo=sess_todo(ix);
old_experimenter=experimenters{1};


for fx=1:numel(sess_todo)
    try
        data_file=data_files{fx};
        if isempty(strtrim(data_file))
            continue
        end
        ratname=ratnames{fx};
        experimenter=experimenters{fx};
        %		if ~strcmp(experimenter, old_experimenter)
        %			remove_dir(old_experimenter);
        %		end
        sessiondate=sessiondates{fx};
        sessid=sess_todo(fx);
        datapath=[datadir filesep 'Data' filesep experimenter filesep ratname filesep];
        
        setspath=[datadir filesep 'Settings' filesep experimenter filesep ratname filesep];
        % this is redundant, but easier than finding the unique rats....
        verifyPathCVS(datapath);
        
        cd(datapath);
        
        % does our data file have the .mat extension?
        if ~strcmp('.mat',data_file(end-3:end))
            data_file=[data_file '.mat'];
        end
        %% get the file
        %  get all files for a the rat
        df=dir(data_file);
        if isempty(df)
            [sysout]=system(['cvs up ' data_file  ]);
        end
        
        df=dir(data_file);
        if isempty(df)
            bdata('insert into udata.sesstag (ratname, sessid, tag) values ("{S}", "{S}", "not_in_cvs")',ratname, sess_todo(fx));
            fprintf(2,'Session %d not in cvs but in sessions table\n',sess_todo(fx));
            continue
        end
        
        %% Load the file.
        load(data_file);
        
        % sessid hack
        saved.SameDifferent_sessid=sessid;
        
        
        % go through the saved_history structure and split it up by the
        % function owners.
        [a,b,c,d,e,f]=bdata('explain solodata.samedifferent');
        
        fn=fieldnames(saved_history);
        func_list=a(6:end);  % only process SPHs that belong to a column in the table.
        col_list='';
        val_list='';
        var_list='';
        for flx=1:numel(func_list)  % for each function list
            fl_in_fn=strmatch(func_list{flx}, fn);
            % find the fieldnames of saved_history that match
            if ~isempty(fl_in_fn)
                for flfnx=1:numel(fl_in_fn)
                    % for each matching field, assign it to a struct
                    S{flx}.(fn{fl_in_fn(flfnx)})=saved_history.(fn{fl_in_fn(flfnx)});
                end
                
                col_list=[col_list ',' func_list{flx}];
                val_list=[val_list ',"{M}"' ];
                var_list=[var_list ',S{' num2str(flx) '}'];
            end
        end
        
        sqlstr=['''insert into solodata.samedifferent (sessid, ratname, sessiondate,datafile,saved' col_list ') values ("{S}","{S}","{S}","{S}","{M}"'  val_list ')'''];
        
        eval(['bdata(' sqlstr ', sessid, ratname, sessiondate,data_file,saved ' var_list ');'])
        
        fprintf(1,'Session %d done\n',sessid);
    catch
        showerror
        fprintf(1,'Failed to save %d to sql in save_soloparamvalues\n',data_file);
    end
    
    clear saved saved_history
end

cd(curdir)

function remove_dir(oe)
system(['rm -rf ../../' oe])
