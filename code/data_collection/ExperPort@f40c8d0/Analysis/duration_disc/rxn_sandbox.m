function [] = rxn_sandbox

ratset={'S042','S029','S038'};
fromd='090326';
tod='090326';
ratname='S042';
slist={'cue','pre_go','chord','wait_for_apoke'} ;

get_fields(ratname, 'from', fromd, 'to',tod,'datafields', {'tones_list', 'sides', 'pstruct', 'rts'});

[r rstate kept_idx]=rxn_time_statewise(pstruct, rts,'validcoutstates', slist);

idx=find(rstate==1);
figure; plot(tones_list(idx), r(idx),'.b');

2;


