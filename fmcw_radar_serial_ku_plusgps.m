% Ben Panzer
% William Blake
% Carl Leuschen
%adapted by Lora Koenig for WAIS traverse.

% Change the data set prefix, start number, stop number, filebase, output
% directory, and info string

close all; clear all; clc;
format compact; format short;

% Filebase for the data
data_set  = 2;
start_num = 69;
% start_num = 0;
stop_num  = 69;
% stop_num = 240;
radar_dir = ['/Volumes/WARP/Research/Antarctica/WAIS Variability' filesep...
    'SEAT_Traverses/RawDataDurban/SEAT2011/'];


pulse_length = 250e-6;
bandwidth = 2.6320e9;

% Set GPS file name
gps_file='/icebridgedata/lorak/wais_2010/GPS/12172010.csv'; %Set GPS file for the day


% Output Directory
out_dir = '/Volumes/WARP/Research/Antarctica/WAIS Variability/Data/radar-RAW/';
% out_dir = '/icebridgedata/lorak/wais_2010/ku_band_12172010_out/';

% Title for echogram
info_str   = 'Ku-band radar WAIS 2010';

%XXXXXXXXXXXXXXXXXXXX NOT NECESSARY TO MODIFY FOR ARCTIC DATA XXXXXXXXXXXXXXXXXXXXXXX%

% Sampling frequency of the data acquisition system
fs = 62.5e6;

% Length of the FFT
FFT_len = floor((pulse_length*fs)/1000)*1000;

% Real part of the dielectric constant of dry snow (currently set for air)

rho=0.320;
eps_snow = 1+1.5995*rho+1.861*rho^3; %from Matzler

% Number of presums is based on the unfocused synthetic aperture length
presums    = 4;

%XXXXXXXXXXXXXXXXXXXXXX END OF PARAMETERS XXXXXXXXXXXXXXXXXXXXXXXXXXX%

% Pixel size is a function of the length of FFT, pulse length, bandwidth
% and the assumed dielectric constant of dry snow
c   = 299792458;
pixel_size_snow = (fs*pulse_length*c)/(2*FFT_len*bandwidth*sqrt(eps_snow));
pixel_size_air = (fs*pulse_length*c)/(2*FFT_len*bandwidth);
delta_t = (fs*pulse_length)/(2*FFT_len*bandwidth); %use this as pixel size generic


% List all files matching 'wild' within radar directory
wild = 'radar*';
files = dir(strcat(radar_dir, wild));


for i1 = 1:length(files)
    tic
%     i1
    filename = strcat(radar_dir, files(i1).name);
