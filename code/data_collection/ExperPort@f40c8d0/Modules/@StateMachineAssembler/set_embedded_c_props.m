% <~> Sebastien Awwad, 2008. In Progress.
%
% [sma] = set_embedded_c_props( ...
%                   sma,                        ... %required argument
%                   'globals',          '',     ... %optional
%                   'initfunc',         '',     ... %optional
%                   'cleanupfunc',      '',     ... %optional
%                   'transitionfunc',   '',     ... %optional
%                   'tickfunc',         '',     ... %optional
%                   'treshfunc',        '',     ... %optional
%                  );
%
%     Registers C code to run at specific points in State Machine
%       execution, for example upon every transition from one state to
%       another. See optional parameters below.
%     This method grants access to the expanded functionalities of the new
%       RTLSM system (March 2008). You must be using it for this to work.
%
%
% RETURNS:
% --------
%
% sma      The updated State Machine Assembler object, with embedded C
%            properties modified.
%
% PARAMETERS:
% -----------
% sma      The instantiation of the StateMachineAssembler object for which
%            embedded C properties will be modified.
%
% OPTIONAL PARAMETERS: (copied directly from @RTLSM/SetStateProgram)
% --------------------
%
%                'globals' (OPTIONAL)
%
%                  The argument that follows should be a string
%                  that is the free-form C-code that delcares all
%                  globals, typedefs, and implements all functions
%                  that your'matrix' (or other code in your state program)
%                  will reference.  Basically, because this is C, you
%                  need to declare everything, and this is the
%                  place to do it.  Do not forget to implement
%                  functions here too!
%
%                'initfunc' (OPTIONAL)
%
%                  The argument that follows should be a string that
%                  is the name of a C function that you would like
%                  executed when the new state machine program starts.
%                  The function should exist in the 'globals' section
%                  described above, or else there will be a runtime
%                  error when the new state machine program is
%                  compiled and/or executed. The function should have
%                  C type signature void (*)(void).
%
%                'cleanupfunc' (OPTIONAL)
%
%                  The argument that follows should be a string that
%                  is the name of a C function that you would like
%                  executed when the new state machine program is
%                  exited and/or destroyed.  The function should exist
%                  in the 'globals' section described above, or else
%                  there will be a runtime error when the new state
%                  machine program tries to execute.  The function
%                  should have C type signature void (*)(void).
%
%                'transitionfunc' (OPTIONAL)
%
%                  The argument that follows should be a string that
%                  is the name of a C function that you would like
%                  executed whenever a state transition occurs. The
%                  function is executed even for 'jump-to-self'
%                  transitions.  The function should exist in the
%                  'globals' section described above, or else there
%                  will be a runtime error when the new state machine
%                  program tries to execute.  The function should have
%                  C type signature void (*)(void).
%
%                'tickfunc' (OPTIONAL)
%
%                  The name of the function (declared and defined in
%                  the 'globals' above) to call for each tick of the
%                  FSM.  This function will be called once for every
%                  FSM cycle (at the beginning of the cycle, before
%                  anything happens)!  This is going to be called as
%                  many times per second as the FSM's cycle rate,
%                  which by default is 6000!  The type of this
%                  function is void(*)(void).
%
%                'threshfunc' (OPTIONAL)
%
%                  The name of the function (declared and defined in
%                  the 'globals' above) to call for AI threshold
%                  detection in the FSM.  This function will be called
%                  once for every AI sample acquired for each FSM task
%                  cycle, so make sure it is a fast, lightweight function!
%                  The type of this function is TRISTATE(*)(int,double).
%                  And the return type is a TRISTATE which can take values:
%                  POSITIVE for upward threshhold crossing,
%                  NEGATIVE for downward threshold crossing,
%                  or NEUTRAL for no change (historesis band).
%                  Here is the internal function the state machine uses by
%                  default:
%
%                  TRISTATE threshold_detect(int chan, double v)
%                  {
%                    if (v >= 4.0) return POSITIVE; /* if above 4.0 V,
%                                                      above threshold */
%                    if (v <= 3.0) return NEGATIVE;/* if below 3.0,
%                                                     below threshold */
%                    return NEUTRAL; /* otherwise unsure, so no change */
%                  }
%
%                  Note how the function implements a historesis band
%                  between 3.0 and 4.0 volts.  This is recommended in your
%                  custom function as well in order to prevent threshold
%                  detection from flip-flopping back and forth in cases
%                  where the input signal is noisy.
%
% EXAMPLES:
% ----------
%
%<~>TODO: Add example calls for @StateMachineAssembler/set_embedded_c_props
%
%
function [sma] = set_embedded_c_props(sma, varargin)

%     Optional argument parsing. See documentation above.
pairs = { ...
    'globals',          '';     ...
    'initfunc',         '';     ...
    'cleanupfunc',      '';     ...
    'transitionfunc',   '';     ...
    'tickfunc',         '';     ...
    'treshfunc',        '';     ...
    }; parseargs(varargin, pairs);


% --- BEGIN error_checking ---
%<~>TODO: Add some error checking that doesn't make too many assumptions
%           about the interface? Do after send is modified.
% --- END error_checking ---


%     For each featurename-featurevalue pair, register the given value.
%     These values are extracted in @StateMachineAssembler/send.m, which
%       passes them to the RTLSM object via @RTLSM/SetStateProgram.m.
%     Empty values need not be included.
for feature = { ...
        'globals'           globals;        ...
        'initfunc'          initfunc;       ...
        'cleanupfunc'       cleanupfunc;    ...
        'transitionfunc'    transitionfunc; ...
        'tickfunc'          tickfunc;       ...
        'treshfunc'         treshfunc;      ...
        };
    if ~isempty(feature{2})     %     If value is not an empty string,
        sma.(feature{1}) = feature{2}; sma.flagUsingEmbC = true;
    end;                        %     end if feature value is not an empty string
end;                            %     end for each feature

end %     end of method Modules/@StateMachineAssembler/set_embedded_c_props.m
