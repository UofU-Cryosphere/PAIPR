% This script generates the site-specific results figures and values used 
% in the TGARS paper (Keeler et al, 2019)

% Directories to data of interest based on computer (eventually will be
% replaced with GUI for data directory selection)
PC_true = ispc;
switch PC_true
    case true
        computer = 'work';
        %         computer = input('Current PC: ');
        switch computer
            case 'work'
                data_path = 'E:/Research/Antarctica/Data/';
                addon_path = 'C:/Users/u1046484/Documents/MATLAB/Addons/';
                
            case 'laptop'
                data_path = 'E:/Research/Antarctica/Data/';
                addon_path = fullfile('C:/Users/durba/', ...
                    'OneDrive - University of Utah/Documents/MATLAB/Addons/');
        end
        
    case false
        data_path = '/media/durbank/WARP/Research/Antarctica/Data/';
        addon_path = '/home/durbank/MATLAB/Add-Ons/';
end

% Addons needed for analysis
% Add Antarctic Mapping Toolbox (AMT) to path
addon_folder = fullfile(addon_path, 'AntarcticMappingTools_v5.03/');
addpath(genpath(addon_folder))
% Add export_fig to path
addon_folder = fullfile(addon_path, 'altmany-export_fig-cafc7c5/');
addpath(genpath(addon_folder))

% output_dir = uigetdir(data_path, ...
%     'Select directory to which to output images');

%%

% Load core data from file (data used was previously generated using
% import_cores.m)
core_file = fullfile(data_path, 'Ice-cores/SEAT_cores/SEAT_cores.mat');
cores = load(core_file);
Ndraw = 100;

% Find file names for previously processed SEAT2010 accumulation data
wild = '*.mat';
SEAT_files = dir(fullfile(data_path, 'radar/SEAT_Traverses/',...
    'SEAT2010Kuband/SEAT10_4toSEAT10_6/SMB_results/', wild));

% Preallocate arrays of sufficient size for data
SEAT_E = zeros(1, length(SEAT_files)*2*(50*1000/25));
SEAT_N = SEAT_E;
SEAT_SMB_MC = cell(1, length(SEAT_files)*2*(50*1000/25));
SEAT_yr = SEAT_SMB_MC;

for i = 1:length(SEAT_files)
    
    % Load relevent data from current data file
    load(fullfile(SEAT_files(i).folder, SEAT_files(i).name), 'Easting');
    load(fullfile(SEAT_files(i).folder, SEAT_files(i).name), 'Northing');
    load(fullfile(SEAT_files(i).folder, SEAT_files(i).name), 'SMB');
    load(fullfile(SEAT_files(i).folder, SEAT_files(i).name), 'SMB_yr');
    
    % Find position of last data entered into preallocated arrays
    next_idx = sum(~cellfun(@isempty, SEAT_SMB_MC)) + 1;
    
    % Fill current iteration data into preallocated arrays
    SEAT_E(next_idx:next_idx+length(Easting)-1) = Easting;
    SEAT_N(next_idx:next_idx+length(Northing)-1) = Northing;
    SEAT_SMB_MC(next_idx:next_idx+length(SMB)-1) = SMB;
    SEAT_yr(next_idx:next_idx+length(SMB_yr)-1) = SMB_yr;
    
end

% Find and remove empty SEAT indices (usually from excess preallocation)
keep_idx = find(~cellfun(@isempty, SEAT_SMB_MC));
SEAT_E = SEAT_E(keep_idx);
SEAT_N = SEAT_N(keep_idx);
SEAT_SMB_MC = SEAT_SMB_MC(keep_idx);
SEAT_yr = SEAT_yr(keep_idx);

% Calculate mean (and st. dev.) annual SMB from the MC simulations for
% SEAT data
seat_SMB = cellfun(@(x) mean(x, 2), SEAT_SMB_MC, 'UniformOutput', 0);
seat_std = cellfun(@(x) std(x, [], 2), SEAT_SMB_MC, 'UniformOutput', 0);

% Load previously processed 2011 OIB snow radar accumulation results
OIB_files = dir(fullfile(data_path, 'IceBridge/SEAT10_4to10_6/',...
    '2011_SNO/SMB_results/', wild));

