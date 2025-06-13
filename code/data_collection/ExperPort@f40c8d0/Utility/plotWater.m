function plotWater(rat,dates)
    p=inputParser;
    p.KeepUnmatched=true;
    p.addRequired('rat',@(x)validateattributes(x,{'char','cell'},{'nonempty'}));
    p.addRequired('dates',@(x)validateattributes(x,{'char','numeric'},{'nonempty'}));
    p.parse(rat,dates);
    date_str = parse_daterange(dates);
    date_str = regexprep(date_str,'sessiondate','dateval');
    if ischar(rat)
        ratList=bdata(['select distinct(ratname) from ratinfo.rigwater where ratname regexp "' rat '" and (' date_str ') order by ratname']);              
    else
        ratList=bdata(['select distinct(ratname) from ratinfo.rigwater where ratname regexp "' strjoin(rat,'|') '" and (' date_str ') order by ratname']);  
    end    
    if isempty(ratList)
        error('No rats found matching input string in daterange given.');
    end
    for r=length(ratList):-1:1
        [datevals{r},tv{r},nrt{r}]=bdata(['select dateval,totalvol,n_rewarded_trials from ratinfo.rigwater where ratname regexp "' ratList{r} '" and (' date_str ')']);
    end
    date_str = regexprep(date_str,'dateval','date');
    for r=length(ratList):-1:1
        [date{r},pv{r},pbm{r}]=bdata(['select date,volume,percent_bodymass from ratinfo.water where rat regexp "' ratList{r} '" and (' date_str ')']);
        [massdate{r},m{r}] = bdata(['select date,mass from ratinfo.mass where ratname regexp "' ratList{r} '" and (' date_str ')']);        
    end    
    uniqueDates = unique(cat(1,datevals{:}));
    
    for i=length(uniqueDates):-1:1
        for r=1:length(ratList)
            idx=ismember(datevals{r},uniqueDates{i});
            rigvolume(i,r) = sum(tv{r}(idx));
            n_rewarded_trials(i,r) = sum(nrt{r}(idx));   
            idx=ismember(date{r},uniqueDates{i});            
            pubvolume(i,r) = sum(pv{r}(idx));          
            target_percent(i,r) = sum(pbm{r}(idx)); 
            idx=ismember(massdate{r},uniqueDates{i}); 
            if any(idx)
                mass(i,r) = m{r}(idx);
            else
                mass(i,r)=NaN;
            end
        end
    end
    totalvolume = pubvolume + rigvolume;    
    %vol_per_trial = 1000*rigvolume./n_rewarded_trials; % in uL, not mL
    for r=1:length(ratList)
        subplot(length(ratList),1,r);
        if length(uniqueDates)>1
            h=bar(datetime(uniqueDates),[rigvolume(:,r) pubvolume(:,r)],'stacked');
        else
            h=bar([datetime(uniqueDates) datetime(uniqueDates)+1] ,[rigvolume(:,r) pubvolume(:,r); 0 0],'stacked');            
            set(gca,'xlim',[-0.5 0.5] + datetime(uniqueDates));
        end
%         for i=1:20
%             if any(mass(:,r)*0.01*i<=max(totalvolume(:)))
%                 hold on;plot(datetime(uniqueDates),mass(:,r)*0.01*i,'Marker','*','LineStyle','none');
%             end
%         end
        h(1).FaceColor='b';
        h(2).FaceColor='c';
        title(ratList{r});
        ylabel('vol. water delivered (mL)');
        set(gca,'ylim',[0,max(totalvolume(:))+1],'FontSize',14,'Color','none','TickDir','Out','LineWidth',1,'box','off','ygrid','on');        
    end
    
    
end