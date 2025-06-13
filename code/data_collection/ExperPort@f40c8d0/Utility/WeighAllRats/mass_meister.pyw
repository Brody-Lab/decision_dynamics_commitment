#!/usr/bin/env /usr/local/bin/python
import wx
import wx.lib.masked
import time
import datetime
import random
import MySQLdb
import itertools
import sys
import serial
import re
import base64
import unicodedata
from wx.lib.mixins.listctrl import ListCtrlAutoWidthMixin
from wx.lib.wordwrap import wordwrap

#Database Access
db_server="sonnabend.princeton.edu"
db_username=base64.b64decode("cm9vdA==")
db_password=base64.b64decode("ZEA3YTYwZA==")
db_name="ratinfo"
db_mass_table="mass"
db_schedule_table="schedule"
db_contacts_table="contacts"
db_rats_table="rats"
date_shift=0
first_session=1
last_session=6
ratmass_records_thres=30

MASS_ERROR_TOLERANCE=5
MIN_RIGS_FOR_CUSTOM_SETTINGS=25
RIG_NUMBER_LL=1
RIG_NUMBER_UL=30
MIN_ACCEPTED_MASS=100
MAX_ACCEPTED_MASS=680
MINIMUM_SAMPLES=30
MAX_IDLE_LOOP_RUN_TIME=1800
MEAN_WEIGHT_DISPLAY_TIMER=3
ERROR_TOLERANCE_TIMER=3
MIN_TIME_TO_REMOVE_RAT=30
SCALE_OCCUPIED_TIMER=.01
SCALE_OCCUPIED_THRES=5
WEIGHING_TIMER=4
MIN_RAT_WEIGHT_THRES=10
MAIN_WIDTH=1090
MAIN_HEIGHT=680
RIG_ORDER_WORD_WRAP=320
PANEL1_HEIGHT=30
PANEL3_HEIGHT=30
PANEL1_BORDER=1
PANEL2_BORDER=1
PANEL3_BORDER=2
ID_RADIOBOX=1
ID_SESSIONS_BOX=2
ID_LISTCTRL=3
ID_START_BUTTON=4
ID_STOP_BUTTON=5
ID_MASKED_RAT_TEXTCTRL=6
ID_RAT_SEARCH_BUTTON=7
ID_RAT_CLEAR_BUTTON=8
ID_MASKED_MASS_TEXTCTRL=9
ID_MASS_SET_BUTTON=10
ID_MASS_RESET_BUTTON=11
ID_ABOUT_BUTTON=12
ID_CUST_SETT_MASKED_TEXTCTRL=13
ID_CUST_SETT_SET_BUTTON=14
ID_CUST_SETT_RESET_BUTTON=15
ABOUT_BUTTON_BG_COLOR='#977FFF'
REWEIGH_NOTIFICATION_FG_COLOR='RED'
TECH_INST_BG_COLOR_NORMAL='GREEN'
TECH_SPECIAL_INST_PENDING_FGCOLOR='RED'
TECH_SPECIAL_INST_WEIGHED_FGCOLOR='RED'
TECH_INST_BG_COLOR_WARNING='#B44917'
TECH_INST_BG_COLOR_REWEIGH='#D623FF'
TECH_INST_BG_COLOR_WEIGH='#D6E76D'
TECH_INST_BG_COLOR_WEIGHING='RED'
WEIGHTS_NOTIFICATION_BG_COLOR='YELLOW'
PANEL1_BG_COLOR='#95A94C'
PANEL2_BG_COLOR='#D9E7DC'
ROA='The following Custom Rig Order is available for this user:'
RONA='Custom Rig Order not available for this user\nUse the above box to set a custom rig order specific for this user'
APPNAME='Mass Meister'
APPVERSION='1.3'

def is_greater(x):
    return x>MIN_RAT_WEIGHT_THRES

def mean(numberList):
    if len(numberList) == 0:
        return float('nan')
    floatNums = [x for x in numberList]
    return sum(floatNums)/len(numberList)

def isnotEmpty(x):
    return x!=''

def no_records_found(ratname):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select ratname from %s where ratname=\"%s\"" % (db_mass_table,ratname)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0:
	return False
    else:
	return True
    
def verifyRatMass(ratname,current_mass):
    rat_exists=True
    mass_exists=False
    if no_records_found(ratname):
	rat_exists=False
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select mass,date from %s where ratname=\"%s\" and date=(select max(date) from %s where ratname=\"%s\" and datediff(curdate(),date)>%d)" % (db_mass_table,ratname,db_mass_table,ratname,date_shift)
    cursor.execute(sqlstr)
    results=cursor.fetchall()    
    db.close()
    if len(results)>0:
	mass_exists=True
    #print rat_exists,mass_exists
    if rat_exists and mass_exists:
	prev_mass=results[0][0]
	#print 'Previous Mass:', prev_mass
	#print 'Current Mass:', current_mass
	diff_perc=float(abs(prev_mass-current_mass))/float(prev_mass)*100
	#print 'Error Percentage: ',diff_perc
	if diff_perc>MASS_ERROR_TOLERANCE:
	    #print 'Too much error'	    
	    return False
	else:
	    return True
    else:
	#print "No rat",ratname
	if current_mass in range(MIN_ACCEPTED_MASS,MAX_ACCEPTED_MASS):
	    #print "Mass in range"
	    return False
	else:
	    #print "Mass out of range"
	    return True

def isscaleOccupied():
    data_raw=[]
    ser=serial.Serial(port='COM1',timeout=2)
    stop_timer=time.time()+SCALE_OCCUPIED_TIMER
    while time.time()<stop_timer:
        ser.write("P\r\n")
        a=ser.readline().strip()
        data_raw.append(a)    
    ser.close()
    data_raw_str=''.join(data_raw[0:len(data_raw)])
    data_list = re.findall(r"\d+",data_raw_str)
    data_list_numbers=map(int, data_list)
    mean_value=mean(data_list_numbers)    
    if mean_value>SCALE_OCCUPIED_THRES:
        return True
    else:
        return False

# Smart Retrieval of Least Mass Records: START
def getRatsWithLeastMassRecords():
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    
    sqlstr="select ratname from %s group by ratname having count(mass)<%d" % (db_mass_table,ratmass_records_thres)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0:
	rats_with_least_mass_records=[]
	for row in results:
	    rats_with_least_mass_records.append(row[0])
	if len(rats_with_least_mass_records)>0:
	    return rats_with_least_mass_records
	else:
	    return None
    else:
	return None
# Smart Retrieval of Least Mass Records: STOP

def posttoSQLTable(ratname,mass,tech):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select ratname from %s where ratname=\"%s\" and datediff(curdate(),date)=%d" % (db_mass_table,ratname,date_shift)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0:
	sqlstr="update %s set mass=%d,tech=\"%s\" where ratname=\"%s\" and datediff(curdate(),date)=%d" % (db_mass_table,mass,tech,ratname,date_shift)
    else:
	sqlstr="insert into %s (ratname,mass,tech,date) values (\"%s\",%d,\"%s\",curdate()-%d)" % (db_mass_table,ratname,mass,tech,date_shift)    
    try:
	cursor.execute(sqlstr)
	db.commit()
    except:
	db.rollback()
    db.close()
    
def postRigOrdertoSQLTable(experimenter,rig_order):    
    rig_order=','.join(map(str,rig_order))
    rig_order_enc=base64.b64encode(rig_order)
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="update %s set custom_rig_order=\"%s\" where experimenter=\"%s\"" % (db_contacts_table,rig_order_enc,experimenter)
    try:
	cursor.execute(sqlstr)
	db.commit()
    except:
	db.rollback()
    db.close()
    
