% [] = append_comment_line(ratname, experimenter, str)
%
% Finds the latest settings file for a given rat, and if there is a
% variable called CommentsSection_comments (as in the Comments plugin),
% appends a line with str in it to it. Don't forget to commit your updated
% settings files!
%

function [] = append_comment_line(ratname, experimenter, str)

   datadir = bSettings('get', 'GENERAL', 'Main_Data_Directory');
   u = dir([datadir filesep 'Settings' filesep experimenter filesep ratname filesep 'settings*.mat']);
   
   [X{1:length(u)}] = deal(u.name);
  % First find the latest date
   for xind=1:numel(X)
       Xd{xind}=X{xind}(end-10:end-4);  % This avoids getting the wrong setting because of rat that has run on multiple protocols. or has multiple files for one day.
   end
   [Xd, iXd] = sort(Xd);
   X = X{iXd(end)};
   filename = [datadir filesep 'Settings' filesep experimenter filesep ratname filesep X];
   load(filename);
   
   fnames = fieldnames(saved); %#ok<NODEF>
   keeps = find(strcmp('CommentsSection_comments', fnames));
   if isempty(keeps),
     warning('APPEND_COMMENT_LINE:NoMatch', 'Didn''t find a Comments Section, is the Comments plugin part of this protocol?\n');
     return;
   elseif length(keeps)>1,
     warning('APPEND_COMMENT_LINE:MultipleMatches', 'Huh??? More than one Comments Section? Not doing anything\n');
     return;     
   end;
   
   % -- ok, now add the line, making sure it is not too long.
   old_comms = saved.(fnames{keeps});

   % Now cut the new str into rows the size of rows in old_comms and pad
   % with spaces where necessary:
   MAXLEN = size(old_comms,2);
   chopoff = str(1:min(MAXLEN,length(str)));  % First chunk
   newstr = [chopoff ' '*ones(1, MAXLEN-length(chopoff))]; % pad
   str = str(length(chopoff)+1:end); % remainder
   while ~isempty(str),
     chopoff = str(1:min(MAXLEN,length(str)));
     newstr = [newstr ; [chopoff ' '*ones(1, MAXLEN-length(chopoff))]];
     str = str(length(chopoff)+1:end);
   end;

   % Ok, append, report, and save.
   saved.(fnames{keeps}) = [old_comms ; newstr];   
   fprintf(1, '%s: Added "%s" to comments\n', X, newstr');   
   save(filename, 'saved', 'saved_autoset');
   
   
   
   return;
   