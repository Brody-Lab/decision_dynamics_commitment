%function map_bucket_drive
%
%An active lab member needs to replace PUID with the Princeton University
%ID and password with the princeton university password. Then run:
%pcode('map_bucket_drive.m');
%and commit the new map_bucket_drive.p to SVN
%
%Currently map_bucket_drive is using Chuck's PUID and password -2018
%
%Bucket has been renamed but we will keep the function named the same for
%backwards compatibility 2021-09-30
%
%
%disp('Mapping CUP drive...')
%if ~exist('X:\RATTER','dir')
%    system('net use x: \\cup.princeton.edu\brody /user:princeton\PUID password.');
%else
%    disp('CUP drive already mapped');
%end