def ExpHasCustomRigOrder(experimenter):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select custom_rig_order from %s where experimenter=\"%s\"" % (db_contacts_table,experimenter)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0 and results[0][0]!=None and results[0][0]!='':
	return True
    else:
	return False
    db.close()
    
def getExpCustomRigOrderString(experimenter):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select custom_rig_order from %s where experimenter=\"%s\"" % (db_contacts_table,experimenter)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0 and results[0][0]!=None and results[0][0]!='':
	return base64.b64decode(results[0][0])
    else:
	return ''
    db.close()
    
def getSessionRats(experimenter,check_box_flag):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    
    #Get all scheduled rats for the day: START
    sqlstr="select ratname,timeslot from %s where ratname<>\"\" and datediff(curdate(),date)=%d order by ratname" % (db_schedule_table,date_shift)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    ratname_actualTimeslot_dict={}
    for row in results:
	ratname_actualTimeslot_dict[row[0]]=int(row[1])
    #Get all scheduled rats for the day: STOP
    
    #Get all bringup rats: START
    sqlstr="select ratname,bringupat from %s where extant=1 and ratname<>\"\" and bringupat>=%d and bringupat<=%d order by ratname" % (db_rats_table,first_session,last_session)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    ratname_bringupTimeslot_dict={}
    if len(results)>0:
	for row in results:
	    ratname_bringupTimeslot_dict[row[0]]=int(row[1])
    #Get all bringup rats: STOP
    
    #Get all forcedepwater rats: START
    sqlstr="select ratname,forcedepwater from %s where extant=1 and ratname<>\"\" and forcedepwater>=%d and forcedepwater<=%d order by ratname" % (db_rats_table,first_session,last_session)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    ratname_forcedepwaterTimeslot_dict={}
    if len(results)>0:
	for row in results:
	    ratname_forcedepwaterTimeslot_dict[row[0]]=int(row[1])
    #Get all forcedepwater rats: STOP
    
    #Get all extant rats and their cagemates: START
    sqlstr="select ratname,cagemate from %s where extant=1" % (db_rats_table)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    ratname_cagemate_dict={}
    if len(results)>0:
	for row in results:
	    ratname_cagemate_dict[row[0]]=row[1]
    #Get all extant rats and their cagemates: STOP
    
    #Get all recovering rats: START
    sqlstr="select ratname from %s where recovering=1 and extant=1 order by ratname" % (db_rats_table)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    recovering_rats_tuple=[]
    if len(results)>0:
	for row in results:
	    recovering_rats_tuple.append(row[0])
    #Get all recovering rats: STOP
    
    # Fast two-pass Venn Diagram based checking algorithm of actual timeslots, bringup  and forcedepwater timeslots: START
    intersection_1_list=list(set(ratname_actualTimeslot_dict.keys()) & set(ratname_forcedepwaterTimeslot_dict.keys()))
    all_ratnames_valid_timeslots_dict_1=ratname_actualTimeslot_dict
    for ratname in intersection_1_list:
	if ratname_actualTimeslot_dict[ratname]>ratname_forcedepwaterTimeslot_dict[ratname]:
	    all_ratnames_valid_timeslots_dict_1[ratname]=ratname_forcedepwaterTimeslot_dict[ratname]
    
    rem_ratnames_in_forcedepwaterTimeslot=list(set(ratname_forcedepwaterTimeslot_dict.keys())-set(intersection_1_list))
    if len(rem_ratnames_in_forcedepwaterTimeslot)>0:
	for ratname in rem_ratnames_in_forcedepwaterTimeslot:
	    all_ratnames_valid_timeslots_dict_1[ratname]=ratname_forcedepwaterTimeslot_dict[ratname]
    
    all_ratnames_valid_timeslots_dict=all_ratnames_valid_timeslots_dict_1
    operating_date=datetime.date.today()-datetime.timedelta(date_shift)
    weekday_num=operating_date.isoweekday()

    if weekday_num>0 and weekday_num<6:
	intersection_2_list=list(set(all_ratnames_valid_timeslots_dict_1.keys()) & set(ratname_bringupTimeslot_dict.keys()))
	for ratname in intersection_2_list:
	    if all_ratnames_valid_timeslots_dict_1[ratname]>ratname_bringupTimeslot_dict[ratname]:
		all_ratnames_valid_timeslots_dict[ratname]=ratname_bringupTimeslot_dict[ratname]
	rem_ratnames_in_bringupTimeslot=list(set(ratname_bringupTimeslot_dict.keys())-set(intersection_2_list))
	if len(rem_ratnames_in_bringupTimeslot)>0:
	    for ratname in rem_ratnames_in_bringupTimeslot:
		if ratname in recovering_rats_tuple:
		    all_ratnames_valid_timeslots_dict[ratname]=ratname_bringupTimeslot_dict[ratname]
    # Fast two-pass Venn Diagram based checking algorithm of actual timeslots, bringup  and forcedepwater timeslots: STOP

    #Reassign timeslots based on mutual comparison between cagemates: START
    for current_rat in all_ratnames_valid_timeslots_dict.keys():
	current_rat_cagemate=ratname_cagemate_dict[current_rat]
	if current_rat_cagemate!='':
	    if current_rat_cagemate in all_ratnames_valid_timeslots_dict.keys():
		if all_ratnames_valid_timeslots_dict[current_rat_cagemate]>all_ratnames_valid_timeslots_dict[current_rat]:
		    all_ratnames_valid_timeslots_dict[current_rat_cagemate]=all_ratnames_valid_timeslots_dict[current_rat]
	    else:
		all_ratnames_valid_timeslots_dict[current_rat_cagemate]=all_ratnames_valid_timeslots_dict[current_rat]
    #Reassign timeslots based on mutual comparison between cagemates: STOP
    
    #Hash-based allocation of the rats according to sessions: START
    ratnames=[[],[],[],[],[],[],[],[],[]]
    for current_rat in all_ratnames_valid_timeslots_dict.keys():
	ratnames[all_ratnames_valid_timeslots_dict[current_rat]].append(current_rat)
    #Hash-based allocation of the rats according to sessions: STOP
    
    # Get the remaining recovering rats and all rats: START
    if len(recovering_rats_tuple)>0:
	for ratname in recovering_rats_tuple:
	    if not bool(ratname in all_ratnames_valid_timeslots_dict.keys()):
		ratnames[7].append(ratname.upper())

    sqlstr="select ratname from %s where extant=1 order by ratname" % (db_rats_table)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    if len(results)>0:
	for row in results:	    
	    ratnames[8].append(row[0].upper())
    # Get the remaining recovering rats and all rats: STOP
    
    custom_flag=0
    if ExpHasCustomRigOrder(experimenter) and check_box_flag==1:
	custom_flag=1
	rig_order_dec=getExpCustomRigOrderString(experimenter)
	rig_order=rig_order_dec.split(",")
	rig_order=[int(i) for i in rig_order]
    
    # Re-shuffle ratnames according to a specific custom rig order
    if custom_flag==1:
	for i in range(1,7):
	    sqlstr="select rig,ratname from %s where ratname<>\"\" and datediff(curdate(),date)=%d and timeslot=%d" % (db_schedule_table,date_shift,i)
	    cursor.execute(sqlstr)
	    results=cursor.fetchall()	
	    if len(results)>0:
		rig_ratname_list_of_tuples=[]
		for row in results:
		    cur_rat_info=[]
		    cur_rat_info.append(int(row[0]))
		    cur_rat_info.append(row[1])
		    rig_ratname_list_of_tuples.append(tuple(cur_rat_info))
		rig_ratname_dict=dict(rig_ratname_list_of_tuples)
		
		rig_ordered_rats=[rig_ratname_dict[k] for k in rig_order if k in rig_ratname_dict.keys()]
		rem_rats=list(set(ratnames[i])-set(rig_ordered_rats))
		del ratnames[i][:]
		ratnames[i]=rig_ordered_rats
		for k in rem_rats:
		    ratnames[i].append(k)
    else:
	for i in range(1,7):
	    temp=ratnames[i]
	    temp.sort()
	    ratnames[i]=temp
    db.close()
    
    return ratnames
	
