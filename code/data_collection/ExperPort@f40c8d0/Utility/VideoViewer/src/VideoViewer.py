#!/usr/bin/env /usr/local/bin/python

#Video Viewer Python App | Copyright Praveen | HHMI/Princeton University | May 2011

import wx
import wx.lib.masked
import base64
import sys,os
import random
from subprocess import Popen
import MySQLdb
import getpass
import urllib,re,socket

def isDarwin():
    return sys.platform=='darwin'

def isWindows():
    return os.name=='nt'

if isWindows():
    from _winreg import *
    import win32con, win32api

#Database Access
db_server="sonnabend.princeton.edu"
db_username=base64.b64decode("cm9vdA==")
db_password=base64.b64decode("ZEA3YTYwZA==")
db_name="ratinfo"
db_contacts_table="contacts"

#Samba Access
smb_username="brodylab"
smb_password=base64.b64decode("bTNtMHJ5JiQ=")
sonnabend_addr=base64.b64decode("MTI4LjExMi4xNjAuMTQx")
brodyfs_addr=base64.b64decode("MTI4LjExMi4xNjEuMTUw")
if isDarwin():
    sonnabend_share='%s/Sonnabend_Samba_Share' %(os.path.expanduser("~"))
    brodyfs_share='%s/Brodyfs_Samba_Share' %(os.path.expanduser("~"))

ID_MASKED_TEXTCTRL_1=1
ID_MASKED_TEXTCTRL_2=2
ID_BUTTON=3
PANEL1_BG_COLOR='#CEC1FF'

if isWindows():
    last_experimenter_selected='last_experimenter_selected'
if isDarwin():
    last_experimenter_selected='.last_experimenter_selected'
	
def getPublicIP():
    hosts = """http://checkmyip.com/
http://www.ipchicken.com/
http://adresseip.com/
http://www.aboutmyip.com/
http://monip.net/
http://ipcheck.rehbein.net/
http://www.raffar.com/checkip/
http://www.glowhost.com/support/your.ip.php
http://www.tanziars.com/
http://www.naumann-net.org/
http://www.lawrencegoetz.com/programs/ipinfo/
http://www.mantacore.se/whoami/
http://www.edpsciences.org/htbin/ipaddress
http://mwburden.com/cgi-bin/getipaddr
http://checkrealip.com/""".strip().split("\n")
    
    ip = urllib.urlopen('http://www.whatismyip.com/automation/n09230945.asp').read()
    try:
        socket.inet_aton(ip)
        return ip 
    except socket.error:
        ip_regex = re.compile("(([0-9]{1,3}\.){3}[0-9]{1,3})")
        for host in hosts:            
            try:
                results = ip_regex.findall(urllib.urlopen(host).read())
                if results: return results[0][0]
            except:
                pass
        return None

def onPrincetonDomain():
    ip=getPublicIP()
    if ip!=None:
        [hostname,aliaslist,ipaddrlist]=socket.gethostbyaddr(ip)
        if 'princeton.edu' in hostname.lower():
            return True
        else:
            return False
    else:
        return False
    

def getVLCPath():
    vlc_flag=1
    aReg=ConnectRegistry(None,HKEY_CLASSES_ROOT)
    try:
        akey_flag=1
        aKey = OpenKey(aReg, r"Applications\vlc.exe\shell\Open\command")
    except WindowsError:    
        akey_flag=0
    try:
        bkey_flag=1
        bKey = OpenKey(aReg, r"Applications\vlc.exe\shell\Play\command")
    except WindowsError:    
        bkey_flag=0
        
    if akey_flag==1:
        CloseKey(aKey)
        key=OpenKey(aReg, r"Applications\vlc.exe\shell\Open\command")
    elif bkey_flag==1:
        CloseKey(bKey)
        key=OpenKey(aReg, r"Applications\vlc.exe\shell\Play\command")
    else:
        vlc_flag=0
    
    if vlc_flag==1:
        for i in range(1):
            try:
                n,v,t=EnumValue(key,i)
            except EnvironmentError:            
                break
	CloseKey(key)
        vlc_path=str(v[0:v.index("exe")+3])
	vlc_path=[i for i in vlc_path if i!='\"']
	vlc_path=''.join(vlc_path[0:len(vlc_path)])	
        if os.path.exists(vlc_path):            
            return vlc_path
        else:
            return None
        
    else:
        return None

