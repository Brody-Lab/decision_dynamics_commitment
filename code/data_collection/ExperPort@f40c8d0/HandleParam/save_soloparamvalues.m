% [] = save_soloparamvalues(ratname, varargin)
%
% Opens up interactive filename chooser and then saves ALL soloparamvalues
% (gui AND non-gui). First arg is a string identifying the rat.
%
%
% PARAMETERS:
% ----------
%
% ratname     This will determine which directory the file goes into.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% child_protocol     by default, empty. If non-empty, should be an SPH
%                    that holds an object whose class will indicate the
%                    class of the child protocol who is the real
%                    owner of the vars to be saved.
%
% asv                by default, zero. If 1, this is an non-interactive
%                    autosave, and the file will end in _ASV.mat. If 0,
%                    this is a normal file.
%
%                    New behavior as of 5/9/2017, ASV files will now be
%                    saved in parts in a separate subfolder.  The file name
%                    will contain all previous information along with the
%                    range of trials included in the file. When an asv call
%                    is made the folder will be searched for the highest
%                    trial already saved and only trials from there up to
%                    n_completed_trials will be saved in the new file.
%
% interactive        by default 1; dialogues with the user to determine
%                    the file in which the data will be saved. If 0,
%                    the default suggested filename is used, with
%                    possible overwriting and no questions asked.
%
% commit             by default, 0; if 1, tries to add and commit to CVS
%                    the recently saved file.
%
% remove_asvs        by default, 1. If remove_asvs==1 AND asv ~= 1
%                    (i.e., this NOT an asv save), then
%                    after doing the regular saving of the data, any
%                    ASV file of the same date will be removed (i.e.,
%                    cleanup).  
%
% ascii              by default, 0. If set to 1, then the file is saved
%                    with a '.asc' instead of '.mat' extension, and
%                    requests to commit are ignored. ascii files are
%                    human-readable. 
%
%
% <~> experimenter   If not provided (''), data path is of the form:
%                      .../SoloData/Data/ratname/
%                    If provided, settings path is of the form:
%                      .../SoloData/Data/experimentername/ratname/
%                    The former is old behavior, the latter new.
%
% EXAMPLE CALL:
% -------------
%
%   >> save_soloparamvalues(ratname, 'commit', 1);
%



function varargout = save_soloparamvalues(ratname, varargin)

global Solo_datadir;


pairs = { ...
    'child_protocol', [] ; ...
    'asv', 0; ...
    'interactive'      1 ; ...
    'commit'           0 ; ...
    'remove_asvs'      1 ; ...
    'ascii'            0 ; ...
    'owner'           '' ; ...
    'experimenter'    '' ; ...  % <~> added for new directory hierarchy
	  };
parse_knownargs(varargin, pairs);

% <~> There was a hole in the case handling before that resulted in
%       owner and child_protocol being treated differently.
%     I've shuffled things around and made small changes such that
%       child_protocol overrides owner, THEN checking is done.
%     All files will now be saved and loaded with '@' included;
%       @protocolobj-inherited saving/loading is no longer different.
%     Please be careful in the future when adding code.     

if      ~isempty(child_protocol), owner = class(value(child_protocol)); end; % the child protocol owns all vars

if      isempty(owner), owner = determine_owner;
elseif  ~ischar(owner), error('optional param owner must be a string');
end;

if      owner(1) ~= '@', owner = ['@' owner]; end;


% <~> added experimenter
if ~isempty(experimenter) && ~ischar(experimenter),  error('optional param experimenter must be a string'); end;
% <~> end added experimenter


owner = owner;
obj=eval(owner(2:end));
  
if isempty(Solo_datadir),
    Solo_datadir=bSettings('get','GENERAL','Main_Data_Directory');
    if isnan(Solo_datadir)
        Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
    end
