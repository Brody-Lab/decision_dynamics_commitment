function [has,name,T] = hastoolbox(str)
    %HASTOOLBOX   Check if a Matlab toolbox is available.
    %   has = HASTOOLBOX(str) returns 1 if the name of an available toolbox 
    %   contains 'str' (not case sensitive).
    %   [has name] = HASTOOLBOX(str) returns the full name of the matching
    %   toolbox(es).
    %   [has name toolboxes] = HASTOOLBOX(str) returns a list of all available
    %   toolboxes.

    %   Adrian Bondy, 2014.
    if ~ischar(str) || isempty(str)
        error('Input must be a non-empty string.');
    end
    if length(str)<10
        mssg(0,'Warning: Name needs ten characters to match.');
    end
    T=toolboxes;
    has=any(strncmpi(str,T,10));
    if nargout>1
        name=T(has);        
    end    
end


