function [EventList] = GetEvents(sfm, startnum, endnum)
   
   mydata = get(sfm.myfig, 'UserData');
   
   if endnum > mydata.nevents,
      error(['Only have ' num2str(mydata.nevents) ' so far, not ' ...
             num2str(endnum)]);
   end;
   
   EventList = mydata.EventList(startnum:endnum,:);
   
   