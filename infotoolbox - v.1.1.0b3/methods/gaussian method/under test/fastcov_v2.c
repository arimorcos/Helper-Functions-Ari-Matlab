#include <math.h>
#include <stdio.h>
#include <stdlib.h>
/* Needed for building mex file:                                           */
#include <mex.h>
#include <matrix.h>

/*
 *   Copyright (C) 2010 Cesare Magri
 *   Version: 2.0.1
 */

/*
 *-------
 * LICENSE
 * -------
 * This software is distributed free under the condition that:
 *
 * 1. it shall not be incorporated in software that is subsequently sold;
 *
 * 2. the authorship of the software shall be acknowledged and the following
 *    article shall be properly cited in any publication that uses results
 *    generated by the software:
 *
 *      Magri C, Whittingstall K, Singh V, Logothetis NK, Panzeri S: A
 *      toolbox for the fast information analysis of multiple-site LFP, EEG
 *      and spike train recordings. BMC Neuroscience 2009 10(1):81;
 *
 * 3.  this notice shall remain in place in each source file.
 */

/* ----------
 * DISCLAIMER
 * ----------
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


void mexFunction(int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
    double *R, *Nt, totNt;
    double *covPrs, *covPr, *diagCovPrs, *diagCovPr, *sumPrs, *sumPr;
    bool    btspFlag;
    mwSize  Nc, maxNt, Ns, *dims, NcSquare;
    mwIndex c1, c2, t, s, sRand, *sList, sListEndInd, sListRndInd, *nFilledTrial;
    
    int counter;
    counter = 0;
    
    R        =  mxGetPr(prhs[0]);
    Nt       =  mxGetPr(prhs[1]);
    Nc       = (mwSize) *mxGetPr(prhs[2]);
    maxNt    = (mwSize) *mxGetPr(prhs[3]);
    Ns       = (mwSize) *mxGetPr(prhs[4]);
    totNt    = *mxGetPr(prhs[5]);
    btspFlag = (bool) *mxGetPr(prhs[6]);
    
    NcSquare = Nc*Nc;
    
    dims = mxCalloc(3, sizeof(mwSize));
    dims[0] = Nc;
    dims[1] = Nc;
    dims[2] = Ns;
    
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, 0);
    covPrs = mxGetPr(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(Nc, Nc, mxREAL);
    covPr = mxGetPr(plhs[1]);
    
    plhs[2] = mxCreateDoubleMatrix(Ns, Nc, mxREAL);
    diagCovPrs = mxGetPr(plhs[2]);
    
    plhs[3] = mxCreateDoubleMatrix(Nc, 1, mxREAL);
    diagCovPr = mxGetPr(plhs[3]);
    
    sumPrs       = mxCalloc(Nc*Ns, sizeof(double));
    sumPr        = mxCalloc(Nc   , sizeof(double));
    
    nFilledTrial = mxCalloc(Ns   , sizeof(mwIndex));
    
    if (btspFlag) {
        sList    = mxCalloc(Ns   , sizeof(mwIndex));
        
        for(s=0; s<Ns; s++)
            sList[s] = s;
    }
    
    
    sListEndInd = Ns-1;
    for(s=0; s<Ns; s++) {
        for(t=0; t<Nt[s]; t++) {
                    
            /* HOW THE BOOTSTRAPPING IS DONE:                              */
            /* - We keep a list of the indices of the stimuli which have   */
            /*   not been filled in SLIST.                                 */
            /* - We keep record of how many of these non filled stimuli    */
            /*   are in SLISTENDIND                                        */
            /* - We generate a random index SLISTRANDIND between 0 and     */
            /*   SLISTENDIND: SLIST[SLISTRANDIND] provides the index of    */
            /*   the stimulus (chosen at random) to which the current      */
            /*   response values (defined by S and T) will be assigned.    */
            /* - We increment the counter NFILLEDTRIAL, which keeps track  */
            /*   how many trial slots have been filled for each stimulus.  */
            /* - if NFILLEDTRIAL[SRAND] matches NT[SRAND] it means that we */
            /*   have filled all available slots for stimulus SRAND and we */
            /*   can proceed with the mean subtraction. Additionally we    */
            /*   remove the index SRAND from SLIST by overwriting its value*/ 
            /*   with SLIST[NNONFILLEDS] and then decrementing NNONFILLEDS.*/

            if(btspFlag) {
                /* Generating the random stimulus index:                   */
                sListRndInd = rand() % (sListEndInd+1); /* We use mod with */
                                                        /* SLISTENDIND + 1 */
                                                        /* to generate an  */
                                                        /* int btw 0 and   */
                                                        /* SLISTENDIND     */
                sRand = sList[ sListRndInd ];

                nFilledTrial[sRand]++;
                
                if (nFilledTrial[sRand]==Nt[sRand]) {
                    counter++;
                    sList[sListRndInd] = sList[sListEndInd];
                    sListEndInd--;
                }

            } else {
                sRand = s;
                nFilledTrial[s] = t;
            }

            for(c1=0; c1<Nc; c1++) {
                for(c2=c1; c2<Nc; c2++) {
                    
                    covPrs[c1 + c2*Nc + sRand*NcSquare] += R[c1 + t*Nc + s*Nc*maxNt] * R[c2 + t*Nc + s*Nc*maxNt];
                    
                    /* If c1=0, then c2 runs through all Nt[s] slots. We   */
                    /* can thus make use on the loop on c2 to compute      */
                    /* sumPrs.                                             */
                    if(c1==0) {
                        sumPrs[c2 + sRand*Nc] += R[c2 + t*Nc + s*Nc*maxNt];
                        sumPr[c2]             += R[c2 + t*Nc + s*Nc*maxNt];
                    }
                    
                    if (nFilledTrial[sRand]==Nt[sRand]) {
                        covPr[c1 + c2*Nc] += covPrs[c1 + c2*Nc + sRand*NcSquare];
                
                        /* Removing sample mean:                           */
                        covPrs[c1 + c2*Nc + sRand*NcSquare] -= (sumPrs[c1 + sRand*Nc]*sumPrs[c2 + sRand*Nc]) / Nt[sRand];
                        
                        if(c2==c1) {
                            /* Reading the matrix diagonal:                */
                            diagCovPrs[sRand + c1*Ns] = covPrs[c1 + c2*Nc + sRand*NcSquare];
                        } else {
                            /* Making the matrix simmetrical               */
                            covPrs[c2 + c1*Nc + sRand*NcSquare] = covPrs[c1 + c2*Nc + sRand*NcSquare];
                        }
                    }
                    

                    if(s==Ns-1 && t==Nt[s]-1) {
                        /* If we are here it means we have gone through all*/
                        /* trials for all stimuli, thus sumPr is also ready*/
                        covPr[c1 + c2*Nc] -= (sumPr[c1]*sumPr[c2]) / totNt;

                        if (c1==c2)
                            diagCovPr[c1] = covPr[c1 + c2*Nc];
                        else
                            covPr[c2 + c1*Nc] = covPr[c1 + c2*Nc];
                    }
                    
                } /* Loop on c2                                            */
            } /* Loop on c1                                                */
        } /* Loop on t                                                     */
    } /* Loop on s                                                         */
    
    mxFree(dims);
    mxFree(sumPrs);
    mxFree(sumPr);
    
    mxFree(nFilledTrial);
    
    if (btspFlag)
        mxFree(sList);
    
}