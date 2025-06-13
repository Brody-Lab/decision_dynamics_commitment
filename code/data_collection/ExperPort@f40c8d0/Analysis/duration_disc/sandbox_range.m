% sandbox_range
% use this runner file to call scripts that grab data oversessions
% esp. when you need to present two sets of consecutive dates
% ex. {[Feb 5 - Feb 13][Mar 1 - March 10]}

ratname = 'Grimesby';
d1= get_files(ratname,'fromdate', '080218', 'todate', '080223');
d2 = get_files(ratname,'fromdate', '080311', 'todate', '999999');


date_array = [d1; d2]


timeout_rate_oversessions(ratname,'use_dateset','given', 'given_dateset', date_array,...
    'mark_special', [length(d1)+1]);