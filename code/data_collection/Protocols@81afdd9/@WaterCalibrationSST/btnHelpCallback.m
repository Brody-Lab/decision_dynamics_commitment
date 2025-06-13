function btnHelpCallback

helpstr = {'CALIBRATION INSTRUCTIONS:'};

helpstr{end+1} = '';

helpstr{end+1} = '1. Load dry, pre-weighed, marked containers under each';
helpstr{end+1} = '     poke that dispenses water.';
helpstr{end+1} = '2. Press START CALIBRATION (LOW TARGET) to calibrate for';
helpstr{end+1} = '     the low target value, specified in the Settings section.';
helpstr{end+1} = '3. When prompted, enter the water weights (subtract the';
helpstr{end+1} = '     weight of the container) in grams.';
helpstr{end+1} = '4. Repeat steps 2 and 3 until a CALIBRATION VALID message';
helpstr{end+1} = '     appears.';
helpstr{end+1} = '5. Press START CALIBRATION (HIGH TARGET) to calibrate for';
helpstr{end+1} = '     the high target value, specified in the Settings section.';
helpstr{end+1} = '6. Again, enter the water weights when prompted, in grams ';
helpstr{end+1} = '     (similar to step 3).';
helpstr{end+1} = '7. Repeat the process until calibration succeeds';
helpstr{end+1} = '8. When calibration is complete, press EXIT to exit the';
helpstr{end+1} = '     application.';

helpstr{end+1} = '';

helpstr{end+1} = 'HINT: Press the yellow button, in most situations';

helpdlg(helpstr, 'HELP DIALOG');

end