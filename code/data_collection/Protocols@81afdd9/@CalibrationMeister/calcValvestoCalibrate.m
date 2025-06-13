function [valves_to_calibrate]=calcValvestoCalibrate(obj,varargin)
    GetSoloFunctionArgs(obj);
    valves_to_calibrate=[0 0 0];
    if nargin==2
        target_to_be_achieved=varargin{1};
    else
        target_to_be_achieved=value(CALIBRATION_HIGH_OR_LOW_CONST);
    end
    for i=1:3
        if valves_used(i)
            valve=valves_dionames{i};
            sqlstr=sprintf('select count(*) as n from bdata.new_calibration_info_tbl where rig_id="%s" and valve="%s" and target="%s" and isvalid=True and validity="PERM" and datediff(curdate(),dateval)=0',value(rig_id),valve,target_to_be_achieved);
            num_valid_values=bdata(sqlstr);
            if ~isempty(num_valid_values) && num_valid_values>0
                dummy=1;
            else
                valves_to_calibrate(i)=1;
            end
        end
    end
end