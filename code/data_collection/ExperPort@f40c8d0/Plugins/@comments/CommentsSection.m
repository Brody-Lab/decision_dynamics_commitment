% [varargout] = CommentsSection(obj, action, varargin)
%
% A plugin that provides a simple text box for jotting down comments about
% the rat. The plugin creates a togglebutton that opens and closes a new
% figure with two textboxes: an overall comments box, intended as a space
% for comments that cover many days or the entire training lifetime of the
% animal; and a detailed comments textbox, intended for the day-by-day comments.
%
% To use, simply add
%
%  >> [x, y] = CommentsSection(obj, 'init', x, y); 
%
% to your protocol's startup.
%
% IMPORTANT NOTE: Since the text boxes are GUI SoloParamHandles, Dispatcher will
% automatically store a history of the comments boxes on every trial. This
% is completely unnecessary. Clearing the history on each trial is
% recommended so as to avoid unnecessary memory hogging. See
% action='clear_history' below.
%
% 2020-10-03 Thomas Luo allowed the saving of comments on each trial. The
% action 'clear history' does not save trial by trial comments.
%
% PARAMETERS:
% -----------
%
% obj         Defaut object argument
%
% action      A string, one of the following:
%
%     'init' x y     RETURNS x, y
%             The 'init' action expects two more parameters, x and y, the
%             pixel position on the current figure on which a button that
%             opens/closes the Comments box figure will be placed. Returns
%             an x and y position suitable for putting in a GUI element
%             that will not overlap with the CommentsSection one.
%
%     'clear_history'
%             It is recommended that this action be called on every trial.
%             Clears any history of both day-by-day and overall comments.
%
%     'get'    RETURNS str
%             The 'get' action returns the char matrix of the day-by-day
%             comments. This matrix is space-padded to the right.
%
%     'get_latest'    RETURNS str
%             The 'get_latest' action returns the char matrix of the most
%             recent comments. This matrix is space-padded to the right.
%
%     'set' str
%             The 'set' action takes an extra parameter, a char matrix that
%             will be the new value of the day-by-day comments box.
%
%     'append_line'  str
%             The 'append_line' action takes an extra parameter, a char
%             vector that will be appended to the bottom of the day-by-day
%             comments as a new line.
%
%     'append_date'  
%             This action adds a new line with a string indicating the date
%             at the bottom of the day-by-day comments.
%
%     'clean_lines'
%             Make sure all lines are at most 80 chars long, so they fit in
%             window. Break into two any lines that are longer.
%
%     'close'  
%             Close and delete any figures or SoloParamHandles associated
%             with this section.
%
%     'reinit'
%             Closes and deletes figures and SoloParamHandles associated
%             with this section; then reinitializes, starting at the same
%             point of the same original figure than the last 'init'
%
%
% EXAMPLE:
% --------
%
% On every 'prepare_next_trial', you could do:
%
%    CommentsSection(obj, 'clear_history');
%    if n_done_trials == 1,
%        CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
%    end;
%

% Written by Carlos Brody Nov 07

