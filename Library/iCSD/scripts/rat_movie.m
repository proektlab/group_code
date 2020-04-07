% Current Source Density for rat data

% Note that each file provided contains two variables, ans and data1
% data1 is 14000x60 array with 60 trials of 14000 points each
% sampling frequency is 10kHz
data_length = 14000;
nr_trials = 60;

% Rat name
rat_name = 'sow1';
% The path to the experimental data is expected to be ../rat/rat_x_y_z.mat

moviefolder = 'movies';
datafolder = 'data';

%%% Preprocessing parameters
use_sgfilter    = 1;    % Do you want to use Savitzky-Golay filtering?
% 0 - no, 1 - yes
% Savitzky-Golay filter parameters
% the values below define how much you smooth out the data
filter_order    = 3;	% Savitzky-Golay filter order; example in sgolayfilt takes 3
window_size     = 9;    % smoothing window size in Savitzky-Golay filter;
% example in sgolayfilt takes 41 points
% Here: 9 - less smoothing and smearing
save_prep_data  = 1;    % Do you want to save the smoothed, detrended and rescaled data
% for further use? (in datafolder, file rat_field_pot.mat)
def_use_prep_data = 1;  % Use preprocessed data if avilable: 0 - no, 1 - yes, -1 - ask

%%% Output parameters
int_prec_s      = 3;	% Interpolation precision for int CSD (= ntimes in interp2)
n_colors        = 512;
framerate       = 7;    % Default is 15
movie_bgd_imgs  = 1;    % Background anatomical images, requires
% grayscale background images rat _ 1..5.jpg
% in datafolder
% Scaling, normalization etc...
movie_subtract_bgd = 1; % Subtract average from data, see times below
% Method
CSD_method      = 'lin';
% 'lin' 'splinen' 'splinem' 'step'
bound_cond      = 'S';	% Boundary conditions
% S - standard (cut-off),
% B - zeros at additional layer,
% D - repeated values at additional layer,
% JB, JC - jittering over ball, cube using B
% KB, KC - jittering using D

csd_scale_factor = 4;   % Scaling factor, larger value yields more details
% but less info about strong sources; 4 seems ok

save_int_CSD = 1;       % Do you want to save interpolated CSD?
use_saved_CSD = 1;      % Do you want to use previously saved CSD
% if available?

% Electrodes array geometry
nr_of_x = 4;
nr_of_y = 5;
nr_of_z = 7;
distance = 0.7; % milimeters
sigma = 300;    % A/V/mm, value = 300 (0.3 S/m) taken from Hamalainen et al.
% see also Pettersen et al. Other sources: 60-70 (Ueno,
% Sekino)

% CSD is calculated for data points in the following range:
show_first_ms = -10; % time in ms of the first data point we want to display with respect to the stimulus
show_last_ms  = 20; % time in ms of the last  data point we want to display with respect to the stimulus
subt_first_ms = -10; % Subtract mean calculated in this range
subt_last_ms = 0;
%%% Data times
time_start = -405;  % time in ms of the first data point with respect to the stimulus
time_stop  = 995;   % time in ms of the last  data point with respect to the stimulus, modulo delta_t

CSD_filename = [rat_name '_' int2str(int_prec_s) ...
    '_' CSD_method '_' bound_cond '_'];
CSD_filename = [CSD_filename int2str(show_first_ms) '_' ...
    int2str(show_last_ms)];
if movie_subtract_bgd
    CSD_filename = [CSD_filename '_n_' int2str(subt_first_ms) '_' ...
        int2str(subt_last_ms) '.mat'];
else
    CSD_filename = [CSD_filename '.mat'];
