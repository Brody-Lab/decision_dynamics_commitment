function r=getRats(exprmtr_name)
olddir=cd;
try
   

    dd=bSettings('get','GENERAL','Main_Data_Directory');

    if isnan(dd)
        dd='../SoloData';
    end
    
    if dd(end)~=filesep
        dd(end+1)=filesep;
    end
    
    dd=[dd '/Data/' filesep exprmtr_name];
    cd(dd);
    fname=dir;

    r={};
    for xi=1:numel(fname)
        if strcmp(upper(fname(xi).name), 'CVS') || fname(xi).name(1)=='.'
            continue;
        end
        if fname(xi).isdir
			try
				cd(fname(xi).name);
				mf=dir('*.mat');
				if ~isempty(mf)
            r(end+1)={fname(xi).name};
				end
			catch
			end
			cd('..')

        end
    end
    r=r';
catch
    r={''};
end
if isempty(r)
	
    r={''};
end

cd(olddir)