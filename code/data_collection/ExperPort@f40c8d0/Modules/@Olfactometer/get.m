function output = get(obj, varargin)
%GET Get Olfactometer object properties.
%
%    V = GET(OBJ,'Property') returns the value, V, of the specified property
%    for Olfactometer object OBJ.  
%
%    GET(OBJ) displays all property names and their current values for
%    olfactometer object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the name
%    of a property of OBJ and each field contains the value of that property.
%
%    Example:
%       olf = Olfactometer('1.2.3.4');
%       get(olf)
%       banks = get(olf,'Banks')
%       numOdors = get(olf,'BankNumOdors')
%       get(olf,{'MixNames','BankOdorTables'})
%
%    See also Olfactometer, set
%

%    CCC 4-25-2006
%    Copyright 2006 Calin Culianu Consulting LLC
%    May be released under the GPLv2 or greater


ArgChkMsg = nargchk(1,2,nargin);
if ~isempty(ArgChkMsg)
    error('Olfactometer:get:argcheck', ArgChkMsg);
end

if nargout > 1
   error('Olfactometer:get:argcheck', 'Too many output arguments.');
end

% Error appropriately if a user calls get(1,ai);
if ~isa(obj, 'Olfactometer')
   try
      builtin('get', obj, varargin{:});
   catch
      error('Olfactometer:get:unexpected', lasterr);
   end
   return;
end

% Switch on the number of inputs
switch nargin
case 1   % get(obj);
    % Error if an object is invalid.
    if ~all(isvalid(obj))
       error('Olfactometer:get:invalidobject', 'Olfactometer object OBJ is an invalid object.');
    end

   if (~nargout) && (length(obj)>1)
      error('Olfactometer:get:invalidsize', 'Vector of objects not permitted for GET(OBJ) with no left hand side.');
   end
   if (nargout) && (length(obj)>1)
     for i = 1:length(obj)
       output{i} = local1Arg(obj{i});
     end;
     return;
   end;
   output = local1Arg(obj);
   
case 2   % get(obj, 'Property') | get(obj, {'Property'})
   prop = varargin{1};
   
   output = local2Arg(obj, prop);   
end


% *************************************************************************
% Create the struct object.
function out = local1Arg(obj)
   % Build up the structure of property names and property values.  
   % Each column of the structure corresponds to a different object.
   out = buildEmptyStruct_INTERNAL(obj);

   flds = fieldnames(out);
   % now, for each field, do the equivalent of a 'get' on it!
   for i=1:size(flds,1)
     eval(sprintf('out.%s = get(obj, flds{i});', flds{i}));
   end;
   

% *************************************************************************
% Takes a fieldname and returns the data, 
% or a cell array of fieldnames and returns a struct with those fields
function out = local2Arg(obj, f)

   % rotate a cell array
   if (isa(f, 'cell') & size(f,1) == 1 & size(f,2) > 1), 
     f = f'; 
   end;

   % TODO optimize me
   if (isa(f, 'cell') & size(f,1) > 0 & isa(f{1}, 'char'))
     data = cell(size(f,1), 1);
     for i=1:size(data,1),
       data{i} = local2Arg(obj, f{i});
     end;
     out = cell2struct(data, f, 1);
     % Must sort fields of structure
     firstfields = fieldnames(out);
     [sorted, ind] = sort(lower(firstfields));
     out = orderfields(out, ind);
   elseif (isa(f, 'char'))
     
     out = local2Arg_1(obj, f);
     
   else 
     error(['Olfactometer:get second argument needs to be a string' ...
            ' or a Mx1 cell array of strings!' ]);
   end
   
% *************************************************************************
% Takes a fieldname and returns just that data field
function out = local2Arg_1(obj, f)

   % Build up the structure of property names and property values.  
   % Each column of the structure corresponds to a different object.
   it = buildEmptyStruct_INTERNAL(obj);
   out = [];
   
   switch f
     
    case 'BankOdorTables'
     % construct the odor tables cell array of cell arrays
     out = cell(size(it.Banks,1), 1);
     for i=1:size(out,1)
       out{i} = GetOdorTable(obj, it.Banks{i});
     end;
     
    case 'MixFlowRates'     
     % construct MixFlowRates
     out = zeros(size(it.Mixes, 1), 1);
     for i=1:size(out,1)
       out(i) = GetFlow(obj, it.Mixes{i});
     end;
     
    case 'BankFlowRates'
     % construct BankFlowRates
     out = zeros(size(it.Banks, 1), 1);
     for i=1:size(out,1)
       out(i) = GetFlow(obj, it.Banks{i});
     end;
     
    case 'BankCurrentOdors'
     % construct BankCurrentOdors
     out = zeros(size(it.Banks, 1), 1);
     for i=1:size(out,1)
       out(i) = GetOdor(obj, it.Banks{i});
     end;
     
    case 'BankNumOdors'
     % BankNumOdors
     out = zeros(size(it.Banks, 1), 1);
     for i=1:size(it.Banks, 1)
       out(i) = GetNumOdors(obj, it.Banks{i});
     end;
     
    case 'MixBanks'
     % MixBanks
     out = cell(size(it.Mixes, 1), 1);
     for i=1:size(out,1)
       out{i} = GetBankNames(obj, it.Mixes{i});
     end;
     
    case 'MixRatios'
     % MixRatios
     out = cell(size(it.Mixes, 1), 1);
     for i=1:size(out,1)
       out{i} = GetMixRatio(obj, it.Mixes{i});
     end;
     
    case 'MixCarrierFlows'
     % MixCarrierFlows
     out = zeros(size(it.Mixes, 1), 1);
     for i=1:size(out,1)
       out(i) = GetCarrierFlow(obj, it.Mixes{i});
     end;
     
    case 'MixOdorFlows'
     % MixOdorFlows
     out = zeros(size(it.Mixes, 1), 1);
     for i=1:size(out,1)
       out(i) = GetOdorFlow(obj, it.Mixes{i});
     end;
     
    case 'BanksEnabled'
     % BanksEnabled
     out = zeros(size(it.Banks, 1), 1);
     for i=1:size(out,1)
       out(i) = GetEnabled(obj, it.Banks{i});
     end;
          
    otherwise
     
     % if it's one of our pre-computed fields from
     % localBuilsEmptyStruct, just eval it.fieldname and return that     
     items = cell2mat(strfind(fieldnames(it), f));     
     if (~isempty(find(items == 1)))
       eval(sprintf('out = it.%s;', f));
       return;
     end;
     
     % hmm, if we got here, the field name is invalid..      
     error(sprintf(['Olfactometer:get unrecognized fieldname' ...
                    ' %s'], f));
     
   end; % switch f
