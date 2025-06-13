function [sm] = load_from_file(sm, fname)
   
   delete_current_sphandles(sm);
   [stagesep, trainsep, completesep, namesep, varssep, eodsep] = ...
       session_model_stringdefs(sm);
   
   fp = fopen(fname, 'r');
   if fp==-1,
      fprintf('\n\nWarning!! @%s/%s.m couldn''t open "%s" for reading.\n\n',...
              class(sm), mfilename, fname);
      return;
   end;
   
   stage_being_read  = 0;
   train_string      = ''; 
   name_string       = ''; 
   complete_string   = ''; 
   vars_string       = '';
   eod_string        = '';
   string_being_read = 'none';

   sline = fgetl(fp);
   while ~(length(sline)==1 && sline == -1),
      if strcmp(sline, stagesep), 
         if stage_being_read > 0, % if appropriate, store parsed strings
            sm.training_stages{stage_being_read, sm.train_string_COL} = ...
                train_string;
            sm.training_stages{stage_being_read, sm.completion_test_COL}=...
                remove_stage_separator_trailer(complete_string);
            sm.training_stages{stage_being_read, sm.name_COL}=...
                name_string;
            sm.training_stages{stage_being_read, sm.vars_COL}=...
                vars_string;
            sm.training_stages{stage_being_read, sm.EOD_logic_COL}=...
                eod_string;
         end;
         string_being_read = 'none';
         stage_being_read=stage_being_read+1; 
         % Ignore next two lines after the stage separator, they are
         % comments
         fgetl(fp); fgetl(fp);
      elseif strcmp(sline, trainsep),    
         string_being_read = 'train';   
         train_string      = '';
      elseif strcmp(sline, completesep), 
         string_being_read = 'complete';
         complete_string   = '';
      elseif strcmp(sline, namesep),     
         string_being_read = 'name';    
         name_string       = '';
      elseif strcmp(sline, varssep),     
         string_being_read = 'vars';    
         vars_string       = {};
          elseif strcmp(sline, eodsep),     
         string_being_read = 'eod';    
         eod_string       = '';
     
      else
        switch string_being_read,
          case 'none',
          case 'train',
            train_string    = append_with_spaces(train_string,    sline);
          case 'complete',
            complete_string = append_with_spaces(complete_string, sline);
          case 'name',
            if isempty(name_string),
              name_string  = append_with_spaces(name_string,     sline);
            end;
          case 'vars',
            vars_string     = [vars_string ; {sline}]; %#ok<AGROW>
          case 'eod',
            eod_string    = append_with_spaces(eod_string,    sline);
          otherwise
        end;
      end;
      sline = fgetl(fp); %#ok<NASGU>
   end;

   fclose(fp);
   
   if stage_being_read > 0, % if appropriate, store parsed strings
      sm.training_stages{stage_being_read, sm.train_string_COL} = ...
          train_string;
      sm.training_stages{stage_being_read, sm.completion_test_COL}=...
          remove_stage_separator_trailer(complete_string);
      sm.training_stages{stage_being_read, sm.name_COL}=...
          name_string;
      sm.training_stages{stage_being_read, sm.vars_COL}=...
          vars_string;
      sm.training_stages{stage_being_read, sm.EOD_logic_COL}=...
          eod_string;
   end;
   
   sm.training_stages = sm.training_stages(1:stage_being_read,:);
   
   if rows(sm.training_stages)>=1,
      for i=1:rows(sm.training_stages),
         sm.training_stages{i,sm.is_complete_COL} = 0;
      end;
      current_stage = sm.current_train_stage;
      sm = jump(sm, 'to', 1);
      if current_stage == 1,  % Jump had no effect on helper vars, must create 'em:
        create_current_sphandles(sm, 1, get_helper_vars(sm, 1));
      end;
   end;

   
% ----------

function [str] = append_with_spaces(str, sline)

   if isempty(sline), sline = ' '; end;
   
   if cols(str) < cols(sline),
      str   = [str    ' '*ones(rows(str), cols(sline)-cols(str))]; 
   elseif cols(str) > cols(sline),
      sline = [sline  ' '*ones(1, cols(str)-cols(sline))]; 
   end;
   
   str = [str ; sline];
   
   
% ------------

function [str] = remove_stage_separator_trailer(str)
% Checks to see whether the last lines of str are identical to the first
% two big comment lines that introduce a stage separator. If so, removes
% these two trailing lines.

  line1 = '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
  line2 = '%';

  if size(str,1)>2 && size(str,2) >= max(length(line1), length(line2)),
    if strcmp(str(end-1,1:length(line1)), line1) && strcmp(str(end,1:length(line2)), line2),
      str = str(1:end-2,:);
    end;
  end;