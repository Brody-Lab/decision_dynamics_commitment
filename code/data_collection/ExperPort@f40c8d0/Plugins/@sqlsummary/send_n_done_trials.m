function send_n_done_trials(obj,do,varargin) %#ok<INUSD>

if nargin < 2; do = 'update'; end

try %#ok<TRYNC>
    rigid = bSettings('get','RIGS','Rig_ID');
    if isnan(rigid)
        return;
    end
    
    if strcmp(do,'reset')
        bdata('call ratinfo.update_rigtrials("{Si}","{Si}","{S}","{S}")',rigid,0,0,[]);
        bdata('call ratinfo.update_rigtrials_lastupdate("{S}","{Si}")','00:00:00',rigid);
    else

        peh  = [];
        ndt  = 0;
        perf = 0;

        n = bdata(['select n_done_trials from ratinfo.rigtrials where rigid=',num2str(rigid)]);
        if isempty(n)
            bdata(['insert into ratinfo.rigtrials set rigid=',num2str(rigid),', n_done_trials=0, peh=0, performance=0']);
        end

        try %#ok<TRYNC>
            pe  = get_sphandle('name','parsed_events');
            if strcmp(get_name(pe{1}),'parsed_events')
                peh = cell2mat(get_history(pe{1}));
            end
        end
        peh = [];

        try %#ok<TRYNC>
            h = get_sphandle('name','hit_history');
            hh = value(h{1});
            if iscell(hh); hh = cell2mat(hh); end
            perf = nanmean(hh);
        end

        try %#ok<TRYNC>
            nd  = get_sphandle('name','n_done_trials');
            ndt = value(nd{1});
        end

        bdata('call ratinfo.update_rigtrials("{Si}","{Si}","{S}","{S}")',rigid,ndt,perf,peh);
    end
end

