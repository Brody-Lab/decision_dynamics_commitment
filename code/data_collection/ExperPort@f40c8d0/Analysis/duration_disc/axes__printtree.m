function [] = axes__printtree(ahandle)
% print the tree of children of an axes handle

sub__printType(1, ahandle)
sub__printmykids(2, ahandle);

% recursive
function [] = sub__printmykids(numtabs, han)
    c = get(han,'Children');
    for k = 1:length(c)
        sub__printType(numtabs, c(k));        
        sub__printmykids(numtabs+1, c(k));    end;        

function [] = sub__printType(numtabs, han)
    tabs = repmat('---', 1, numtabs);
    fprintf('|%s(%2.1f) %s\n', tabs, han, get(han,'Type'));
