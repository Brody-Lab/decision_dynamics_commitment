%recall.m  [r,nums,seps]=recall(ratname, experimenter, varname, {'protocol', 'quadsamp'},
%                         {'daterange' []'}, {'settings', 0}, {'autoset', 0}, 
%                         {'history', 0}, {'plotit', 0}, {'running_avg', 0})
%
% Looks through data files in default data directories to hunt for values
% of a particular variable, with name varname. Can get one data point per
% day, or if you ask for history, one data point per trial; can plot the
% results if you wish; and will smooth the results with an exponential
% filter if you wish.
%
% See example calls at bottom of these help comments.
%
% Special case varnames are 'hit_history' and 'gotit_history', which always
% get trial-by-trial history of hits, regardless of whether the optional
% param 'history' is 0 or 1.
%
%
% PARAMETERS:
% -----------
%
% ratname     String indicating rat's ID.
%
% varname     String indicating the name of the variable to hunt
%             for. SPH fullnames (i.e., var's function owner name,
%             followed by underscore, followed by var name) are matched
%             to this string; matching guys are considered to be the
%             hunted-for variable.
%
%             varname may be a cell column of strings, in which case
%             each of these vars is retrieved separately.
%          
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% protocol    Name of the protocol to hunt for. Default is
%             'quadsamp'. This should match the protocol part of the
%             filenames you want.
%
% daterange   A numeric vector determining which days to
%             consider. Two formats are allowed. Any number bigger than
%             1000 is interpreted as a yearmonthday datenumber. For
%             example, 50416 means "2005, April, 16." Any number n with
%             magnitude less than 1000 is interpreted as "n days from
%             today." For example, -3 means "three days ago."
%
%             If daterange is left empty, it means "just today."
%
%             If daterange is a single number, this is interpreted as
%             "from the indicated date to today". For example, 50416
%             would mean "from 2005, April 16 to today." Or -3 would
%             mean "from 3 days ago to today." The single number 0
%             means "just today."
%
%             If daterange is a two-element vector, it means "from the
%             date indicated by first element to the date indicated by
%             second element." For example, [-5 -2] means "from 5 days
%             ago to 2 days ago, inclusive."
%      
%
% settings    Default 0. If 1, look in Settings files, not Data files.
%
% autoset     Default 0. If 1, look for autoset strings, not var values.
%
% history     Default 0. Under the default value, one data point per
%             file is retrieved. If 'history' is 1, the one data point
%             per trial is retrieved. Special case varnames are
%             'hit_history' and 'gotit_history', which always get the
%             trial-by-trial history of hits, regardless of the value of
%             'history'.
%
%             If varname is a cell column of strings, then history may
%             be a scalar, or it may be a cell column of numbers the
%             same size as varname, each entry corresponding to one varname.
%
%
% plotit      Default 0. If 1, the current axes are used to plot the
%             results. If history is asked for, then different days are
%             divided by vertical lines.
%
%             If varname is a single string, plotit 1 results in a plot
%             on the current axes. If varname is a cell column of
%             strings, then vertical subplots are formed and used to
%             plot each of the varnames.
%
%
% running_avg Default 0. If non-zero, then the results are smoothed
%             with an exponential filter, with length constant
%             running_avg data points.
% 
%             If varname is a cell column of strings, then running_avg may
%             be a scalar, or it may be a cell column of numbers the
%             same size as varname, each entry corresponding to one varname.
%
% RETURNS:
% --------
%
% r           A cell, the first column of which contains the
%             SPH value; the second column of which
%             contains the datafile corresponding to each
%             performance datapoint; and the third column of which
%             contains the number of days elapsed since the first
%             datafile read.   
%                Thus, to plot a numeric sph value as a function of day, you
%             could call  
%                   plot(cell2mat(r(:,3)), cell2mat(r(:,1)), '.-');
%
% Example calls:
%
% To look at the value of RelevantSoundDur over the last 5 days, one
% data point per day, as used with rat 'blacky':
%
%  >> recall('blacky', 'RelevantSoundDur', 'daterange', -5, 'plotit', 1)
%
% To look at the trial-by-trial history of RelevantSoundDur, not just
% the last value of the day:
%
%  >> recall('blacky', 'RelevantSoundDur', 'daterange', -5, 'history', ...
%              'plotit', 1)
%
% To plot a running average of Honduras' performance in quadsamp over
% the last 15 days: 
% 
%  >> recall('Honduras', 'hit_history', 'daterange', -15, ...
%               'running_avg', 15, 'plotit', 1);
%
%
% To simultaneously hunt for, and plot many variables from Honduras:
%
%  >> recall('Honduras', {'hit_history'; 'Right1_F1' ; 'F1_Duration'}, ...
%       'daterange', -4, 'running_avg', {30;0;0}, 'plotit', 1, 'history', 1); 
%


function [r,nums,seps] = recall(ratname, experimenter, varname, varargin)

   protocol = [];
   pairs = { ...
     'evaluateable' ''            ; ...
     'protocol'     {'quadsamp' 'quadsamp3'}    ; ...     
     'daterange'    []            ; ...
     'settings'      0            ; ...
     'autoset'       0            ; ...
     'history'       0            ; ...
     'plotit'        0            ; ...
     'doplot'        0            ; ...
     'running_avg'   0            ; ...
     'default_dir'  '../SoloData' ; ...
     'print_progress'  1          ; ...
   }; parseargs(varargin, pairs);
   plotit = plotit | doplot;  %#ok<NASGU,NODEF> % Backwards compatibility.

   if ~isempty(evaluateable) && ~iscell(evaluateable), evaluateable = {evaluateable}; end; %#ok<NODEF,AGROW>
   if ~iscell(varname),                                varname      = {varname};      end;

   if ~isempty(evaluateable),   
     if ~iscell(history),     history = num2cell(history*ones(length(evaluateable),1));         end; %#ok<NODEF,NASGU>
     if ~iscell(running_avg), running_avg = num2cell(running_avg*ones(length(evaluateable),1)); end; %#ok<NASGU,NODEF>
     if length(varname)>1, warning('recall:Invalid', 'since evaluateable is non-empty, using only the first varname, ignoring rest'); end;
     varname = varname(1);
     for i=2:length(evaluateable), varname = [varname varname{1}]; end; %#ok<AGROW>
   else
     if ~iscell(history),     history = num2cell(history*ones(length(varname),1));         end; %#ok<NASGU,NODEF>
     if ~iscell(running_avg), running_avg = num2cell(running_avg*ones(length(varname),1)); end; %#ok<NODEF,NASGU>
   end;
  
   
   u = get_file_list(settings, default_dir, ratname, experimenter, protocol);
   
   % -------
   
   if isempty(daterange), 
      daterange = [0 0]; 
   end;
   if length(daterange)==1,
      daterange = sort([daterange 0]);
   end;

   dd = find(daterange<1000);
   for i=1:length(dd),
      daterange(dd(i)) = str2num(yearmonthday(now+daterange(dd(i))));
   end;

   startdate=daterange(1); enddate=daterange(2);    

   keep = zeros(size(u));
   for i=1:length(u),
      filedate = str2num(u(i).name(end-10:end-5));
      if ~isempty(filedate) && startdate <= filedate && filedate <= enddate, keep(i) = 1; end;
   end;
   u = u(find(keep));
   
   if isempty(evaluateable),  r = cell(length(u), 3, length(varname));
   else                       r = cell(length(u), 3, length(evaluateable));
   end;
   
   for i=1:length(u),
      ydm = u(i).name(end-10:end-5);
      daynum = datenum(2000+str2num(ydm(1:2)), str2num(ydm(3:4)), ...
                       str2num(ydm(5:6)));
      if i==1, firstday = daynum; end;
      
      if isempty(evaluateable), % evaluateable is empty ---------  Do it var by var
        for v = 1:length(varname),
          if ~settings,
            if v==1,
              if ~isempty(experimenter),
                fname = sprintf('%s/Data/%s/%s/%s',default_dir, experimenter, ratname, u(i).name);
              else
                fname = sprintf('%s/Data/%s/%s',default_dir, ratname, u(i).name);
              end;
              [r{i,1,v}, G] = hunt(fname, varname{v}, ...
                'autoset_string', autoset, ...
                'history', history{v}, 'evaluateable', evaluateable);
            else
              r{i,1,v} = hunt(G, varname{v}, ...
                'autoset_string', autoset, ...
                'history', history{v}, 'evaluateable', evaluateable);
            end;
          else
            if v==1,
              if ~isempty(experimenter),
                fname = sprintf('%s/Settings/%s/%s/%s',default_dir, experimenter, ratname,u(i).name);
              else
                fname = sprintf('%s/Settings/%s/%s',default_dir, ratname,u(i).name);
              end;
              [r{i,1,v}, G] = hunt(fname, varname{v}, ...
                'autoset_string', autoset, 'evaluateable', evaluateable);
            else
              r{i,1,v} = hunt(G, varname{v}, ...
                'autoset_string', autoset, 'evaluateable', evaluateable);
            end;
          end;
          
          r{i,2,v} = u(i).name(end-10:end-4);
          r{i,3,v} = daynum - firstday + 1;
        end;
        
      else  % evaluateable is not empty ---------
        for v = 1:length(evaluateable),
          if ~settings,
            if v==1,
              if ~isempty(experimenter),
                fname = sprintf('%s/Data/%s/%s/%s',default_dir, experimenter, ratname, u(i).name);
              else
                fname = sprintf('%s/Data/%s/%s',default_dir, ratname, u(i).name);
              end;
              [r{i,1,v}, G] = hunt(fname, varname{v}, ...
                'autoset_string', autoset, ...
                'history', history{v}, 'evaluateable', evaluateable{v});
            else
              r{i,1,v} = hunt(G, varname{v}, ...
                'autoset_string', autoset, ...
                'history', history{v}, 'evaluateable', evaluateable{v});
            end;
          else
            if v==1,
              if ~isempty(experimenter),
                fname = sprintf('%s/Settings/%s/%s/%s',default_dir, experimenter, ratname,u(i).name);
              else
                fname = sprintf('%s/Settings/%s/%s',default_dir, ratname,u(i).name);
              end;
              [r{i,1,v}, G] = hunt(fname, varname{v}, ...
                'autoset_string', autoset, 'evaluateable', evaluateable);
            else
              r{i,1,v} = hunt(G, varname{v}, ...
                'autoset_string', autoset, 'evaluateable', evaluateable);
            end;
          end;
          
          r{i,2,v} = u(i).name(end-10:end-4);
          r{i,3,v} = daynum - firstday + 1;
        end;
      end;
      
      
      if print_progress,
        fprintf(1, '   hunted through %s\n', u(i).name);
      end;
   end;
   
   
   if plotit,
      nums = {};
      for v = 1:length(varname),
         if length(varname)>1, subplot(length(varname), 1, v); end;

         rr = r(:,:,v);
         num = []; seps = []; for i=1:rows(rr),
            if history{v} || strcmp(varname{v}, 'hit_history') || strcmp(varname{v}, 'gotit_history'), 
               num = [num ; rowvec(cell2mat(rr{i,1}{1}(2:end)))'];
               seps = [seps ; rows(num)-0.5]; 
            else
               num = [num ; rr{i,1}];
            end;
         end;

         if running_avg{v},
            t = (1:length(num))';
            a = zeros(size(t));
   
            for i=1:length(num),
               x = 1:i; non_nans = find(~isnan(num(1:i)));

               kernel = exp(-(i-t(1:i))/running_avg{v});
               kernel = kernel(non_nans) / sum(kernel(non_nans));               

               a(i) = sum(num(x(non_nans)).*kernel);
            end;
            num = a;
         end;

         if iscell(num), num = cell2mat(num); end;
         plot(num, '.-'); nums = [nums ; {num}];
         if history{v} || strcmp(varname{v}, 'hit_history') || strcmp(varname{v}, 'gotit_history'), 
            set(vlines(seps), 'Color', 'k'); 
            xlabel('Trial '); 
         else
            xlabel('Day');
         end;
         ylabel(varname{v}, 'Interpreter', 'none'); 
         if ~running_avg{v},
            title(ratname);
         else
            title(sprintf('%s  tau=%g', ratname, running_avg{v}));
         end;
         set(gca, 'YAxisLocation', 'right')
      end;
   end;
   

   sz = size(r);
   if length(sz)==3,
      for v=1:sz(end), 
         for i=1:sz(1), r{i,1,v} = r{i,1,v}{1}; end;
      end;
   else
      for i=1:sz(1), r{i,1} = r{i,1}{1}; end;
   end;
   
   
   
   
% --------------------

function [uu] = get_file_list(settings, default_dir, ratname, experimenter, protocol)

   if ~iscell(protocol), protocol = {protocol}; end;

   uu =[];

   for i=1:length(protocol),
     if ~settings,
       if ~isempty(experimenter),
         u = dir(sprintf('%s/Data/%s/%s/data_@%s_%s_%s_*', ...
           default_dir, experimenter, ratname, protocol{i}, experimenter, ratname));
       else
         u = dir(sprintf('%s/Data/%s/data_@%s_%s_*', default_dir, ratname, protocol{i}, ratname));
       end;

       if isempty(u),
         if ~isempty(experimenter),
           u2 = dir(sprintf('%s/Data/%s/%s/data_%s_%s_%s_*', ...
             default_dir, experimenter, ratname, protocol{i}, experimenter, ratname));
         else
           u2 = dir(sprintf('%s/Data/%s/data_%s_%s_*', default_dir, ratname, protocol{i}, ratname));
         end;
         if ~isempty(u2), u = u2; end;
       end;

     else
       if ~isempty(experimenter),
         u = dir(sprintf('%s/Settings/%s/%s/settings_@%s_%s_%s_*', ...
           default_dir, experimenter, ratname, protocol{i}, experimenter, ratname));
       else
         u = dir(sprintf('%s/Settings/%s/settings_@%s_%s_*', default_dir, ratname, protocol{i}, ratname));
       end;
       if isempty(u),
         if ~isempty(experimenter),
           u2 = dir(sprintf('%s/Settings/%s/%s/settings_%s_%s_%s_*', ...
             default_dir, experimenter, ratname, protocol{i}, experimenter, ratname));
         else
           u2 = dir(sprintf('%s/Settings/%s/settings_%s_%s_*', default_dir, ratname, protocol{i}, ratname));
         end;
         if ~isempty(u2), u = u2; end;
       end;
     end;

     if isempty(uu), uu = u; else uu = [uu ; u]; end;
   end;

   if isempty(uu), return; end;
   
   dates = {};
   for i=1:length(uu),
      filedate = uu(i).name(end-10:end-4);
      dates = [dates ; {filedate}];
   end;
   
   [trash, I] = sort(dates);
   uu = uu(I);