def getExperimenters():    
    try:
	db=MySQLdb.connect(db_server,db_username,db_password,db_name)
	cursor=db.cursor()
	sqlstr="select experimenter from %s where tech_morning=0 and tech_afternoon=0 and tech_computer=0 or lab_manager=1 order by experimenter" % (db_contacts_table)
	cursor.execute(sqlstr)
	results=cursor.fetchall()
	db.close()
	i=0
	experimenter=[]	
	for row in results:		
		experimenter.insert(i,row[0].capitalize())
		i=i+1	    
	return experimenter
    except:
	print "Error: Fetching Failed from %s" % (db_contacts_table)
	
def getDefaultExperimenter(experimenters):
    expr_cap=[i.capitalize() for i in experimenters]
    cur_user=getpass.getuser().split(" ")
    cur_user_cap=[i.capitalize() for i in cur_user]    

    if len(list(set(cur_user_cap) & set(expr_cap)))!=0:	
        for i in cur_user_cap:
            if i in expr_cap:
                exp_index=expr_cap.index(i)
                break
        return exp_index
    else:
	if os.path.exists(last_experimenter_selected):            
	    if isWindows():
		win32api.SetFileAttributes(last_experimenter_selected,win32con.FILE_ATTRIBUTE_READONLY)
		os.system('attrib +h %s' %(last_experimenter_selected))
            if isDarwin():
		os.system('chmod 400 %s' %(last_experimenter_selected))
	    f=open(last_experimenter_selected,'r')
	    line = f.readline()
	    f.close()
	    if not line or line not in experimenters:
		dummmy=1
	    else:
		exp_index=expr_cap.index(line)
		return exp_index    
		
    return random.randint(0,len(experimenters)-1)
	
def mountSambaServer():    
    if isWindows():
	transformed_ip='''\\%s''' %(sonnabend_addr)
	comd='net use S: \%s\\video /u:\"%s\" \"%s\"' % (transformed_ip,smb_username,smb_password)
	os.system(comd)
	transformed_ip='''\\%s''' %(brodyfs_addr)
	comd='net use T: \%s\\Video /u:\"%s\" \"%s\"' % (transformed_ip,smb_username,smb_password)
	os.system(comd)
    if isDarwin():
	if not os.path.exists(sonnabend_share):
	    mac_commd='mkdir %s' %(sonnabend_share)
	    os.system(mac_commd)
	if not os.path.ismount(sonnabend_share):
	    mac_commd='''mount -t smbfs //%s:\"%s\"@%s/video %s''' %(smb_username,smb_password,sonnabend_addr,sonnabend_share)
	    os.system(mac_commd)
	if not os.path.exists(brodyfs_share):
	    mac_commd='mkdir %s' %(brodyfs_share)
	    os.system(mac_commd)
	if not os.path.ismount(brodyfs_share):
	    mac_commd='''mount -t smbfs //%s:\"%s\"@%s/video %s''' %(smb_username,smb_password,brodyfs_addr,brodyfs_share)
	    os.system(mac_commd)
	
def unmountSambaServer():
    if isWindows():
	comd='net use S: /delete'
	os.system(comd)
	comd='net use T: /delete'
	os.system(comd)
    if isDarwin():
	if os.path.ismount(sonnabend_share):
	    mac_commd='umount -f %s' %(sonnabend_share)
	    os.system(mac_commd)
	if os.path.exists(sonnabend_share):
	    mac_commd='rm -rf %s' %(sonnabend_share)
	    os.system(mac_commd)
	if os.path.ismount(brodyfs_share):
	    mac_commd='umount -f %s' %(brodyfs_share)
	    os.system(mac_commd)
	if os.path.exists(brodyfs_share):
	    mac_commd='rm -rf %s' %(brodyfs_share)
	    os.system(mac_commd)
    