OIB_E = zeros(1, length(OIB_files)*2*(50*1000/25));
OIB_N = OIB_E;
OIB_SMB_MC = cell(1, length(OIB_files)*2*(50*1000/25));
OIB_yr = OIB_SMB_MC;

for i = 1:length(OIB_files)
    load(fullfile(OIB_files(i).folder, OIB_files(i).name), 'Easting');
    load(fullfile(OIB_files(i).folder, OIB_files(i).name), 'Northing');
    load(fullfile(OIB_files(i).folder, OIB_files(i).name), 'SMB');
    load(fullfile(OIB_files(i).folder, OIB_files(i).name), 'SMB_yr');
    
    next_idx = sum(~cellfun(@isempty, OIB_SMB_MC)) + 1;
    OIB_E(next_idx:next_idx+length(Easting)-1) = Easting;
    OIB_N(next_idx:next_idx+length(Northing)-1) = Northing;
    OIB_SMB_MC(next_idx:next_idx+length(SMB)-1) = SMB;
    OIB_yr(next_idx:next_idx+length(SMB_yr)-1) = SMB_yr;
end

keep_idx = find(~cellfun(@isempty, OIB_SMB_MC));
OIB_E = OIB_E(keep_idx);
OIB_N = OIB_N(keep_idx);
OIB_SMB_MC = OIB_SMB_MC(keep_idx);
OIB_yr = OIB_yr(keep_idx);

oib_SMB = cellfun(@(x) mean(x, 2), OIB_SMB_MC, 'UniformOutput', 0);
oib_std = cellfun(@(x) std(x, [], 2), OIB_SMB_MC, 'UniformOutput', 0);

% Attempt to additionally load OIB elevation data, if available
try
    OIB_elev = false(1, length(OIB_files)*2*(50*1000/25));
    for i=1:length(OIB_files)
        load(fullfile(OIB_files(i).folder, OIB_files(i).name), 'elev');
        next_idx = sum(logical(OIB_elev)) + 1;
        OIB_elev(next_idx:next_idx+length(elev)-1) = elev;
    end
    keep_idx = find(logical(OIB_elev));
    OIB_elev = OIB_elev(keep_idx);
catch
    disp('Flag: Missing elevation data')
end

%%

sites = {'SEAT10_4', 'SEAT10_5', 'SEAT10_6'};
bias_stats = struct();