end;
   data_path = [Solo_datadir filesep 'Data'];
   
   % <~> Added experimenter here instead of later on to reduce
   %       probability of break.
   %     Note that organization of filesep applications don't always match
   %       for the load and save fns. :P
   if ~isempty(experimenter)
       data_path = [data_path filesep experimenter];
   end;
   % <~> end Added experimenter

   
   if ~exist(data_path, 'dir'),
      success = mkdir(Solo_datadir, 'Data');
      if ~success, error(['Couldn''t make directory ' data_path]); end;
   end;
   
   handles = get_sphandle('owner', owner);
   k = zeros(size(handles));
   for i=1:length(handles),
      if get_saveable(handles{i}), k(i) = 1; end;
   end;
   handles = handles(find(k));
   
      %%
   protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
   if ~isempty(protocol_name),
       protocol_name = protocol_name{1};   
       fig_position = get(...
       findobj(get(0, 'Children'), 'Name', value(protocol_name)),'Position');
   else
      fig_position = [];
   end;
   
   % Now set the path for the data file
   
   if data_path(end)~=filesep, data_path=[data_path filesep]; end;
   
   rat_dir = [data_path ratname];
   if ~exist(rat_dir)
       success = mkdir(data_path, ratname);
       if ~success, error(['Couldn''t make directory ' rat_dir]); end;
   end;
   if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;
   if strcmp(rat_dir(1:2),'C:') == 0 && exist(['C:',rat_dir],'dir') == 7; 
       rat_dir = ['C:',rat_dir]; 
   end
   
   saved = struct; saved_history = struct; saved_autoset = struct;  
   for i=1:length(handles),
      saved.(get_fullname(handles{i}))        = value(handles{i});
      saved_autoset.(get_fullname(handles{i}))= get_autoset_string(handles{i});
   end;
   
   if asv > 0
       %new asv saving behavior only the last n trials will be saved in a
       %unique file in a subdirectory in the rat directory. Subdirectory name
       %will be the date yymmdd_ASV format and the file name will include the
       %trials included in the file. We will pull the full history of each
       %varibale and then crop before inserting into the saved_history
       %struct
       
       pname = [rat_dir,'data_',owner,'_',experimenter,'_',ratname,'_',yearmonthday,'_ASV',filesep];
       if ~exist(pname,'dir') 
           success = mkdir(pname);
           if ~success, error(['Couldn''t make directory ' pname]); end;
       end

       fname = ['data_',owner,'_',experimenter,'_',ratname,'_',yearmonthday,'_*.mat'];
       u = dir([pname,fname]);
       min_trial = 1;
       for i = 1:numel(u)
           if u(i).isdir == 0
               new_min_trial = str2num(u(i).name(end-7:end-4)); %#ok<ST2NM>
               if new_min_trial > min_trial
                   min_trial = new_min_trial + 1;
               end
           end
       end
       if isfield(saved,'ProtocolsSection_n_completed_trials')
           max_trial = saved.ProtocolsSection_n_completed_trials;
       else
           max_trial = Inf; 
       end
       
       N = zeros(1,length(handles));
       for i=1:length(handles),
          full_history = get_history(handles{i});
          n = numel(full_history);
          N(i)=n;
          if     n > min_trial && n >= max_trial
              crop_history = full_history(min_trial:max_trial);
          elseif n > min_trial && n < max_trial
              crop_history = full_history(min_trial:end);
          elseif n < min_trial && n >= max_trial
              crop_history = full_history(1:max_trial);
          else
              crop_history = full_history;
          end
          saved_history.(get_fullname(handles{i}))=crop_history;
       end;
       if max_trial == Inf; 
           max_trial = min(N(N>0)); %highest trial we have a value for on every trial
       end
       if all(N < min_trial)
           %The autosave files are from a previous run and should be
           %removed since they are conflicting. While not a great behavior
           %it's consistant with previous behavior of this code
           min_trial = 1;
           for i = 1:numel(u)
               if u(i).isdir == 0
                   delete([pname,u(i).name]);
               end
           end
       end
       fname = ['data_',owner,'_',experimenter,'_',ratname,'_',yearmonthday,'_',...
           sprintf('%04i',min_trial),'_',sprintf('%04i',max_trial),'.mat'];
       
   else
   
       for i=1:length(handles),
          saved_history.(get_fullname(handles{i}))= get_history(handles{i});
       end;
   end
   
  

   
% <~> Added conditional handling for new filename format.
%     When experimenter is non-empty, filenames will be of the form
%       data_@protocolobj_experimentername_ratname_YYMMDDz
%     Otherwise (if experimenter is empty), they will be of the old form:
%       data_@protocolobj_ratname_YYMMDDz
experimenter_ = '';
if ~isempty(experimenter), experimenter_ = [experimenter '_']; end;
% <~> end Added conditional handling for new filename format.