def getCategoryDictionary(ratnames):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="select ratname,mass from %s where ratname<>\"\" and mass<>\"\" and mass is not null and datediff(curdate(),date)=%d order by ratname" % (db_mass_table,date_shift)
    cursor.execute(sqlstr)
    results=cursor.fetchall()
    db.close()
    ratname_mass_list=[]
    i=0
    for row in results:
	cur_rat_info=[]
	cur_rat_info.append(row[0])
	cur_rat_info.append(row[1])
	ratname_mass_list.append(tuple(cur_rat_info))
	i=i+1
	
    ratname_mass_dict =dict(ratname_mass_list)    
	
    category_rats_dict=dict([(x, None) for x in ratnames])
    
    for item in ratname_mass_dict.keys():
	if item in category_rats_dict.keys():
	    category_rats_dict[item]=ratname_mass_dict[item]    
    
    return category_rats_dict

def resetMass(ratname):
    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
    cursor=db.cursor()
    sqlstr="delete from %s where ratname=\"%s\" and datediff(curdate(),date)=%d" % (db_mass_table,ratname,date_shift)
    try:
	cursor.execute(sqlstr)
	db.commit()
    except:
	db.rollback()
    db.close()

def getValidTechsandInitials():
    try:
	    db=MySQLdb.connect(db_server,db_username,db_password,db_name)
	    cursor=db.cursor()
	    sqlstr="select experimenter,initials from %s where (tech_morning=1 or tech_afternoon=1 or tag_letter<>\"\") and is_alumni=0 order by experimenter" % (db_contacts_table)
	    cursor.execute(sqlstr)
	    results=cursor.fetchall()
	    db.close()
	    i=0
	    experimenter=[]
	    initials=[]
	    for row in results:		
		    experimenter.insert(i,row[0])
		    initials.insert(i,row[1])			   
		    i=i+1	    
	    return (len(results),experimenter,initials)
    except:
	    print "Error: Fetching Failed from %s" % (db_contacts_table)

