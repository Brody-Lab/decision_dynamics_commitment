% <~> Quick script to check on biases.

cd /ratter/ExperPort/
newstartup;
flush;

N = 20; %     how many sessions to grab


[sessiondate hostname avg_bias avg_delta] = ...
    bdata(['select sessiondate,hostname,avg_bias,avg(delta_bias) from biasview order by sessiondate,hostname limit ' int2str(N)]);

N = min(N,length(sessiondate)); %     If we retrieved fewer than N, use that number of sessions.


%     Which rigs have biases?
rigsToAnalyze = cell(0);
for i=1:N,
    if avg_bias > 0.2,
        rigsToAnalyze{end+1} = hostname{i};
    end;
end;
rigsToAnalyze = unique(rigsToAnalyze);

%     For each rig with a high level of bias,
for i=1:length(rigsToAnalyze),

    %     Grab the date in a mysql-friendly format for three days ago.
    m = datestr(now,'mm');
    d = datestr(now,'dd');
    y = datestr(now,'yy');
    if str2int(d) < 3

        %     Find cases in which the right_correct value was much higher than
        %       the left_correct value and vice versa.
        bdata('select sessid,ratname,hostname,experimenter,starttime,endtime,n_done_trials,comments,protocol,total_correct,right_correct,left_correct,percent_violations,brokenbits from sessions where ({S} - {S})/total_correct > 0.1 and hostname="{S}" and session_date > "{S}" order by session_date desc limit 15','right_correct','left_correct',rigsToAnalyze{i});
        bdata('select sessid,ratname,hostname,experimenter,starttime,endtime,n_done_trials,comments,protocol,total_correct,right_correct,left_correct,percent_violations,brokenbits from sessions where ({S} - {S})/total_correct > 0.1 and hostname="{S}" and session_date > "{S}" order by session_date desc limit 15','left_correct','right_correct',rigsToAnalyze{i});

        %     [sessid ratname hostname experimenter starttime endtime n_done_trials comments protocol total_correct right_correct left_correct percent_violations brokenbits] = ...
        %         bdata('select sessid,ratname,hostname,experimenter,starttime,endtime,n_done_trials,comments,protocol,total_correct,right_correct,left_correct,percent_violations,brokenbits from sessions where ({S} - {S})/total_correct > 0.1 and hostname="{S}" and session_date > "{S}" order by session_date desc limit 25','right_correct','left_correct',rigsToAnalyze{i});
    end;
end;
