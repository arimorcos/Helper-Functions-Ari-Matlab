% This scritp allows to easily compile the MEX functions in the toolbox.
% Once the compiler has been setup properly (see help for function MEX in
% Matlab) simply run the script. Remember that, in order for the make file
% to work properly, the toolbox folders need to be included in the Matlab
% path: see the installation instruction and function STARTUP_infolab.

% Looking for INFORMATION cause there might be other ENTROPY function
% installed:
informationDir = which('information.m');
% Toolbox directory:
toolboxDir = informationDir(1:end-14);
% Verifying that we are compiling for the correct version
vdot_locations = strfind(toolboxDir, 'v.');
version = toolboxDir(vdot_locations(end):end);
if ~strcmp(version, 'v.1.1.0b2')
    error('Update the path to the correct toolbox version before proceeding with compilation.');
end

basicOpt = {'-O', '-largeArrayDims'};


disp(['Compiling: files for infoLab ' version ':']);

% Compiling PARTITION_R -----------------------------------------------
outDir   = fullfile(toolboxDir, 'Extrapolations', 'Auxiliary Functions', 'partition_R');
filePath = fullfile(outDir, 'partition_R.c');

disp(['   Compiling: ' filePath]);

mex(basicOpt{:}, '-outdir', outDir, filePath);

% Compiling SHUFFLE_R_ACROSS_TRIALS -----------------------------------
outDir   = fullfile(toolboxDir, 'Extrapolations', 'Auxiliary Functions', 'shuffle_R_across_trials');
filePath = fullfile(outDir, 'shuffle_R_across_trials.c');

disp(['   Compiling: ' filePath]);

mex(basicOpt{:}, '-outdir', outDir, filePath);

% Compiling SHUFFLE_R_ACROSS_CELLS ------------------------------------
outDir   = fullfile(toolboxDir, 'Methods', 'Auxiliary Functions', 'shuffle_R_across_cells');
filePath = fullfile(outDir, 'shuffle_R_across_cells.c');

disp(['   Compiling: ' filePath]);

mex(basicOpt{:}, '-outdir', outDir, filePath);

% Compiling DIRECT_METHOD ---------------------------------------------
outDir = fullfile(toolboxDir, 'Methods', 'Direct Method');
file1Path = fullfile(outDir, 'direct_method_v6a.c');
file2Path = fullfile(toolboxDir, 'Bias Corrections', 'Bias Corrections for Direct Method', 'panzeri_and_treves_96.c');

disp(['   Compiling: ' file1Path]);
disp(['              ' file2Path]);

mex(basicOpt{:}, '-outdir', outDir, file1Path, file2Path);

% Compiling FASTCOV ---------------------------------------------------
outDir = fullfile(toolboxDir, 'Methods', 'Gaussian Method');
filePath = fullfile(outDir, 'fastcov_v2.c');

disp(['   Compiling: ' filePath]);

mex(basicOpt{:}, '-outdir', outDir, filePath);

disp('File compiling successful.');