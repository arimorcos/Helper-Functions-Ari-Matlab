/**************************************************************************
 * KBHITDEMO - demonstrates use of kbhit function  
 * to compile, use the following command
 
     mex mexKbhitDemo.c -l mexKbhit.lib
 
 * Created by Amanda Ng 3 March 2011
 */

#include "mex.h"
#include "time.h"
#include "mexKbhit.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    clock_t t;
    struct key k;
    
    if (!init_mexKbhit()) {
        mexPrintf("Could not start kbhit.\n");
        return;
    }

    t = clock();
    // poll for 5 seconds
    mexPrintf("Wait 5 seconds ... ");
    mexEvalString("drawnow");
    while ((clock()-t)/CLOCKS_PER_SEC < 5) {    
        k = mexKbhit();  
        if (k.character == 'C' && k.ctrl == 1) {
            mexPrintf("interrupted by Ctrl+c! ");
            break;
        }
    }
    k = mexKbhit();  
    mexPrintf("done.\n");
    mexEvalString("drawnow");
    
    if (k.ascii == NULL) {
        mexPrintf("No key pressed\n");
    }
    else {
        mexPrintf("Data returned by kbhit :\n");
        mexPrintf("   ascii :%d\n", k.ascii);
        mexPrintf("   char : %c\n", k.character);
        mexPrintf("   alt : %d\n", k.alt);
        mexPrintf("   ctrl : %d\n", k.ctrl);
        mexPrintf("   shift : %d\n", k.shift);
    }    

    stop_mexKbhit();


}
