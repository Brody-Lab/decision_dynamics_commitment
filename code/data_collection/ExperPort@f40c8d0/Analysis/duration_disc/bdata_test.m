function [] = bdata_test

%[timeslot rig ratname] =
bdata('select timeslot,rig,ratname FROM  ratinfo.schedule WHERE date="2008-09-15" and rig<6');

2;