%tab2pad.m         tab2pad(fname, [offline_flag=0])
%
% If you are looking at this file in your web browser, download it 
% by going to the "File --> Save As" menu option.
%
% Takes an itinerary file, produced by sfn.ScholarOne.com/itin and 
% exported in TAB-separated format, and turns it into two .mpa
% archives, suitable for importing into Memopad for Palm OS.
%
% EXAMPLE CALL:     >> tab2pad('sfn.tsv');
%
%
% ARGUMENTS:
%
% -fname     The name of the itinerary TAB_delimited file produced 
%            by ScholarOne.
%
% -offline_flag  OPTIONAL argument, default value is 0. If you
%            used the ONLINE version of ScholarOne, you can forget
%            about this argument, you don't need it. If you used
%            the DOWNLOADED version (Windows only, I am not
%            supporting MAc), read on.
%
%            If the optional argument _off_flag is given, and
%            given as 1, tab2pad assumes that the itinerary was
%            produced by the DOWNLOADED version of ScholarOne, and 
%            furthermore, that you are running tab2pad on the same 
%            machine that this was downloaded to, and that this
%            version is on C:\sfn_ip (which is the standard place
%            for it). If this is true, tab2pad will work
%            correctly. 
%
%            tab2pad may prompt you to download some files
%            from Carlos' web site that fix some bugs in
%            ScholarOne's downloaded version.
%

% Written by Carlos Brody 29-Oct-00. Freely distributable with no
% restricions whatsoever.


function [MME] = tab2pad(fname, offline_flag, extra_chars_flag)

   if nargin < 3, extra_chars_flag = 0; end;
   if nargin < 2, offline_flag = 0; end;
   
   if offline_flag,
      if ~check_offline_tables_existence, return; end;
   end;
   
   ME = tab2entries(fname);
   ME = clean_entries(ME, offline_flag);
   
   if nargout > 0, MME = ME; end;
   
   % First make the abstracts file -------------
   
   Entries = cell(size(ME));
   for i=1:length(ME),
      if extra_chars_flag, Entries{i} = ['@' ME(i).number ' '];
      else Entries{i} = [ME(i).number ' '];
      end;      
      Entries{i} = [Entries{i} ME(i).day ' '  ME(i).time ' ' ...
	     ME(i).ampm ' ' ME(i).type ' ' ...
	     ME(i).location char([10 13])];

      Entries{i} = [Entries{i} ...
	     ME(i).title    char([10 13]) ...
	     ME(i).authors  ' ' ...
	     ME(i).affiliation char([10 13]) ...	     
	     ME(i).abstract char([10 13])];
   end;
   
   mpa_write([nopath(noextension(fname)) '_abs.mpa'], Entries);
   
   fprintf(1, ['\nWrote Memopad importable files:\n' ...
	  '   "%s"    (full abstracts).\n'],...
       [nopath(noextension(fname)) '_abs.mpa']);

   
   % Now make the titles file -------------
   
   Entries = cell(size(ME));
   for i=1:length(ME),
      if extra_chars_flag, Entries{i} = ['=' ME(i).number ' '];
      else Entries{i} = [ME(i).number ' '];
      end;      
      Entries{i} = [Entries{i} ME(i).day ' '  ME(i).time ' ' ...
	     ME(i).ampm ' ' ME(i).type ' ' ...
	     ME(i).location char([10 13])];

      Entries{i} = [Entries{i} ...
	     ME(i).title    char([10 13]) ...
	     ME(i).authors  ' ' ...
	     ME(i).affiliation char([10 13])];
   end;
   
   mpa_write([nopath(noextension(fname)) '_titles.mpa'], Entries);
   
   fprintf(1, ['   "%s" (titles, one per memo).\n'],...
       [nopath(noextension(fname)) '_titles.mpa']);

   
   % Now make the itinerary file -----------------
   
   mpa_write([nopath(noextension(fname)) '_itin.mpa'], ...
       make_title_entries(ME, extra_chars_flag));

   fprintf(1, ['   "%s"   (itinerary).\n\n'],...
       [nopath(noextension(fname)) '_itin.mpa']);


   % Now make the dailies  -----------------

   days  = {'Sat' 'Sun' 'Mon' 'Tue' 'Wed' 'Thu'};
   ampms = {'AM' 'PM'}; 
   for d = 1:length(days), for a = 1:length(ampms),
      day = days{d}; ampm = ampms{a};
      Entries = select_ampm(select_day(ME, day), ampm);
      if ~isempty(Entries),
	 mpa_write([nopath(noextension(fname)) ...
		'_' day '_' ampm '.mpa'], ...
	     make_session_entries(Entries, extra_chars_flag));

	 fprintf(1,['   "%s"    (titles, one memo/session).\n'],...
	     [nopath(noextension(fname)) '_' day '_' ampm '.mpa']);
      end;
   end; end;
   fprintf(1, '\n');
   
 
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%noextension  [r] = noextension(fname)  discard filename extension
%
% Takes a single string argument, and discards anything after (and
% including) the last '.'
%
% Does not take string matrices, but does take cell string vectors.
%


