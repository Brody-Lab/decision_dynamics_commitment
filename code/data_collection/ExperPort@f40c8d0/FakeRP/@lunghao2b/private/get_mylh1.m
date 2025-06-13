function [lh1] = get_mylh1(lh1)

    global private_lunghao2b_list;
    lh1 = private_lunghao2b_list{lh1.list_position};
