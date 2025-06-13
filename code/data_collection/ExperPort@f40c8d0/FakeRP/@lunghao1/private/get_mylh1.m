function [lh1] = get_mylh1(lh1)

    global private_lunghao1_list;
    lh1 = private_lunghao1_list{lh1.list_position};
