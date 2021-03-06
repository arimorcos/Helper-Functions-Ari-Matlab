function direct_method_v6

% DIRECT_METHOD_V6 Estimate entropy quantities with direct method.
%
% This function is the direct method engine of called by ENTROPY and its
% related functions.
%
% USAGE
%
%   [HR, HRS, HlR, HlRS, HiR, HiRS, ChiR, HshR, HshRS] = direct_method_v6(R, nt, pars);
%
%
% INPUTS
%
%   R    - response matrix
%   pars - parameters structure
%
% The parameters structure must include the following fields:
%
% =========================================================================
% | FIELD NAME       | TYPE          | DESCRIPTION                        |
% =========================================================================
% | pars.nt          | numeric array | number of trials per stimulus.     |
% |-----------------------------------------------------------------------|
% | pars.biasCorrNum | scalar value  | bias correction number:            |
% |                  |               |                                    |
% |                  |               |  -1 : user-defined bias            |
% |                  |               |       correction routine           |
% |                  |               |                                    |
% |                  |               |   2 : Panzeri & Treves             |
% |-----------------------------------------------------------------------|
% | pars.doHR        | logical value | flag specifying whether H(R) needs |
% |                  |               | to be estimated                    |
% |-----------------------------------------------------------------------|
% | pars.doHRS       | logical value | flag specifying whether H(R|S)     |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHlR       | logical value | flag specifying whether H_lin(R)   |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHlRS      | logical value | flag specifying whether H_lin(R|S) |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHiR       | logical value | flag specifying whether H_ind(R)   |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHiRS      | logical value | flag specifying whether H_ind(R|S) |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doChiR      | logical value | flag specifying whether Chi(R)     |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHshR      | logical value | flag specifying whether H_sh(R)    |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.doHshRS     | logical value | flag specifying whether H_sh(R|S)  |
% |                  |               | needs to be estimated              |
% |-----------------------------------------------------------------------|
% | pars.testMode    | logical value | flag specifying whther test-mode   | 
% |                  |               | has been selected                  |
% =========================================================================
%
% OUTPUTS
%
%   HR    -   direct estimate of H(R)
%   HRS   -      "       "    of H(R|S)
%   HlR   -      "       "    of H_lin(R)
%   HlRS  -      "       "    of H_lin(R|S)
%   HiR   -      "       "    of H_ind(R)
%   HiRS  -      "       "    of H_ind(R|S)
%   ChiR  -      "       "    of Chi(R)
%   HshR  -      "       "    of H_shuffle(R)
%   HshRS -      "       "    of H_shuffle(R|S)
%
% Zero is returned for all outputs corresponding to output options that
% were not selected by the user.
%
% REMARK!
% As for all the functions in the toolbox, the difference between the
% quantities H_lin(R|S) and H_ind(R|S) is kept in this function. See the
% "REMARKS FOR DEVELOPERS" note in function ENTROPY.
%
%
% See also ENTROPY, INFORMATION, GAUSSIAN_METHOD_v9.

% Copyright (C) 2010 Cesare Magri
% Version 6a

% -------
% LICENSE
% -------
% This software is distributed free under the condition that:
%
% 1. it shall not be incorporated in software that is subsequently sold;
%
% 2. the authorship of the software shall be acknowledged and the following
%    article shall be properly cited in any publication that uses results
%    generated by the software:
%
%      Magri C, Whittingstall K, Singh V, Logothetis NK, Panzeri S: A
%      toolbox for the fast information analysis of multiple-site LFP, EEG
%      and spike train recordings. BMC Neuroscience 2009 10(1):81;
%
% 3.  this notice shall remain in place in each source file.

% ----------
% DISCLAIMER
% ----------
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.