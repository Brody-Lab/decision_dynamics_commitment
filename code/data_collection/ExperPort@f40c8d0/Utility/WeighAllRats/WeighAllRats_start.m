function WeighAllRats_start
cd('C:\ratter\ExperPort\Utility\WeighAllRats'); pause(0.1);
currdir = pwd;
cd('\ratter\ExperPort'); system('svn update');
cd('\ratter\Rigscripts'); system('cvs update -d -P -A');
cd('\ratter\bcg'); system('cvs update -d -P -A');
cd(currdir);
clc;

clear('functions');

WeighAllRats('init');

end

