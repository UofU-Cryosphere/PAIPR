
% Add PAIPR-core functions to path
addon_struct = dir(fullfile('src/', 'PAIPR-core*'));
addpath(genpath(fullfile(addon_struct.folder, addon_struct.name)))

% Add cresis-matlab-reader functions to path
addon_struct = dir(fullfile('src/Dependencies/', ...
    'cresis-L1B-matlab-reader*'));
addpath(genpath(fullfile(addon_struct.folder, addon_struct.name)))

% Add Antarctic Mapping Toolbox (AMT) to path
addon_struct = dir(fullfile('src/Dependencies/', ...
    'AntarcticMappingTools_*'));
addpath(genpath(fullfile(addon_struct.folder, addon_struct.name)))

% Add PAIPR scripts to path
addpath('src/scripts/')

%%

% If required, start parellel pool
poolobj=parpool('local',11);



% Define input/output file locations
rho_file = 'rho_data.csv';
out_dir = 'Outputs/';

% Define directories for raw echogram inputs
data_dirs = dir('Data');
data_dirs = data_dirs([data_dirs(:).isdir]);
datadir_list = data_dirs(~ismember({data_dirs(:).name},{'.','..'}));


for i=1:length(datadir_list)
    
    % Get raw echogram directory for current iteration
    echo_dir = datadir_list(i);
    
    % Create output directory for current iteration
    out_i = fullfile(out_dir, echo_dir.name);
    mkdir(out_i);
    
    % Run PAIPR functions
    [success_codes] = process_SLURM(...
        fullfile(echo_dir.folder, echo_dir.name), rho_file, out_i);
    
    % Save sucess codes as .csv table
    T = table(1:length(success_codes), success_codes, ...
        'VariableNames', {'Iteration', 'Exit_code'});
    writetable(T, fullfile(out_i, 'exit_codes.csv'))
    
end

% If required, close parellel pool
delete(poolobj)