function [r] = noextension(fname)

   if isempty(fname), r = fname; return; end;
   
   if iscell(fname),
      for i=1:length(fname), fname{i} = noextension(fname{i}); end;
      r = fname;
      return;
   end;

   p = max(find(fname == '.'));
   if isempty(p),
      r = fname;
   else	
      r = fname(1:(p-1));
   end;
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


function [MemoEntries] = tab2entries(fname)

fp = fopen(fname, 'r'); s = fscanf(fp, '%c'); fclose(fp);

u = find(s == sprintf('\n'));
if isempty(u), MemoEntries = {}; return; end;

u = [0 u];

MemoEntries = cell(length(u)-1, 1);
for i=1:length(u)-1,
   MemoEntries{i} = s(u(i)+1:u(i+1)-1);
end;	



% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

%clean_entries.m  [ME] = clean_entries(ME, offline_flag)
%
% Goes through the entries in the cell vector of strings ME, as
% obtained from tab2entries.m, and cleans them up a bit
% (e.g. removes Month and day of Month; removes AM and PM; uses
% only first three letters of day; and turns ME into a
% struct. 
%

function [nME] = clean_entries(ME, offline_flag)

   u = find(ME{1} == sprintf('\t'));
   
   if offline_flag | length(u)==6, 
      if ~offline_flag, if ~check_offline_tables_existence; 
            error(' '); 
         end;end;
      if isunix,
	 load /dosc/sfn_ip/abstracts_map.mat;
	 load /dosc/sfn_ip/poster_locations.mat;
      else
	 load C:\sfn_ip\abstracts_map.mat;
	 load C:\sfn_ip\poster_locations.mat;
      end;
 	   offline_flag = 1;
   end;
   
   shortEntriesFlag = 0;
   nME = struct('number', [], 'day', [], 'time', [], ...
       'ampm', [], 'conflict', [], ...
       'starttime', [], 'endtime', [], ...
       'type', [], 'title', [], 'location', [], ...
       'authors', [], 'affiliation', [], 'abstract', []);
   
   nentries = length(ME);
   nME(nentries).number = 1;
   

   if offline_flag, i=2; else i=1; end;
   while i<=nentries,
      
      u = find(ME{i} == sprintf('\t'));

      if isempty(u), % This is just a continued abstract
                     % from the previous entry.
	 nME(i-1).abstract = [nME(i-1).abstract ME{i}];
	 ME = ME([1:i-1  i+1:end]);      
	 nentries = nentries-1;
      
      else % Nope, this is a real entry
	 
	 if offline_flag | length(u)~=7,
	    if length(u)~=6,  old_offline_version; end;
	    
	    onumber            = ME{i}(1 : u(1)-1);
	    daytime            = ME{i}(u(1)+1 : u(2)-1);
	    nME(i).type        = ME{i}(u(2)+1 : u(3)-1);
	    nME(i).title       = ME{i}(u(3)+1 : u(4)-1);
	    nME(i).location    = ME{i}(u(4)+1 : u(5)-1);
	    nME(i).authors     = ME{i}(u(5)+1 : u(6)-1);
	    nME(i).affiliation = ME{i}(u(6)+1 : end);
	    
	    nME(i).number      = padnumber(onumber);
    
	    onum = presstr2presnum(onumber);
	    if strcmp(nME(i).type, 'Poster'), 
	       nME(i).location = poster_locations{onum};
	    end;
	    nME(i).abstract = ...
		htmlabs2abstext([abstracts_map{onum,1} ...
		   filesep abstracts_map{onum,2}]);
	    
	 else  % online version
	    if length(u)==7,
	       nME(i).number      = padnumber(ME{i}(1 : u(1)-1));
	       daytime            = ME{i}(u(1)+1 : u(2)-1);
	       nME(i).type        = ME{i}(u(2)+1 : u(3)-1);
	       nME(i).title       = ME{i}(u(3)+1 : u(4)-1);
	       nME(i).location    = ME{i}(u(4)+1 : u(5)-1);
	       nME(i).authors     = ME{i}(u(5)+1 : u(6)-1);
	       nME(i).affiliation = ME{i}(u(6)+1 : u(7)-1);
	       nME(i).abstract    = ME{i}(u(7)+1 : end);
	    elseif length(u)==5, % Bug in exported file
	       nME(i).number      = padnumber(ME{i}(1 : u(1)-1));
	       daytime            = ME{i}(u(1)+1 : u(2)-1);
	       nME(i).type        = ME{i}(u(2)+1 : u(3)-1);
	       nME(i).location    = ME{i}(u(3)+1 : u(4)-1);
	       nME(i).authors     = ME{i}(u(4)+1 : u(5)-1);
	       nME(i).affiliation = ME{i}(u(5)+1 : end);
	       
	       nME(i).title = ''; nME(i).abstract = '';
	       
	       if ~shortEntriesFlag,
		  print_warning(nME(i).number);
		  shortEntriesFlag = 1;
	       end;
	    end;
	 end;

	 [nME(i).day, nME(i).time, nME(i).ampm] = ...
	     separate_daytime(daytime);
	 
	 [nME(i).starttime, nME(i).endtime] = ...
	     military_time(nME(i).time);
	 
	 nME(i).authors = clean_authors(nME(i).authors);

	 if rem(i,10) == 0,
	    fprintf(1, 'Read entry %d ...\n', i);
	 end;
	 
	 i = i+1;  % Go on to next entry
      end;
   end;
   
   if offline_flag,
      nME = nME(2:nentries);
   else
      nME = nME(1:nentries);
   end;
   
   fprintf(1, 'Finished reading entries.\n');
   return
   
   
% -----------------

function [day, time, ampm] = separate_daytime(daytime)

   if length(daytime)<4, day = daytime; return; end;
   
   day = daytime(1:3);
   
   u = find(daytime == ',');
   if isempty(u), time = daytime(4:end); return; end
   
   time = daytime(u(end)+1:end);
   
   if     ~isempty(findstr(time, 'PM')), ampm= 'PM';
   elseif ~isempty(findstr(time, 'AM')), ampm= 'AM';
   end;
   
   time = time(find(~isspace(time) & ~isletter(time)));

   u = find(time=='-');
   if length(u) == 1  &  u>1  &  u<length(time),
      time = [time(1:u-1) '--' time(u+1:end)];
   end;
   
   return;
   
   
   
% -----------------

function [authors] = clean_authors(authors)

   u = findstr(authors, '<U>');
   keep = setdiff(1:length(authors), [u u+1 u+2]);
   authors = authors(keep);

   u = findstr(authors, '<u>');
   keep = setdiff(1:length(authors), [u u+1 u+2]);
   authors = authors(keep);

   u = findstr(authors, '</U>');
   keep = setdiff(1:length(authors), [u u+1 u+2 u+3]);
   authors = authors(keep);

   u = findstr(authors, '</u>');
   keep = setdiff(1:length(authors), [u u+1 u+2 u+3]);
   authors = authors(keep);

   % ---
   
   ustart = findstr(authors, '<SUP>');
   uend   = findstr(authors, '</SUP>')+5;
   
   if length(ustart)~=length(uend), return; end;
   
   killguys = []; for i=1:length(ustart),
      killguys = [killguys ustart(i):uend(i)];
   end;
      
   keep = setdiff(1:length(authors), killguys);
   authors = authors(keep);
   
   % ----

   ustart = findstr(authors, '<sup>');
   uend   = findstr(authors, '</sup>')+5;
   
   if length(ustart)~=length(uend), return; end;
   
   killguys = []; for i=1:length(ustart),
      killguys = [killguys ustart(i):uend(i)];
   end;
      
   keep = setdiff(1:length(authors), killguys);
   authors = authors(keep);
   
   % ----
   
   if ~isempty(findstr(authors, 'GREENGARD')),
      guga = 10;
   end;
   
   u = find(authors=='.');
   if ~isempty(u),if u(end)==length(authors), u=u(1:end-1);end;end;
   if ~isempty(u), if u(1)==1, u=u(2:end); end; end;
   if ~isempty(u),
      nauth = [authors(1:u(1))];
      for i=2:length(u),
	 nauth = [nauth ' ' authors(u(i-1)+1:u(i))];
      end;
      if isempty(i), i=1; end;
      nauth = [nauth ' ' authors(u(i)+1:end)];
   end;
   authors = nauth;
   
	 
% ------------------

function [starttime, endtime] = military_time(time)
   
   u = find(time == '-');
   
   if length(u) < 1 | u(1) < 2 | u(end) > length(time)-1,
      starttime = 0;
      endtime = 0;
      return;
   end;
   
   starttime = time(1:u(1)-1);
   v = find(starttime == ':');
   starttime = ...
       str2num(starttime(1:v-1))*100 + str2num(starttime(v+1:end));

   endtime = time(u(end)+1:end);
   v = find(endtime == ':');
   endtime = ...
       str2num(endtime(1:v-1))*100 + str2num(endtime(v+1:end));
    
 % ----------
 
 function [num] = padnumber(num)
 
    v = find(num=='.');
    if ~isempty(v),
       numa = num(1:v-1);
       numb = num(v+1:end);
       
       if length(numa)<3, 
	  numa = ['0'*ones(1, 3-length(numa)) numa]; 
       end;	
       if length(numb)<2, 
	  numb = ['0'*ones(1, 2-length(numb)) numb]; 
       end;	 
       
       num = [numa '.' numb];   
    else
       if length(num)<3, 
	  num = ['0'*ones(1, 3-length(num)) num]; 
       end;	    
    end;	
    
    return;
    
       
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

%mpa_write.m   [] = mpa_write(fname, MemoEntryStrings)
%
% Writes out a .mpa (".mpa" is appended to fname if not already
% there) within a single category named "Mpa_stuff". The produced
% file is good for importing into Memopad using the Palm Desktop
% Windows PC software.
%

function [] = mpa_write(fname, MemoEntryStrings)
   
   if length(fname) <= 4, fname = [fname '.mpa']; end;
   if ~strcmp(fname(end-3:end), '.mpa'),
      fname = [fname '.mpa'];
   end;
   
   fp = fopen(fname, 'w');

   fwrite(fp, 1.2971e9 - 11232, 'uint32');
   mpa_write_cstring(fp, fname);
   mpa_write_cstring(fp, '');
   fwrite(fp, 132, 'uint32');
   fwrite(fp, 1,   'uint32');
   mpa_write_catentries(fp);

   fwrite(fp, 64, 'uint32');
   fwrite(fp, 6,  'uint32');
   fwrite(fp, 0,  'uint32');
   fwrite(fp, 1,  'uint32');
   fwrite(fp, 2,  'uint32');
   
   % FieldCount and FieldEntries:
   fwrite(fp, 6,  'uint16');
   fwrite(fp, 1,  'uint16');
   fwrite(fp, 1,  'uint16');
   fwrite(fp, 1,  'uint16');
   fwrite(fp, 5,  'uint16');
   fwrite(fp, 6,  'uint16');
   fwrite(fp, 1,  'uint16');

   % NumEntries
   fwrite(fp, length(MemoEntryStrings)*6, 'uint32');
   mpa_write_memoentries(fp, MemoEntryStrings(end:-1:1));
   fclose(fp);

   return;
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

%mpa_write_memoentries  [] = mpa_write_memoentries(fp,MemoStrings);
%
% Always writes CategoryID as 1; MemoString must be cell vector of 
% strings 
%

function [] = mpa_write_memoentries(fp, MemoStrings);
   % Always writes category 1
   
   for i=1:length(MemoStrings),
      
      fwrite(fp, 1, 'uint32');
      % fwrite(fp, 0, 'uint32');
      fwrite(fp, 2048+i, 'uint32');

      fwrite(fp, 1, 'uint32');
      fwrite(fp, 1, 'uint32');
      
      fwrite(fp, 1, 'uint32');
      % fwrite(fp, 2.1475e9-16353, 'uint32');
      fwrite(fp, 2048+4*i, 'uint32');
      
      fwrite(fp, 5, 'uint32');
      fwrite(fp, 0, 'uint32');
      
      mpa_write_cstring(fp, MemoStrings{i});
      
      fwrite(fp, 6, 'uint32');
      fwrite(fp, 0, 'uint32');

      fwrite(fp, 1, 'uint32');
      fwrite(fp, 1, 'uint32');
      
   end;
   

% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   



function  [] = mpa_write_cstring(fp, cstr);

   if length(cstr) < 255,
      fwrite(fp, length(cstr), 'uint8');
   else
      fwrite(fp, 255, 'uint8');
      fwrite(fp, length(cstr), 'uint16');
   end;
   
   fwrite(fp, cstr, 'uchar');

   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   



%mpa_write_catentries.m    [] = mpa_write_catentries(fp);
%
% Always writes a single category, category with ID 24 and Index
% 1, named "Mpa_stuff"
%


function [] = mpa_write_catentries(fp);
   
   fwrite(fp, 1,  'uint32');
   fwrite(fp, 24, 'uint32');
   fwrite(fp, 0,  'uint32');
   mpa_write_cstring(fp, 'Mpa_stuff');
   mpa_write_cstring(fp, 'Mpa_stuff');
   
   return;

   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%make_title_entries  [TE] = make_title_entries(ME, [ecfg=0])
%
% Takes an entries struct as produced by clean_entries.m and turns 
% it into a cell vector of memopad entries with titles only
%


function [TE] = make_title_entries(ME, ecfg)

   if nargin < 2, ecfg = 0; end;

   TE = {};
   currstr = '';
   
   for i=1:length(ME),
      if ecfg, newbit = '#'; else newbit = ''; end;
      newbit = [newbit ME(i).number ' ' ...
	     ME(i).day ' '  ME(i).time ' ' ...
	     ME(i).ampm ' ' ME(i).type ' ' ME(i).location];

      newbit = [newbit char([10 13]) ...
	     ME(i).title    char([10 13]) ...
	     ME(i).authors  char([10 13 10 13])];
      
      if length(currstr) + length(newbit) > 4000,
	 TE = [TE ; {currstr}];
	 currstr = newbit;
      else
	 currstr = [currstr newbit];
      end;
   end;
   
   TE = [TE ; {currstr}];

   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

function [] = print_warning(num)
   fprintf(2, ['\n   ** WARNING!! ** \n\n' ...
	  '   AT LEAST ONE of the '...
	  'entries in the file from ScholarOne\n   '...
	  'is lacking some info. (Most likely ' ...
	  'lacking title and abstract.)\n' ...
	  '   This info will therefore be ' ...
	  'unavoidably missing ' ...
	  'in the memo \n   entry also. :(\n\n']);
   fprintf(2, '   Offending presentation is: %s\n', num);
   fprintf(2, ['\n   This is a bug in the ' ...
	  'ScholarOne site. I still haven''t\n' ...
	  '   figured out why or when the darn ' ...
	  'thing happens. Let me\n   ' ...
	  'know (carlos@cns.nyu.edu) if you want ' ...
	  'to be notified if\n   a bug fix ' ...
	  'or workaround becomes available.\n\n']);
   fprintf(2, '   ** End of WARNING!! ** \n\n\n');

   % fprintf(2, 'Press any key to continue...\n'); pause;
   % fprintf(2, '\n');
   
   return;
   
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

function  [e] = check_offline_tables_existence()
   
   if isunix,
      SFN_HOME = '/dosc/sfn_ip/';
   else
      SFN_HOME = 'C:\sfn_ip\';
   end;
   
   WEB_HOME = 'http://shadrach.cns.nyu.edu/~carlos/palmsfn/';
   
   if ~exist([SFN_HOME 'poster_locations.mat'], 'file')  |  ...
	  ~exist([SFN_HOME 'abstracts_map.mat'], 'file'),
      
      fprintf(1, '\n');
      fprintf(1, ['You have indicated (or tab2pad guessed) ' ...
            'that you used the downloaded\n' ...
            'version of ScholarOne ' ...
	     'to generate your itinerary.\n']);
      fprintf(1, ['ScholarOne left some bugs in that version.\n'...
	     'Carlos wrote a fix for those bugs, ' ...
	     'but to use the fix you have to\ndownload two ' ...
	     'extra files from his site.\n\n' ...
	     'These are:\n\n' ...
	     '     %s (1.6 Mbytes)\n and\n     %s (3.6 Mbytes)\n\n' ...
        'A faster download alternative is to download the much smaller .zip file,\n\n' ...
        '     %s (153 Kbytes)\n\n' ...
        'When you download the files, save them in ' ...
        'C:\\sfn_ip (unzip into this directory\n' ...
        'if you downloaded "extras.zip"), ' ...
        'then run tab2pad again.\n' ...
	     'Everything should work fine at that point!\n\n' ...
	     '(Note that only the Windows downloaded version ' ...
	     'is supported for this fix.)\n\n'], ... 
	  [WEB_HOME 'poster_locations.mat'], ... 
	  [WEB_HOME 'abstracts_map.mat'], [WEB_HOME 'extras.zip']); 
      
      e = 0; return;
   end;

   e = 1;
   return;
   
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%presstr2presnum.m    [pn] = presstr2presnum(ps)
%
% Takes a presentation number (e.g. 216.3), multiplies the part
% before the dot by 100, adds the part after the dot. So 216.3
% would turn into 21603.
%

function [pn] = presstr2presnum(ps)
   
   dot = find(ps=='.');
   if ~isempty(dot) & dot<length(ps), 
      pn = str2num(ps(1:dot-1))*100;
      pn = pn + str2num(ps(dot+1:end));
   else
      pn = str2num(ps)*100;
   end;

   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

% htmlabs2abstext.m   [astr] = htmlabs2abstext(fname)
%
% Taking the filename of a ScholarOne html abstract file, produces 
% the abstract text associated with it.
%
% If fname can't be found, 
%
%    under Unix:      prepends /dosc/sfn_ip/abstract_files/ to it
%    under non-Unix:  prepends C:\sfn_ip\abstract_files\    to it


function  [astr] = htmlabs2abstext(fname)
   
   if ~exist(fname, 'file')
      if isunix,
	 fname = ['/dosc/sfn_ip/abstract_files/' fname];
      else
	 fname = ['C:\sfn_ip\abstract_files\' fname];
      end
   end;
   

   fp = fopen(fname);
   s = fscanf(fp, '%c');
   fclose(fp);
   
   abs_start = '<TD VALIGN=TOP>';
   abs_end   = '</TD>';
   
   u = findstr(s, abs_start) + length(abs_start);
   if isempty(u), astr = ''; return; end;
   if length(u) > 1, u = u(end); end;

   s = s(u:end);
   u = find(~isspace(s));
   if isempty(u), astr = ''; return; end;
   s = s(u(1):end);

   % O.k., now we're at the first non-space char of the abstract
   
   u = findstr(s, abs_end) - 1;
   if isempty(u), astr = ''; return; end;

   s = s(1:u(end));
   u = find(~isspace(s));
   if isempty(u), astr = ''; return; end;
   s = s(1:u(end));
   
   astr = s;
   return;
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


function [] = old_offline_version()
   
   fprintf(1, '\n');

   error(['You appear to have used a downloaded ScholarOne ' ...
	  'site older than 31-Oct-00 to generate your ' ...
	  'itinerary file. Sorry! Get a newer ' ...
	  'version from ScholarOne, ' ...
	  'the older one has bugs that Carlos hasn''t'...
	  'fixed yet.']);
   
   return;
   
	  
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   

%nopath 	[r] = nopath(fname)	discard path header
%
% Takes a single string argument, and discards anything before
% (and including) the last '\'. Also discards drive if there.
%
% Does not take string matrices, but does take cell vectors of
% strings. 
%
% See also NOEXTENSION, PATHONLY, EXTENSION

function [r] = nopath(fname)

   if isempty(fname), r = fname; return; end;

   if iscell(fname),
      for i=1:length(fname), fname{i} = nopath(fname{i}); end;
      r = fname;
      return;
   end;
          
   if ~isunix,
      p = max(find(fname == '\'  |  fname == ':'));
   else
      p = max(find(fname == '/'));
   end;
   
   if isempty(p),
      r = fname;
   else	
      r = fname((p+1):length(fname));
   end;

   
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%get_presentation_numbers  [pn] = get_presentation_numbers(ME)
%
% Takes an entries struct as produced by clean_entries.m and turns 
% it into a numeric vector that indicates the presentation
% number of each entry. Doing floor(sn) will get session numbers. 
%


function [pn] = get_presentation_numbers(ME)
   
   X = cell(size(ME));
   [X{1:end}] = deal(ME.number);
   
   pn = zeros(size(X));
   for i=1:length(X),
      pn(i) = str2num(X{i});
   end;
   
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%make_session_entries  [SE] = make_session_entries(ME, [ecfg=0])
%
% Takes an entries struct as produced by clean_entries.m and turns 
% it into a cell vector of memopad entries, one session per entry.
%


function [TE] = make_session_entries(MME, ecfg)

   if nargin < 2, ecfg = 0; end;

   TE = {};

   sn  = floor(get_presentation_numbers(MME));
   usn = unique(sn);

   for s=1:length(usn),
      u = find(sn==usn(s));
      ME = MME(u);
      if ~isempty(u),
	 switch ME(1).type, 
	    case 'Poster',          type = 'Pr';
	    case 'Slide',           type = 'Sl';
	    case 'Symposium',       type = 'Sy';
	    case 'Special Lecture', type = 'Sp Lec';
	    otherwise      type = ME(1).type;
	 end;

	 tit = ME(1).title; 
	 [t1, tit] = strtok(tit); [t2, tit] = strtok(tit);
	 title = lower([t1 ' ' t2]);

	 location = ME(1).location;
	 if ~isempty(myfindstr(location, 'Room')),
	    rp = myfindstr(location, 'Room');
	    location = [location(1:rp-1) 'Rm' location(rp+4:end)];
	 end;
	 if ~isempty(myfindstr(location, 'Ballroom')),
	    rp = myfindstr(location, 'Ballroom');
	    location = [location(1:rp-1) 'Bm' location(rp+8:end)];
	 end;
	 
	 currstr = [noextension(ME(1).number) ' ' ...
		ME(1).day(1:2) ' ' ME(1).ampm ' ' ...
		type ' ' location ' ' ...
		title char([10 13]) ...
		'-----------------------------' ...
		char([10 13 10 13])];	       
      else
	 currstr = '';
      end;

      xts = 0;
      for i=1:length(ME),
	 if ecfg, newbit = '$'; else newbit = ''; end;
	 newbit = [newbit ME(i).number ' ' ...
		ME(i).day ' '  ME(i).time ' ' ...
		ME(i).ampm ' ' ME(i).type ' ' ME(i).location];
	 
	 newbit = [newbit char([10 13]) ...
		ME(i).title    char([10 13]) ...
		ME(i).authors  char([10 13 10 13])];
	 
	 if length(currstr) + length(newbit) > 3500,	    
	    TE = [TE ; {currstr}];
	    xts = xts+1;
	    currstr = [noextension(ME(1).number) ' ' ...
		   'x' num2str(xts) ' ' ...
		   '                                ' ...
		   location char([10 13]) ...
		   '-----------------------------' ...
		   char([10 13 10 13])];
	 end;
	 currstr = [currstr newbit];
      end;
      TE = [TE ; {currstr}];
   end;

   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%select_day.m  [SME] = select_day(ME, day)
%
% Takes an entries struct as produced by clean_entries.m and
% returns another struct but with only those entries that match
% "day". 
%
% "day" must be one of {'Sat' 'Sun' 'Mon' 'Tue' 'Wed' 'Thu'}
%

function [SME] = select_day(ME, day)
   
   if ~ismember(day, {'Sat' 'Sun' 'Mon' 'Tue' 'Wed' 'Thu'}),
      error(['the day must be one of ' ...
	     '{''Sat'' ''Sun'' ''Mon'' ''Tue'' ''Wed'' ''Thu''}']);
   end;
   
   days = get_presentation_days(ME);
   
   u = find(strcmp(day, days));
   
   SME = ME(u);
   
   
   
   
% -----------------------------------------------------------   
% 
% -----------------------------------------------------------   


%get_presentation_days  [pn] = get_presentation_days(ME)
%
% Takes an entries struct as produced by clean_entries.m and turns 
% it into a cell vector of strs that indicates the presentation
% day of each entry. 
%


function [pd] = get_presentation_days(ME)
   
   pd = cell(size(ME));
   [pd{1:end}] = deal(ME.day);
   
   