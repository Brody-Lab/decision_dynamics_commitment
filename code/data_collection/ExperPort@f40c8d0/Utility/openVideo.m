function openVideo(experimenter, ratname,sessiondate)

olddir=cd;
viddate=sessiondate([1:4 6 7 9 10]);

   if str2double(viddate)<20130514 
       server='brodyfs.princeton.edu';
   else
       server='brodyfs2.princeton.edu';
   end


if ispc
   viddir=sprintf('\\\\%s\\video',server);
   system(sprintf('explorer %s',viddir));
   ratdir=sprintf('\\%s\\%s',experimenter,ratname);
   cd([viddir ratdir]); 
   these_files=dir(sprintf('*%s*',viddate));
   for nx=1:numel(these_files)
       system(sprintf('explorer %s',these_files(nx).name));
   end

elseif isunix
    sysstr=['/ratter/Rigscripts/Play_Rat_Video_Segment.sh ' experimenter ' ' ratname ' ' viddate ' 3 ' server];
    system(sysstr)
end
% Mount brodyfs video
cd(olddir)
% 