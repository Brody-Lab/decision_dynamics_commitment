
#include "mex.h"
#include <math.h>
#include <stdio.h>

//function ys=qfind(x,ts)
/* % function y=qfind(x,ts)
% x is a vector , t is the target (can be one or many targets),
% y is same numel as ts
% does a binary search: assumes that x is sorted low to high and unique.
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray
*prhs[])
{

int t, high, low,y, probe;
double *ts;
double *x;

int ts_N = mxGetNumberOfElements(prhs[1]) ;
int x_N = mxGetNumberOfElements(prhs[0]) ;
x = mxGetPr(prhs[0]) ;
ts = mxGetPr(prhs[1]) ;
    
// mexPrintf("%i, %i\n", ts_N, x_N);

    plhs[0]=mxCreateDoubleMatrix(ts_N, 1, mxREAL) ;
   double *ys = mxGetPr(plhs[0]) ;
for(int num=0; num < ts_N; num++)
{
            t=ts[num];
            high=x_N;
            low=-2;
 // mexPrintf("%i\n", t);

 
 
            if (t>=x[x_N-1])
                {
   //             mexPrintf("should not be here, %i, %i", t, *(x+x_N-1));
                y=x_N;
                }
                else
                {
                while (high-low>1)
                {probe=ceil((high+low)/2);
     //            mexPrintf("%i\n",probe);
                if (x[probe]>t)
                {high=probe;}
                else
                {
                low=probe;
                }
                }
                y=low;
                
                }
            
            ys[num]=y+1;
}
}

    