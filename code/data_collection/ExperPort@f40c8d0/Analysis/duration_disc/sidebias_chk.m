 sl = [0 0 1 1 1];
 biaslist = zeros(5,1);
 LeftRewards = [0 0 1 1 1 ];
 RightRewards = [1 1  0 0 0];
 
 for t = 1:5

  mn = max(1, t - 15);
        fprintf(1, 'Indexing sides from %i to %i\n', mn, t);
        left_trials = sum(sl(mn:t));
        lefthits = sum(LeftRewards(mn:t));
        if left_trials == 0, lefthits=0;
        else lefthits = lefthits/left_trials;
        end;
        tmp = sl(mn:t);
        right_trials = length(find(tmp < 1));
        righthits = sum(RightRewards(mn:t));
        if right_trials == 0,
            righthits = 0;
        else
            righthits = righthits/right_trials;
        end;
        b = lefthits - righthits;
        fprintf(1,'b is: %2.1f, Left: (%2.1f), RightRew: (%2.1f)\n', b, lefthits,righthits);

        biaslist(t) = b;
  end;
      
  biaslist