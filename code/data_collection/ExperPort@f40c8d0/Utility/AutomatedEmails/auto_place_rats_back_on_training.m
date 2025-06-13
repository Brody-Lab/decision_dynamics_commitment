function auto_place_rats_back_on_training

[Rs,Cs,Is,Gs] = bdata(['select ratname, comments, schedentryid, rig from ratinfo.schedule where date>="',...
    datestr(now+1,'yyyy-mm-dd'),'"']);

for i = 1:numel(Cs)
    temp1 = strfind(lower(Cs{i}),'reserved for');
    temp2 = strfind(Cs{i},datestr(now+1,'yyyy-mm-dd'));
    if ~isempty(temp1) && ~isempty(temp2)
        %found a rig that is reserved for someone until tomorrow.
        
        %Is the rig reserved for someone
        if numel(Cs{i}) >= temp1 + 16
            rtemp = Cs{i}(temp1+13:temp1+16);
        else
            continue;
        end
        
        %Is it a rat's name
        if isempty(str2num(rtemp(2:4)))
            continue;
        end
            
        %Is the rat dead?
        ex = bdata(['select extant from ratinfo.rats where ratname="',rtemp,'"']);
        if isempty(ex) || ex == 0
            continue;
        end
        
        %Is this rat training somehwere else
        if sum(strcmp(Rs,rtemp)) > 0
            %remove reserved note and do not return to training here
            
        else
            %remove reserved note and do return to training here
            
            fakeexp = bdata(['select experimenter from ratinfo.rats where ratname="',rtemp,'"']);
            if isempty(fakeexp); continue; end
            fakeexp = fakeexp{1};
            
            phrase = lower(['reserved for ',rtemp,' until ',datestr(now+1,'yyyy-mm-dd')]);
            
            st = strfind(Cs{i},'[[');
            ed = strfind(Cs{i},']]');
            if numel(st) == 1 && numel(ed) == 1
                newnote = Cs{i}(st+2:ed-1);
            else
                newnote = Cs{i};
            end
            b = strfind(lower(newnote),phrase);
            bad = zeros(size(newnote));
            for k = 1:numel(b)
                bad(b(k):b(k)+numel(phrase)-1) = 1;
            end
            newnote(bad == 1) = '';
            
            %mym(bdata,['update ratinfo.schedule set ratname="',rtemp,'", experimenter="',fakeexp,...
            %    '", comments="',newnote,'", instructions="Remove from free water" where schedentryid=',num2str(Is(i))]);
            
            bdata('call ratinfo.return_rat_to_training("{Si}","{Si}","{Si}","{Si}","{S}")',rtemp,fakeexp,newnote,'Remove from free water',Is(i));
        end
    end
end
    