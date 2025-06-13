function [y] = fillSoundsMenu

global Solo_rootdir;
try
    pname=bSettings('get','SOUND','Sound_Directory');
catch
    pname=[Solo_rootdir filesep '..' filesep 'CNMC' filesep 'Sounds' filesep];
end

oldir=cd;

try
   cd(pname);
   s_files=dir('*.mat');
   y{1}='';
   for xi=1:numel(s_files)
       y{xi+1}=s_files(xi).name(1:end-4);
   end
    
   
catch
    y={''};
end
cd(oldir);
