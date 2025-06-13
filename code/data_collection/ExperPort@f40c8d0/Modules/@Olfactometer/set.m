function obj = set(obj, varargin)
% SET Set Olfactometer object properties.
%
%    OBJ = SET(OBJ,'Property', V) set  the value, V, of the specified property
%    for Olfactometer object OBJ.
%
%    OBJ = SET(OBJ, S) sets the property values for the
%    Olfactometer object OBJ given a structure S.  The fieldnames
%    of the structure should correspond to valid property values
%    for OBJ, and the values for those fields should be of a
%    compatible type and shape.  See Olfactometer:GET for a list of property
%    names and values.
%
%    SET(H,pn,pv) sets the named properties specified in the cell array
%    of strings pn to the corresponding values in the cell array pv for
%    all objects specified in H.  The cell array pn must be 1-by-N, but
%    the cell array pv can be M-by-N where M is equal to length(H) so 
%    that each object will be updated with a different set of values
%    for the list of property names contained in pn.
%
%    SET(H,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%    sets multiple property values with a single statement.  Note that it
%    is permissible to use property/value string pairs, structures, and
%    property/value cell array pairs in the same call to SET. 
%
%    Example:
%       olf = Olfactometer('1.2.3.4');
%       get(olf)
%       olf = set(olf,'BankCurrentOdors', [ 1 1 2 0 ])
%       set({olf},{'BankCurrentOdors','OdorTables'}, { [1 1 2 0], otvector } )
%
%    See also Olfactometer, get
%

%    CCC 4-25-2006
%    Copyright 2006 Calin Culianu Consulting LLC
%    May be released under the GPLv2 or greater

%
it = buildEmptyStruct_INTERNAL(obj);

ArgChkMsg = nargchk(2,size(fieldnames(it),1)+1,nargin);
if ~isempty(ArgChkMsg)
    error('Olfactometer:set:argcheck', ArgChkMsg);
end

if nargout > 1
   error('Olfactometer:set:argcheck', 'Too many output arguments.');
end

% usage case: set(obj, 'Property1', Value1, 'Property2', Value2 ...)
if (nargin > 3 & isstr(varargin{1}))
  for i=1:(nargin-1)/2
    obj = set(obj, varargin{i*2-1}, varargin{i*2});
  end;
  return;
end;

if (nargin == 3 & isstr(varargin{1}))
  obj = doSimpleSet(obj, varargin{1}, varargin{2});
  return;
end;

error(['This usage of this function is not yet implemented! Sorry! '...
       'Bug Calin if you want to use this function in this way!'] );


%% INTERNAL FUNCTION -- Actually has all the logic for doing the set
function obj = doSimpleSet(obj, prop, val)
  
    it = buildEmptyStruct_INTERNAL(obj);
    
    % determine if prop is a valid property
    exists = 1;
    try
      % awkward
      eval(sprintf('dummy = it.%s;', prop));
    catch
      exists = 0;
    end;
    if (~exists) 
      error(sprintf([ '\n\n*******************\n' ...
                      'Olfactometer:set property ''%s'' does not' ...
                      ' exist!' ...
                      '\n*******************\n\n' ],  prop));
      return;
    end;
    
    % rotate any row arrays sideways to make them column-arrays
    if (size(val,1) == 1 & size(val,2) > 1 & ~isstr(val))
      val = val';
    end;
    
    switch prop
      
    case 'BankOdorTables'
     % validate args
     numbanks = size(it.Banks,1);
     if (~iscell(val) | ~all(size(val) == [ numbanks  1 ]))
       error(sprintf(['Olfactometer:set need to specify a %dx1 cell array ' ...
                      ' of cell arrays'], numbanks));
     end;
     % for each bank, set the odor table
     for i=1:numbanks
       obj = SetOdorTable(obj, it.Banks{i}, val{i});
     end;
          
    case 'MixFlowRates'     
     % validate args
     nummix = size(it.Mixes,1);
     if (~isnumeric(val) | ~all(size(val) == [ nummix  1 ]))
       error(sprintf(['Olfactometer:set need to specify a %dx1 matrix ' ...
                      ' of numbers'], nummix));
     end;
     % for each mix, set the flow
     for i=1:nummix
       obj = SetOdorFlow(obj, it.Mixes{i}, val(i));
     end;
            
    case 'BankFlowRates'
     % TODO
     %
     error('This set function, BankFlowRates, is unimplemented!');
     %
     % TODO

     % validate args
     num = size(it.Banks,1);
     if (~isnumeric(val) | ~all(size(val) == [ num  1 ]))
       error(sprintf(['Olfactometer:set need to specify a %dx1 matrix ' ...
                      ' of numbers'], num));
     end;
     % for each bank, set the flow
     for i=1:num
       obj = SetBankFlow(obj, it.Banks{i}, val(i));
     end;
     
    case 'BankCurrentOdors'
     % validate args
     num = size(it.Banks,1);
     if (~isnumeric(val) | ~all(size(val) == [ num  1 ]))
       error(sprintf(['Olfactometer:set need to specify a %dx1 matrix ' ...
                      ' of numbers'], num));
     end;
     % for each bank, set the flow
     for i=1:num
       obj = SetOdor(obj, it.Banks{i}, val(i));
     end;
          
    case 'MixRatios'
     % validate args
     numMixes = size(it.Mixes,1);
     if (~all(size(val) == [ numMixes 1 ]) )
       error(sprintf(['Olfactometer:set need to specify a %dx1 cell ' ...
                      ' of cells'], numMixes));
     end;
     for i=1:numMixes
       obj = SetMixRatio(obj, it.Mixes{i}, val{i});
     end;
          
    case 'MixOdorFlows'
     % validate args
     numMixes = size(it.Mixes,1);
     if (~isnumeric(val) | ~all(size(val) == [ numMixes 1 ]) )
       error(sprintf(['Olfactometer:set need to specify a %dx1 matrix ' ...
                      ' of numbers'], numMixes));
     end;
     for i=1:numMixes
       obj = SetOdorFlow(obj, it.Mixes{i}, val(i));
     end;
     
    case 'BanksEnabled'
     % validate args
     numBanks = size(it.Banks,1);
     if (~isnumeric(val) | ~all(size(val) == [ numBanks 1 ]) )
       error(sprintf(['Olfactometer:set need to specify a %dx1 matrix ' ...
                      ' of numbers'], numBanks));
     end;
     for i=1:numBanks
       obj = SetEnabled(obj, it.Banks{i}, val(i));
     end;
     
    otherwise

     % this default case is reached only when it's a readonly
     % property -- code before switch caught invalid props     
     error(sprintf('\n\n*******************\nProperty ''%s'' is readonly!\n*******************\n\n', prop));
     
   end; % switch f

