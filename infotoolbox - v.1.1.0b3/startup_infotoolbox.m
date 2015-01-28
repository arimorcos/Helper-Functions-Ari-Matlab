% This script sets add all folders required by the tolbox to work to the
% MATLAB path.
%
% HOW TO USE THIS SCRIPT
%   You can use this script in two ways:
%   
%   - MANUALLY:
%     set the variable V110B2_ROOT (first code line) to the path of the
%     toolbox folder "infotoolbox - v.1.1.0b3" on your computer (the folder
%     including this script file) and run the script (by CTRL-ENTER)
%
%   - WITH A STARTUP FILE:
%     in your startup file cd to the folder including this file and invoke
%     STARTUP_INFOTOOLBOX. Each time you start MATLAB the toolbox path will
%     be correctly added. This also allows to easily manage different
%     versions of the code.

v110b3_root = cd;

addpath(v110b3_root)
addpath(fullfile(v110b3_root, 'auxiliary functions', 'findtrial'));
addpath(fullfile(v110b3_root, 'auxiliary functions', 'intshift'));
addpath(fullfile(v110b3_root, 'bias corrections', 'Bias Corrections for Direct Method'));
addpath(fullfile(v110b3_root, 'bias corrections', 'Bias Corrections for Guassian Method'));
addpath(fullfile(v110b3_root, 'binning functions'));
addpath(fullfile(v110b3_root, 'extrapolations', 'auxiliary functions', 'partition_R'));
addpath(fullfile(v110b3_root, 'extrapolations', 'auxiliary functions', 'shuffle_R_across_trials'));
addpath(fullfile(v110b3_root, 'extrapolations', 'auxiliary functions', 'xtrploop'));
addpath(fullfile(v110b3_root, 'extrapolations', 'quadratic extrapolation'));
addpath(fullfile(v110b3_root, 'input parsing'));
addpath(fullfile(v110b3_root, 'methods', 'auxiliary Functions', 'shuffle_R_across_cells'));
addpath(fullfile(v110b3_root, 'methods', 'direct method'));
addpath(fullfile(v110b3_root, 'methods', 'gaussian method'));