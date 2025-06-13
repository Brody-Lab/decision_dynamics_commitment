function [] = lunghao1_timer_fcn(obj, event, lid)

    global private_lunghao1_list;
    TimesUp(private_lunghao1_list{lid});
    