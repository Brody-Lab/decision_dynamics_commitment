function S=update_subject_species(ratname,is_rat)
% err=change rat -> mouse or viceversa
%
% Input:
% Takes a ratname and is_rat boolean
%    if boolean = 1 => subject = rat;
%    if boolean = 0 => subject = mouse;
%
% Optional Output
% S    0 if everything worked
%      1 if there was an error

try
    [ratID]=bdata(['select internalID from ratinfo.rats where ratname="',ratname,'"']);
    bdata('call ratinfo.update_subject_species("{Si}","{Si}")',ratID,is_rat);
    S.err=0;
catch le
    showerror(le)
    S.err=1;
    
    
end
end