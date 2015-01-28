#include <math.h>
#include <stdio.h>
#include <stdlib.h>
/* Needed for building mex file:                                           */
#include <mex.h>
#include <matrix.h>

/*
 *   Copyright (C) 2010 Cesare Magri
 *   Version: 1.0.0
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
 *
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
 
/* ------------------------------------------------------------------------*/
/* Part II: Panzeri & Treves bias correction routine                       */
/* ------------------------------------------------------------------------*/

void panzeri_treves_96(double *C_ptr, mwSize Rtot, double N, double *bias)

/* References:
/*
/* [1] S.Panzeri, A.Treves (1996) "Analytical estimates of limited sampling*/
/*     biases in different information measures", Network: Computation in  */
/*     Neural Systems 7, pp. 87-107.                                       */
/*                                                                         */
/* [2] G.Pola, S.Schultz, R.Petersen, S.Panzeri (2003) "A practical guide  */
/*     to information analysis of spike trains", Neuroscience Databases: A */
/*     Practical Guide, pp. 139-153.                                       */

{
    mwIndex indx;
    mwSize  NnonZeroCvalues;
    
    double  R;
    double  Rnaive;
    double  Rexpected;
    
    double  deltaR;
    double  deltaRprevious;
    
    double *PnonZero;
    double  Pbayes;
    
    double  gamma;

    /* Allocating memory for PnonZero                                      */
    PnonZero = mxCalloc(Rtot , sizeof(double));

    /* Reading the non-zero prob values in the y-th column of Pmat and     */
    /* computing Rnaive (i.e., number of non-zero prob bins). Note: we     */
    /* initialized PnonZero and nonZeroIndxes to Rtot (= Ny) length but    */
    /* we will only make use of Rnaive values (Rnaive <= Rtot).            */
    NnonZeroCvalues = 0;
    for(indx=0; indx<Rtot; indx++) {
        if(C_ptr[indx]>0) {
            PnonZero[NnonZeroCvalues++] = C_ptr[indx] / N;
        }
    }
    
    /* Rnaive is the number of non-null probability values                 */
    Rnaive = NnonZeroCvalues;

    if(Rnaive < Rtot) {

        /* Initial value for Rexpected                                     */
        Rexpected = Rnaive;
        for(indx=0;indx<NnonZeroCvalues;indx++)
            Rexpected -= pow(1 - PnonZero[indx], N);

        /* Initial values for deltaRprevious and deltaR                    */
        deltaRprevious = Rtot;
        deltaR = fabs(Rnaive - Rexpected);

        R = Rnaive;
        while(deltaR<deltaRprevious && R<Rtot) {

            R++;

            gamma = (R - Rnaive) * (1 - pow(N/(N+Rnaive), 1/N));

            Rexpected = 0;
            /* Occupied bins (we only run through non-zero prob bins)      */
            for(indx=0; indx<NnonZeroCvalues; indx++) {
                Pbayes = (PnonZero[indx]*N + 1) / (N + Rnaive) * (1 - gamma);
                Rexpected += 1 - pow(1 - Pbayes, N);
            }

            /* Estimating non-occupied bins according to model in [2]      */
            Pbayes = gamma / (R - Rnaive);
            Rexpected += (R - Rnaive) * (1 - pow(1 - Pbayes, N));

            deltaRprevious = deltaR;
            deltaR = fabs(Rnaive - Rexpected);
        }
        R--;
        if(deltaR < deltaRprevious)
            R++;
    } else {
        R = Rtot;
    }

    /* Freeing allocated memory                                            */
    mxFree(PnonZero);

    /* Estimating bias                                                     */
    *bias = (R-1) / (2*N*log(2));
}