for i = 1:length(sites)
    
    site_nm = sites{i};
    
    % Load relevant radar data (previously generated using the above section)
    OIB_manual = load(fullfile(data_path, 'IceBridge/manual_layers', site_nm, ...
        strcat('layers_', site_nm, '_opt.mat')));
    
    % Load manually traced layers for current SEAT core site (generated using
    % 'draw_manual.m')
    tmp = load(fullfile(data_path, 'IceBridge/manual_layers', site_nm, ...
        strcat('manual_', site_nm, '.mat')));
    man_layers = tmp.man_all;
    
    % Remove manual count layer data deeper than the deepest point in processed
    % radargram data
    keep_idx = cellfun(@(x) round(x(:,2))<=size(OIB_manual.data_smooth,1), ...
        man_layers, 'UniformOutput', false);
    OIB_manual.man_layers = cellfun(@(x,y) x(y,:), man_layers, keep_idx, ...
        'UniformOutput', false);
    
    %%% Age-depth scales from manual count data
    
    % Preallocate matrix array for manual layer group number indices
    man_Gnum = zeros(size(OIB_manual.data_smooth));
    
    % Place manual layer group numbers within a matrix array of the same size
    % as radargram data
    for i = 1:length(OIB_manual.man_layers)
        
        layer_idx = sub2ind(size(man_Gnum), round(OIB_manual.man_layers{i}(:,2)), ...
            OIB_manual.man_layers{i}(:,1));
        man_Gnum(layer_idx) = i;
    end
    
    % Logical array of presence of manual layer member
    man_log = logical(man_Gnum);
    
    % Preallocate matrix of manual layer ages
    ages_man = zeros(size(OIB_manual.data_smooth));
    
    % Define surface age as the collection date of the radar data
    age_top = OIB_manual.collect_date;
    yr_pick1 = ceil(OIB_manual.collect_date - 1);
    
    % Interpolate manual layer age-depth scales for each trace
    for i = 1:size(ages_man,2)
        depths_i = [0; OIB_manual.depth(man_log(:,i))];
        yrs_i = ([age_top yr_pick1:-1:yr_pick1-length(depths_i)+2])';
        ages_man(:,i) = interp1(depths_i, yrs_i, OIB_manual.depth, ...
            'linear', 'extrap');
    end
    
    OIB_manual.man_ages = ages_man;
    
    % Find manual count data within a threshold of ith core and the nearest
    % manual count data to ith core
    dist_man = pdist2([cores.(site_nm).Easting  cores.(site_nm).Northing], ...
        [OIB_manual.Easting', OIB_manual.Northing']);
    trace_idx = 1:length(OIB_E);
    threshold = 5000;
    man_idx = trace_idx(dist_man<=threshold);
    [~, man_near] = min(dist_man);
    
    figure
    hold on
    for n = 1:Ndraw
        h0 = plot(OIB_manual.depth, OIB_manual.ages(:,man_near,n), ...
            'm', 'LineWidth', 0.5);
        h0.Color(4) = 0.03;
    end
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages, 2), ...
        'b', 'LineWidth', 2)
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages,2) + ...
        std(cores.(site_nm).ages, [], 2), 'b--', 'LineWidth', 0.5)
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages,2) - ...
        std(cores.(site_nm).ages, [], 2), 'b--', 'LineWidth', 0.5)
    plot(OIB_manual.depth, mean(squeeze(OIB_manual.ages(:,man_near,:)), 2), ...
        'm', 'LineWidth', 2)
    plot(OIB_manual.depth, OIB_manual.man_ages(:,man_near), ...
        'k', 'LineWidth', 2)
    hold off
    
    
    idx_ages = reshape(OIB_manual.ages(:,man_idx,:), ...
        size(OIB_manual.ages,1), length(man_idx)*Ndraw);
    figure
    hold on
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages, 2), ...
        'b', 'LineWidth', 2)
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages,2) + ...
        std(cores.(site_nm).ages, [], 2), 'b--', 'LineWidth', 0.5)
    plot(cores.(site_nm).depth, mean(cores.(site_nm).ages,2) - ...
        std(cores.(site_nm).ages, [], 2), 'b--', 'LineWidth', 0.5)
    plot(OIB_manual.depth, mean(idx_ages, 2), 'm', 'LineWidth', 2)
    plot(OIB_manual.depth, mean(idx_ages, 2) + std(idx_ages, [], 2), ...
        'm--', 'LineWidth', 0.5)
    plot(OIB_manual.depth, mean(idx_ages, 2) - std(idx_ages, [], 2), ...
        'm--', 'LineWidth', 0.5)
    plot(OIB_manual.depth, mean(OIB_manual.man_ages(:,man_idx), 2), ...
        'k', 'LineWidth', 2)
    plot(OIB_manual.depth, mean(OIB_manual.man_ages(:,man_idx), 2) + ...
        std(OIB_manual.man_ages(:,man_idx), [], 2), 'k--', 'LineWidth', 0.5)
    plot(OIB_manual.depth, mean(OIB_manual.man_ages(:,man_idx), 2) - ...
        std(OIB_manual.man_ages(:,man_idx), [], 2), 'k--', 'LineWidth', 0.5)
    hold off
    
    
    
    
    
    
    % Find SEAT data within a threshold of the ith core and the nearest 
    % trace to the core
    dist_SEAT = pdist2([cores.(site_nm).Easting  cores.(site_nm).Northing], ...
        [SEAT_E', SEAT_N']);
    trace_idx = 1:length(SEAT_E);
    threshold = 7500;
    SEATi_idx = trace_idx(dist_SEAT<=threshold);
    [~, SEATi_near] = min(dist_SEAT);
    
    % Find min length of SMB records within SEAT data in threshold, and
    % extract calendar year values
    min_length = min(cellfun(@length, seat_SMB(SEATi_idx)));
    SEATi_yr = SEAT_yr{SEATi_near}(1:min_length);
    
    % Subset OIB SMB records to those within distance threshold and clipped
    % to minimum length
    SEAT_clip = cellfun(@(x) x(1:min_length,:), SEAT_SMB_MC(SEATi_idx), ...
        'UniformOutput', false);
    
    % Convert full dataset (all MC simulations) to matrix)
    SEATi_SMB = cell2mat(SEAT_clip);