end;
CSD_filename = fullfile(datafolder, CSD_filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% End of configuration parameters %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delta_t = (time_stop-time_start)/data_length; % distance between consecutive measurements in time
timesc = time_start:delta_t:time_stop-delta_t;
% change the time axis so that 0 is the stimulus time
% vector timesc has exactly data_length points

show_first = round((show_first_ms - time_start+1)/delta_t);
show_last  = round((show_last_ms - time_start+1)/delta_t);
show_stimulus = round((0 - time_start+1)/delta_t); % Location of stimulus
subt_first = round((subt_first_ms - time_start+1)/delta_t);
subt_last  = round((subt_last_ms - time_start+1)/delta_t);
nr_frames = show_last-show_first+1;

field_potentials = zeros(data_length,nr_of_x,nr_of_y,nr_of_z);

%%% Detection of previously saved preprocessed data
use_prep_data = 0;
if def_use_prep_data==1
    if exist(fullfile(datafolder, [rat_name '_field_pot.mat']), 'file')
        use_prep_data = 1;
    end
end

%%% Load data
switch use_prep_data
    case 0 %%% Load raw data and preprocess
        disp('  Loading and preprocessing raw data... ')
        for x=1:nr_of_x
            for y=1:nr_of_y
                for z = 1:nr_of_z
                    electrode = [ rat_name '_' int2str(x) '_' int2str(y) '_' int2str(z)];
                    load(fullfile('..',rat_name, electrode)); % here we load experimental results into matrix data1
                    if use_sgfilter
                        data2 = sgolayfilt(data1,filter_order,window_size); % smooth out data with SG filter
                    else
                        data2 = data1;
                    end;
                    data2 = detrend(data2);                             % detrend data
                    data2 = data2 .* (5/32768);                         % change scale to miliVolts
                    % calculate average potentials
                    field_potentials(:,x,y,z) = mean(data2');
                    clear data1 data2;
                end
            end
        end
        if save_prep_data
            save (fullfile(datafolder, [rat_name '_field_pot.mat']), 'field_potentials');
        end;
    case 1 %%% Load previously saved field_potentials
        disp('  Loading preprocessed data... ')
        load(fullfile(datafolder, [rat_name '_field_pot']));
end;

%%% Movie
% Preprocessing
disp(['CSD filename is ' CSD_filename]);
if (use_saved_CSD)&&(exist(CSD_filename, 'file'))
    load(CSD_filename);
    disp(['  Loaded ' CSD_filename]);
    using_saved_CSD = 1;
    [N_int_x, N_int_y, N_int_z] = size(squeeze(csd_int2(1,:,:,:)));
else
    using_saved_CSD = 0;
    N_int_x = 2^int_prec_s*nr_of_x - 2^int_prec_s+1;
    N_int_z = 2^int_prec_s*nr_of_z - 2^int_prec_s+1;
    N_int_y = nr_of_y;
    VX = 1:(nr_of_x-1)/(N_int_x-1):nr_of_x;
    VY = 1:(nr_of_y-1)/(N_int_y-1):nr_of_y;
    VZ = 1:(nr_of_z-1)/(N_int_z-1):nr_of_z;
    switch bound_cond(1)
        case 'B'
            disp(['  Calculating CSD for slices & movies, method: ' ...
                CSD_method ' (zeros at boundary)... '])
            csd_int = icsd(field_potentials(show_first:show_last,:,:,:),distance,CSD_method,'B');
        case 'D'
            disp(['  Calculating CSD for slices & movies, method: ' ...
                CSD_method ' (repetition at boundary)... '])
            csd_int = icsd(field_potentials(show_first:show_last,:,:,:),distance,CSD_method,'D');
        case {'J', 'K'}
            disp(['  Calculating CSD for slices & movies, method: ' ...
                CSD_method ' (jittering)... '])
            csd_int = jitter(field_potentials(show_first:show_last,:,:,:),...
                distance, CSD_method, VX, VY, VZ, bound_cond);
        case 'S'
            disp(['  Calculating CSD for slices & movies, method: ' ...
                CSD_method '...'])
            if strcmp(CSD_method, 'vaknin')
                csd_int = csd_vaknin(field_potentials(show_first:show_last,:,:,:),distance);
            else
                csd_int = icsd(field_potentials(show_first:show_last,:,:,:),distance,CSD_method,'no');
            end;
    end;
    % CSD in grid points
    % or on a denser grid ('J')
end;

nr_av = subt_last-subt_first+1; % Nr of points to calc. average
av_first = subt_first-show_first + 1; % Where to start averaging
nr_pre_stim = show_stimulus-show_first+1;

movie_norm_ffix = '';
if movie_subtract_bgd % Subtract pre-stimulus average
    movie_norm_ffix = '_n';
    pre_st_av_pot = zeros (nr_of_x,nr_of_y,nr_of_z);
    if not(using_saved_CSD)
        pre_st_av = zeros (size(squeeze(csd_int(1,:,:,:))));
        for i=1:size(pre_st_av,1)
            for j=1:size(pre_st_av,2)
                for k=1:size(pre_st_av,3)
                    pre_st_av(i,j,k) = mean(csd_int(av_first:av_first+nr_av-1,i,j,k));
                end;
            end;
        end;
    end;
    for i=1:nr_of_x
        for j=1:nr_of_y
            for k=1:nr_of_z
                pre_st_av_pot(i,j,k) = mean(field_potentials(subt_first:subt_first+nr_av-1,i,j,k));
            end;
        end;
    end;


    if not(using_saved_CSD)
        for i=1:nr_frames
            csd_int(i,:,:,:) = squeeze(csd_int(i,:,:,:))-pre_st_av(:,:,:);
        end;
    end;
    for i=1:nr_frames
        field_potentials(show_first+i-1,:,:,:)= squeeze(field_potentials(show_first+i-1,:,:,:)) ...
            - pre_st_av_pot(:,:,:);
    end;
end;

% Appropriate scale for CSD plots
if not(using_saved_CSD)
    csd_scale = max(max(max(max(abs(csd_int(nr_pre_stim: ...
        round((nr_frames-nr_pre_stim)/2)+nr_pre_stim,:,:,:))))));
    % Range of CSD in the first half of the movie after stimulus
    clims=[-csd_scale/csd_scale_factor, csd_scale/csd_scale_factor];
end;
% colorbar
cbar = linspace(csd_scale/csd_scale_factor, -csd_scale/csd_scale_factor, 101);
csd_cbar_tick = str2num(num2str(linspace(csd_scale/csd_scale_factor*sigma, ...
    -csd_scale/csd_scale_factor*sigma, 5),2)); %#ok<ST2NM>

% Appropriate scale for comparison with potentials

pot_scale = max(max(max(max(abs(field_potentials(show_stimulus: ...
    show_stimulus+(round((nr_frames-nr_pre_stim)/2)),:,:,:)))))); % Range of pot
ratio = csd_scale/pot_scale;
pot_cbar_tick = str2num(num2str(linspace(csd_scale/csd_scale_factor/ratio, ...
    -csd_scale/csd_scale_factor/ratio, 5),2)); %#ok<ST2NM>
fpot2 = field_potentials(show_first:show_last,:,:,:); %%% For further interpolation

% Interpolation of potentials
disp('  Interpolating potentials...'); % Interpolate CSD
[N_int_x, N_int_y, N_int_z] = size(squeeze(fpot2(1,:,:,:)));
fpot_temp = fpot2;

if int_prec_s > 0
    [N_int_x, N_int_z] = size(interp2(squeeze(fpot_temp(1,:,1,:)), int_prec_s));
    fpot3 = zeros(nr_frames, N_int_x, N_int_y, N_int_z);
    for i = 1:nr_frames
        for j = 1:N_int_y
            fpot3(i,:,j,:) = interp2(squeeze(fpot_temp(i,:,j,:)), int_prec_s, 'spline');
        end;
    end;
else
    fpot3 = fpot_temp;
end;
clear('fpot_temp');
clear('fpot2');

% Interpolation of CSD
if not(using_saved_CSD)
    if bound_cond(1) =='J'||bound_cond(1) =='K'
        csd_int2 = csd_int;
    else
        disp('  Interpolating CSD...'); % Interpolate CSD
        if strcmp(CSD_method, 'vaknin')
            csd_int2 = interpolate_CSD(csd_int, VX, VY, VZ, 'splinem', 'S');
        else
            csd_int2 = interpolate_CSD(csd_int, VX, VY, VZ, CSD_method, bound_cond);
        end;
    end;
    clear csd_int;
    if save_int_CSD
        save(CSD_filename, 'csd_int2', 'clims', 'csd_scale');
        disp('  CSD saved to file.');
    end;
end;

% Load background images
if movie_bgd_imgs
    disp('  Loading background images...');
    if exist(fullfile(datafolder, [rat_name '_1.jpg']), 'file')
        tla = zeros(5,300,150);
        for i=1:5
            tla(i,:,:) = imread(...
                fullfile(datafolder, [rat_name '_' int2str(i) '.jpg']));
            tla(i,:,:) = 1.-tla(i,:,:)/255;
        end;
    else
        disp('  Background images not found.');
        movie_bgd_imgs=0;
    end;
end;

%%% Create movie
disp('  Creating AVI file (CSD vs potential)...');
nr_rows = 2;
nr_cols = 5;
base_size = 150;
tpos = [0.5, 0.97];
t2pos = [0.5, 0.48];
nyp = 5; % number of y plotted

aviobj = avifile(fullfile(moviefolder, [rat_name '_' CSD_method '_' bound_cond ...
    movie_norm_ffix ...
    int2str(show_first_ms) '_' int2str(show_last_ms) '.avi']), 'fps',framerate);
fig = figure('Position',[16 48 base_size*(nr_cols+1) round(base_size*2*nr_rows/0.8)], ...
    'Color', 'w');
wyk_tlo = axes('Position', [0 0 1 1], 'Visible', 'off');
for i = 1:2*nyp
    row_nr = nr_rows-(floor((i-1)/nr_cols)+1);
    col_nr = mod(i-1, nr_cols)+1;
    bot_pos = (0.1 + row_nr*1.25)/(nr_rows/0.8);
    wyk(i) = axes('Position', ...
        [(col_nr-1+0.5*col_nr/(nr_cols+1))/(nr_cols+1) bot_pos ...
        1/(nr_cols+1) 0.8/nr_rows]);
end;
row_nr = 1;
bot_pos = (0.1 + row_nr*1.25)/(nr_rows/0.8);
wyk(2*nyp+1) = axes('Position', ...
    [(nyp+0.50)/(nr_cols+1) bot_pos ...
    0.2/(nr_cols+1) 0.8/nr_rows]);
set(gcf, 'CurrentAxes', wyk_tlo);
text('Position', [(nyp+0.50)/(nr_cols+1)+0.15/(nr_cols+1) bot_pos-0.04/nr_rows], ...
    'HorizontalAlignment', 'center', 'Interpreter', 'tex', ...
    'String', '[nA/mm^3]' );
row_nr = 0;
bot_pos = (0.1 + row_nr*1.25)/(nr_rows/0.8);
wyk(2*nyp+2) = axes('Position', ...
    [(nyp+0.50)/(nr_cols+1) bot_pos ...
    0.2/(nr_cols+1) 0.8/nr_rows]);
set(gcf, 'CurrentAxes', wyk_tlo);
text('Position', [(nyp+0.50)/(nr_cols+1)+0.15/(nr_cols+1) bot_pos-0.035/nr_rows], ...
    'HorizontalAlignment', 'center', 'String', '[mV]' );
title_h = text('Position', tpos, 'HorizontalAlignment', 'center', ...
    'String', 'CSD, t = ' );
title2_h = text('Position', t2pos, 'HorizontalAlignment', 'center', ...
    'String', 'Potentials, t = ' );

for i = 1:nr_frames
    for l = 1:nyp
        if movie_bgd_imgs
            set(gcf, 'CurrentAxes', wyk(l));
            img = imagesc([1,nr_of_x],[1,nr_of_z], ...
                interp2(squeeze(csd_int2(i,:,l,:))', ...
                1:(N_int_x-1)/(base_size-1):N_int_x, ...
                (1:(N_int_z-1)/(2*base_size-1):N_int_z)' , ...
                'nearest'),clims);
            set(img, 'AlphaData', squeeze(tla(l,:,:)));
            set(gca, 'Color', [0 0 0]);
            colormap(flipud(jet(n_colors)));

            set(gcf, 'CurrentAxes', wyk(l+5));
            img = imagesc([1,nr_of_x],[1,nr_of_z], ...
                ratio*interp2(squeeze(fpot3(i,:,l,:))', ...
                1:(N_int_x-1)/(base_size-1):N_int_x, ...
                (1:(N_int_z-1)/(2*base_size-1):N_int_z)' , ...
                'nearest'),clims);
            set(img, 'AlphaData', squeeze(tla(l,:,:)));
            set(gca, 'Color', [0 0 0]);
            colormap(flipud(jet(n_colors)));

        else
            set(gcf, 'CurrentAxes', wyk(l));
            imagesc([1,nr_of_x],[1,nr_of_z], ...
                squeeze(csd_int2(i,:,l,:))',clims);
            colormap(flipud(jet(n_colors)));
            set(gcf, 'CurrentAxes', wyk(l+5));
            imagesc([1,nr_of_x],[1,nr_of_z], ...
                ratio*squeeze(fpot3(i,:,l,:))',clims);
        end;
        if l>1
            set(wyk(l), 'YTickLabel', '');
            set(wyk(l+5), 'YTickLabel', '');
        end;

        frame_time = num2str(show_first_ms+(i-1)*delta_t,'%04.1f');
        set(title_h, 'String', ['CSD, t = ' frame_time 'ms']);
        set(title2_h, 'String', ['Potentials, t = ' frame_time 'ms']);
        colormap(flipud(jet(n_colors)));
    end;
    set(gcf, 'CurrentAxes', wyk(2*nyp+1));
    imagesc(cbar');
    set(gca, 'YAxisLocation', 'right', 'YTick', 1:25:101, ...
        'XTickLabel', '', 'YTickLabel', csd_cbar_tick);

    set(gcf, 'CurrentAxes', wyk(2*nyp+2));
    imagesc(cbar');
    set(gca, 'YAxisLocation', 'right', 'YTick', 1:25:101, ...
        'XTickLabel', '', 'YTickLabel', pot_cbar_tick);

    frame = getframe(gcf);
    aviobj = addframe(aviobj,frame);
end;
aviobj = close(aviobj);
disp ('  Done.')