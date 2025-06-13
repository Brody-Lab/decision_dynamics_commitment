% <~> Sebastien Awwad, 2008.
%
%
   % <~> The new embedded-C feature of the new RT software is now
   %       officially disabled. This is because it its performance is slow
   %       and nobody is currently employing it, and because the
   %       StateMachineAssembler modifications I made to accommodate it
   %       cause problems for dispatcher('disassemble') that do not merit
   %       remedy unless someone is actually using embedded-C.
   %
   %     Consequently, this method always returns false.
%
%
%     [truefalse] = isUsingEmbC(sma)
%
%    isUsingEmbC is a get method. See below.
%
%     This method is a part of the modifications to the State Machine
%       Assembler made for compatibility with the new RTLSM system (March
%       2008) with its additional functionality.
%
% RETURNS:
% --------
%
% truefalse  True if embedded C code has been submitted to this
%              StateMachineAssembler object, and false otherwise.
%
%            Such submission can occur either through inclusion of C code
%              in the state transitions in an add_state call or through
%              definition of embedded C properties through the method
%              @StateMachineAssembler/set_embedded_c_props.
%
% PARAMETERS:
% -----------
% sma      The instantiation of the StateMachineAssembler object for which
%            the determination is made.
%
% EXAMPLES:
% ----------
%
%      if ~isUsingEmbC(sma), display('Using old functionality.'); end;
%
%
function truefalse = isUsingEmbC(sma)

% truefalse = sma.flagUsingEmbC;
truefalse = false;

    return;
    
end %     End of method isUsingEmbC
