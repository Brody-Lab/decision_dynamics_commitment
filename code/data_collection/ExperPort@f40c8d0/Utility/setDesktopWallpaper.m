function setDesktopWallpaper(this_rig)

if nargin==0
this_rig=getRigID;
end

figure(999); clf;
set(999,'Color','k','Position',[30 40 290 200])
ax=axes; set(ax,'Visible','off');
th=text(0,0.5,sprintf('Rig %02d',this_rig));
set(th,'FontSize',48,'FontWeight','bold','Color',[0.6 0.6 0.6])
set(999,'InvertHardcopy','off','PaperPositionMode','auto')

if ispc
    print(999,'-dbmp','c:\wallpaper.bmp')    
    regstr='reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d c:\wallpaper.bmp /f';
    system(regstr);
    system('RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters');
    close(999);
else
    print(999,'-dbmp','/tmp/wallpaper.bmp')    
end


