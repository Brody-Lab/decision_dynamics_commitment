%==  Equal for WaterCalibrationTable objects, an overloading method
%   
%     Mathworks' interface for an eq() method:
%--
%--    A == B does element by element comparisons between A and B
%--    and returns a matrix of the same size with elements set to logical 1
%--    where the relation is true and elements set to logical 0 where it is
%--    not.  A and B must have the same dimensions unless one is a
%--    scalar. A scalar can be compared with any size array.
%--
%--    C = EQ(A,B) is called for the syntax 'A == B' when A or B is an
%--    object.
%--
%
%     We consider individual WaterCalibrationTable objects identical if all
%       their fields are equal (== or strcmp).
%
%     The various cases here behave, as far as I can see, exactly as eq
%       generally does.
%
%     Sebastien Awwad, Feb.2008
%
function areEqual = eq(A,B)

if ~isa(A,'WaterCalibrationTable') || ~isa(B,'WaterCalibrationTable'),
    error('eq for WaterCalibrationTable objects obviously needs two WaterCalibrationTable objects!');
end;

fieldnames  = fields(A); %     Fields of a WaterCalibrationTable object
nFields     = length(fieldnames);
lA          = length(A);
lB          = length(B);
% lS          = min(lA,lB); %     length of the shorter vector
% lL          = max(lA,lB); %     length of the longer vector
% areEqual    = false(1,lL); %     output

if      lA == 0 && lB == 1,
    areEqual        = false(0);
    return;
elseif  lA == 1 && lB == 0,
    areEqual        = false(0);
    return;
elseif lA == 1 && lB == 1,
    areEqual        = true; %     Equal until we find an unequal field.
    for f = 1:nFields,
        eA = A.(fieldnames{f});
        eB = B.(fieldnames{f});
        %cA = class(eA);
        %cB = class(eB);
        %if ~strcmp(cA,cB), areEqual(i) = false; break; end; %     If they're not the same class, they're not equal. !!Edited: bool false still equals int 0, and so on :P 
        if ischar(eA) && ischar(eB),
            if ~strcmp(eA,eB), areEqual = false; break; end;
        else
            if eA ~= eB, areEqual = false; break; end;
        end; %     end if/else both ischar
    end; %     end for each fieldname
    return;
elseif lA == 1, %     and lB > 1
    areEqual        = false(1,lB);
    for i = 1:lB,
        areEqual(i) = eq(A,B(i));
    end;
elseif lB == 1, %     and lA > 1
    areEqual        = false(1,lA);
    for i = 1:lA,
        areEqual(i) = eq(A(i),B);
    end;
elseif lA ~= lB,
    error('Matrix dimensions must agree, or be [0 1] or [1 0] or [1 N] or [N 1], where N is any positive integer.');
else
    error('Programming error. Previous cases should have captured all possibilities. Something has been missed. Please contact a developer about Modules/@WaterCalibrationTable/eq.m.');
end; %     End if/elseif/.../else lengths of A and B
end %     End of function eq for WaterCalibrationTable objects
