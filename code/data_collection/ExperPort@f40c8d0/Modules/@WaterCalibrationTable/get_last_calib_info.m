function output = get_last_calib_info(wt)

[VALVE, TIME, DISPENSE, DATE, TECH] = deal_last_table_entry(wt); 

DATE = datestr(DATE,29);
DATE(DATE == '-') = ' ';

output.tech = TECH;
output.date = DATE;