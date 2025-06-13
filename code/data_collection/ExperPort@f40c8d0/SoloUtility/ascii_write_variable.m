% [] = ascii_write_variable(fp, var)
%
% Given a variable, writes it out in ascii-readable form to the
% filestream fp (see fopen.m for help on filestreams). An optional
% third argument is the name of the variable.
%
% var can be a numeric variable, or can be a structure or a cell. This
% function recursively goes down elements of the variable.
%
% KNOWN LIMITATION: When var or elements of var are multidimensional,
% this function assumes there are no more than two dimensions.
%

function [] = ascii_write_variable(fp, var, varname)
   
   switch class(var),
   
    case {'double' 'single'},
      fprintf(fp, '[');
      for i=1:rows(var),
         fprintf(fp, '%g, ', var(i,1:end-1));
         fprintf(fp, '%g', var(i, end));
         if i<rows(var), fprintf(fp, ';\n'); end;
      end;
      fprintf(fp, ']');

    case 'char',      
      fprintf(fp, '''');
      for i=1:rows(var),
         fprintf(fp, '%c', var(i,1:end));
         if i<rows(var), fprintf(fp, '\n'); end;
      end;
      fprintf(fp, '''');

      
    case 'cell',
      fprintf(fp, '{');
      for i=1:rows(var),
         for j=1:cols(var),
            ascii_write_variable(fp, var{i,j});
            if j<cols(var), fprintf(fp, ', ');
            elseif i<rows(var), fprintf(fp, ';\n');
            end;
         end;
      end;
      fprintf(fp, '}');

    case 'struct',
      fnames = fieldnames(var);
      for i=1:rows(fnames),
         fprintf(fp, '%s = ', fnames{i});
         ascii_write_variable(fp, var.(fnames{i}));
         fprintf(fp, '\n\n');
      end;
      
   end;
   return;
   
      
