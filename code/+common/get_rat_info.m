function ratinfo = get_rat_info(ratname)
% Create a table with information on each rat
validateattributes(ratname, {'string', 'char'}, {})
T = M23a.tabulaterats;
index = T.ratname == ratname;
if sum(index) < 1
    error('no rat found')
elseif sum(index) > 1
    error('multiple rats found')
end
ratinfo = table2struct(T(index,:));