%     % Convert mean dataset (averages of MC simulation sets) to matrix
%     SEATi_SMB = cell2mat(cellfun(@(x) mean(x,2), SEAT_clip, ...
%         'UniformOutput', false));
    
    % Find OIB data within a threshold of the ith core and the nearest 
    % trace to the core
    dist_OIB = pdist2([cores.(site_nm).Easting  cores.(site_nm).Northing], ...
        [OIB_E', OIB_N']);
    trace_idx = 1:length(OIB_E);
    OIBi_idx = trace_idx(dist_OIB<=threshold);
    [~, OIBi_near] = min(dist_OIB);
    
    % Find min length of SMB records within OIB data in threshold, and
    % extract calendar year values
    min_length = min(cellfun(@length, oib_SMB(OIBi_idx)));
    OIBi_yr = OIB_yr{OIBi_near}(1:min_length);
    
    % Subset OIB SMB records to those within distance threshold and clipped
    % to minimum length
    OIB_clip = cellfun(@(x) x(1:min_length,:), OIB_SMB_MC(OIBi_idx), ...
        'UniformOutput', false);
    
    % Convert full dataset (all MC simulations) to matrix)
    OIBi_SMB = cell2mat(OIB_clip);
%     % Convert mean dataset (averages of MC simulation sets) to matrix
%     OIBi_SMB = cell2mat(cellfun(@(x) mean(x,2), OIB_clip, ...
%         'UniformOutput', false));
    
    figure
    hold on
    for n = 1:Ndraw
        h0 = plot(SEAT_yr{SEATi_near}, SEAT_SMB_MC{SEATi_near}(:,n), ...
            'r', 'LineWidth', 0.5);
        h0.Color(4) = 0.05;
    end
    for n = 1:Ndraw
        h0 = plot(OIB_yr{OIBi_near}, OIB_SMB_MC{OIBi_near}(:,n), ...
            'm', 'LineWidth', 0.5);
        h0.Color(4) = 0.05;
    end
    for n = 1:Ndraw
        h0 = plot(cores.(site_nm).SMB_yr, cores.(site_nm).SMB(:,n), ...
            'b', 'LineWidth', 0.5);
        h0.Color(4) = 0.05;
    end
    plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB,2),'b','LineWidth',2)
%     plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB, 2) + ...
%         std(cores.(site_nm).SMB, [], 2),'b--', 'LineWidth', 0.5)
%     plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB, 2) - ...
%         std(cores.(site_nm).SMB, [], 2),'b--', 'LineWidth', 0.5)
    plot(SEAT_yr{SEATi_near}, mean(SEAT_SMB_MC{SEATi_near},2), 'r','LineWidth',2)
%     plot(SEAT_yr{SEAT_near}, mean(SEAT_SMB_MC{SEAT_near},2) + ...
%         std(SEAT_SMB_MC{SEAT_near}, [], 2), 'r--', 'LineWidth', 0.5)
%     plot(SEAT_yr{SEAT_near}, mean(SEAT_SMB_MC{SEAT_near},2) - ...
%         std(SEAT_SMB_MC{SEAT_near}, [], 2), 'r--', 'LineWidth', 0.5)
    plot(OIB_yr{OIBi_near}, mean(OIB_SMB_MC{OIBi_near},2), 'm', 'LineWidth', 2)
