%% stimulus paradigm set up: Run Experiment
% 05/30/18 AA


%% General Set Up
clear
close all
clc
sca
stimDir = '/home/adeeti/Dropbox/KelzLab/ECogJunk/PsychoPhysics/stimuli/AdeetiStim/';
cd(stimDir);

% Here we call some default settings for setting up Psychtoolbox
clear params
rng('shuffle')

% Setup PTB with some default values
PsychDefaultSetup(2);

%% Setting up parameters

%Constants: viewing distance, pixel size, ppd
params.distanceToMonitor=30; %cm
params.mouseID = 'StimTest1';
params.Date=date;

params = configureScreens_pipelineAA(params); % Set up monitors and initialize blank screen - grey background

% sca
% close all;
% Make sure the GLSL shading language is supported:44
%AssertGLSL;

display('ready');
w = params.window;
%[w screenRect]=PsychImaging('OpenWindow',params.screenNumber, params.gray);

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% Parameters

conRevParam.angles = [0 180]; %horizontal or vertical grating
conRevParam.cpd = 0.08;
conRevParam.cps = 2; 
conRevParam.contrast = 1;
conRevParam.movieDurationSecs = 10;
conRevParam.centers = [0 1 2 3 4]; % C, UL, UR, LL, UR
conRevParam.gratingSize = 5; % in degrees of visual space
conRevParam.drawmask = 0;





conRevParam.totalTrialsPerCondition = 50;

%% Loop through for location and angle 

for trial = 1:length(centers)*conRevParam.totalTrialsPerCenter

%contrastRevGratFun(params, angle, cpd, cps, contrast, movieDurationSecs, center, gratingSize, drawmask)
contrastRevGratFun(params, 0, conRevParam.cpd, conRevParam.cps, conRevParam.contrast, conRevParam.movieDurationSecs, 1, conRevParam.gratingSize, conRevParam.drawmask)



end

%contrastRevGratFun(params, 0, 0.08, 2, 1, 20, 0, 5, 0)




