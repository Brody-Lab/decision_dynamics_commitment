function btnEditSelectedEntryCallback

global FIGURE_NAME;
global EDIT_SELECTED_ENTRY_CALLBACK;

EDIT_SELECTED_ENTRY_CALLBACK = false;

hndlMassMeister = findobj(findall(0), 'Name', FIGURE_NAME);
handles = guihandles(hndlMassMeister(1));

%Get selected rat and mass
lbxlist = get(handles.lbxRatInfo, 'String');
lbxval = get(handles.lbxRatInfo, 'Value');
if lbxval>=2
    lbxlist{lbxval} = regexprep(lbxlist{lbxval}, '\s', '');
    rat_name_str = regexprep(lbxlist{lbxval}, '\|.*', '');
    mass_str = regexprep(lbxlist{lbxval}, '[^\|]*\|', '');
    
    prompt = {['Enter the mass for ' rat_name_str ' in grams:']};
    defAns = {mass_str};
    dlg_title = 'Edit Rat Information';
    numlines = 1;
    options.WindowStyle = 'modal';
    
    errflag = true;
    while errflag == true
        
        errflag = false;
        
        answer = inputdlg(prompt, dlg_title, numlines, defAns, options);
        
        if ~isempty(answer)
            for ctr = 1:length(answer)
                try
                    answer{ctr} = regexprep(answer{ctr}, '\s', '');
                    answer_num = eval(answer{ctr});
                    if ~isnumeric(answer_num) || answer_num<0
                        error(' ');
                    end
                    
                catch %#ok<CTCH>
                    errflag = true;
                    waitfor(errordlg('ERROR: Invalid input.', 'ERROR', 'modal'));
                    break;
                end
            end
        else
            errflag = false;
        end
        
    end
    
    if ~isempty(answer)
        mass_str = answer{1};
        
        load('ratinfo_temp.mat'); %Loads 'RATLIST' 'CAGEMATELIST' 'MASSLIST' 'TIMESLOTLIST' 'ISRECOVERINGLIST' 'ISNEWLIST' 'ISTRAININGLIST'
        for ctr = 1:length(RATLIST) %#ok<USENS>
            if strcmp(RATLIST{ctr}, rat_name_str)
                if ~strcmp(MASSLIST{ctr}, mass_str) %#ok<NODEF>
                    EDIT_SELECTED_ENTRY_CALLBACK = true;
                    MASSLIST{ctr} = mass_str; %#ok<AGROW,NASGU>
                    ISNEWLIST(ctr) = true; %#ok<AGROW,NASGU>
                    save('ratinfo_temp.mat', ...
                        'RATLIST', ...
                        'CAGEMATELIST', ...
                        'MASSLIST', ...
                        'TIMESLOTLIST', ...
                        'ISRECOVERINGLIST', ...
                        'ISNEWLIST', ...
                        'ISTRAININGLIST', ...
                        'ISFORCEFREEWATERLIST', ...
                        'ISFORCEDEPWATERLIST', ...
                        '-v7');
                    refreshLbxRatInfo;
                    pause(0.05);
                    break;
                end
            end
        end
    end
end

end

