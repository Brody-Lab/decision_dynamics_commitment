%function map_archiveme_drive
%
%An active lab member needs to replace PUID with the Princeton University
%ID and password with the princeton university password. Then run:
%pcode('map_archiveme_drive.m');
%and commit the new map_archiveme_drive.p to SVN
%
%Currently map_archiveme_drive is using Chuck's PUID and password -2019
% 
% 
% if ~exist('Y:\','dir')
%     system('net use y: \\cup.princeton.edu\archive_me\brody /user:princeton\PUID password');
% else
%     disp('ArchiveMe drive already mapped');
% end
