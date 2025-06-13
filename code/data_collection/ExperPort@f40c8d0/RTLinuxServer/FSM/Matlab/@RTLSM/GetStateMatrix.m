% Inverse of above..
function [matrx] = GetStateMatrix(sm)

     matrx = DoQueryMatrixCmd(sm, 'GET STATE MATRIX');

end
