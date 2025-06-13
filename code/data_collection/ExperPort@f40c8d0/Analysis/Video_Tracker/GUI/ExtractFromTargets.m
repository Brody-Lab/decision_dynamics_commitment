%ExtractFromTargets Extract various values from array of neuralynx video tracker led/diode/bright spot bitfields ("targets" or "points").
%   [x,y,color,valid_targets] = ExtractFromTargets( nlx_targets ), for M-by-N matrix nlx_targets.
%   nlx_targets is composed of M number nlx records by N max targets per record.
%   The function returns 4 parameters:
%       x - an M by N matrix where M = the number of records and N = number of x coordinates per record.
%           this value represents the x coordinate of a given target.
%       y - an M by N matrix where M = the number of records and N = number of y coordinates per record.
%           this value represents the y coordinate of a given target.
%       color - an M by N by 7 matrix where M = the number of records and N = number of colors per record.
%           The 7 represents the 7 types of color information that is stored.
%           this value represents the color of a given target, or zero if that color is not present, or one if present.
%           color(:,:,1) = Raw Red
%           color(:,:,2) = Pure Red
%           color(:,:,3) = Raw Green
%           color(:,:,4) = Pure Green
%           color(:,:,5) = Raw Blue
%           color(:,:,6) = Pure Blue
%           color(:,:,7) = Luminance
%       valid_targets - a matrix containing the number of values for each N in the above variables.
%           this value represents the number of targets per record (which varies from record to record).
%
%   NOTE:  if a target is equal to zero i.e. the bitfield, then the target is empty for there wasn't any data written to it.
%
%   Author: Kevin Iamiceli
%   Date:   1/31/02
%   Co.     Neuralynx Inc.
%
%   Example:
%       Use NLX_VTRead which is a mex-file, or matlab_read.exe to read a neuralynx video tracker file into matlab.
%       >> [TS, Lights, Pixels] = NLX_VTRead('C:\Cheetah_Data\01_31_2002_8_31_04\VT1.nvt');
%
%       A who command will list the variable names in matlab
%       >> who;
%
%       Usually a good idea is to make smaller buffers from the ones read in from a file.
%       It is not recommended to do more than 1000 video tracker records at a time.
%       Using slicing to create new buffers is a great way to accomplish this.
%       >> Targets = Lights(:,1:1000);
%       The first : represents all data in that dimension, which happens to be 50 targets per record, and the 1:1000 represents 1000 records.
%       This Targets variable can now also be passed to the following function just as Lights.
%
%       Then call this function passing it the targets extracted, in this example the variable name is Lights.
%       Return parameters should include 4 fields as described above.
%       >> [x, y, color, valid_targets] = ExtractFromTargets(Lights);
%
%       Then make a call to the following function to display the targets with their appropriate color.
%       Color information is not exact, it is displayed as well as possible using matlab.
%       The Function is mainly for demostration purposes, please read all documentation within that m-file.
%       >> PlotFrameFromTarget(x, y, color,100);
%
%----------------------------------------------------------------------------------------------------------------------
%   This function extracts x and y coordinates, and color information from the array of target bitfields passed to it.
%----------------------------------------------------------------------------------------------------------------------
function [x,y,color,valid_targets] = ExtractFromTargets(nlx_targets, varargin)
pairs = { ...
    'RigPos'         [230, 63, 320, 400]; ...
    'h'              []; ...
    'savetype'       'mat'; ...
}; parseargs(varargin, pairs);


    % find how many recs and how many targets per record
    [max_targets,max_records] = size( nlx_targets );

    %output number of rec in file
    str = sprintf('There are %d records in this file',max_records);
    
    % loop to extract all targets from each record
    for rec_index = 1:max_records

        %get record
        current_record = nlx_targets(:,rec_index);

        % loop to extract all targets from current record
        target_index = 1;
        i = 1;
        while target_index <= max_targets
            
            % if the bitfield is equal to zero, then we know there is no valid data for that
            % field, or the rest of the bitfields in the record.
            if current_record( target_index ) == 0
                break;
            end

            
%             [x{rec_index}(target_index) , y{rec_index}(target_index)] = ExtractXY( current_record( target_index ) );
%             [color{rec_index}(target_index, 1:7)] = ExtractColor( current_record( target_index ) );

            % extract the x and y positions and store them to be returned to matlab
            [xcoord ycoord] = ExtractXY( current_record(target_index) );
            % ignore points outside the position of the rig
            if xcoord > RigPos(1) && ycoord > RigPos(2),
                switch savetype,
                    case 'mat',
                        x(rec_index, i) = xcoord;
                        y(rec_index, i) = ycoord;
                        [color(rec_index, i, 1:7)] = ExtractColor( current_record( target_index ) ); 
                    case 'cell',
                        x{rec_index}(i) = xcoord;
                        y{rec_index}(i) = ycoord;
                        color{rec_index}(i, 1:7) = ExtractColor( current_record(target_index) );
                end;
                i = i + 1;
            end;
            target_index = target_index + 1;
        end  %end inner loop

        % record the number of targets within each rec that contain data
        valid_targets( rec_index ) = i-1;
        
    
        if mod(rec_index,100) == 0
            str = sprintf('Record number %d processed.',rec_index);
            display(str);
            set(h, 'String', str);
        end

    end  %end loop
    
    display('All records extracted');
    set(h, 'String', 'All records extracted');

%----------------------------------------------------------------------------------------------------------------------
%   This function extracts the x and y coordinates from the bitfield for a given target.  
%----------------------------------------------------------------------------------------------------------------------
function [x,y] = ExtractXY(bitfield)

    VREC_X_MASK = hex2dec('00000FFF');    %x value mask
	VREC_Y_MASK = hex2dec('0FFF0000');    %y value mask

   	x = bitand( bitfield, VREC_X_MASK );   % extract x from bit field
	y = bitand( bitfield, VREC_Y_MASK );   % extract y from bit field
	y = bitshift( y, -16 );                % shift y all the way to the right

   
%----------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------
function [color] = ExtractColor(bitfield)

    % luminance and pure/raw RGB masks
    VREC_RR_MASK = hex2dec('4000');       % raw red mask
    VREC_RG_MASK = hex2dec('2000');       % raw green mask
    VREC_RB_MASK = hex2dec('1000');       % raw blue mask
    VREC_PR_MASK = hex2dec('40000000');   % pure red mask
    VREC_PG_MASK = hex2dec('20000000');   % pure green mask
    VREC_PB_MASK = hex2dec('10000000');   % pure blue mask
    VREC_LU_MASK = hex2dec('8000');       % luminance mask
    
	color(1) = 0;   % raw red
	color(2) = 0;   % pure red 
	color(3) = 0;   % raw green
	color(4) = 0;   % pure green
	color(5) = 0;   % raw blue
	color(6) = 0;   % pure blue
	color(7) = 0;   % luminance

    % put in the color for each color in record
    if ( bitand(bitfield,VREC_RR_MASK) ~= 0)
            color(1) = 1;
    end
    if ( bitand(bitfield,VREC_PR_MASK) ~= 0)
            color(2) = 1;
    end
    if ( bitand(bitfield,VREC_RG_MASK) ~= 0)
            color(3) = 1;
    end
    if ( bitand(bitfield,VREC_PG_MASK) ~= 0)
            color(4) = 1;
    end
    if ( bitand(bitfield,VREC_RB_MASK) ~= 0)
            color(5) = 1;
    end
    if ( bitand(bitfield,VREC_PB_MASK) ~= 0)
            color(6) = 1;
    end
    if ( bitand(bitfield,VREC_LU_MASK) ~= 0)
            color(7) = 1;
    end