function [x, y] = CommentsSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
    ToggleParam(obj, 'CommentsShow', 0, x, y, 'OnString', 'Comments showing', ...
      'OffString', 'Comments hidden', 'TooltipString', 'Show/Hide Comments panel'); 
    set_callback(CommentsShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    next_row(y);
    
    SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [100 100 560 660], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename)), 'saveable', 0);
    set(gcf, 'Visible', 'off');

    % ---

    comments = [];
    TextBoxParam(obj, 'comments', '', 10, 10, 'labelpos', 'top', 'labelfraction', 0.0625, ...
      'position', [10 10 540 320], 'label', 'Detailed Comments (e.g., day-by-day)');
    set(get_ghandle(comments), 'HorizontalAlignment', 'Left', 'FontSize', 14);
    set(get_lhandle(comments), 'FontSize', 16);

    TextBoxParam(obj, 'comments_on_each_trial', '', 10, 10, 'labelpos', 'top', 'labelfraction', 0.25, ...
      'position', [10 450 540 210], 'label', 'Comments saved on each trial (empty by default to avoid memory hogging)');
    set(get_ghandle(comments_on_each_trial), 'HorizontalAlignment', 'Left', 'FontSize', 14);
    set(get_lhandle(comments_on_each_trial), 'FontSize', 16);
    
    TextBoxParam(obj, 'overall_comments', '', 10, 10, 'labelpos', 'top', 'labelfraction', 0.25, ...
      'position', [10 340 540 100], 'label', 'Overall Comments');
    set(get_ghandle(overall_comments), 'HorizontalAlignment', 'Left', 'FontSize', 14);
    set(get_lhandle(overall_comments), 'FontSize', 16);
    
    PushbuttonParam(obj, 'clean_lines', 350, 415, 'position', [350 415 100 20], ...
      'label', 'Clean Lines', 'TooltipString', sprintf(['\nMake sure no lines are greater than 80 chars' ...
      '\nlong (so they all fit in window). Breaks any longer lines into two.']));
    set_callback(clean_lines, {mfilename, 'clean_lines'});
    
    % ---
    
    figure(value(my_xyfig(3)));

    
  % ------------------------------------------------------------------
  %              CLEAN_LINES
  % ------------------------------------------------------------------    

  case 'clean_lines',
    MAXLEN = 80;
    
    comms = value(comments); %#ok<NODEF>
    nlines = size(comms,1);
    newcomms = cell(nlines,1);
    for i=1:nlines, newcomms{i} = deblank(comms(i,:)); end;
    k = 1; 
    while k<= size(newcomms,1),
      if length(newcomms{k}) > MAXLEN,
        newestline = newcomms{k}(MAXLEN+1:end);
        newcomms{k} = newcomms{k}(1:MAXLEN);
        newcomms = [newcomms(1:k) ; {newestline} ; newcomms(k+1:end)];
      end;
      k = k+1;
    end;

    width = 0;
    for i=1:size(newcomms,1), width = max(length(newcomms{i}), width); end;
    comms = ' '*ones(size(newcomms,1),width);
    for i=1:size(newcomms,1),
      comms(i,1:length(newcomms{i})) = newcomms{i};
    end;
    comments.value = char(comms);
    
  % ------------------------------------------------------------------
  %              CLEAR_HISTORY
  % ------------------------------------------------------------------    

  case 'clear_history',
    clear_history(comments); %#ok<NODEF>
    clear_history(overall_comments); %#ok<NODEF>
    

  % ------------------------------------------------------------------
  %              GET
  % ------------------------------------------------------------------    

  case 'get',
    x = value(comments);     %#ok<NODEF>
    
  % ------------------------------------------------------------------
  %              GET_LATEST
  % ------------------------------------------------------------------    
    
    
  case 'get_latest',
    x = value(comments);
	r=strmatch('***', x);
    if isempty(r), r=0; end
    x=x(max(r)+1:end,:);
     
    
  % ------------------------------------------------------------------
  %              SET
  % ------------------------------------------------------------------    

  case 'set',
    if nargin < 3,
      warning('CommentsSection:Invalid', '''set'' action needs third parameter');
      return;
    end;
    comments.value = varargin{1};    

    
  % ------------------------------------------------------------------
  %              APPEND_LINE
  % ------------------------------------------------------------------    

  case 'append_line',
    if nargin < 3,
      warning('CommentsSection:Invalid', '''append_line'' action needs third parameter');
      return;
    end;
    newline = varargin{1}; if size(newline,1) > size(newline,2), newline = newline'; end;

    newlen = length(newline);
    oldsize = size(value(comments));  %#ok<NODEF>
    
    if newlen > oldsize(2),
      tmp_com = [comments(:,:) ' '*ones(oldsize(1), newlen - oldsize(2))];
      comments.value='';
      comments.value=tmp_com;
    elseif newlen < oldsize(2),
      newline = [newline ' '*ones(1, oldsize(2) - newlen)];
    end;
    tmp_com = [comments(:,:) ; newline];     %#ok<NODEF>
    comments.value='';
    comments.value=tmp_com;
    
    

  % ------------------------------------------------------------------
  %              APPEND_DATE
  % ------------------------------------------------------------------    

  case 'append_date',
    feval(mfilename, obj, 'append_line', ['*** ' date ' ***']);
    
    
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    


  case 'hide',
    CommentsShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    CommentsShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if CommentsShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myfig), 'Visible', 'off');
    end;
    
    
  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
  case 'reinit'
    x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3); 
    currfig = double(gcf);
    
    feval(mfilename, obj, 'close');
    
    figure(origfig);
    feval(mfilename, obj, 'init', x, y);
    figure(currfig);

    
  otherwise
    warning('CommentsSection:Invalid', 'Don''t know action %s\n', action);
end;

