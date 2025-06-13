function newasv = rename_ASV_folder(ratname,sessiondate)

newasv = '';
datadir = bSettings('get','GENERAL','Main_Data_Directory');
if datadir(end) == filesep
    datadir = datadir(1:end-1);
end

E = bdata(['select experimenter from ratinfo.rats where ratname="',ratname,'"']);
if ~isempty(E)
    E = E{1};
    
    rat_data_folder = [datadir,filesep,'Data',filesep,E,filesep,ratname,filesep];
    
    d = dir(rat_data_folder);
    asvltr = [];
    asvgood = [];
    
    fileltr = [];
    filegood = [];
    for i = 1:numel(d)
        if d(i).isdir == 1 && ~isempty(strfind(d(i).name,sessiondate)) && ~isempty(strfind(d(i).name,'ASV'))
            %This is an ASV folder for the indicated sessiondate
            asvgood(end+1) = i; %#ok<AGROW>
            asvltr(end+1) = d(i).name(strfind(d(i).name,sessiondate) + 6); %#ok<AGROW>
            if asvltr(end) == 95; asvltr(end) = 96; end
            
        elseif d(i).isdir == 0 && ~isempty(strfind(d(i).name,sessiondate))
            %This is a data file with the indicated sessiondate
            filegood(end+1) = i; %#ok<AGROW>
            fileltr(end+1) = d(i).name(strfind(d(i).name,sessiondate) + 6); %#ok<AGROW>
            if fileltr(end) == 95; fileltr(end) = 96; end
        end
    end
    
    if ~isempty(asvltr) || ~isempty(fileltr)
        newltr = char(max([asvltr,fileltr]) + 1);
        if double(newltr) < 122 && sum(asvltr == 96) == 1
            %current working ASV folder is the one with no letter
            oldasv = [rat_data_folder,d(asvgood(asvltr == 96)).name];
            
            %The new asv folder will have a letter 1 higher than exists
            newasv = [oldasv(1:end-4),newltr,oldasv(end-3:end)];
            
            movefile(oldasv,newasv);
        end
    end
end