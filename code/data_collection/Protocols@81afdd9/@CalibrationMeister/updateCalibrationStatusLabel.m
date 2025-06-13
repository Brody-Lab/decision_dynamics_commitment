function []=updateCalibrationStatusLabel(obj)
    GetSoloFunctionArgs(obj);
    
    valves_to_calibrate_array_low=calcValvestoCalibrate(obj,'LOW');
    valves_to_calibrate_array_high=calcValvestoCalibrate(obj,'HIGH');
    valves_to_calibrate=sum([valves_to_calibrate_array_low valves_to_calibrate_array_high]);
    
    if valves_to_calibrate>0
        CalibrationStatusLabelString='CALIBRATION INCOMPLETE!!!';
        CalibrationStatusLabelBGColor=[244 32 47]/255;
    else
        CalibrationStatusLabelString='CALIBRATION COMPLETE!!!';
        CalibrationStatusLabelBGColor=[64 201 47]/255;
    end
    
    mh=get_ghandle(sub_header_6);
    set(mh,'String', CalibrationStatusLabelString,...
        'BackgroundColor', CalibrationStatusLabelBGColor);