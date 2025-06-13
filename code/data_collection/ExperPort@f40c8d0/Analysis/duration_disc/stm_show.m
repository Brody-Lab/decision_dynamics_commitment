function [] = stm_show(stm, startrow, endrow)
% prints state matrix contents and appends the row number as the first
% column
%
% example use: 
% stm_show(stm,rewardstart,RddS+3)
%stm_show(stm,LgcS+1,ItiS)

[(startrow:endrow)' stm(startrow:endrow,:)]