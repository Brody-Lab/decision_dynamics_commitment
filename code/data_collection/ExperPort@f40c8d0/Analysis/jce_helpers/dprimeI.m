function x=dprimeI(stim,nostim)

    thres=mean([mean(stim) mean(nostim)]);
    h=sum(stim<thres);
    FA=sum(nostim<thres);
    ph=h/(length(stim)+length(nostim));
    pFA=FA/(length(stim)+length(nostim));

    x=norminv(ph)-norminv(pFA);