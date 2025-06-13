function [pSaline] = probsaline

numSaline = 10;
numToxin = 10;
numChoice = 3;
numSalineChoice = 3;
total = numSaline + numToxin;

pSaline = (choose(numSaline, numSalineChoice) * choose(numToxin,numChoice - numSalineChoice)) / choose(total, numChoice);




% computes n choose k
% n!/(n-k)! (k)!
function [num] = choose(n,k)
    num = factorial(n)/(factorial(k) * factorial(n-k));