function [status out_fname] = load_datafile(ratname, date, varargin)

pairs = { ...
    'f_ver', '' ;...
    'experimenter', 'Shraddha' ; ...
    'classical', 0 ; ...
    'ftype', 'Data' ; ...% can also be set to 'Settings'
    'own_name', ''; ... % when nonblank, loads a file with a name of one's choosing
    'out_fname',''; ...
    'suppress_out', 0 ; ... % set to 1 to not print any information to stdout when loading
    };
parse_knownargs(varargin,pairs);

if classical > 0
    task = '@classical2afc_soloobj';
else
    ratrow = rat_task_table(ratname);
    task = ratrow{1,2};
end;

status = 1;

if ~isstr(ratname)  % callback    if nargin < 4   % src, event + 3 mandatory
    if nargin < 8
        warning('Either make the rat a string, or give me more args!');
        status = -1;;
    end;
    temp = varargin;
    varargin{1} = date; varargin{2} = f_ver; varargin(3:length(temp)+2) = temp;
end;

if strcmpi(f_ver,'')
    f_ver = date(end);
    date = date(1:end-1);
end;

pairs = {
    'realign', 0 ; ...
    'dlist', []; ...
    'plist', [];...
    'rlist', []; ...
    };
parse_knownargs(varargin, pairs);

if ~isempty(rlist)
    ratname = get(rlist, 'String'); ratname = ratname{get(rlist, 'Value')};
    task = get(plist, 'String'); task = [lower(task{get(plist, 'Value')}) 'obj'];
    date = get(dlist, 'String'); date = date{get(dlist, 'Value')}; f_ver = date(end); date = date(1:end-1);

end;
%    fprintf(1,'%s\n',fname_cshl);

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
try
    if strcmpi(ftype,'Data') & suppress_out == 0,fprintf(1,'(C).');end;
    %    fprintf(1,'Trying CSHL directory ...\n');
    load([fname_cshl '.mat']);
    out_fname = [fname_cshl '.mat'];
catch % Princeton-land
    try
        if length(experimenter) > 0 % has experimenter
            try % no @ sign
                if strcmpi(ftype,'Data') && suppress_out == 0, fprintf(1,'(P-@).');end;
                load([fname_princeton_exp_noat '.mat']);
                out_fname = [fname_princeton_exp_noat '.mat'];
            catch
                try % @ sign
                    if strcmpi(ftype,'Data') && suppress_out == 0,fprintf(1,'(P+@).');end;
                    load([fname_princeton_exp_at '.mat']);
                    out_fname = [fname_princeton_exp_at '.mat'];
                catch
                    % now the scenario where old CSHL rats have been moved
                    % to Princeton dir. Their directory is under the
                    % experimenter's name but filename does not have
                    % experimenter in it.
                    try
                    if strcmpi(ftype,'Data') && suppress_out == 0,fprintf(1,'(P*).');end;
                    load([fname_princeton_exp2 '.mat']);
                    out_fname = [fname_princeton_exp2 '.mat'];
                    
                catch
                    warning(['Invalid file: ' fname]);
                    status = -1;
                    return;
                end;
                end;
            end;
        else % no experimenter
            error('In Princeton repository and no experimenter? Seems fishy ...\n');
        end;
    catch
        if strcmpi(ftype,'Data'),warning(['Invalid file: ' fname_cshl]);end;
        status = -1;
        return;
    end;
    fname = [fname ratname '_' date f_ver];
    load([fname '.mat']);
catch
    error(['Invalid file: ' fname]);

end;

if strcmpi(ftype,'Data') && suppress_out ==0, fprintf(1,'\n');end;
assignin('caller', 'saved', saved);
if strcmpi(ftype,'Data')
assignin('caller', 'saved_history', saved_history);
end;
assignin('caller', 'fig_position', fig_position);
assignin('caller', 'saved_autoset', saved_autoset);