def PlayVideo(exp,rat,exp_date):
    if isWindows():
	video_file_0='S:\\%s\%s\%s_%s_%sa.mp4' % (exp,rat,exp,rat,exp_date)
	video_file_1='S:\\%s\%s\%s_%s_%sa.avi' % (exp,rat,exp,rat,exp_date)
	video_file_2='T:\\%s\%s\%s_%s_%sa.mp4' % (exp,rat,exp,rat,exp_date)
	video_file_3='T:\\%s\%s\%s_%s_%sa.avi' % (exp,rat,exp,rat,exp_date)
	
	video_file_4='S:\\%s\%s\%s_%s_%sb.mp4' % (exp,rat,exp,rat,exp_date)
	video_file_5='S:\\%s\%s\%s_%s_%sb.avi' % (exp,rat,exp,rat,exp_date)
	video_file_6='T:\\%s\%s\%s_%s_%sb.mp4' % (exp,rat,exp,rat,exp_date)
	video_file_7='T:\\%s\%s\%s_%s_%sb.avi' % (exp,rat,exp,rat,exp_date)	
	
	if os.path.isfile(video_file_0):
	    vid1_path=video_file_0
	elif os.path.isfile(video_file_1):
	    vid1_path=video_file_1
	elif os.path.isfile(video_file_2):
	    vid1_path=video_file_2
	elif os.path.isfile(video_file_3):
	    vid1_path=video_file_3
	else:
	    vid1_path=''
	    
	if os.path.isfile(video_file_4):
	    vid2_path=video_file_4
	elif os.path.isfile(video_file_5):
	    vid2_path=video_file_5
	elif os.path.isfile(video_file_6):
	    vid2_path=video_file_6
	elif os.path.isfile(video_file_7):
	    vid2_path=video_file_7
	else:
	    vid2_path=''	
	
	vlc_path=getVLCPath()
	
	if (vid1_path!='' or vid2_path!='') and vlc_path!=None:
	    if vid1_path!='':
		play_vid_commnd='\"%s\" %s' %(vlc_path,vid1_path)
		Popen(play_vid_commnd)
	    if vid2_path!='':
		play_vid_commnd='\"%s\" %s' %(vlc_path,vid2_path)
		Popen(play_vid_commnd)
	    return True
	else:
	    return False
	    
    if isDarwin():
	video_file_0='%s/%s/%s/%s_%s_%sa.mp4' % (sonnabend_share,exp,rat,exp,rat,exp_date)
	video_file_1='%s/%s/%s/%s_%s_%sa.avi' % (sonnabend_share,exp,rat,exp,rat,exp_date)
	video_file_2='%s/%s/%s/%s_%s_%sa.mp4' % (brodyfs_share,exp,rat,exp,rat,exp_date)
	video_file_3='%s/%s/%s/%s_%s_%sa.avi' % (brodyfs_share,exp,rat,exp,rat,exp_date)
	
	video_file_4='%s/%s/%s/%s_%s_%sb.mp4' % (sonnabend_share,exp,rat,exp,rat,exp_date)
	video_file_5='%s/%s/%s/%s_%s_%sb.avi' % (sonnabend_share,exp,rat,exp,rat,exp_date)
	video_file_6='%s/%s/%s/%s_%s_%sb.mp4' % (brodyfs_share,exp,rat,exp,rat,exp_date)
	video_file_7='%s/%s/%s/%s_%s_%sb.avi' % (brodyfs_share,exp,rat,exp,rat,exp_date)
	
	if os.path.isfile(video_file_0):
	    vid1_path=video_file_0
	elif os.path.isfile(video_file_1):
	    vid1_path=video_file_1
	elif os.path.isfile(video_file_2):
	    vid1_path=video_file_2
	elif os.path.isfile(video_file_3):
	    vid1_path=video_file_3
	else:
	    vid1_path=''
	    
	if os.path.isfile(video_file_4):
	    vid2_path=video_file_4
	elif os.path.isfile(video_file_5):
	    vid2_path=video_file_5
	elif os.path.isfile(video_file_6):
	    vid2_path=video_file_6
	elif os.path.isfile(video_file_7):
	    vid2_path=video_file_7
	else:
	    vid2_path=''
	    
	if vid1_path!='' or vid2_path!='':
	    if vid1_path!='':
		play_vid_commnd='open %s -a QuickTime\ Player' %(vid1_path)
		Popen(play_vid_commnd,shell=True)
	    if vid2_path!='':
		play_vid_commnd='open %s -a QuickTime\ Player' %(vid2_path)
		Popen(play_vid_commnd,shell=True)
	    return True
	else:
	    return False
	
    return play_vid_commnd
	
