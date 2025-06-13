function update_riginfo()
try
rigid=getRigID;

if isnan(rigid)
    fprintf(2,'This is not a rig, skipping update.\n');
    return;
end

[ip,ma,hn]=get_network_info;
[steMS errID errmsg] = ...
    bSettings('get','RIGS','state_machine_server'); 

 [vidS errID errmsg] = ...
    bSettings('get','RIGS','video_server_ip'); 
if isnan(vidS)
    vidS='';
end

comptype = computer;
if ~isempty(comptype) && ~ischar(comptype)
    comptype = '';
else
    comptype = [comptype,' '];
end

os = system_dependent('getos');
if ~isempty(os) && ~ischar(os)
    os = '';
end

ct = [comptype,os];

%bdata('call ratinfo.update_riginfo("{S}","{S}","{S}","{S}","{S}","{S}","{S}")',rigid,ip,steMS,ma,hn,isunix,vidS)
bdata('call ratinfo.update_riginfo_computertype("{S}","{S}","{S}","{S}","{S}","{S}","{S}","{S}")',...
    rigid,ip,steMS,ma,hn,isunix,vidS,ct);
fprintf('Rig Info updated successfully.\nRig %d: IP=%s, MAC=%s, Hostname=%s, ComputerType=%s\n',rigid,ip,ma,hn,ct);
catch
    showerror
    fprintf(2,'Rig Info failed to update');
end

