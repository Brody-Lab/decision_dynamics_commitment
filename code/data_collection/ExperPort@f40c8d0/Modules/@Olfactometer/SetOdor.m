% SETODOR 
% olf = SetOdor(olf, bankname, odornum, ...) 
% sets the odor for olfactometer olf, bank bankname to odornum
function olf = SetOdor(varargin)
    
    if (nargin < 3 | mod(nargin, 2) ~= 1),
      error('Wrong number of arguments to SetOdor()');
      return;
    end;
    
    olf = varargin{1};

    if (~isa(olf, 'Olfactometer')),
      error('Arg 1 to SetOdor should be an olfactometer instance');
      return;
    end;
    
    cmd = 'SET BANK ODOR';
    
    % concatenate 'bankname odor' pairs to the end of the command
    for i=2:2:nargin,
      bankname = varargin{i};
      odor = varargin{i+1};      
      idx = GetBankIndex_INTERNAL(olf, bankname);
      if (odor < 0 | odor >= olf.banks{idx, 3}),
        error(sprintf('Odor number %d is out of range!', odor));
        return;
      end;
      cmd = [ cmd sprintf(' %s %d', bankname, odor) ];
    end;
    
    DoSimpleCmd(olf, cmd);
