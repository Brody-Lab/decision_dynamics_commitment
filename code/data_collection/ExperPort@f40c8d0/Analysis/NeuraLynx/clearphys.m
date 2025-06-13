
function clearphys(sessid)

[user pass] = logindlg('Title','Login Title');

bdata('connect','brodyfs2.princeton.edu',user, pass);

mym(bdata,'delete from cells where sessid="{S}"',sessid);
mym(bdata,'delete from spktimes where sessid="{S}"',sessid);
mym(bdata,'delete from channels where sessid="{S}"',sessid);
mym(bdata,'delete from phys_sess where sessid="{S}"',sessid);
