function do_old_raw(S)


base_dir='c:\CheetahData\Jeff';

if nargin==0
sessid=bdata('select sessid from do.dosess where good_tracking=1');

S=get_sessdata(sessid,'fetch_peh',0);
end

%% recurse through directories
cd(base_dir)
jdirs=dir;

for dx=1:numel(jdirs)
    
    dn=jdirs(dx).name;
    if jdirs(dx).isdir==1 && ~isequal(dn,'.') && ~isequal(dn,'..') && (jdirs(dx).name(1)=='C' || jdirs(dx).name(1)=='J')
        
        [ratname]=parse_rat_dir(dn);
        cd(dn);
        subdirs=dir;
        
        for sdx=1:numel(subdirs)
            sdn=subdirs(sdx).name;
            if subdirs(sdx).isdir && ~isequal(sdn,'.') && ~isequal(sdn,'..')  
            sessiondate=parse_subdir(sdn);
            cd(sdn);
            ev=dir('Events*');
            cd('..')
            if isempty(ev) || ev.bytes<=16384
                continue
            end
        
        ss=bdata('select p.sessid from sessions s, phys_sess p where s.ratname="{S}" and sessiondate="{S}" and p.sessid=s.sessid', ratname, sessiondate);
        if numel(ss)==1
            sx=find(S.sessid==ss);
            if ~isempty(sx)
            [rm,rb]=bdata('select sync_fit_m, sync_fit_b from phys_sess where sessid="{S}"',ss);
            r1=[rm rb];
            process_raw_video(ss,sdn,r1,0)
            end
        end
            end
        end
        cd('..')
    end
    
end


function r=parse_rat_dir(str)

   [r,k]=strtok(str,'_');
   
function s=parse_subdir(str)

   [s,k]=strtok(str,'_');
   
   