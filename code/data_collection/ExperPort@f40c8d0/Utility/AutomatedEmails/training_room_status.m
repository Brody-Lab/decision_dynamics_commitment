function training_room_status

%updatefile = 'C:\Brody Lab\ratter\ExperPort\Utility\AutomatedEmails\last_time_training_room_update.mat';

r = check_running([]);
m = update_lists([]);
w = init_check([]);

N = bdata(['select telephone from ratinfo.contacts where experimenter="',r.activetech,'"']);

M = 'Weighed: ';
for i = 1:numel(m.completed)
    if m.completed(i) == 1
        if numel(M) == 9; extra = ''; 
        else              extra = ','; %#ok<SEPEX>
        end
        
        if i == 10
            M = [M,extra,'Recov']; %#ok<AGROW>
        elseif i == 11
            M = 'Weighed: ALL';
        else
            M = [M,extra,num2str(i)]; %#ok<AGROW>
        end
    end
end

W = 'Watered: ';
if sum(w.comp) == numel(w.comp)
    W = [W,'ALL'];
else
    for i = 1:numel(w.comp)
        if w.comp(i) == 1
            if numel(W) == 9; extra = ''; 
            else              extra = ','; %#ok<SEPEX>
            end

            if i == 10
                W = [W,extra,'Free']; %#ok<AGROW>
            else
                W = [W,extra,num2str(i)]; %#ok<AGROW>
            end
        end
    end
end

towers = [1,2,3;...
          4,5,6;...
          7,8,9;...
          10,11,12;...
          13,14,15;...
          16,17,18;...
          19,20,21;...
          22,23,24;...
          25,26,27;...
          28,29,30;...
          31,32,33;...
          34,35,36;...
          37,38,39;...
          201,202,203;...
          204,205,210];
      
% for i = 1:17
%     x = bdata(['select top from ratinfo.training_room where tower=',num2str(i)]);
%     if isempty(x)
%         bdata('insert into ratinfo.training_room set top="", middle="", bottom=""');      
%     end
% end

%mym(bdata,'update ratinfo.training_room set top="{S}", middle="{S}", bottom="{S}" where tower=1',r.time,M,W);
bdata('call ratinfo.update_training_room("{S}","{S}","{S}","{Si}")',r.time,M,W,1);

if ~isfield(r,'duration'); r.duration = 0; end

%mym(bdata,'update ratinfo.training_room set top="{S}", middle="{S}", bottom="{S}" where tower=2',[r.activetech,' ',num2str(N)],r.session,r.duration);      
bdata('call ratinfo.update_training_room("{S}","{S}","{S}","{Si}")',[r.activetech,' ',num2str(N)],r.session,r.duration,2)
      
for i = 1:size(towers,1)      
    for j = 1:size(towers,2)
        try status = eval(['r.status',num2str(towers(i,j))]);
        catch status = '';
        end
        temp{j} = [sprintf('%3i',towers(i,j)),': ',status];
    end
    %mym(bdata,'update ratinfo.training_room set top="{S}", middle="{S}", bottom="{S}" where tower={S}',temp{1},temp{2},temp{3},i+2);
    bdata('call ratinfo.update_training_room("{S}","{S}","{S}","{Si}")',temp{1},temp{2},temp{3},i+2);
end

bdata('select top, middle, bottom from ratinfo.training_room')

%lastupdate = now; %#ok<NASGU>
%save(updatefile,'lastupdate')
