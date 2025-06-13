function [] = add_rat_to_eibs(ratname, eib_num, made_by, notes, region)
%  adds new rat to eibs table so that spikes can be synced in database
% example usage add_rat_to_eibs('H037','AEH001','Ahmed','32 channels','FOF')

% before using, make sure that you understand that structure of the table
% you can examine the structure using bdata('explain ratinfo.eibs')
% you can gather up example entries using:
%   [eibid,ratname,eib_num,made_by,made_on,notes,region] = bdata('select * from ratinfo.eibs');

eibid = max(bdata('select eibid from ratinfo.eibs'))+1;

the_query = sprintf(['insert into ratinfo.eibs set ratname="%s", made_by="%s", notes="%s",' ...
    'region ="%s", eibid=%i, eib_num="%s"'],...
    ratname, made_by, notes, region, eibid, eib_num)

bdata(the_query)