% [concat] = get_string(str, [old_parse_style_flag=1])
%
% Given a char matrix str, concatenates it into a single-row string vector
% concat.
%
% If no second argument is passed, then old_parse_style_flag takes the
% default value 1, in which case he entire string box concatenated into a
% single long string, no special syntax for line breaks or comments. So
% make sure to finish your statements with ";" if they are alone on a line!
%
% If a second argument is passed, and it is non-zero, then parsing is done
% new style: every row is treated as a separate line, and a ";" is added in
% between all lines. In addition, lines that start with "%" are treated as
% comments and ignored (they don't make it into the final output). Finally,
% to continue a Matlab statement across a line break, use "...". The
% ellipsis will be deleted from the final output.

function [concat] = get_string(str, old_style_flag)

if nargin == 1 || old_style_flag==1,
  % The entire string box concatenated into a single long string, no
  % special syntax for line breaks or comments. So make sure to finish your
  % statements with ";" if they are alone on a line!
  t = cellstr(str); %#ok<NASGU>
  concat = 't{1}';
  for ctr = 2:size(t,1)
    temp = t{ctr}; t{ctr} = [' ' temp ' '];
    concat = [concat ', t{' num2str(ctr) '}']; %#ok<AGROW>
  end;

  eval(['dummy = strcat(' concat ');']);
  concat = dummy;
  return;
  
else
  % New style: every line treated as a separate line. ";" added in between
  % lines. Lines that start with "%" treated as comments and ignored. To
  % continue a statement across a line break, use "..."
  concat = '';
  if size(str,2)<1, return; end;
  
  continuing_line_flag = 0;
  for i=1:size(str,1),
    u = find(~isspace(str(i,:)), 1,'first');
    if ~isempty(u) && str(i,u)~='%',  % ignore empty lines or comment lines
      if ~isempty(find(str(i,:)=='%'))
          fprintf(2,'Line %d: Comments in the middle of lines of session control are not supported.\n',i);
      end          
        if i>1 && continuing_line_flag==0, concat = [concat '; ']; end; %#ok<AGROW>
      u = find(~isspace(str(i,:)), 1, 'last');
      if u>=3 && strcmp(str(i,u-2:u), '...'),
        concat = [concat str(i, 1:u-3)]; %#ok<AGROW>
        continuing_line_flag = 1;
      else
        concat = [concat str(i, 1:u)]; %#ok<AGROW>
        continuing_line_flag = 0;
      end;
    end;
       
  end;
end;