class myFrame(wx.Frame):
    def __init__(self, parent, id):
	wx.Frame.__init__(self,parent,id,'%s v%s' % (APPNAME,APPVERSION),size=(MAIN_WIDTH,MAIN_HEIGHT),style=wx.MINIMIZE_BOX | wx.SYSTEM_MENU | wx.CAPTION | wx.CLOSE_BOX | wx.CLIP_CHILDREN)	
	self.InitUI()
        
    def InitUI(self):	
	icon1 = wx.Icon('icons/convertall.ico',wx.BITMAP_TYPE_ICO)
	self.SetIcon(icon1)
	heading_font = wx.Font(22, wx.ROMAN, wx.NORMAL, wx.BOLD)
	about_button_font = wx.Font(15, wx.ROMAN, wx.NORMAL, wx.BOLD)

	self.mainVbox=wx.BoxSizer(wx.VERTICAL)
	self.statusbar=self.CreateStatusBar(4)
	self.statusbar.SetStatusWidths([200,280,240,370])
	
	self.subPanel1=wx.Panel(self, -1, size=(MAIN_WIDTH,PANEL1_HEIGHT))
	self.subPanel1.SetBackgroundColour(PANEL1_BG_COLOR)	
	self.subPanel1.SetForegroundColour("black")
	hbox=wx.BoxSizer(wx.HORIZONTAL)
	heading=wx.StaticText(self.subPanel1, -1, APPNAME)
	heading.SetFont(heading_font)
	self.subPanel1.about_button=wx.Button(self.subPanel1,ID_ABOUT_BUTTON,label='About')
	self.subPanel1.about_button.SetFont(about_button_font)
	self.subPanel1.about_button.SetBackgroundColour(ABOUT_BUTTON_BG_COLOR)
	hbox.Add(heading,proportion=2)
	hbox.Add(self.subPanel1.about_button,proportion=0,flag=wx.ALIGN_RIGHT|wx.EXPAND)
	self.subPanel1.SetSizer(hbox)	
	
	self.subPanel2=wx.Panel(self, -1)
	self.subPanel2_font=wx.Font(12, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.subPanel2.SetFont(self.subPanel2_font)
	self.subPanel2.SetBackgroundColour(PANEL2_BG_COLOR)
	
	self.panel2hbox=wx.BoxSizer(wx.HORIZONTAL)
	self.panel2vbox0=wx.BoxSizer(wx.VERTICAL)
	self.panel2vbox1=wx.BoxSizer(wx.VERTICAL)
	self.panel2vbox2=wx.BoxSizer(wx.VERTICAL)
	
	(self.total_experimenters,self.experimenters,self.initials)=getValidTechsandInitials()
	self.tech_list=[self.experimenters[i]+' ('+self.initials[i]+')' for i in range(self.total_experimenters)]
	self.panel2radioBox1 = wx.RadioBox(self.subPanel2, id=ID_RADIOBOX, label='User', size=(-1,-1), choices = self.tech_list, majorDimension=1, style=wx.RA_SPECIFY_COLS)
	self.panel2radioBox1_font= wx.Font(12, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.panel2radioBox1.SetFont(self.panel2radioBox1_font)
	radioidx=self.panel2radioBox1.GetSelection()
	self.statusbar.SetStatusText(self.experimenters[radioidx],0)
	
	operating_date=datetime.date.today()-datetime.timedelta(date_shift)
	if date_shift>0:
	    operating_date_formatted='Operating Date: %s' % (operating_date.strftime("%Y-%m-%d"))
	else:
	    operating_date_formatted=''
	self.subPanel2.date_txt=wx.StaticText(self.subPanel2,-1,wordwrap(operating_date_formatted,120, wx.ClientDC(self)))	
	
	cust_sett_mask_field=['##']*30
	cust_sett_mask=','.join(cust_sett_mask_field[0:len(cust_sett_mask_field)])
	cust_sett_textctrl_font=wx.Font(8, wx.ROMAN, wx.NORMAL, wx.BOLD)
	cust_sett_indicator_font=wx.Font(10, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.subPanel2.cust_sett_checkbox=wx.CheckBox(self.subPanel2, -1, 'Use Custom Rig Order')
	self.subPanel2.cust_sett_textctrl=wx.lib.masked.TextCtrl(self.subPanel2,ID_CUST_SETT_MASKED_TEXTCTRL,mask=cust_sett_mask,size=(200,-1))
	self.subPanel2.cust_sett_textctrl.SetFont(cust_sett_textctrl_font)
	self.subPanel2.cust_sett_set_button=wx.Button(self.subPanel2,ID_CUST_SETT_SET_BUTTON,label='Set')
	self.subPanel2.cust_sett_indicator=wx.StaticText(self.subPanel2,-1)
	self.subPanel2.cust_sett_indicator.SetFont(cust_sett_indicator_font)
	if ExpHasCustomRigOrder(self.experimenters[radioidx]):
	    self.subPanel2.cust_sett_checkbox.SetValue(True)	    
	    indicator_string='%s\n%s' %(ROA,getExpCustomRigOrderString(self.experimenters[radioidx]))
	    wrapped_indicator_string=wordwrap(indicator_string,RIG_ORDER_WORD_WRAP, wx.ClientDC(self))
	    self.subPanel2.cust_sett_indicator.SetLabel('%s' %(wrapped_indicator_string))
	else:
	    self.subPanel2.cust_sett_checkbox.SetValue(False)
	    self.subPanel2.cust_sett_indicator.SetLabel(wordwrap(RONA,RIG_ORDER_WORD_WRAP, wx.ClientDC(self)))
	
	self.subPanel2.cust_sett_gbsizer=wx.GridBagSizer(1,1)
	self.subPanel2.cust_sett_gbsizer.Add(self.subPanel2.cust_sett_checkbox,pos=(0,0),flag=wx.ALL,border=1)
	self.subPanel2.cust_sett_gbsizer.Add(self.subPanel2.cust_sett_textctrl,pos=(1,0),flag=wx.TOP,border=3)
	self.subPanel2.cust_sett_gbsizer.Add(self.subPanel2.cust_sett_set_button,pos=(1,1),flag=wx.LEFT|wx.BOTTOM,border=2)
	self.subPanel2.cust_sett_gbsizer.Add(self.subPanel2.cust_sett_indicator,pos=(2,0),span=(4,2),flag=wx.ALL,border=1)
	
	self.subPanel2.cust_sett_StaticBox=wx.StaticBox(self.subPanel2,-1,'Custom Rig Order')
        self.subPanel2.cust_sett_StaticBoxSizer=wx.StaticBoxSizer(self.subPanel2.cust_sett_StaticBox)
        self.subPanel2.cust_sett_StaticBoxSizer.Add(self.subPanel2.cust_sett_gbsizer,1,flag=wx.EXPAND)
	
	self.sessions_list=['None','Session -  1','Session -  2','Session -  3','Session -  4','Session -  5','Session -  6','Recovering','All']
	self.subPanel2.sessions=wx.ListBox(parent=self.subPanel2, id=ID_SESSIONS_BOX, choices=self.sessions_list, style=0, size=(220,-1))
	self.subPanel2.sessions.SetBackgroundColour(wx.Colour(255, 255, 128))
	self.subPanel2.sessions.SetSelection(0)
	self.statusbar.SetStatusText(self.sessions_list[0],1)
	panel2StaticBox1=wx.StaticBox(self.subPanel2, -1,'Category')
	panel2StaticBoxSizer1=wx.StaticBoxSizer(panel2StaticBox1, wx.HORIZONTAL)
	panel2StaticBoxSizer1.Add(self.subPanel2.sessions,flag=wx.TOP|wx.LEFT|wx.RIGHT,border=10)
	
	self.subPanel2.rat_search_txt=wx.StaticText(self.subPanel2,-1,'Rat')
        self.subPanel2.rat_search_txtctrl=wx.lib.masked.TextCtrl(self.subPanel2,ID_MASKED_RAT_TEXTCTRL,mask='C###',size=(50,-1))
        self.subPanel2.rat_search_button=wx.Button(self.subPanel2,ID_RAT_SEARCH_BUTTON,label='Search')
        self.subPanel2.rat_clear_button=wx.Button(self.subPanel2,ID_RAT_CLEAR_BUTTON,label='Clear')
        
        self.subPanel2.mass_txt=wx.StaticText(self.subPanel2,-1,'Mass')
        self.subPanel2.mass_txtctrl=wx.lib.masked.TextCtrl(self.subPanel2,ID_MASKED_MASS_TEXTCTRL,mask='###',size=(40,-1))
        self.subPanel2.mass_set_button=wx.Button(self.subPanel2,ID_MASS_SET_BUTTON,label='Set')
        self.subPanel2.mass_reset_button=wx.Button(self.subPanel2,ID_MASS_RESET_BUTTON,label='Reset')
        
        self.subPanel2.gbsizer=wx.GridBagSizer(2,2)
        self.subPanel2.gbsizer.Add(self.subPanel2.rat_search_txt,pos=(0,0),flag=wx.ALL,border=8)
        self.subPanel2.gbsizer.Add(self.subPanel2.mass_txt,pos=(1,0),flag=wx.ALL,border=8)        
        self.subPanel2.gbsizer.Add(self.subPanel2.rat_search_txtctrl,pos=(0,1),flag=wx.TOP|wx.RIGHT,border=5)
        self.subPanel2.gbsizer.Add(self.subPanel2.mass_txtctrl,pos=(1,1),flag=wx.TOP|wx.RIGHT,border=5)        
        self.subPanel2.gbsizer.Add(self.subPanel2.rat_search_button,pos=(0,2),flag=wx.ALL,border=3)
        self.subPanel2.gbsizer.Add(self.subPanel2.mass_set_button,pos=(1,2),flag=wx.ALL,border=3)        
        self.subPanel2.gbsizer.Add(self.subPanel2.rat_clear_button,pos=(0,3),flag=wx.ALL,border=3)
        self.subPanel2.gbsizer.Add(self.subPanel2.mass_reset_button,pos=(1,3),flag=wx.ALL,border=3)
        
        self.subPanel2.seStaticBox=wx.StaticBox(self.subPanel2,-1,'Search and Set')
        self.subPanel2.seStaticBoxSizer=wx.StaticBoxSizer(self.subPanel2.seStaticBox)
        self.subPanel2.seStaticBoxSizer.Add(self.subPanel2.gbsizer,1,flag=wx.EXPAND)
	
	self.subPanel2.categorylist=wx.ListCtrl(self.subPanel2,ID_LISTCTRL,style=wx.LC_REPORT)
	self.categorylist_font= wx.Font(12, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.subPanel2.categorylist.SetFont(self.categorylist_font)
	self.subPanel2.categorylist.InsertColumn(0, 'Rat',width=60)
        self.subPanel2.categorylist.InsertColumn(1, 'Mass',width=60)
	self.subPanel2.categorylist.InsertColumn(2, 'Comments',width=90)
	self.subPanel2.categorylist.width= self.subPanel2.categorylist.GetColumnWidth(0)+self.subPanel2.categorylist.GetColumnWidth(1)+self.subPanel2.categorylist.GetColumnWidth(2)+25
        self.subPanel2.categorylist.SetInitialSize((self.subPanel2.categorylist.width, -1))
	panel2StaticBox2=wx.StaticBox(self.subPanel2, -1,'Rats')
	panel2StaticBoxSizer2=wx.StaticBoxSizer(panel2StaticBox2, wx.VERTICAL)
	panel2StaticBoxSizer2.Add(self.subPanel2.categorylist,1,flag=wx.ALL|wx.EXPAND,border=10)
	
	panel2StaticBox3=wx.StaticBox(self.subPanel2, -1,'Weigh the rats')
	panel2StaticBoxSizer3=wx.StaticBoxSizer(panel2StaticBox3, wx.HORIZONTAL)
	self.button_font= wx.Font(15, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.subPanel2.startbutton=wx.Button(self.subPanel2,ID_START_BUTTON,'Start Weighing',size=(250,-1))
	self.subPanel2.stopbutton=wx.Button(self.subPanel2,ID_STOP_BUTTON,'Stop Weighing',size=(250,-1))
	self.subPanel2.startbutton.SetFont(self.button_font)
	self.subPanel2.stopbutton.SetFont(self.button_font)
	self.subPanel2.startbutton.Enable(False)
	self.subPanel2.stopbutton.Enable(False)	
	self.tech_instructions_string="\nTECH\nINSTRUCTIONS\n"
	self.tech_instructions_font = wx.Font(25, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.tech_instructions_special_font = wx.Font(12, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.weights_notification_font = wx.Font(20, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.reweigh_notification_font= wx.Font(13, wx.ROMAN, wx.NORMAL, wx.BOLD)
	self.subPanel2.tech_instructions_special=wx.StaticText(self.subPanel2, -1, '',style=wx.ALIGN_CENTER|wx.ALIGN_CENTER_HORIZONTAL)
	self.subPanel2.tech_instructions_special.SetFont(self.tech_instructions_special_font)
	self.subPanel2.tech_instructions=wx.StaticText(self.subPanel2, -1, self.tech_instructions_string,style=wx.ALIGN_CENTER|wx.ST_NO_AUTORESIZE)
	self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_NORMAL)
	self.subPanel2.tech_instructions.SetFont(self.tech_instructions_font)
	self.subPanel2.weights_notification=wx.TextCtrl(self.subPanel2,style=wx.ALIGN_CENTER_HORIZONTAL|wx.TE_READONLY)
	self.subPanel2.weights_notification.SetFont(self.weights_notification_font)
	self.subPanel2.weights_notification.SetBackgroundColour(WEIGHTS_NOTIFICATION_BG_COLOR)
	self.subPanel2.reweigh_notification=wx.StaticText(self.subPanel2, -1, '',style=wx.ALIGN_CENTER|wx.ALIGN_CENTER_HORIZONTAL)
	self.subPanel2.reweigh_notification.SetFont(self.reweigh_notification_font)
	self.subPanel2.reweigh_notification.SetForegroundColour(REWEIGH_NOTIFICATION_FG_COLOR)
	
	self.panel2vbox0.Add(self.panel2radioBox1,flag=wx.ALIGN_CENTER)
	self.panel2vbox0.Add((0,25),0)	
	self.panel2vbox0.Add(self.subPanel2.date_txt,flag=wx.ALIGN_CENTER)
	
	self.panel2vbox1.Add(panel2StaticBoxSizer1,flag=wx.ALIGN_CENTER)
	self.panel2vbox1.Add((0,15),0)
	self.panel2vbox1.Add(self.subPanel2.seStaticBoxSizer)
	self.panel2vbox1.Add((0,10),0)
	self.panel2vbox1.Add(self.subPanel2.cust_sett_StaticBoxSizer,flag=wx.ALIGN_CENTER|wx.EXPAND)
	
	self.panel2vbox2.Add(self.subPanel2.startbutton)
	self.panel2vbox2.Add((0,15),0)
	self.panel2vbox2.Add(self.subPanel2.stopbutton)
	self.panel2vbox2.Add((0,25),0)
	self.panel2vbox2.Add(self.subPanel2.tech_instructions_special)
	self.panel2vbox2.Add((0,10),0)
	self.panel2vbox2.Add(self.subPanel2.tech_instructions)	
	self.panel2vbox2.Add((0,15),0)
	self.panel2vbox2.Add(self.subPanel2.weights_notification,flag=wx.ALIGN_CENTER)
	self.panel2vbox2.Add((0,25),0)
	self.panel2vbox2.Add(self.subPanel2.reweigh_notification)
	panel2StaticBoxSizer3.Add(self.panel2vbox2,flag=wx.TOP|wx.LEFT|wx.RIGHT|wx.EXPAND,border=10)	
	
	self.panel2hbox.Add((10,0),0)
	self.panel2hbox.Add(self.panel2vbox0,flag=wx.ALL,border=10)
	self.panel2hbox.Add(self.panel2vbox1,flag=wx.ALL,border=10)
	self.panel2hbox.Add(panel2StaticBoxSizer2,0,flag=wx.EXPAND|wx.ALL,border=10)
	self.panel2hbox.Add(panel2StaticBoxSizer3,1,flag=wx.EXPAND|wx.ALL,border=10)
	self.panel2hbox.Add((10,0),0)
	
	#Set sizer for subpanel2
	self.subPanel2.SetSizer(self.panel2hbox)
	
	#Set working status to 0
	self.working=0	
	
	#Set Events
	self.subPanel2.Bind(wx.EVT_RADIOBOX,self.radioboxSelect,id=ID_RADIOBOX)
	self.subPanel2.Bind(wx.EVT_LISTBOX,self.sessionsboxSelect,id=ID_SESSIONS_BOX)
	self.subPanel2.Bind(wx.EVT_LIST_ITEM_SELECTED,self.categoryListSelected,id=ID_LISTCTRL)
	self.subPanel2.Bind(wx.EVT_LIST_ITEM_DESELECTED,self.categoryListDeSelected,id=ID_LISTCTRL)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reactToStartButton, id=ID_START_BUTTON)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reactToStopButton, id=ID_STOP_BUTTON)	
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reacttoRatSearchButton, id=ID_RAT_SEARCH_BUTTON)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reacttoRatClearButton, id=ID_RAT_CLEAR_BUTTON)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reacttoMassSetButton, id=ID_MASS_SET_BUTTON)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reacttoMassResetButton, id=ID_MASS_RESET_BUTTON)
	self.subPanel1.Bind(wx.EVT_BUTTON, self.OnAboutBox, id=ID_ABOUT_BUTTON)
	self.subPanel2.Bind(wx.EVT_BUTTON, self.reactToSetRigOrderButton, id=ID_CUST_SETT_SET_BUTTON)	
	
	self.mainVbox.Add(self.subPanel1,proportion=0,flag=wx.BOTTOM | wx.EXPAND |wx.ALIGN_CENTER,border=PANEL1_BORDER)
	self.mainVbox.Add(self.subPanel2,proportion=1,flag=wx.TOP | wx.BOTTOM | wx.EXPAND,border=PANEL2_BORDER)	
	
	self.SetSizer(self.mainVbox)
	self.SetSize((MAIN_WIDTH,MAIN_HEIGHT))
	self.Center()
	self.Show()
	
	self.setsessionboxCompletionStatus()
	self.rats_with_least_mass_records=getRatsWithLeastMassRecords()
    
    def OnAboutBox(self, event):
        description = """\n1. Select your name from the \"User\" Menu before proceeding further.\n
2. It is MANDATORY that you select your name before starting the weighing process.\n
3. Select a session for which you want to weigh the rats from the \"Category\" menu.\n
4. Press \"Start Weighing\" button to start weighing the rats.\n
5. If the rat's weight is hugely deviant from it's normal behavior, a message pops up at the bottom-right corner. Read it carefully and reweigh the rat.\n
6. As long as the \"Start Weighing\" button stays pressed, a message constantly appears just above the \"TECH INSTRUCTIONS\" box which tells you whether all rats belonging to the selected category are weighed or if some are still pending.\n
7. After you are done weighing a particular category of rats, press \"Stop Weighing\" button to re-enable the \"Category\" menu. Then select another category to start weighing again.\n
8. In the yellow box named \"Category\" a particular category will be marked as \"(Complete)\" when all rats belonging to that category are weighed.\n
9. The \"Search and Set\" box will allow you search for a rat and set its mass manually.\n 
10. Use the \"Reset\" button to delete a rat's mass if you set/weighed it by mistake.\n"""

        licence = "All rights to Mass Meister belong to Princeton University and HHMI"

        info = wx.AboutDialogInfo()

        info.SetIcon(wx.Icon('icons/convertall.ico', wx.BITMAP_TYPE_ICO))
        info.SetName(APPNAME)
        info.SetVersion(APPVERSION)
        info.SetDescription(wordwrap(description,750, wx.ClientDC(self)))
        info.SetCopyright('(C) 2011 HHMI/Princeton University')
        info.SetLicence(licence)
        info.AddDeveloper('Praveen Karri')
        
        wx.AboutBox(info)
	
    def reactToSetRigOrderButton(self,event):	
	radioidx=self.panel2radioBox1.GetSelection()
	curr_expr=self.experimenters[radioidx]
	cust_rig_order=str(self.subPanel2.cust_sett_textctrl.GetValue())	
	cust_rig_order=cust_rig_order.split(",")	
	cust_rig_order=[i for i in cust_rig_order if i!='  ']
	cust_rig_order=[int(i) for i in cust_rig_order if int(i)>=RIG_NUMBER_LL and int(i)<=RIG_NUMBER_UL]
	if len(cust_rig_order)>=MIN_RIGS_FOR_CUSTOM_SETTINGS:
	    postRigOrdertoSQLTable(curr_expr,cust_rig_order)
	    wx.MessageBox('Rig Order for %s is set' %(curr_expr), 'Message')
	    self.update_cust_settings_box()
	    self.subPanel2.cust_sett_textctrl.Clear()
	else:
	    wx.MessageBox('Atleast %d rig numbers in the valid range (%d, %d) are required. Rig Order for %s is NOT set.' %(MIN_RIGS_FOR_CUSTOM_SETTINGS,RIG_NUMBER_LL,RIG_NUMBER_UL,curr_expr), 'Message')
	    self.subPanel2.cust_sett_textctrl.Clear()
	
    def update_cust_settings_box(self):
	radioidx=self.panel2radioBox1.GetSelection()
	curr_expr=self.experimenters[radioidx]
	if ExpHasCustomRigOrder(curr_expr):
	    self.subPanel2.cust_sett_checkbox.SetValue(True)
	    indicator_string='%s\n%s' %(ROA,getExpCustomRigOrderString(curr_expr))
	    wrapped_indicator_string=wordwrap(indicator_string,RIG_ORDER_WORD_WRAP, wx.ClientDC(self))
	    self.subPanel2.cust_sett_indicator.SetLabel('%s' %(wrapped_indicator_string))
	else:
	    self.subPanel2.cust_sett_checkbox.SetValue(False)
	    self.subPanel2.cust_sett_indicator.SetLabel(wordwrap(RONA,RIG_ORDER_WORD_WRAP, wx.ClientDC(self)))
    
    def getSelectedTechInitials(self):
	radioidx=self.panel2radioBox1.GetSelection()
	return self.initials[radioidx]
    
    def reacttoMassResetButton(self,event):	
	ratname_in_search_box=self.subPanel2.rat_search_txtctrl.GetValue()
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)	
	if selected_item!=-1:
	    ratname_selected=self.subPanel2.categorylist.GetItem(selected_item,0).GetText()   
	    if ratname_selected==ratname_in_search_box.upper() and not self.subPanel2.mass_txtctrl.IsEmpty():		
		dial=wx.MessageDialog(None, 'Are you sure you want to reset the mass?', 'Question', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)		    
		result=dial.ShowModal()		    
		if result==wx.ID_YES:
		    self.subPanel2.categorylist.SetStringItem(selected_item, 1, '')
		    resetMass(ratname_selected)
		dial.Destroy()		
		self.selectandfocusNextListCtrlItem()
	    else:
		self.subPanel2.mass_txtctrl.Clear()
	else:
	    self.subPanel2.mass_txtctrl.Clear()
	self.setSpecialInstructions()
	
    def reacttoMassSetButton(self,event):	
	ratname_in_search_box=self.subPanel2.rat_search_txtctrl.GetValue()
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)	
	if selected_item!=-1:
	    ratname_selected=self.subPanel2.categorylist.GetItem(selected_item,0).GetText()   
	    if ratname_selected==ratname_in_search_box.upper() and not self.subPanel2.mass_txtctrl.IsEmpty():
		mass_entered=self.subPanel2.mass_txtctrl.GetValue()
		if not verifyRatMass(ratname_selected,int(mass_entered)):
		    dial=wx.MessageDialog(None, 'Mass out of range or high error deviation. Are you sure you want to set this number?', 'Question', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)		    
		    result=dial.ShowModal()		    
		    if result==wx.ID_YES:
			self.subPanel2.categorylist.SetStringItem(selected_item, 1, mass_entered)
			tech=self.getSelectedTechInitials()
			posttoSQLTable(ratname_selected,int(mass_entered),tech)
		    dial.Destroy()
		else:
		    self.subPanel2.categorylist.SetStringItem(selected_item, 1, mass_entered)
		    tech=self.getSelectedTechInitials()
		    posttoSQLTable(ratname_selected,int(mass_entered),tech)
		self.selectandfocusNextListCtrlItem()		
	    else:
		self.subPanel2.mass_txtctrl.Clear()
	else:
	    self.subPanel2.mass_txtctrl.Clear()
	self.setSpecialInstructions()
    
    def reacttoRatClearButton(self,event):
	rat_in_search_box=self.subPanel2.rat_search_txtctrl.GetValue()
	self.subPanel2.rat_search_txtctrl.Clear()
	self.subPanel2.mass_txtctrl.Clear()
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
	if selected_item!=-1:
	    selected_rat=self.subPanel2.categorylist.GetItem(selected_item,0).GetText()
	    if rat_in_search_box==selected_rat:
		self.subPanel2.categorylist.Select(selected_item,False)
    
    def reacttoRatSearchButton(self,event):
	self.subPanel2.mass_txtctrl.Clear()
	ratname_to_search=self.subPanel2.rat_search_txtctrl.GetValue()
	category_index=-1
	for sublist in self.ratnames:
	    if ratname_to_search.upper() in sublist:
		category_index=self.ratnames.index(sublist)
		rat_index=sublist.index(ratname_to_search.upper())
		break
	if category_index>0:
	    if self.working==0:
		self.subPanel2.startbutton.Enable(True)
		self.subPanel2.sessions.SetSelection(category_index)	    
		self.statusbar.SetStatusText(self.subPanel2.sessions.GetString(category_index),1)	    
		self.subPanel2.categorylist.SetBackgroundColour('#87ceeb')	    
		self.loadratsandmasses(category_index)	    
		self.subPanel2.categorylist.Select(rat_index,True)
		self.subPanel2.categorylist.Focus(rat_index)
	    elif self.working==1 and category_index==self.subPanel2.sessions.GetSelection():
		selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
		if selected_item!=-1:
			self.subPanel2.categorylist.Select(selected_item,False)
		self.subPanel2.categorylist.Select(rat_index,True)
		self.subPanel2.categorylist.Focus(rat_index)
	    else:
		self.subPanel2.rat_search_txtctrl.Clear()
	else:
	    self.subPanel2.rat_search_txtctrl.Clear()
    
    def setTechInstructions(self):
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
	if selected_item!=-1:
	    selected_item_rat=self.subPanel2.categorylist.GetItem(selected_item,0).GetText()
	    selected_item_mass=self.subPanel2.categorylist.GetItem(selected_item,1).GetText()
	    if selected_item_mass=='':
		tech_instructions_string="PLACE %s \nON SCALE\nTO WEIGH" % (selected_item_rat)
		bgcolor=TECH_INST_BG_COLOR_WEIGH
	    else:
		tech_instructions_string="PLACE %s \nON SCALE\nTO REWEIGH" % (selected_item_rat)
		bgcolor=TECH_INST_BG_COLOR_REWEIGH
	    if self.subPanel2.tech_instructions.GetLabel()!=tech_instructions_string:
		self.subPanel2.tech_instructions.SetBackgroundColour(bgcolor)
		self.subPanel2.tech_instructions.SetLabel(tech_instructions_string)
	    return True
	else:
	    tech_instructions_string="WARNING: SELECT A RAT \nOR PRESS STOP"
	    if self.subPanel2.tech_instructions.GetLabel()!=tech_instructions_string:
		self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_WARNING)
		self.subPanel2.tech_instructions.SetLabel(tech_instructions_string)
	    return False
    
    def reactToStartButton(self,event):
	self.subPanel2.startbutton.Enable(False)
	self.subPanel2.stopbutton.Enable(True)
	self.subPanel2.sessions.Enable(False)
	self.selectandfocusNextListCtrlItem()	
	to_be_reweighed_list=[]
	
	if not self.working:
	    self.working=1
            self.abort=0
	    self.setSpecialInstructions()
	    loop_stop_time=time.time()+MAX_IDLE_LOOP_RUN_TIME
	    while not self.abort:		
		time.sleep(.01)
		wx.Yield()
		return_value=self.setTechInstructions()		
		if isscaleOccupied() and return_value:		    
		    item_index=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
		    rat_name=self.subPanel2.categorylist.GetItem(item_index,0).GetText()		    
		    self.UnlockUI(False)	    
		    self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_WEIGHING)
		    self.subPanel2.tech_instructions.SetLabel('WEIGHING PLEASE DO NOT REMOVE THE RAT')		    
		    
		    #Weighing Starts		    
		    data_raw=[]
		    ser=serial.Serial(port='COM1',timeout=2)
		    stop_timer=time.time()+WEIGHING_TIMER
		    while time.time()<stop_timer:
			ser.write("P\r\n")
			a=ser.readline().strip()
			cur_data_point=re.findall(r"\d+",a)
			time.sleep(.001)
			self.subPanel2.weights_notification.SetValue('')
			self.subPanel2.weights_notification.Replace(self.subPanel2.weights_notification.GetInsertionPoint(),self.subPanel2.weights_notification.GetLastPosition(),'')
			self.subPanel2.weights_notification.SetValue(cur_data_point[0])
			self.subPanel2.weights_notification.Replace(self.subPanel2.weights_notification.GetInsertionPoint(),self.subPanel2.weights_notification.GetLastPosition(),cur_data_point[0])
			data_raw.append(a)
		    ser.close()
		    data_raw_str=''.join(data_raw[0:len(data_raw)])
		    data_list = re.findall(r"\d+",data_raw_str)
		    data_list_numbers=map(int, data_list)
		    data_list_filtered_numbers=filter(is_greater,data_list_numbers)
		    data_list_considered_numbers=data_list_filtered_numbers[-MINIMUM_SAMPLES:]
		    mean_value=mean(data_list_considered_numbers)		    
		    #Weighing Stops
		    
		    #Aftermath Starts
		    reweigh_flag=0
		    if mean_value>MIN_ACCEPTED_MASS and mean_value<MAX_ACCEPTED_MASS:
			if not verifyRatMass(rat_name,mean_value):
			    if rat_name not in to_be_reweighed_list:				
				to_be_reweighed_list.append(rat_name)
				reweigh_flag=1
				reweigh_label='High Error Deviation noticed\ncompared to previous measurement\nMass Meister suggests\nREWEIGHING %s' % (rat_name)
			    else:
				to_be_reweighed_list.remove(rat_name)
				self.subPanel2.categorylist.SetStringItem(item_index, 1, str(mean_value))
				tech=self.getSelectedTechInitials()
				posttoSQLTable(rat_name,mean_value,tech)
			else:
			    self.subPanel2.categorylist.SetStringItem(item_index, 1, str(mean_value))
			    tech=self.getSelectedTechInitials()
			    posttoSQLTable(rat_name,mean_value,tech)
			self.subPanel2.categorylist.Focus(item_index)
			self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_NORMAL)
			weighing_complete_label='WEIGHING COMPLETE\n%d g\nREMOVE RAT' % (mean_value)
		    elif mean_value<MIN_ACCEPTED_MASS:
			weighing_complete_label='NEGLIGIBLE WEIGHT\nREWEIGH RAT'
		    elif mean_value>MAX_ACCEPTED_MASS:
			weighing_complete_label='TOO HEAVY\nREWEIGH RAT'
		    self.subPanel2.tech_instructions.SetLabel(weighing_complete_label)		    
		    self.subPanel2.weights_notification.SetValue('')
		    self.subPanel2.weights_notification.Replace(self.subPanel2.weights_notification.GetInsertionPoint(),self.subPanel2.weights_notification.GetLastPosition(),'')
		    remove_rat_timer=time.time()+MIN_TIME_TO_REMOVE_RAT
		    while isscaleOccupied():
			time.sleep(.01)			
			if self.abort or time.time()>remove_rat_timer:			    
			    self.abort=1
			    time.sleep(.5)
			    break
		    if reweigh_flag==1:
			self.subPanel2.reweigh_notification.SetLabel(reweigh_label)
		    else:
			self.subPanel2.reweigh_notification.SetLabel('')
		    self.UnlockUI(True)		    
		    self.selectandfocusNextListCtrlItem()
		    self.setSpecialInstructions()
		    #Aftermath Stops
		    
		if self.abort or (time.time()>loop_stop_time and not isscaleOccupied()):
		    self.subPanel2.reweigh_notification.SetLabel('')
		    self.subPanel2.startbutton.Enable(True)
		    self.subPanel2.stopbutton.Enable(False)
		    self.subPanel2.tech_instructions_special.SetLabel('')
		    self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_NORMAL)
		    self.subPanel2.tech_instructions.SetLabel(self.tech_instructions_string)
		    self.subPanel2.sessions.Enable(True)
		    break		
		    
	    self.working = 0
	    
    def UnlockUI(self,lock_parameter):
	self.subPanel2.stopbutton.Enable(lock_parameter)
	self.subPanel2.categorylist.Enable(lock_parameter)
	self.panel2radioBox1.Enable(lock_parameter)
	
	self.subPanel2.rat_search_txtctrl.Enable(lock_parameter)
	self.subPanel2.rat_search_button.Enable(lock_parameter)
	self.subPanel2.rat_clear_button.Enable(lock_parameter)
	
	self.subPanel2.mass_txtctrl.Enable(lock_parameter)
	self.subPanel2.mass_set_button.Enable(lock_parameter)
	self.subPanel2.mass_reset_button.Enable(lock_parameter)
	
    def setSpecialInstructions(self):	
	result=True
	lastfounditem=-1
	while True:
	    index=self.subPanel2.categorylist.GetNextItem(lastfounditem,wx.LIST_NEXT_ALL)
	    if index==-1:
		break
	    else:
		lastfounditem=index
		lastfounditem_mass=self.subPanel2.categorylist.GetItem(lastfounditem,1).GetText()
		if lastfounditem_mass=='':
		    result=False
		    break
	listBoxindex=self.subPanel2.sessions.GetSelection()	
	current_session=self.sessions_list[listBoxindex]
	current_session_list_string=self.subPanel2.sessions.GetString(listBoxindex)
	
	if result:
	    tech_instructions_special="All rats are weighed in this session"
	    fgcolor=TECH_SPECIAL_INST_WEIGHED_FGCOLOR
	    updated_session_list_string='%s          (Complete)' % (current_session)
	else:
	    tech_instructions_special="Some rats are not weighed in this session"
	    fgcolor=TECH_SPECIAL_INST_PENDING_FGCOLOR
	    updated_session_list_string=current_session
	    
	if current_session_list_string!=updated_session_list_string:
	    self.subPanel2.sessions.SetString(listBoxindex,updated_session_list_string)
	    
	if self.working==1:
	    if self.subPanel2.tech_instructions_special.GetLabel()!=tech_instructions_special:
		self.subPanel2.tech_instructions_special.SetForegroundColour(fgcolor)
		self.subPanel2.tech_instructions_special.SetLabel(tech_instructions_special)
	    
    def selectandfocusNextListCtrlItem(self):
	lastfounditem=-1
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
	while True:
	    index=self.subPanel2.categorylist.GetNextItem(lastfounditem,wx.LIST_NEXT_ALL)
	    if index==-1:
		break
	    else:
		lastfounditem=index
		lastfounditem_mass=self.subPanel2.categorylist.GetItem(lastfounditem,1).GetText()
		if lastfounditem_mass=='' and lastfounditem>=selected_item:
		    if selected_item!=-1:
			self.subPanel2.categorylist.Select(selected_item,False)
		    self.subPanel2.categorylist.Select(lastfounditem,True)
		    self.subPanel2.categorylist.Focus(lastfounditem)
		    break
	selected_item=self.subPanel2.categorylist.GetNextItem(-1,wx.LIST_NEXT_ALL,wx.LIST_STATE_SELECTED)
	if selected_item==-1:
	    top_item_index=self.subPanel2.categorylist.GetTopItem()
	    self.subPanel2.categorylist.Select(top_item_index,True)
	    self.subPanel2.categorylist.Focus(top_item_index)
	else:
	    self.subPanel2.categorylist.Select(selected_item,False)
	    self.subPanel2.categorylist.Select(selected_item,True)
	    self.subPanel2.categorylist.Focus(selected_item)

    def reactToStopButton(self,event):
	if self.working:
	    time.sleep(.1)
            self.abort=1
	    self.subPanel2.tech_instructions.SetBackgroundColour(TECH_INST_BG_COLOR_NORMAL)
	    self.subPanel2.tech_instructions.SetLabel(self.tech_instructions_string)
	    self.subPanel2.sessions.Enable(True)	

    def categoryListSelected(self,event):
	selected_row=event.GetIndex()
	self.setStatusBarandSearchBox(selected_row)
    
    def categoryListDeSelected(self,event):
	self.statusbar.SetStatusText('',2)
	self.subPanel2.rat_search_txtctrl.Clear()
	self.subPanel2.mass_txtctrl.Clear()	
    
    def setStatusBarandSearchBox(self,index):
	selected_row_col1=self.subPanel2.categorylist.GetItem(index,0).GetText()
	selected_row_col2=self.subPanel2.categorylist.GetItem(index,1).GetText()
	self.subPanel2.rat_search_txtctrl.SetValue(selected_row_col1)
	self.subPanel2.mass_txtctrl.SetValue(selected_row_col2)
	statusbar_text="Rat: %s                                      Mass: %s" %(selected_row_col1,selected_row_col2)
	if selected_row_col2=='':
	    statusbar_text="Rat: %s                    Mass: Not Weighed yet!!!" %(selected_row_col1)
	self.statusbar.SetStatusText(statusbar_text,2)
    
    def radioboxSelect(self,event):
	self.subPanel2.sessions.Enable(True)
	radioBox=event.GetEventObject()
	radioidx=radioBox.GetSelection()
	self.statusbar.SetStatusText(self.experimenters[radioidx],0)
	self.update_cust_settings_box()
	
    def sessionsboxSelect(self,event):
	self.subPanel2.rat_search_txtctrl.Clear()
	self.subPanel2.mass_txtctrl.Clear()
	listBoxindex=event.GetSelection()
	self.statusbar.SetStatusText(self.sessions_list[listBoxindex],1)
	self.statusbar.SetStatusText('',2)
	if listBoxindex>0:
	    if self.working==0:
		self.subPanel2.startbutton.Enable(True)
	    self.subPanel2.categorylist.SetBackgroundColour('#87ceeb')
	    self.loadratsandmasses(listBoxindex)
	else:
	    self.subPanel2.startbutton.Enable(False)
	    self.subPanel2.categorylist.DeleteAllItems()
	    self.subPanel2.categorylist.SetBackgroundColour('white')
	    
    def setsessionboxCompletionStatus(self):
	sessions_list_completion_array=[]
	radioidx=self.panel2radioBox1.GetSelection()
	ratnames_temp=getSessionRats(self.experimenters[1],0)
	for listBoxindex in range(1,8):
	    current_category_rats=ratnames_temp[listBoxindex]
	    current_category_dict=getCategoryDictionary(current_category_rats)
	    current_category_dict_length=len(current_category_dict)
	    current_category_subdict=dict((k, v) for k, v in current_category_dict.iteritems() if v!=None)
	    current_category_subdict_length=len(current_category_subdict)
	    current_session=self.sessions_list[listBoxindex]
	    current_session_list_string=self.subPanel2.sessions.GetString(listBoxindex)
	    if not current_category_subdict_length<current_category_dict_length:
		updated_session_list_string='%s          (Complete)' % (current_session)		
	    else:
		updated_session_list_string=current_session
	    if current_session_list_string!=updated_session_list_string:
		self.subPanel2.sessions.SetString(listBoxindex,updated_session_list_string)
		self.subPanel2.sessions.SetItemBackgroundColour(listBoxindex,wx.RED)
	    current_category_dict.clear()
	    current_category_subdict.clear()

    def loadratsandmasses(self,listBoxindex):
	radioidx=self.panel2radioBox1.GetSelection()
	if self.subPanel2.cust_sett_checkbox.IsChecked():
	    check_box_flag=1
	else:
	    check_box_flag=0
	self.ratnames=getSessionRats(self.experimenters[radioidx],check_box_flag)
	current_category_rats=self.ratnames[listBoxindex]
	current_category_dict=getCategoryDictionary(current_category_rats)
	self.subPanel2.categorylist.DeleteAllItems()
	j=0
	for i in current_category_rats:
	    index=self.subPanel2.categorylist.InsertStringItem(j, i)
	    if current_category_dict[i]!=None:
		self.subPanel2.categorylist.SetStringItem(index, 1, str(current_category_dict[i]))
	    if self.rats_with_least_mass_records!=None:
		if i in self.rats_with_least_mass_records or no_records_found(i):
		    self.subPanel2.categorylist.SetStringItem(index, 2, 'New Rat')
	    j=j+1

if __name__=='__main__':
	app=wx.App()
	myFrame(parent=None,id=-1)
	app.MainLoop()