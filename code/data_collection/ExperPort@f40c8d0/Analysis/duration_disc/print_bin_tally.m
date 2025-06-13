function []  = print_bin_tally(date_vers, tally_list)

% figure;

rows = ceil(size(tally_list,2)/2);
cols = 2;

cout = char('Bins:', num2str(tally_list{2,1}), 'Sample size:');
for c = 1:size(tally_list,2)
    cout = char(cout, [ date_vers{c,3} ': ' num2str(tally_list{1,c}) ] );
end;

cout
