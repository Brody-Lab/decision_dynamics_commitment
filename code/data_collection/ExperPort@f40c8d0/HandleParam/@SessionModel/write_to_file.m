function [] = write_to_file(sm, fname)
   
   [stagesep, trainsep, completesep, namesep, varssep,eodsep] = ...
       session_model_stringdefs(sm);
   
   fp = fopen(fname, 'w');
   if fp==-1,
      fprintf('\n\nWarning!! @%s/%s.m couldn''t open "%s" for writing.\n\n',...
              class(sm), mfilename, fname);
      return;
   end;

   for i = 1:rows(sm.training_stages),
      fprintf(fp, ['\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '\n']);
      fprintf(fp, '%%\n%s\n%%\n', stagesep);
      fprintf(fp, ['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                   '\n']);

      fprintf(fp, '%s\n', namesep);
      print_str_matrix(fp, sm.training_stages{i,sm.name_COL});
      
      fprintf(fp, '%s\n', varssep);
      print_str_matrix(fp, sm.training_stages{i,sm.vars_COL});
      
      fprintf(fp, '%s\n', trainsep);
      print_str_matrix(fp, sm.training_stages{i,sm.train_string_COL});
      
      fprintf(fp, '%s\n', eodsep);
      print_str_matrix(fp, sm.training_stages{i,sm.EOD_logic_COL});

      
      fprintf(fp, '%s\n', completesep);
      print_str_matrix(fp, sm.training_stages{i,sm.completion_test_COL});

   end;
   fclose(fp);
   
   
   
% ----------


function [] = print_str_matrix(fp, strmatrix)
   
   for j=1:rows(strmatrix),
      if iscell(strmatrix) myline = strmatrix{j,:};
      else                 myline = strmatrix(j,:);
      end;
      fprintf(fp, '%s\n', deblank(myline));
   end;
   fprintf(fp, '\n');
