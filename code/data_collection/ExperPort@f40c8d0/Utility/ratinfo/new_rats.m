function new_rats(ratnames,varargin)

experimenter='';
contact='';
deliverydate=datestr(now(),29);
cagemate=[];

overridedefaults(who, varargin);

if isempty(cagemate)
cagemate=set_cagemates(ratnames);
end

for rx=1:numel(ratnames)
    if isempty(ratnames{rx})
        continue;
    end
    
    [this_cont,this_exper]=get_exp_cont(ratnames{rx}(1),experimenter, contact);
    
    sqlstr='insert into ratinfo.rats (ratname,experimenter, contact,cagemate,deliverydate,extant) values ("{S}","{S}","{S}","{S}","{S}")';
    bdata(sqlstr,ratnames{rx},this_exper,this_cont, cagemate{rx},deliverydate,1);
    
end
    
    





function [this_cont,this_exper]=get_exp_cont(rat_init,experimenter, contact)
    [bexp,bcont]=bdata('select experimenter, email from ratinfo.contacts where tag_letter="{S}"',rat_init);
    
    if isempty(experimenter)
       this_exper=bexp{1};
    elseif ischar(experimenter)
        this_exper=experimenter;
    else
        this_exper=experimenter{cx};
    end
    
    if isempty(contact)
       this_cont=bcont{1};
    elseif ischar(contact)
        this_cont=contact;
    else
        this_cont=contact{cx};
    end

    this_cont=strtok(this_cont,'@');
    
    
    

function cagemate=set_cagemates(ratnames)
if ischar(ratnames)
    ratnames={ratnames};
end

n_rats=numel(ratnames);
if rem(n_rats,2)==1
    ratnames{end+1}='';
end

for cx=1:2:numel(ratnames)
    cagemate(cx)=ratnames(cx+1);
end

for cx=2:2:numel(ratnames)
    cagemate(cx)=ratnames(cx-1); %#ok<*AGROW>
end