%     plot(OIB_yr{OIB_near}, mean(OIB_SMB_MC{OIB_near},2) + ...
%         std(OIB_SMB_MC{OIB_near}, [], 2), 'm--', 'LineWidth', 0.5)
%     plot(OIB_yr{OIB_near}, mean(OIB_SMB_MC{OIB_near},2) - ...
%         std(OIB_SMB_MC{OIB_near}, [], 2), 'm--', 'LineWidth', 0.5)
    hold off
    
    
    
    
    figure
    hold on
    plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB,2), ...
        'b', 'LineWidth', 2)
    plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB, 2) + ...
        std(cores.(site_nm).SMB, [], 2),'b--', 'LineWidth', 0.5)
    plot(cores.(site_nm).SMB_yr, mean(cores.(site_nm).SMB, 2) - ...
        std(cores.(site_nm).SMB, [], 2),'b--', 'LineWidth', 0.5)
    plot(SEATi_yr, mean(SEATi_SMB,2), 'r', 'LineWidth', 2)
    plot(SEATi_yr, mean(SEATi_SMB,2) + std(SEATi_SMB, [], 2), ...
        'r--', 'LineWidth', 0.5)
    plot(SEATi_yr, mean(SEATi_SMB,2) - std(SEATi_SMB, [], 2), ...
        'r--', 'LineWidth', 0.5)
    plot(OIBi_yr, mean(OIBi_SMB,2), 'm', 'LineWidth', 2)
    plot(OIBi_yr, mean(OIBi_SMB,2) + std(OIBi_SMB, [], 2), ...
        'm--', 'LineWidth', 0.5)
    plot(OIBi_yr, mean(OIBi_SMB,2) - std(OIBi_SMB, [], 2), ...
        'm--', 'LineWidth', 0.5)
    
    
    
    
    
    yr_start = min([cores.(site_nm).SMB_yr(1) ...
        cellfun(@(x) x(1), SEAT_yr(SEATi_idx)) ...
        cellfun(@(x) x(1), OIB_yr(OIBi_idx))]);
    yr_end = max([cores.(site_nm).SMB_yr(end) ...
        cellfun(@(x) x(end), SEAT_yr(SEATi_idx)) ...
        cellfun(@(x) x(end), OIB_yr(OIBi_idx))]);
    site_yr_i = (yr_start:-1:yr_end)';
    
    core_start = find(cores.(site_nm).SMB_yr==yr_start);
    core_end = find(cores.(site_nm).SMB_yr==yr_end);
    core_SMB_i = cores.(site_nm).SMB(core_start:core_end,:);
    
    SEAT_start = cellfun(@(x) find(x==yr_start, 1), SEAT_yr(SEATi_idx));
    SEAT_end = cellfun(@(x) find(x==yr_end, 1), SEAT_yr(SEATi_idx));
    OIB_start = cellfun(@(x) find(x==yr_start, 1), OIB_yr(OIBi_idx));
    OIB_end = cellfun(@(x) find(x==yr_end, 1), OIB_yr(OIBi_idx));
    
    
    SEAT_SMB_near = SEAT_SMB_MC{SEATi_near}(SEAT_start(1):...
        SEAT_start(1)+length(site_yr_i)-1,:);
    OIB_SMB_near = OIB_SMB_MC{OIBi_near}(OIB_start(1):...
        OIB_start(1)+length(site_yr_i)-1,:);
    
    
    SEAT_tmp = cellfun(@(x) mean(x, 2), SEAT_SMB_MC, 'UniformOutput', 0);
    SMB_tmp = SEAT_tmp(SEATi_idx);
    SEATi_SMB = zeros(length(site_yr_i), length(SEAT_start));
    for j = 1:length(SEAT_start)
        
        SEATi_SMB(:,j) = SMB_tmp{j}(SEAT_start(j):SEAT_end(j));
    end
    
    OIB_tmp = cellfun(@(x) mean(x, 2), OIB_SMB_MC, 'UniformOutput', 0);
    SMB_tmp = OIB_tmp(OIBi_idx);
    OIBi_SMB = zeros(length(site_yr_i), length(OIB_start));
    for j = 1:length(OIB_start)
        
        OIBi_SMB(:,j) = SMB_tmp{j}(OIB_start(j):OIB_end(j));
    end
    
    
    
    
    % SEAT bias relative to the core (nearest trace distribution)
    bias_SEATnear = (SEAT_SMB_near - mean(core_SMB_i,2))./mean(core_SMB_i,2);
    bias_Snear_mu = median(bias_SEATnear(:));
%     bias_Snear_mu = mean(bias_SEATnear(:));
    bias_Snear_std = std(bias_SEATnear(:));
    bias_Snear_SEM = bias_Snear_std/sqrt(numel(bias_SEATnear));
    T_SEATnear = tinv(0.975, numel(bias_SEATnear)-1);
    MoE_SEATnear = T_SEATnear*bias_Snear_SEM;
    
    % OIB bias relative to the core (nearest trace distribution)
    bias_OIBnear = (OIB_SMB_near - mean(core_SMB_i,2))./mean(core_SMB_i,2);
    bias_Onear_mu = median(bias_OIBnear(:));
