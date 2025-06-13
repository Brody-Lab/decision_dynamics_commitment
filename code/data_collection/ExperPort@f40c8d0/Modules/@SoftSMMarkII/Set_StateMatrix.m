% sm = Set_StateMatrix(sm, Matrix state_matrix) 
%
%       Alias for SetStateMatrix().  See SetStateMatrix() help.
%
function [sm] = Set_StateMatrix(sm, mat)
    sm = SetStateMatrix(sm, mat);
    
    return;
    