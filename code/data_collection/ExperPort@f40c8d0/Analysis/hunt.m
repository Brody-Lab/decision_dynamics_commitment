% [r, G] = hunt(fname, sphname, varargin)
%
% Look inside Solo datafile fname for SoloParamHandles whose name
% matches sphname; return its value.
%
% RETURNS:
% --------
%
% r       The value of the variable hunted for.
%
% G       The result of doing load() on the requested filename.
%

function [r, G] = hunt(fname, sphname, varargin)

   history = 0;
   pairs = { ...
     'history'           0   ; ...
     'autoset_string'    0   ; ...
     'evaluateable'     ''   ; ...
   }; parseargs(varargin, pairs);
   
   
   
   if ischar(fname),       G = load(fname);
   elseif isstruct(fname)  G = fname;
   else
      error('Don''t understand this fname');
   end;

   if ~iscell(sphname), sphname = {sphname}; end;

   r = cell(size(sphname));
   for i=1:rows(sphname),
      for j=1:cols(sphname),
         switch sphname{i,j},
          case 'hit_history',
            a = recover(G.saved, 'hit_history');
            b = recover(G.saved, 'n_done_trials');
            r{i,j} = num2cell(a(1:b)');

           case 'gotit_history',
            a = recover(G.saved, 'gotit_history');
            b = recover(G.saved, 'n_done_trials');
            r{i,j} = num2cell(a(1:b)');

          case 'prevtrial',
            lte = recover_history(G.saved_history, 'LastTrialEvents');
            rts = recover_history(G.saved_history, 'RealTimeStates');
            rts = rts(1:length(lte));
            r{i,j} = parse_trial(lte, rts);            

          otherwise,
            if history,
               r{i,j} = recover_history(G.saved_history, sphname{i,j});      
            elseif autoset_string   
               r{i,j} = recover(G.saved_autoset, sphname{i,j});
            else
               r{i,j} = recover(G.saved, sphname{i,j});
            end;
         end;
      end;
   end;

   if ~isempty(evaluateable), 
     if history==1,    
       r = r(:);
       ntrials = minlength(r);
       answers = cell(ntrials, 1);
       for i=1:ntrials,
         this_r = cell(size(r));
         for j=1:length(r),
           this_r{j} = r{j}{i};
         end;
         answers{i} = evaluate_answer(sphname, this_r, evaluateable);
       end;       
       r = {answers};

     else
       r = {evaluate_answer(sphname, r, evaluateable)};
     end;     
   end;
   
   return;

%% evaluate_answer
 
function [answer] = evaluate_answer(sphname, r, evaluateable) %#ok<STOUT>
   sphname = sphname(:); r = r(:);  %#ok<NASGU>
   
   for private_i=1:length(sphname),
     eval([sphname{private_i} ' = r{private_i};']);
   end;
   
   try   eval([evaluateable ' ;']);
   catch
     lerr = lasterror;
     error('hunt:Invalid', 'Couldn''t evaluate "%s".\nError was "%s"', evaluateable, lerr.message);
   end;
   
   if ~exist('answer', 'var'),
     error('hunt:Invalid', 'The result of an evaluatable string must be in the variable "answer".');
   end;
   
   return;


%% minlength

function [m] = minlength(r)

   m = Inf; for i=1:length(r), m = min([m, length(r{i})]); end;
   return;
   
   
% --------   


function [r] = recover(saved, name)
   
   fnames = fieldnames(saved);
   keeps = [];
   for i=1:length(fnames),
     if ~isempty(regexp(fnames{i}, name, 'ONCE')), keeps = [keeps; i]; end;
   end;
   
   if length(keeps)~=1, r = NaN;
   else                 r = saved.(fnames{keeps});
   end;
   

   
% --------   
   
function [hist] = recover_history(hstruct, name)
   
   fnames = fieldnames(hstruct);
   keeps = [];
   for i=1:length(fnames),
     if ~isempty(regexp(fnames{i}, name, 'ONCE')), keeps = [keeps; i]; end;
   end;
   
   
   if length(keeps)>1,
      fprintf(1, 'More than one SoloParamHandle found for name %s:\n', name);
      for i=1:length(keeps), fprintf(1, '   %s\n', fnames{keeps(i)}); end;      
      warning(['More than one SoloParamHandle found for name ' name ', returning NaN']);
      hist = NaN;
      return;
      
   elseif isempty(keeps),
      warning(['No SoloParamHandle found for name ' name]);
      hist = NaN;
      return;
   end;
   
   hist = hstruct.(fnames{keeps});
      