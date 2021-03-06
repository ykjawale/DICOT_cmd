%% =====Main Dicot File======
% Created by: Dhruv Khatri, summarizes dicot workflow written by Yash,
% Anushree, Dhruv , C.A.Athale
% last update: 20/March/2020
%{
Changed Filenames
migLoop = DICOT_segmentation

%}
%% User input for time series
[filename,pathname]=uigetfile('*.tif', 'Select an image time-series (.tif)');
fullfilename=[pathname,filename];
[~,fname,~]=fileparts(filename);
outfolder= [pathname,'DICOT_', fname];
if ~exist(outfolder, 'dir')
    mkdir(outfolder);
else
    choice_continue = questdlg('Output directory exists data will be overwritten, continue');
    switch choice_continue 
        case 'Yes'
            disp('Data will be overwritten')
        case 'No'
            disp('Try deleting the output directory')
    end 
end
%% Select filter type 
prompt_seg_filter = {'Select filter type:'};
% Create a figure window:
fig = uifigure('Name', 'Filter Type','Position',[100 100 300 276]);
% Create a button group and radio buttons:
bg = uibuttongroup('Parent',fig,...
    'Position',[56 77 200 85]);
rb1 = uiradiobutton(bg,'Position',[10 60 210 15]);
rb1.Text = 'Scaling of Gaussian'; 
rb2 = uiradiobutton(bg,'Position',[10 38 210 15]);
rb2.Text = 'Laplacian of Gaussian';
rb3 = uiradiobutton(bg,'Position',[10 16 210 15]);
rb3.Text = 'Difference of Gaussian';
% Create a check box:
cbx = uicheckbox(fig,'Position',[55 217 150 15],...
     'Text', 'Apply regional max');
btn = uibutton(fig, 'Text', 'Confirm', 'Position', [80 50 150 20]); 
%% Initialize variables for segmentation
while(1)
    prompt_seg = {'Enter filter size:', 'Enter sigma value:',...
        'Enter sensitivity factor:', 'Black(0) or white(1) granules:'};
    dlgtitle_seg = 'Segmentation parameters';
    dims_seg = [1 40];
    definput_seg =  {'9','1.25','0.001', '1'};
    user_choice = inputdlg(prompt_seg, dlgtitle_seg, dims_seg, definput_seg);
    %===============Segmentation results with current parameters==========%
    % read in image data frame one and display segmentation output
    test_image = imread(fullfilename,1);
    % pass the image to SOG filter and display overlay of segmentation
    DICOT_seg_overlay(test_image, user_choice);
    %=====================================================================%
    choice_segmentation = questdlg('continue with these parameters? ');
    switch choice_segmentation
        case 'Yes'
            break 
            
        case 'No'
            continue 
    end
end
%% Segmentation output
% Selected parameters
filter_size = str2double(user_choice{1});
sigma_seg = str2double(user_choice{2});
sens_fact = str2double(user_choice{3});
bw = str2double(user_choice{4});
distUnit = 'px';
Num_frames  = imfinfo(fullfilename);
savestats = DICOT_segmentation(fullfilename, length(Num_frames),...
    filter_size, sigma_seg, sens_fact,bw, outfolder,distUnit);
%% Tracking section
prompt_seg_track = {'Gating/Linking Threshold:',...
    'Scaling_factor:', 'Distance Unit:','Time Unit', 'Time Interval'};
dlgtitle_seg_track = 'Tracking Parameters';
dims_seg_track= [1 60];
definput_seg_track =  {'10','1.00','px', 's','1'};
user_choice_track = inputdlg(prompt_seg_track, dlgtitle_seg_track, dims_seg_track, definput_seg_track);
micron_search_radius = str2double(user_choice_track{1});
scal_fact = str2double(user_choice_track{2});
distUnit = str2double(user_choice_track{3});
timeUnit = str2double(user_choice_track{4});
interval = str2double(user_choice_track{5});
[tracks,objno,outmat] = DICOT_tracking(outfolder, savestats, micron_search_radius, scal_fact, interval, distUnit, timeUnit);
%% Tracking output save?
question_save  = questdlg('Would you like to save tracking output');
switch question_save
    case 'Yes'
        close all
        makemovie_DICOT(outfolder,[1:length(Num_frames)],fullfilename)
    case 'No'
end
