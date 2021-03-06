% Function for stacking radar records by an arbitrary window size

function [mdata_stack] = radar_stack(mdata, window_length)

stack_val = (1:window_length:mdata.dist(end)) - 1;
stack_idx = zeros(1, length(stack_val));
for i = 1:length(stack_val)
    stack_idx(i) = find(mdata.dist > stack_val(i), 1, 'first')-1;
end
stack_idx = [unique(stack_idx) length(mdata.dist)];

% Preallocate stacked arrays
E_stack = zeros(1, length(stack_val));
N_stack = zeros(1, length(stack_val));
lat_stack = zeros(1, length(stack_val));
lon_stack = zeros(1, length(stack_val));
time_stack = NaT(1, length(stack_val));
dist_stack = stack_val;
% dist_stack = zeros(1, length(stack_val));
data_stack = zeros(size(mdata.data_out,1), length(stack_val));

for i = 1:length(stack_idx)-1
    time_stack(i) = datetime(mean(datenum(mdata.collect_time(...
        stack_idx(i):stack_idx(i+1)))), 'ConvertFrom', 'datenum');
    E_stack(i) = mean(mdata.Easting(stack_idx(i):stack_idx(i+1)));
    N_stack(i) = mean(mdata.Northing(stack_idx(i):stack_idx(i+1)));
    lat_stack(i) = mean(mdata.lat(stack_idx(i):stack_idx(i+1)));
    lon_stack(i) = mean(mdata.lon(stack_idx(i):stack_idx(i+1)));
    data_stack(:,i) = mean(mdata.data_out(...
        :,stack_idx(i):stack_idx(i+1)), 2);
end

% Check for missing timestamp, and remove traces without timestamp
keep_idx = ~isnat(time_stack);

mdata_stack = struct('collect_time', time_stack(keep_idx), ...
    'Easting', E_stack(keep_idx), 'Northing', N_stack(keep_idx), ...
    'Lat', lat_stack(keep_idx), 'Lon', lon_stack(keep_idx), ...
    'dist', dist_stack(keep_idx), 'data_stack', data_stack(:,keep_idx), ...
    'time_trace', mdata.time_trace);

% Check for elevation data, and if present, stack similarly as other data
if isfield(mdata, 'elev')
    elev_stack = zeros(1, length(stack_val));
    for i = 1:length(stack_idx)-1
        elev_stack(i) = mean(mdata.elev(stack_idx(i):stack_idx(i+1)));
    end
    mdata_stack.elev = elev_stack;
end


% if size(mdata.depth, 2) > 1
% %     stack_idx = 1:window_sz:size(mdata.data_out, 2);
%     E_stack = zeros(1, length(stack_idx)-1);
%     N_stack = zeros(1, length(stack_idx)-1);
%     dist_stack = zeros(1, length(stack_idx)-1);
%     data_stack = zeros(size(mdata.data_out, 1), length(stack_idx)-1);
%     rho_stack = zeros(size(mdata.rho_coeff, 1), length(stack_idx)-1);
%     var_stack = zeros(size(mdata.rho_var, 1), length(stack_idx)-1);
%     depth_stack = zeros(size(mdata.data_out, 1), length(stack_idx)-1);

%     for i = 1:length(stack_idx)-1
%         E_stack(i) = mean(mdata.Easting(stack_idx(i):stack_idx(i+1)));
%         N_stack(i) = mean(mdata.Northing(stack_idx(i):stack_idx(i+1)));
%         dist_stack(i) = round(mean(mdata.dist(stack_idx(i):stack_idx(i+1))));
%         data_stack(:,i) = mean(mdata.data_out(:,stack_idx(i):stack_idx(i+1)), 2);
%         rho_stack(:,i) = mean(mdata.rho_coeff(:,stack_idx(i):stack_idx(i+1)), 2);
%         var_stack(:,i) = mean(mdata.rho_var(:,stack_idx(i):stack_idx(i+1)), 2);
%         depth_stack(:,i) = mean(mdata.depth(:,stack_idx(i):stack_idx(i+1)), 2);
%     end

% else
% %     stack_idx = 1:window_sz:size(mdata.data_out, 2);
%     E_stack = zeros(1, length(stack_idx)-1);
%     N_stack = zeros(1, length(stack_idx)-1);
%     dist_stack = zeros(1, length(stack_idx)-1);
%     data_stack = zeros(size(mdata.data_out, 1), length(stack_idx)-1);
%     for i = 1:length(stack_idx)-1
%         E_stack(i) = mean(mdata.Easting(stack_idx(i):stack_idx(i+1)));
%         N_stack(i) = mean(mdata.Northing(stack_idx(i):stack_idx(i+1)));
%         dist_stack(i) = round(mean(mdata.dist(stack_idx(i):stack_idx(i+1))));
%         data_stack(:,i) = mean(mdata.data_out(:,stack_idx(i):stack_idx(i+1)), 2);
%     end
%     rho_stack = repmat(mdata.rho_coeff, 1, size(data_stack, 2));
%     var_stack = repmat(mdata.rho_var, 1, size(data_stack, 2));
%     depth_stack = repmat(mdata.depth, 1, size(data_stack, 2));
% end

% % Determine whether manual layers are present in data, and extract layers
% % at same resolution of stacked data where present
% if isfield(mdata, 'arr_layers')
%     man_layers = mdata.arr_layers(:,stack_idx(1:end-1));
%     mdata_stack = struct('collect_date', mdata.collect_date, 'Easting', E_stack,...
%         'Northing', N_stack, 'dist', dist_stack,  'depth', depth_stack, ...
%         'data_stack', data_stack, 'rho_coeff', rho_stack, 'rho_var', var_stack,...
%         'man_layers', man_layers);
% else
%     % Export stacked radar data as a data structure with specified fields
%     mdata_stack = struct('collect_date', mdata.collect_date, 'Easting', E_stack,...
%         'Northing', N_stack, 'dist', dist_stack,  'depth', depth_stack, ...
%         'data_stack', data_stack, 'rho_coeff', rho_stack, 'rho_var', var_stack);
% end

% % Check for elevation data, and if present, stack similarly as other data
% if isfield(mdata, 'elev')
%     elev_stack = zeros(1, length(stack_idx)-1);
%     for i = 1:length(stack_idx)-1
%         elev_stack(i) = mean(mdata.elev(stack_idx(i):stack_idx(i+1)));
%     end
%     mdata_stack.elev = elev_stack;
% end
end
