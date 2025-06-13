function generate_test_technotes(type,varargin)

if nargin < 1; type = 'random'; end

%time = clock;
%fs = round((time(6) - floor(time(6)))*1000);
%rand('twister',sum(time(1:5))+fs);
rng('shuffle','twister');

cr = bdata('select contact from ratinfo.rats where extant=1');
[ex,em] = bdata('select experimenter, email from ratinfo.contacts where is_alumni=0');

for i=1:numel(em)
    id{i} = em{i}(1:find(em{i}=='@',1,'first')-1);
end

EX=cell(0);
for i = 1:numel(cr)
    x = cr{i};
    if isempty(x); continue; end
    bks = [0,find(x==' ' | x==','),numel(x)+1];
    for j = 1:numel(bks)-1
        temp1 = x(bks(j)+1:bks(j+1)-1);
        temp2 = find(strcmp(id,temp1)==1,1,'first');
        if ~isempty(temp2)
            EX{end+1} = ex{temp2};
        end
    end
end

uex = unique(EX');
colors = upper({'red','orange','yellow','green','blue','purple','magenta','cyan','black','white','brown','pink'});

for i = 1:numel(uex)
    if strcmp(type,'random'); x = rand(1);
    else                      x = 0;
    end
    
    if x < 1/21
        note = ['This is a test. Please respond to this email with the word ',colors{ceil(rand(1)*numel(colors))}];
        bdata(['insert into ratinfo.technotes set datestr="',datestr(now,'yyyy-mm-dd'),'", timestr="',...
            datestr(now,'HH:MM:SS'),'", experimenter="',uex{i},'", note="',note,'", techinitials="CK"']);
    end
end

    
    