class Frame(wx.Frame):
    def __init__(self, parent, id, title):
        wx.Frame.__init__(self, parent, id, title, size=(390, 220),style=wx.MINIMIZE_BOX | wx.SYSTEM_MENU | wx.CAPTION | wx.CLOSE_BOX | wx.CLIP_CHILDREN)
	panel_font=wx.Font(12, wx.ROMAN, wx.NORMAL, wx.BOLD)
	icon1 = wx.Icon('icons/applications-multimedia-2.png',wx.BITMAP_TYPE_PNG)
	self.SetIcon(icon1)
	if not onPrincetonDomain():	    
	    wx.MessageBox('Your machine should be connected to internet on the Princeton domain to use this app','Info')
	    self.Destroy()
        else:
            mountSambaServer()
            self.experimenters=getExperimenters()
            self.panel=wx.Panel(self,-1)
            self.panel.SetFont(panel_font)
            self.panel.SetBackgroundColour(PANEL1_BG_COLOR)	
            self.experimenters_sttxt=wx.StaticText(self.panel,-1,'Experimenter')
            self.rat_sttxt=wx.StaticText(self.panel,-1,'Rat')
            self.date_sttxt=wx.StaticText(self.panel,-1,'Date')
            self.rat_help_sttxt=wx.StaticText(self.panel,-1,'E.g. K045')
            self.date_help_sttxt=wx.StaticText(self.panel,-1,'(YYYYMMDD)')
            self.experimentersBox=wx.ComboBox(self.panel, -1, size=(150, -1), choices=self.experimenters, style=wx.CB_READONLY)	
            self.experimentersBox.SetSelection(getDefaultExperimenter(self.experimenters))
            self.experimenters_help_sttxt=wx.StaticText(self.panel,-1,'E.g. %s' %(self.experimentersBox.GetValue()))
            self.rat_txtctrl=wx.lib.masked.TextCtrl(self.panel,ID_MASKED_TEXTCTRL_1,mask="C###",size=(60,-1))
            self.date_txtctrl=wx.lib.masked.TextCtrl(self.panel,ID_MASKED_TEXTCTRL_2,mask="########",size=(100,-1))	
            self.getvideo=wx.Button(self.panel,ID_BUTTON,label='Get Video')	

            self.gbsizer=wx.GridBagSizer(2,2)	
            self.gbsizer.Add(self.experimenters_sttxt,pos=(0,0),flag=wx.ALL,border=5)
            self.gbsizer.Add(self.experimentersBox,pos=(0,1),flag=wx.ALL,border=5)
            self.gbsizer.Add(self.experimenters_help_sttxt,pos=(0,2),flag=wx.TOP,border=8)
            self.gbsizer.Add(self.rat_sttxt,pos=(1,0),flag=wx.ALL,border=5)
            self.gbsizer.Add(self.rat_txtctrl,pos=(1,1),flag=wx.TOP|wx.BOTTOM|wx.LEFT,border=5)
            self.gbsizer.Add(self.rat_help_sttxt,pos=(1,2),flag=wx.TOP,border=8)
            self.gbsizer.Add(self.date_sttxt,pos=(2,0),flag=wx.ALL,border=5)
            self.gbsizer.Add(self.date_txtctrl,pos=(2,1),flag=wx.TOP|wx.BOTTOM|wx.LEFT,border=5)
            self.gbsizer.Add(self.date_help_sttxt,pos=(2,2),flag=wx.TOP,border=8)
            self.gbsizer.Add(self.getvideo,pos=(3,1),flag=wx.ALL,border=5)
            self.panel.SetSizer(self.gbsizer)

            self.Bind(wx.EVT_CLOSE, self.OnClose)
            self.Bind(wx.EVT_BUTTON, self.GetVideoButton,id=ID_BUTTON)

            self.Centre()
            self.Show()
    
    def OnClose(self,evt):
	if onPrincetonDomain():
	    unmountSambaServer()
	if os.path.exists(last_experimenter_selected):
	    if isWindows():
		win32api.SetFileAttributes(last_experimenter_selected,win32con.FILE_ATTRIBUTE_NORMAL)
		os.system('attrib -h %s' %(last_experimenter_selected))
            if isDarwin():
		os.system('chmod 600 %s' %(last_experimenter_selected))
	f=open(last_experimenter_selected,'w')
	f.write(self.experimentersBox.GetValue())
	f.close()
	if isWindows():
	    win32api.SetFileAttributes(last_experimenter_selected,win32con.FILE_ATTRIBUTE_READONLY)
	    os.system('attrib +h %s' %(last_experimenter_selected))
        if isDarwin():
		os.system('chmod 400 %s' %(last_experimenter_selected))
        self.Destroy()
	
    def GetVideoButton(self,evt):
	exp=self.experimentersBox.GetValue()
	rat=self.rat_txtctrl.GetValue().upper()
	exp_date=self.date_txtctrl.GetValue()
	if not PlayVideo(exp,rat,exp_date):
	    self.rat_txtctrl.Clear()
	    self.date_txtctrl.Clear()
	
if __name__ == '__main__':
    app = wx.App(redirect=False)
    frame = Frame(None, -1, 'Video Viewer')
    app.MainLoop()