function [added,skipped]=add_old_data

% This script should be :
% 1) run on sonnabend after doing a cvs update on
% 2) run in ExperPort, after doing newstartup.
% 3) run by a user with update priveleges on bdata after doing
% bdata('connect','sonnabend',user,pass)

%dispatcher init;

data_dir=bSettings('get','GENERAL','Main_Data_Directory');

cd(data_dir)
!ls -R | grep data* > /tmp/datafiles.txt

fid=fopen('/tmp/datafiles.txt','r');

dfiles=[];




while 1
    tline=fgetl(fid);
    if ~ischar(tline), break, end

    dfiles=[dfiles {tline}];
end
fclose(fid);

% dfiles=sort(dfiles);  % this puts all files of a certain protocol together.

bdata_protocols=bdata('select distinct(protocol) from sessions');

added={};
skipped={};

for dfx=1:numel(dfiles)
    fname=dfiles{dfx};
    fname=fname(1:end-4); % strip the .mat off the end
    try
        fprintf(1,'Processing %s\n',fname);
        already_in=bdata('select sessid from sessions where data_file="{S}"',fname);
        if isempty(already_in),
            % check if the protocol uses bdata
            [protocol,experimenter,ratname]=get_info_from_fname(fname);
            prot_obj=eval(protocol);
            if ismember(protocol,bdata_protocols)
                cur_prot=dispatcher('get_protocol_object');
% The following code would speed things up.  But it is dangerous, because
% loading a data file doesn't clear out the old data.  
%                 if ~isequal(class(cur_prot), protocol)
%                     dispatcher('set_protocol',protocol);
%                 end

                dispatcher('set_protocol',protocol);  

                SavingSection(prot_obj,'set','ratname',ratname);
                SavingSection(prot_obj,'set','experimenter',experimenter);
                load_soloparamvalues(ratname, 'experimenter', experimenter ,...
                    'owner', protocol, 'interactive', 0,'data_file',fname);

                SavingSection(prot_obj,'set','data_file',[experimenter filesep ratname filesep fname]);



                sessid=getSessID(prot_obj);
                already_in=bdata('select sessid from sessions where sessid="{S}"',sessid);
                if ~isempty(already_in)
                    % this implies that the session was in bdata, but the
                    % data_file column was not set.  let's try to fix that.
                    mym(bdata,'update sessions set data_file="{S}" where sessid="{Si}"',fname, sessid);
                else
                    feval(protocol, prot_obj, 'pre_saving_settings');

                    % now let's double check to see if it was added.
                    already_in=bdata('select sessid from sessions where sessid="{S}"',sessid);
                    if isempty(already_in)
                        skipped=[skipped; {fname}];
                        fprintf(1,'Skipped %s, Tried to add but insert failed\n',fname);
                    else
                        added=[added; {fname already_in}];
                    end

                end

            else
                skipped=[skipped; {fname}];
                fprintf(1,'Skipped %s, cannot process files from this protocol\n',fname);
            end



        end
    catch
        skipped=[skipped; {fname}];
        fprintf(1,'Skipped %s, failed.\n',fname);
        showerror(lasterror);

    end

end


%% subfunctions

function [p,e,r]=get_info_from_fname(x)

x=x(7:end);
[p,x]=strtok(x,'_');
[e,x]=strtok(x,'_');
[r,x]=strtok(x,'_');



