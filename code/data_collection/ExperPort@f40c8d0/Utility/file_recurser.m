function files = file_recurser(p,skip,maindir,varargin) %#ok<INUSD>

if nargin < 3; maindir = ''; end %#ok<NASGU>

oldfolders{1} = p;
newfolders = [];

temp.dir  = zeros(1,200);
temp.name = zeros(1,200);
temp.date = zeros(1,20);
temp.bytes = 0;

lp = length(p); %#ok<NASGU>

nonew = 0;

cnt1 = 0;
cnt2 = 1; c2 = num2str(cnt2);
maxcnt = 1e4;

files1(1:maxcnt) = temp; %#ok<NASGU>

totalfiles = 0;
totalbytes = 0;
disp('Gathering File Info, Please Wait...');
while nonew == 0
    
    for i = 1:length(oldfolders)
        if sum(strcmp(skip,oldfolders{i})) > 0; 
            continue; 
        end
        
        x = dir(oldfolders{i});
        
        foundfile = 0;
        for j = 1:length(x)
            if strcmp(x(j).name,'.') || strcmp(x(j).name,'..');                        continue; end
            if x(j).isdir == 1; newfolders{end+1} = [oldfolders{i},filesep,x(j).name]; continue; end %#ok<AGROW>
            if isempty(x(j).bytes) || isnan(x(j).bytes);                               continue; end
            
            foundfile = 1;
            cnt1 = cnt1+1;
            totalfiles = totalfiles + 1;
            if cnt1 > maxcnt
                cnt1 = 1;
                cnt2 = cnt2 + 1; c2 = num2str(cnt2);
                eval(['files',num2str(cnt2),'(1:maxcnt) = temp;']);
                
                disp(['Total Files: ',num2str(totalfiles-1),'   Total Bytes: ',num2bytes(totalbytes)]);
            end 
            
            eval(['files',c2,'(cnt1).dir   = [maindir,oldfolders{i}(lp+1:end)];']);
            eval(['files',c2,'(cnt1).name  = x(j).name;']);
            eval(['files',c2,'(cnt1).date  = x(j).date;']);
            eval(['files',c2,'(cnt1).bytes = x(j).bytes;']);

            totalbytes = totalbytes + x(j).bytes;
        end
        if foundfile == 0
            cnt1 = cnt1+1;
            if cnt1 > maxcnt
                cnt1 = 1;
                cnt2 = cnt2 + 1; c2 = num2str(cnt2);
                eval(['files',num2str(cnt2),'(1:maxcnt) = temp;']);
                
                disp(['Total Files: ',num2str(totalfiles-1),'   Total Bytes: ',num2bytes(totalbytes)]);
            end 
            es = ''; %#ok<NASGU>
            eval(['files',c2,'(cnt1).dir   = oldfolders{i}(lp+1:end);']);
            eval(['files',c2,'(cnt1).name  = es;']);
            eval(['files',c2,'(cnt1).date  = es;']);
            eval(['files',c2,'(cnt1).bytes =  0;']);   
        end
    end
    
    if isempty(newfolders); nonew = 1; end
    
    oldfolders = newfolders;
    newfolders = [];
end

eval(['files',c2,'(cnt1+1:maxcnt) = [];']);
    
files = [];
for i = 1:cnt2
    files = [files eval(['files',num2str(i)])]; %#ok<AGROW>
end
                
%disp(['Total Files: ',num2str(totalfiles),'   Total Bytes: ',num2bytes(totalbytes)]);