%     filename = sprintf('%s.%04d.dat',filebase,i1);
    fid = fopen(filename,'r','ieee-be');
    deadbeef = hex2dec('deadbeef');
    
    while 1
        tmp_search     = fread(fid,80000,'uint8');
        tmp_search_len = length(tmp_search);
        tmp_search     = tmp_search(1:(floor(tmp_search_len/4)*4));
        tmp            = tmp_search(1:tmp_search_len-3)*2^24+tmp_search(2:tmp_search_len-2)*2^16+ ...
            tmp_search(3:tmp_search_len-1)*2^8+tmp_search(4:tmp_search_len);
        if isempty(tmp_search)
            error('No Records found in %s',just_fn);
        end
        deadbeef_idx = find(tmp == deadbeef);
        if length(deadbeef_idx) >=2
            rec_len = (deadbeef_idx(2) - deadbeef_idx(1))/2;
        end
        if ~isempty(deadbeef_idx)
            fseek(fid,-tmp_search_len,'cof');
            fseek(fid,(deadbeef_idx(1)-1)*1,'cof');
            break;
        end
        fseek(fid,-4,'cof');
    end
    index = ftell(fid);
    clear tmp tmp_search tmp_search_len
    
    % Windowing for fast and slow time
    fast_time_win = hanning(FFT_len); %LK fast time is the sampling rate
    slow_time_win = hanning(presums); %LK slow time is the PRF May want
    %to remove
    
    % Resampling the data as samples are flipped
    %%LK are the data I have  flipped? Yes Per Ben This is a firm ware
    %%issue with the radars and is fixed here.
    rsmp = zeros(1,FFT_len);
    for i0 = 1:FFT_len/2
        rsmp(2*i0-1) = 2*i0 + 16; %+16 is for hte header data
        rsmp(2*i0) = 2*i0-1 + 16;
    end
    
    % Read in data
    fseek(fid,index,'bof');
    fprintf('Reading In data\n');
    Data = fread(fid,[rec_len,Inf],'uint16=>float32');
    fclose(fid);
    
    fprintf('Processing data\n');
    hdr = Data(1:16,:);
    Data = Data(rsmp,:);
    
    % Random records contain saturated triplets spaced by 3 and 2 or
    % quadruplets spaced by 2, 1, and 2.
    % Find these triplets and replace them with the mean of adjacent
    % samples
    for idx = 1:size(Data,2)
        bad_idx = find(Data(:,idx) < 4000);
        if (length(bad_idx) == 3) && all(diff(bad_idx) == [3; 2])
            if bad_idx(1) > 1
                Data(bad_idx(1),idx) = (Data(bad_idx(1)-1,idx)+Data(bad_idx(1)+1,idx))/2;
            else
                Data(bad_idx(1),idx) = Data(bad_idx(1)+1,idx);
            end
            Data(bad_idx(2),idx) = (Data(bad_idx(2)-2,idx)+Data(bad_idx(2)+1,idx))/2;
            Data(bad_idx(2)-1,idx) = (Data(bad_idx(2)-2,idx)+Data(bad_idx(2)+1,idx))/2;
            if bad_idx(3) < size(Data,1)
                Data(bad_idx(3),idx) = (Data(bad_idx(3)-1,idx)+Data(bad_idx(3)+1,idx))/2;
            else
                Data(bad_idx(3),idx) = Data(bad_idx(3)-1,idx);
            end
        elseif (length(bad_idx) == 4) && all(diff(bad_idx) == [2; 1; 2])
            if bad_idx(1) > 1
                Data(bad_idx(1),idx) = (Data(bad_idx(1)-1,idx)+Data(bad_idx(1)+1,idx))/2;
            else
                Data(bad_idx(1),idx) = Data(bad_idx(1)+1,idx);
            end
            Data(bad_idx(3),idx) = (Data(bad_idx(3)-2,idx)+Data(bad_idx(3)+1,idx))/2;
            Data(bad_idx(2),idx) = (Data(bad_idx(2)-1,idx)+Data(bad_idx(2)+2,idx))/2;
            if bad_idx(4) < size(Data,1)
                Data(bad_idx(4),idx) = (Data(bad_idx(4)-1,idx)+Data(bad_idx(4)+1,idx))/2;
            else
                Data(bad_idx(4),idx) = Data(bad_idx(4)-1,idx);
            end
        end
    end
    
    % Subtract the mean from the data
    for st_idx = 1:size(Data,2)
        Data(:,st_idx) = Data(:,st_idx)-mean(Data(:,st_idx));
    end
    
    % Perform Coherent Integrations
    siz = size(Data);
    new_len      = floor(siz(2)/presums);
    nearest_len  = floor(siz(2)/presums)*presums;
    Data         = reshape(Data(:,1:nearest_len), ...
        [siz(1) presums new_len]);
    tmp_Data      = zeros(size(Data,1),size(Data,3),'single');
    slow_time_win = repmat(slow_time_win.',[size(Data,1),1,1]);
    for st_idx = 1:size(Data,3)
        Data(:,:,st_idx)   = Data(:,:,st_idx).*slow_time_win;
        tmp_Data(:,st_idx) = mean(Data(:,:,st_idx),2);
    end
    Data = double(tmp_Data);
    clear tmp_Data slow_time_win
    %     LK removed this step for stationary data the slow time filter
    %     takes out the laer when the radar is stationary and is not ideal
    %     for the ground plication.  The non-stationary data is not
    %     effected.
    %     % High pass filter in slow time
    %         b     = fir1(64,0.2,'high');
    %         Data  = filtfilt(b,1,Data.').';
    %
    
    % Window data in fast time
    for st_idx = 1:size(Data,2)
        Data(:,st_idx) = Data(:,st_idx).*fast_time_win;
    end
    
    Data     = fft(Data);
    fft_idxs = 1:(floor(size(Data,1)/2));
    Data     = Data(fft_idxs,:);
    %Data     = flipud(Data);
    Data     = abs(Data);
    
      %
    %     % Tracking the surface return and eliminating outliers to set the data
    %     % start and stop range
    %     [tmp,pk]    = max(20.*log10(Data(:,500:new_len-500)),[],1);
    %     pk_stdev    = floor(std(pk));
    %     avg_pk      = floor(mean(pk));
    %     count       = 0;
    %     for idx = 1:length(pk)
    %         if pk(idx) < avg_pk - pk_stdev || pk(idx) > avg_pk + pk_stdev
    %             continue;
    %         else
    %             count           = count+1;
    %             new_pk(count)   = pk(idx);
    %         end
    %     end
    %
    %     avg_pk      = floor(mean(new_pk));
    %     clear count new_pk
    %
    %     % Set start and stop indices around the max value
    %     istart  = max(1,avg_pk - round(30/pixel_size_snow));
    %     istop   = min(size(Data,1),avg_pk + round(40/pixel_size_snow));
    %LK for the ground based radars we know where the surface is and the the
    %penetration depth so we can set the istart and istop values.
    istart = 1; %allow us to see the antenna height at 170 or 171 is the snow surface
    istop = 1016; %this is 40 meters into the snow assuming rho=320. and is below the penetration depth.
    
    Data            = Data(istart:istop,:);
    Depth           = ((0:istop-istart)-169)*pixel_size_snow;
    %     tmp_ind=1:169;
    %     Depth(tmp_ind)=0;
    %     clear tmp_ind
    
    % Calculate radar time and position values
    utc_sec  = hdr(9,:).*2^16 + hdr(10,:);
    utc_frac = hdr(11,:).*2^16 + hdr(12,:);
    utc_time = utc_sec+utc_frac/(fs);
    gps_time = (utc_time+16)/3600;
    %add the + 15 sec UTC to GPS time conversion and 1 second
    %for the 1u daq write delay
    %in hours to match gps_data
    
    clear utc_sec utc_frac utc_time
    
%     %load GPS file
%     gps_data=csvread(gps_file);
%     
%     % Convert UTC time to GPS time and interpolate latitude, longitude, and
%     % aircraft altitude to record time
%     Latitude  = interp1(gps_data(:,4),gps_data(:,1),gps_time);
%     Longitude = interp1(gps_data(:,4),gps_data(:,2),gps_time);
%     Altitude  = interp1(gps_data(:,4),gps_data(:,3),gps_time);
%     
%     clear gps_data
%     
%     % Coherent decimation of GPS data to correspond with coherently
%     % integrated radar data
%     gps_time     = gps_time(floor(presums/2):presums:nearest_len);
%     Latitude     = Latitude(floor(presums/2):presums:nearest_len);
%     Longitude    = Longitude(floor(presums/2):presums:nearest_len);
%     Altitude     = Altitude(floor(presums/2):presums:nearest_len);
%     Distance     = dist_KBrunt(Latitude,Longitude);
%     cshift = 0; % there is not cshift for ground data but kept for consistency with IceBridge data fromat.
    
    fprintf('Creating images\n');
    
    % Plot Normal
    hf = figure;
    imagesc([],Depth,20.*log10(Data));
    caxis([40 150]);
    hold on;
    colormap(1-bone);
    
%     xt=1:floor(length(Latitude)/5):length(Latitude); %set tick marks
%     set(gca,'XTick',xt,'XTickLabel', round2(Distance(xt),.01))
%     img_title = sprintf('Data %02d Echogram %04d, %s, %6.2f %6.2f',data_set,i1,info_str, Latitude(1), Longitude(1));
%     title(img_title,'FontWeight','Bold');
%     ylabel('Depth [m]');
%     xlabel('Distance [km]');
%     filename = sprintf('%sFFT_image.%02d.%04d',out_dir,data_set,i1);
%     print('-djpeg','-r300',[filename '.jpg']);
%     close(hf);
%     
%     fprintf('Writing data to file\n');
%     % Write necessary data to binary format for upload to NSIDC
%     write_data(1:2:2*size(Data,1),:) = real(Data);
%     write_data(2:2:2*size(Data,1),:) = imag(Data);
%     noBytes         = 4*7+8*size(Data,1);
%     filename_write = sprintf('%sdata%02d.%04d.bin',out_dir,data_set,i1);
%     fid             = fopen(filename_write,'w');
%     for idx = 1:size(Data,2)
%         fwrite(fid,noBytes,'int32');
%         fwrite(fid,gps_time(idx)*1e3,'int32');
%         fwrite(fid,Latitude(idx)*1e6,'int32');
%         fwrite(fid,Longitude(idx)*1e6,'int32');
%         fwrite(fid,Altitude(idx)*1e3,'int32');
%         fwrite(fid,cshift,'int32'); %keep for consistency with IceBridge data but is 0 for ground data
%         fwrite(fid,delta_t*1e12,'float32');
%         fwrite(fid,write_data(:,idx),'float32');
%     end
%     fclose(fid);
%     clear noBytes write_data
    
    
    toc
end