if asv == 0
   if ~ascii,
      u = dir([rat_dir 'data_' owner '_' experimenter_ ratname '_' yearmonthday '*.mat']); % <~> added experimenter_
   else
      u = dir([rat_dir 'data_' owner '_' experimenter_ ratname '_' yearmonthday '*.asc']); % <~> added experimenter_
   end

   if ~isempty(u),
      [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
      fullname = [rat_dir filenames{end}]; 
      fullname = fullname(1:end-4); % chop off .mat or .asc
      if strcmpi(fullname(end-3:end),'_ASV')
          fullname = [fullname(1:end-4) 'a'];
      else
          fullname(end) = fullname(end)+1;
      end;
      
   else
      fullname = [rat_dir 'data_' owner '_' experimenter_ ratname '_' yearmonthday 'a']; % <~> added experimenter_
   end;

   fullname=check_name(fullname, ratname);   
   rn = [experimenter_ ratname]; % <~> added experimenter_
    if interactive,
       if ~ascii, ext = '*.mat'; else ext = '*.asc'; end;
       [fname, pname] = ...
           uiputfile({['*' owner '*' rn ext], ...
                      [ owner ' ' rn ' files (*' owner '*' rn ext ')'] ;...
                      ['*' rn ext], [rn ' files (*' rn ext ')'] ; ...
                      ext,  ['All ' ext(2:end) ' files (' ext ')']}, ...
                     'Save data', fullname);
       if fname == 0, varargout{1}=''; return; end;    
    else
       fname = fullname; pname = '';
    end;       
end;

if ~ascii,
   save([pname fname], 'saved', 'saved_history', 'saved_autoset', ...
        'fig_position');
else
   save_ascii([pname fname], saved_history);
end;

if nargout>=1
    varargout{1}=[pname fname];
end

if ~ascii, % Only commit to CVS repository if not saved in ascii form
   % Make sure it is a .mat extension:
   [path, name, ext] = fileparts([pname fname]); 
   if ~strcmp('.mat', ext), fname = [name '.mat']; end;
   % Then add and commit if necessary:
   if commit, add_and_commit([path filesep fname]); end;
end;


if ~asv,
    %new code to delete ASV folder, first we must delete all the files,
    %then we can remove the folder
    asv_pname = [rat_dir,'data_',owner,'_',experimenter,'_',ratname,'_',yearmonthday,'_ASV'];
    if exist(asv_pname,'dir') == 7
        disp(['Data file saved. Deleting ASV folder ',asv_pname]);
        disp(' ');
        u = dir(asv_pname);
        for i = 1:numel(u);
            if u(i).isdir == 0
                delete([asv_pname,filesep,u(i).name]);
            end
        end
        rmdir(asv_pname);
    end
end;

 
return;


% ----------------------------------------

function save_ascii(fullpathname, saved_history) 
   
   fp = fopen(fullpathname, 'w');
   ascii_write_variable(fp, saved_history);
   fclose(fp);
   

   
% ----------------------------------------

% THIS FUNCTION NO LONGER USED
function write_structure(fp, saved, structname)
   
   fnames = fieldnames(saved);
   for i=1:rows(fnames),
      switch class(saved.(fnames{i})),
       case {'double' 'single'},
         fprintf(fp, [structname '.%s = '], fnames{i});
         fprintf(fp, '[ ');
         fprintf(fp, '%g  ', saved.(fnames{i}));
         fprintf(fp, ' ];\n');
       
       case 'char',
         fprintf(fp, [structname '.%s = '], fnames{i});
         fprintf(fp, '''');
         fprintf(fp, '%c', saved.(fnames{i}));
         fprintf(fp, ''';\n');

       case 'cell',
         fprintf(fp, [structname '.%s = '], fnames{i});
         fprintf(fp, '{ ');
         for j=1:rows(saved.(fnames{i})),
            for k=1:cols(saved.(fnames{i})),
               switch class(saved.(fnames{i}){j,k}),
                case {'double' 'single'},
                  fprintf(fp, '[ ');
                  fprintf(fp, '%g  ', saved.(fnames{i}){j,k});
                  fprintf(fp, ' ];\n');
                  
                case {'char'},
                  fprintf(fp, '''');
                  fprintf(fp, '%c', saved.(fnames{i}){j,k});
                  fprintf(fp, ''';\n');
                  
                otherwise
                  fprintf(fp, '''data type not supported for ascii saving''');
               end;
               
               if cols(saved.(fnames{i})) > 1  &  k<cols(saved.(fnames{i})),
                  fprintf(fp, ' , ');
               else
                  fprintf(fp, ' ; ');
               end;
            end;
         end;
         fprintf(fp, ' };\n');

       otherwise,
         fprintf(fp, [structname '.%s = '], fnames{i});
         fprintf(fp, '''data type not supported for ascii saving'';\n');
      end;
   end;

   % Check for existing runs in the sessions table and increment the file
   % name by the number of previous runs of the day.
   %
   %Changing this behavior.  We should check for previous runs and make
   %sure the letter is more than that number, i.e. if the rat has 3
   %previous runs today then at a minimum his letter should be "d" but if
   %it's greater than that just leave it as is. This way files will
   %increment as a,b,c... rather than a,c,f... -Chuck 7/12/2018
   
    function fn=check_name(fn,rat)
    try 
        second_run=bdata('select sessid from sessions where ratname="{S}" and sessiondate=date(now())',rat);
        
        if double(fn(end)) < double('a') + numel(second_run)
            fn(end)=char(double('a')+numel(second_run));
        end
    catch
       %hack
    end
   