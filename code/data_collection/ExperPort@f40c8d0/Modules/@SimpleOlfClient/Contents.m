%--------------------------------------------------------------------------
% HELP FOR THE SimpleOlfClient Object Interface
%--------------------------------------------------------------------------
% STARTING AND STOPPING THE CLIENT
%--------------------------------------------------------------------------
% function [olf] = SimpleOlfClient(host)
% function [olf] = SimpleOlfClient(host, port)
%
%    Connect to the olfactometer at host:port, and instantiate a new SimpleOlfClient
%--------------------------------------------------------------------------
%function [olf] = Close(olf)
%    Close the olfactometer and end the connection
%--------------------------------------------------------------------------
% LISTING OBJECTS
%--------------------------------------------------------------------------
% function [cell_array_out] = List(olf)
%
%    List all components of the olfactometer
%
%
%    function [cell_array_out] = List(olf, objtype)
%
%    List all components of the olfactometer that match a certain
%    object type.  Known object types are:
%      'saveables'  for all objects that support the save method
%      'readables'  for all objects that support the read method
%      'writeables' for all objects that support the write method
%      'startstop'  for all objects that support the start/stop methods
%      'log'        for all objects that support the log method
%      'cont'       for all objects that take control parameter set/get
%                   methods
%--------------------------------------------------------------------------
% CONTROL PARAMETERS, CALIBRATION, and COEFFICIENTS FOR PIDFlow and PWM
%--------------------------------------------------------------------------
% function [res] = SetCoeffs(olf, pidflow, coeffs_vector)
%    Returns the coefficients for a PID-style flow controller.
%    See also List method to list components; GetCoeffs to
%    get coefficients.
%--------------------------------------------------------------------------
% function [coeffs_vector] = GetCoeffs(olf, pidflow)
%    Returns the coefficients for a PID-style flow controller.
%    See also List method to list components; SetCoeffs to
%    set coefficients.
%--------------------------------------------------------------------------
% function [res] = SetParams(olf, controlable, vector)
%    The control params for a controlable object to vector.
%    See also List method to list which components are controlable; GetParams to
%    get control params.
%--------------------------------------------------------------------------
% function [params_vector] = GetParams(olf, controlable)
%    Returns the control params for a controlable object.
%    See also List method to list which components are controlable; SetParams to
%    set control paobjectrams.
%--------------------------------------------------------------------------
% function [cell_array_out] = GetCalib(olf, comp)
%
%    Retreives the entire contents of the in-memory calibration table for a
%    PIDFlow controller.  See SetCalib and List.
%--------------------------------------------------------------------------
% function [cell_array_out] = SetCalib(olf, comp, calibtable)
%
%    Set the entire contents of the in-memory calibration table for a
%    PIDFlow controller.  See GetCalib.
%--------------------------------------------------------------------------
% function [res] = Save(olf, saveable_component)
%    Save the parameters for a saveable component (such as a PIDFlow).
%    See also List to find out which components are saveable.
%--------------------------------------------------------------------------
% RUNNABLES (PIDFlow and PWM)
%--------------------------------------------------------------------------
% function [out] = IsRunning(olf, runnable)
%    Returns true iff a runnable object is started
%    See also List method to list which components are runnable.
%--------------------------------------------------------------------------
% function [res] = Start(olf, component)
%    Start a runnable component.
%    See also IsRunning, Stop and List methods.
%--------------------------------------------------------------------------
% function [res] = Stop(olf, component)
%    Start a runnable component.
%    See also IsRunning, Start and List methods.
%--------------------------------------------------------------------------
% LOGGING
%--------------------------------------------------------------------------
% function [res] = ClearLog(olf)
%    Unconditionally deletes all the data log entries
%    See also List method to list which components are logable, GetLog and LogCount for other log manipulators.
%--------------------------------------------------------------------------
% function [res] = IsLogging(olf, comp)
%    Returns true iff a logable object is being logged
%    See also List method to list which components are logable.
%--------------------------------------------------------------------------
% function [cell_array_out] = GetLog(olf)
%
%    Retreives the entire contents of the in-memory data log from the
%    olfactometer olf
%--------------------------------------------------------------------------
% function [res] = SetLogging(olf, comp, bool_flg)
%    Enable disable data logging for a particular logable component
%    See also List method to list which components are logable.
%--------------------------------------------------------------------------
% function [count] = LogCount(olf, runnable)
%    Returns the number of events in the olfactometer's log event memory.
%    A call to GetLog() will retreive these events
%    See also List method to list which components are logable; GetLog to
%    retreive the log.
%--------------------------------------------------------------------------
% READING and WRITING Sensors and Actuators
%--------------------------------------------------------------------------
% function [out] = Read(olf, sensor)
%    Read cooked data from a sensor named 'sensor'
%    See also ReadRaw and List methods.
%--------------------------------------------------------------------------
% function [out] = ReadRaw(olf, sensor)
%    Read raw data from a sensor named 'sensor'
%    See also Read and List methods.
%--------------------------------------------------------------------------
% function [res] = Write(olf, component, val)
%    Write a cooked value 'val' to an actuator named 'component'
%    See also WriteRaw and List methods.
%--------------------------------------------------------------------------
% function [res] = WriteRaw(olf, component, val)
%    Write a raw value 'val' to an actuator named 'component'
%    See also Write and List methods.
%--------------------------------------------------------------------------
% function [carriers, banks] = GetOlfHardware(olf)
%     Returns which carrier/s and bank/s are hooked up to a particular machine.
%     If a new rig is hooked up, add a 'case' for it in the hostname switchyard.
%     Added by GF 12/29/06
%--------------------------------------------------------------------------
% END CONTENTS.M
%--------------------------------------------------------------------------