%     bias_Onear_mu = mean(bias_OIBnear(:));
    bias_Onear_std = std(bias_OIBnear(:));
    bias_Onear_SEM = bias_Onear_std/sqrt(numel(bias_OIBnear));
    T_OIBnear = tinv(0.975, numel(bias_OIBnear)-1);
    MoE_OIBnear = T_OIBnear*bias_Onear_SEM;

    % SEAT bias relative to the core (distribution of nearby mean traces)
    bias_SEATi = (SEATi_SMB - mean(core_SMB_i,2))./mean(core_SMB_i,2);
    biasSEATi_mu = median(bias_SEATi(:));
%     biasSEATi_mu = mean(bias_SEATi(:));
    biasSEATi_std = std(bias_SEATi(:));
    biasSEATi_sem = biasSEATi_std/sqrt(numel(bias_SEATi));
    T_SEATi = tinv(0.975, numel(bias_SEATi)-1);
    MoE_SEATi = T_SEATi*biasSEATi_sem;
    
    % OIB bias relative to the core (distribution of nearby mean traces)
    bias_OIBi = (OIBi_SMB - mean(core_SMB_i,2))./mean(core_SMB_i,2);
    biasOIBi_mu = median(bias_OIBi(:));
%     biasOIBi_mu = mean(bias_OIBi(:));
    biasOIBi_std = std(bias_OIBi(:));
    biasOIBi_sem = biasOIBi_std/sqrt(numel(bias_OIBi));
    T_OIBi = tinv(0.975, numel(bias_OIBi)-1);
    MoE_OIBi = T_OIBi*biasOIBi_sem;
    
    bias_mu = [bias_Snear_mu; biasSEATi_mu; bias_Onear_mu; biasOIBi_mu];
    bias_MoE = [MoE_SEATnear; MoE_SEATi; MoE_OIBnear; MoE_OIBi];
    bias_std = [bias_Snear_std; biasSEATi_std; bias_Onear_std; biasOIBi_std];
    bias_stats.(site_nm) = table(bias_mu, bias_MoE, bias_std, ...
        'VariableNames', {'mean', 'MoE', 'StdDev'}, 'RowNames', ...
        {'SEAT-core (nearest trace)', 'SEAT-core (mean traces)', ...
        'OIB-core (nearest trace)', 'OIB-core (mean traces)'});
    
    
    
    
    
%     SEATi_b1 = zeros(1, size(SEATi_SMB, 2));
%     SEATi_p = zeros(1, size(SEATi_SMB, 2));
%     for j = 1:size(SEATi_SMB, 2)
% %         [trend, stats] = robustfit(site_yr_i, SEATi_SMB(:,j));
% %         SEATi_b1(j) = trend(2);
% %         SEATi_p(j) = stats.p(2);
%         [trend,~,~,~,stats] = regress(SEATi_SMB(:,j), ...
%             [ones(length(site_yr_i),1) site_yr_i]);
%         SEATi_b1(j) = trend(2);
%         SEATi_p(j) = stats(3);
%     end
%     
%     OIBi_b1 = zeros(1, size(OIBi_SMB, 2));
%     OIBi_p = zeros(1, size(OIBi_SMB, 2));
%     for j = 1:size(OIBi_SMB, 2)
% %         [trend, stats] = robustfit(siteI_yr, OIBi_SMB(:,j));
% %         OIBi_b1(j) = trend(2);
% %         OIBi_p(j) = stats.p(2);
%         [trend,~,~,~,stats] = regress(OIBi_SMB(:,j), ...
%             [ones(length(site_yr_i),1) site_yr_i]);
%         OIBi_b1(j) = trend(2);
%         OIBi_p(j) = stats(3);
%     end
%     
%     core_trend = zeros(1, size(core_SMB_i,2));
%     core_p = zeros(1, size(core_SMB_i,2));
%     for j = 1:size(core_SMB_i,2)
% %         [trend, stats] = robustfit(siteI_yr, coreI_SMB(:,j));
% %         core_trend(j) = trend(2);
% %         core_p(j) = stats.p(2);
%         [trend_tmp,~,~,~,stats] = regress(core_SMB_i(:,j), ...
%             [ones(length(site_yr_i),1) site_yr_i]);
%         core_trend(j) = trend_tmp(2);
%         core_p(j) = stats(3);
%     end
    
    
    
end
