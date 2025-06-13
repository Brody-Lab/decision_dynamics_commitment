function test_bdata
%This function is designed to test basic MySQL functions.
%Run each section separately and see if you get the correct output.

disp('Open the function and run each section separately');

return

%%
%You should see
% Field        Type                           Null   Key   Default   Extra          
% +----------+ +----------------------------+ +----+ +---+ +-------+ +--------------+
%  ratname      varchar(30)                    YES                                   
%  randomblob   blob                           YES                                   
%  anumber      tinyint(3) unsigned zerofill   NO           000                      
%  id           int(10) unsigned               NO     PRI             auto_increment 

bdata('describe carlosexperiment')

%%
%You should see
%  ratname   randomblob                                                                                                                                                                                                                                         anumber   id 
% +-------+ +------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ +-------+ +--+
%  X011      mYm                                                                                                                                                                                                                                                018       18 

bdata('select * from carlosexperiment where id=18');

%%
%You should see
%x =
%
%  1×3 cell array
%
%    {'hello'}    {3×3 double}    {1×1 struct}
%
%
%ans =
%
%    'hello'
%
%
%ans =
%
%    0.9058    0.6324    0.5469
%    0.1270    0.0975    0.9575
%    0.9134    0.2785    0.9649
%
%
%ans = 
%
%  struct with fields:
%
%    a: 1
%    b: 2

x = bdata('select randomblob from carlosexperiment where id=18');
id = bdata('select id from carlosexperiment order by id desc');
id = id(1);

x = x{1}
x{1}
x{2}
x{3}

%%
%You should see the same as above
bdata('insert into carlosexperiment (ratname, randomblob, anumber) values ("{S}","{M}","{Si}")','X999',x,id+1);

x = bdata(['select randomblob from carlosexperiment where id=',num2str(id+1)]);

x = x{1}
x{1}
x{2}
x{3}

