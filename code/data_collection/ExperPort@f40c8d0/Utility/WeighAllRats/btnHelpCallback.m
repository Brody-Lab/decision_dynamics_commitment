function btnHelpCallback

helpstr = {'WEIGHING INSTRUCTIONS:'};

helpstr{end+1} = '';

helpstr{end+1} = '1. Place the container for the rat on the balance, and';
helpstr{end+1} = '     ensure that the balance is zeroed on the container''s weight.';
helpstr{end+1} = '2. Select the session you want to weigh rats for and press';
helpstr{end+1} = '     START.';
helpstr{end+1} = '3. After the rats for a particular session have been weighed,';
helpstr{end+1} = '     select a new session if necessary. Repeat this process';
helpstr{end+1} = '     until all the rats selected for weighing have been weighed.';
helpstr{end+1} = '4. At the end of the weighing process, hit SAVE AND EXIT to';
helpstr{end+1} = '     write the data to the database and exit.';

helpstr{end+1} = '';

helpdlg(helpstr, 'HELP DIALOG');