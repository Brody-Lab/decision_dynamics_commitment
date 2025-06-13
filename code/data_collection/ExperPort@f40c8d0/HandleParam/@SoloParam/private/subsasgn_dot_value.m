function [sp] = subsasgn_dot_value(sp, rhs)

sp.value = rhs;
switch sp.type, % type of SoloParam

    case '',       % not UI, no extra stuff to do

    case {'edit' 'disp', 'subheader', 'header'}, % internal values,
        % if possible, always
        % numeric, but the display is a string.
        if ischar(rhs),
            set(sp.ghandle, 'String', rhs);
            if strcmp(rhs, 'NaN'), sp.value = NaN;
            else d = sscanf(rhs,'%g',[1 inf]); if ~isnan(d), sp.value = d; end;
            end;
        elseif iscellstr(rhs)
            set(sp.ghandle, 'String', rhs);  %Sundeep Tuteja, 2010-03-10, we must allow cell arrays of strings for multi line displays
        elseif  islogical(rhs) || (isnumeric(rhs) && min(size(rhs))==1),
            set(sp.ghandle, 'String', sprintf('  %.4g', rhs));
        else
            error(['edit and disp ui values can only be scalar numbers ' ...
                'or strings']);
        end;

    case 'textbox',
        if ischar(rhs),
            set(sp.ghandle, 'String', rhs);
            if strcmp(rhs, 'NaN'), sp.value = NaN;
            else rhs = rhs'; d = str2double(rhs(:)'); if ~isnan(d), sp.value = d; end;
            end;
        elseif islogical(rhs) || (isnumeric(rhs) && min(size(rhs))==1),
            set(sp.ghandle, 'String', sprintf('  %.4g', rhs));
        elseif iscell(rhs),
            set(sp.ghandle, 'String', rhs);
        else
            error(['edit and disp ui values can only be scalar numbers ' ...
                'or strings']);
        end;

    case 'numedit',  % Can only take scalar numbers or strings representing
        % scalar numbers
        if ischar(rhs),
            if strcmp(rhs, 'NaN'), sp.value = NaN;
            else d = sscanf(rhs,'  %g',[1 inf]);
                if ~isnan(d), sp.value = d;
                else error(['numedit can only take strings that represent ' ...
                        'numbers']);
                end;
            end;
        elseif islogical(rhs) || (isnumeric(rhs) & min(size(rhs))==1),
            set(sp.ghandle, 'String', sprintf('  %.4g', rhs));
            sp.value = rhs;
        else
            error(['numedit ui values can only be 1D vectors or ' ...
                'strings of scalar nunbers']);
        end;


    case 'slider', % Can only take numbers within the allowed range
        if ~isnumeric(sp.value) || isnan(sp.value),
            error('slider can only take numeric values');
        end;

        mmin = get(sp.ghandle, 'Min'); mmax = get(sp.ghandle, 'Max');
        if sp.value < mmin, sp.value = mmin; end;
        if sp.value > mmax, sp.value = mmax; end;
        set(sp.ghandle, 'Value', sp.value);

        if ~isempty(sp.lhandle),
            str = get(sp.lhandle, 'String');
            if isempty(str),
                set(sp.lhandle, 'String', sprintf('%g : ', sp.value));
            else
                u = strfind(str, ' : '); if isempty(u), u=-2; end;
                set(sp.lhandle, 'String',sprintf('%g : %s',sp.value,str(u+3:end)));
            end;
        end;


    case 'logslider', % Can only take numbers within the allowed range
        if ~isnumeric(sp.value) || isnan(sp.value),
            error('slider can only take numeric values');
        end;
        mmin = get(sp.ghandle, 'Min'); mmax = get(sp.ghandle, 'Max');
        if sp.value < mmin, sp.value = mmin; end;
        if sp.value > mmax, sp.value = mmax; end;
        % The actual GUI stores a linear number between max and min
        set(sp.ghandle, 'Value', ...
            mmin  +  (mmax-mmin)*(log(sp.value/mmin)/log(mmax/mmin)));

        if ~isempty(sp.lhandle),
            str = get(sp.lhandle, 'String');
            if isempty(str),
                set(sp.lhandle, 'String', sprintf('%g : ', sp.value));
            else
                u = strfind(str, ' : '); if isempty(u), u=-2; end;
                if abs(sp.value) > 999,  numpart = sprintf('%d', round(sp.value));
                elseif abs(sp.value)>99, numpart = sprintf('%.1f', sp.value);
                else                     numpart = sprintf('%.2f', sp.value);
                end;
                set(sp.lhandle,'String',sprintf('%s : %s',numpart,str(u+3:end)));
            end;
        end;


    case 'listbox',
        boxlist = get(sp.ghandle, 'String');
        if ischar(rhs),
            % Try to find it in the box list
            u = find(strcmp(rhs, boxlist));
            if isempty(u), error(['value ' rhs ' not valid for this list']); end;
            set(sp.ghandle, 'Value', u(end));
            % If it can be turned into a number, do so:
            if strcmp(rhs, 'NaN'), sp.value = NaN;   % it really is NaN
            else
                v = str2double(rhs);              % try to make it non-NaN number
                if ~isnan(v), sp.value = v; else sp.value=rhs; end;
            end;
        elseif ~isnumeric(rhs),
            error(['Listboxes can only take string or numeric values']);
        else % see if the number is in the box list as a string
            str = sprintf('%g', rhs);
            u = find(strcmp(str, boxlist));
            if ~isempty(u), set(sp.ghandle, 'Value', u); % found it in list
            elseif rhs < 1  ||  rhs > length(boxlist),
                error(['Value is not in the range of this listbox.']);
            else
                set(sp.ghandle, 'Value', rhs);
                if strcmp(boxlist{rhs}, 'NaN'), sp.value = NaN;
                else
                    v = str2double(boxlist{rhs});
                    if ~isnan(v), sp.value = v; else sp.value = boxlist{rhs}; end;
                end;
            end;
        end;



    case 'menu', % value is the item number in the list of menu possibilities
        menulist = get(sp.ghandle, 'String');
        if ischar(rhs),
            % Try to find it in the menu list
            u = find(strcmp(rhs, menulist));
            if isempty(u), error(['value ' rhs ' not valid for this menu']); end;
            set(sp.ghandle, 'Value', u);
            % If it can be turned into a number, do so:
            if strcmp(rhs, 'NaN'), sp.value = NaN;   % it really is NaN
            else
                v = str2double(rhs);              % try to make it non-NaN number
                if ~isnan(v), sp.value = v; else sp.value=rhs; end;
            end;
        elseif ~isnumeric(rhs),
            error(['Menus can only take string or numeric values']);
        else % see if the number is in the menu list as a string
            str = sprintf('%g', rhs);
            u = find(strcmp(str, menulist));
            if ~isempty(u), set(sp.ghandle, 'Value', u); % found it in list
            elseif rhs < 1  ||  rhs > length(menulist),
                error(['Value is not in the range of this menu.']);
            else
                set(sp.ghandle, 'Value', rhs);
                if strcmp(menulist{rhs}, 'NaN'), sp.value = NaN;
                else
                    v = str2double(menulist{rhs});
                    if ~isnan(v), sp.value = v; else sp.value = menulist{rhs}; end;
                end;
            end;
        end;

    case 'solotoggler',
        if sp.value,
            set(sp.ghandle, 'ForegroundColor', sp.typedata.bgc, ...
                'BackgroundColor', sp.typedata.fgc, ...
                'String',          sp.typedata.OnString, ...
                'FontWeight',      sp.typedata.OnFontWeight);
        else
            set(sp.ghandle, 'ForegroundColor', sp.typedata.fgc, ...
                'BackgroundColor', sp.typedata.bgc, ...
                'String',          sp.typedata.OffString, ...
                'FontWeight',      sp.typedata.OffFontWeight);
        end;

    case 'saveable_nonui',
        % do nothing

    otherwise,
        error(['Don''t know this type (' sp.type ') of UI Param']);
end;

