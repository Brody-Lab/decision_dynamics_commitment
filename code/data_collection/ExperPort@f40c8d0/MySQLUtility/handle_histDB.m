function c=handle_histDB(sessid, owner, funcname, varname, trialnum)
% c=handle_histDB(sessid, owner, funcname, varname, trialnum)
%
% 
%   Return the value of a SoloParamHandle in a particular trial number. If
%   trialnum is not passed, then returns a cell vector with the whole history
%   of the SoloParamHandle. If the SoloParamHandle is not found, returns an
%   empty cell; if the trial number requested is not found, returns an empty
%   vector.
%  
%   PARAMETERS:
%   -----------
%
%   sessid    The session id.  
%   
%   owner     Either an object, or a string indicating the class of an object
%  
%   funcname  A string indicating the name of the m-file in which the
%             SoloParamHamdle was declared.
%  
%   varname   The name of the SoloParamHandle
%  
%   trialnum  An optional integer vector. If passed, the value of the
%             SoloParamHandle for the indicated trial numbers will be
%             returned; if not passed, a cell vector with the entire history
%             will be returned.
%  
%   RETURNS:
%   --------
%  
%   If trialnum is not passed, returns a cell vector with the entire history
%   of the SoloParamHandle; if trialnum is passed, returns the value on the
%   indicated trialnum.
%  
%   If the SoloParamHandle is not found, either because the owner is not
%   found, the funcname is not found, or the varname is not found, returns an
%   empty cell. If the history is empty, returns an empty cell. If the
%   trialnum is not found, returns an emoty matrix.
%  
%  
%   EXAMPLES:
%   ---------
%  
%    lwm=handle_histDB(42036,SameDifferent,'RewardsSection','left_wtr_mult')


if ~ischar(owner)
	owner=class(owner);
end

S=bdata(['select ' funcname ' from solodata.' owner ' where sessid="{S}"'], sessid);
if isempty(S)
    fprintf(2,'Session %d not in table %s',sessid, owner);
    c=[];
    return;
end
S=S{1};
fullname=[funcname '_' varname];
if isfield(S,fullname)
if nargin<5
	c=S.(fullname);
else
	c=S.(fullname)(trialnum);
end
else
c=[];
	fprintf(1,'%s not found\n',fullname);
    fn=fieldnames(S);
    vind=strfind(fn, varname);
    for vx=1:numel(vind)
        if ~isempty(vind{vx})
            fprintf(1,'Did you mean "%s"\n',fn{vx})
        end
    end
end