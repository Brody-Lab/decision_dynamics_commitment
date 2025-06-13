%selectize.m   [t] = selectize(pstruct, selectstr, [tstruct])
%
% Selects trials in pstruct (the output of parse_trial.m) based on
% evaluating a Matlab string. An optional third argument, tstruct can
% contain extra information about each trial.
%
% For each trial in pstruct, all of the fieldnames in pstruct are
% instantiated as variables (e.g., pstruct.wait_for_apoke gets
% instantiates as variable "wait_for_apoke") and their length gets
% instantiated as the same variable with an "n_" in front of it
% (variable "n_wait_for_apoke" will hold the value of
% "length(pstruct.wait_for_apoke)"). In that context, selectstr is
% evaluated. 
% 
% If the result of the evaluation is true, t will be 1. If there is an
% error in the evaluation, t will be 0. If there is no error in the
% evaluation, but selectstr does not evaluate to a scalar, selectize.m
% will check to see whether a variable called "this_trial" was
% instantiated. If it was, then t will have the value of "this_trial,"
% otherwise t will be 0.
%
% If pstruct is a cell (each element one trial), then t will be a
% matrix of the same size as pstruct; each element of t will then have
% the value of applying selectize.m to that element of the pstruct
% cell.
%
% If tstruct is passed, it is treated the same as pstruct (each of its
% fieldnames is evaluated into a variable for each trial; if pstruct is
% a cell of trials, tstruct must be also), except that no "n_"
% variables are instantiated.
%


function [private_t] = selectize(private_pstruct, private_selectstr, ...
                                 private_tstruct)

   if nargin < 3, private_tstruct = []; end;
   
   if iscell(private_pstruct),
      if ~isempty(private_tstruct)  &&  ...
           (~iscell(private_truct) || ...
            ~all(size(private_pstruct)==size(private_tstruct))),
         error(['if pstruct is a cell, tstruct must be either empty or ' ...
                'a cell of the same size']);
      end;
      if isempty(private_tstruct) 
         private_tstruct = cell(size(private_pstruct));
      end;
      
      private_t = zeros(size(private_pstruct));
      for i=1:rows(private_pstruct), for j=1:cols(private_pstruct),
            private_t(i,j) = ...
                selectize(private_pstruct{i,j}, private_selectstr, ...
                          private_tstruct{i,j});
      end; end;
      return;
   end;

   
   if isempty(private_selectstr), private_t = 1; return; end;
   % Make sure the selection string is a single row vector:
   private_selectstr = ...
       reshape(private_selectstr', 1, prod(size(private_selectstr)));

   % First evaluate anything in pstruct:
   private_fnames = fieldnames(private_pstruct);   
   for private_i=1:rows(private_fnames),
      multi_assign(private_fnames{private_i}, ...
                   private_pstruct.(private_fnames{private_i}));
   end;

   % Now evaluate anything in tstruct:
   if ~isempty(private_tstruct),
      private_fnames = fieldnames(private_tstruct);
      for private_i=1:rows(private_fnames),
         single_assign(private_fnames{private_i}, ...
                       private_tstruct.(private_fnames{private_i}));
      end;
   end;
      
   try,
      private_t = eval(private_selectstr);
      return;
      
   catch,
      [lerrstr, lerrid] = lasterr;
      if strcmp(lerrid, 'MATLAB:m_invalid_lhs_of_assignment'),
         try,
            eval([private_selectstr ';']);
         catch,
            fprintf(1, ['\nWARNING --  This string could not be evaluated:' ...
                        '\n"%s"\n    error was "%s"\n'], ...
                        private_selectstr, lasterr);
            private_t = 0; return;
         end;
      else
         fprintf(1, ['\nWARNING --  This string could not be evaluated:' ...
                     '\n"%s"\n    error was "%s"\n'], ...
                     private_selectstr, lasterr);
         private_t = 0; return;         
      end;

      if exist('this_trial', 'var'),
         private_t = this_trial;
      else
         private_t = 0;
      end;
      return;
   end;
   
   
   
% ----------

function [] = multi_assign(name, val)
   
   assignin('caller', name, val);
   r = size(val,1);
   nname = sprintf('n_%s', name);
   assignin('caller', nname, r);
   
   
   
% ----------

function [] = single_assign(name, val)
   
   assignin('caller', name, val);

   