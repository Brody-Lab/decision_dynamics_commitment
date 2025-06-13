
% cannula_dailynumtrials.m
% Little driver .m file that runs numtrials_oversessions for all rats
% currently undergoing cannula experiments


Lascar__date = '080323';
Grimesby__date = '080331';
Pips__date = '080407';
Blaze__date = '080414'; 

%numtrials_oversessions('Lascar','from','080415','to','999999','mark_breaks',0)

numtrials_oversessions('Grimesby','from','080424','to','999999','mark_breaks',0)

numtrials_oversessions('Pips','from','080424','to','999999','mark_breaks',0)

numtrials_oversessions('Blaze','from','080424','to','999999','mark_breaks',0)
