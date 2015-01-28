/**************************************************************************
 * MEXKBHIT - emulates the kbhit c function. 
 *
 * mexKbhit checks whether a key has been pressed in the command prompt and 
 * returns information about the key. 
 *
 * Warning : mexKbhit calls the matlab function kbhit. While CTRL+C doesn't
 * interrupt mex functions, it will interrupt matlab functions called by a 
 * mex function. Therefore, the key combo CTRL+C may cause problems when 
 * your mex function is executing mexKbhit. 
 *
 * COMPILING THE LIBRARY
 * =====================
 * To compile the library (.lib) file (lcc instructions), in Matlab command 
 * window, change to the folder containing the mexKbhit files, then run the
 * following commands
 
 eval(['!"' matlabroot '\sys\lcc\bin\lcc" -noregistrylookup -I"' matlabroot '\sys\lcc\include" -I"' matlabroot '\extern\include" mexKbhit.c']);
 eval(['!"' matlabroot '\sys\lcc\bin\lcclib" mexKbhit.lib mexKbhit.obj']);
  
 * An error "Impossible to open 'mexKbhit.lib'" will occur. Ignore it.
 *
 * USING MEXKBHIT
 * ==============
 * Include the header file mexKbhit.h.
 * Use
 * 
 *    init_kbhit(); 
 * 
 * to initialise mexKbhit before using it. To get the last key pressed, use 
 * 
 *    struct key k;
 *    k = mexKbhit(); 
 *
 * which will return a struct containing information on the last key. When 
 * no longer required, stop mexKbhit with
 *
 *    stop_kbhit();
 *
 * When compiling your mex file, the .lib file needs to be linked by 
 * including it in the mex command eg.
 *
 *    mex your_mex_file.c -l mexKbhit.lib
 *
 * If the kbhit.lib is in a different folder to your_mex_file.c, you will
 * probably need to include the full path of the .lib file eg.
 *
 *    mex your_mex_file.c -l C:\Documents\Matlab\medKbhit.lib
 *
 * See mexKbhitDemo.c for a demonstration on using mexKbhit.
 *
 * Created by Amanda Ng 3 March 2011
 */

#include "mex.h"
#include "time.h"
#include "mexKbhit.h"

bool init_mexKbhit(void) {
    mxArray *parIn, *parOut;
    parIn = mxCreateString("init");
    mexCallMATLAB(1, &parOut, 1, &parIn, "kbhit");
    return *mxGetPr(parOut);
}

void stop_mexKbhit(void) {
    mxArray *par;
    
    // flush any previous calls to kbhit, otherwise may quit while retrieving key data */
    mexEvalString("drawnow");    
    
    par = mxCreateString("stop");
    mexCallMATLAB(0, NULL, 1, &par, "kbhit");
}

struct key mexKbhit(void) {
    mxArray *par_in, **par_out, *mxA;
    struct key k;
    
    // flush matlab command window i/o
    mexEvalString("drawnow");
    
    par_out = (mxArray**) mxCalloc(1, sizeof(mxArray*));
    par_in = mxCreateString("struct");
    mexCallMATLAB(2, par_out, 1, &par_in, "kbhit");
    
    if (mxIsEmpty(par_out[0])) {
        k.ascii = NULL;
        return k;
    }
    
    mxA = mxGetField(par_out[0], 0, "ascii");
    k.ascii = (int) *mxGetPr(mxA);
    
    mxA = mxGetField(par_out[0], 0, "char");
    k.character = (char) *mxGetChars(mxA);;
    
    mxA = mxGetField(par_out[0], 0, "alt");
    k.alt = (bool) *mxGetLogicals(mxA);
            
    mxA = mxGetField(par_out[0], 0, "ctrl");
    k.ctrl =  (bool) *mxGetLogicals(mxA);

    mxA = mxGetField(par_out[0], 0, "shift");
    k.shift =  (bool) *mxGetLogicals(mxA);
    
    return k;
}
