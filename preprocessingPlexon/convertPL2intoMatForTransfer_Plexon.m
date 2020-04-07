%% Preprocessing code
% Convert PL2 into .mat files for transfer onto the workstation for futher
% analysis
% 11/29/18 AA only written so far for LFP data 

%% Making snippits for each experiment
clear
clc

genDirIn = 'D:\Brenna\ForkingTheBrain\2018-12-10\';
identifierSubjects = '2018*';
identifierFile = '*.pl2';
START_AT= 1;
eventsChan{1} = 'EVT01';
numChan = 64;
before = 1; %in seconds amount of prestim data
l = 3; %total length in seconds of the trial
startBaseline = 0; %0 if want to make chan by trials by timepoints, 1 if want to extract intial baseline sequence
LFPcutOff = 200; % low pass cut off if want to extract LFP from WB signal
finalSampR = 1000;

makeSnippits = 0; %1 if want to make snippits from events, 0 if want to extract LFP data only
extractLFPFromWB = 0; %1 if recorded WB data and want to use filtered to filter out LFP, 0 if only recoded FP
useMultipleSubject =0; %0 if using only one subject, 1 if wanting to convert multiple subjects in the same mother directory

if extractLFPFromWB ==0
    startChan = 1;
end

cd(genDirIn)
if useMultipleSubject ==1
    allSubjects = dir(identifierSubjects);
end
    
loadingWindow = waitbar(0, 'Converting data...');

for subject = START_AT%:length(allSubjects)
    if useMultipleSubject ==1
        dirIn = [genDirIn, allSubjects(subject).name, '\'];
        dirOut = [dirIn, 'matlab\'];
        mkdir(dirOut)
    elseif useMultipleSubject ==0
        dirIn = genDirIn;
        dirOut = [dirIn, 'matlab\'];
        mkdir(dirOut)
    end
    
    cd(dirIn)
    allData = dir(identifierFile);

    for experiment = 1:length(allData)
        
        %[LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2ECOG_LFP_data(allData(experiment).name,eventsChan, 64, 1);
        if extractLFPFromWB ==1
            [LFPData, ogSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB_Plexon(allData(experiment).name,eventsChan, numChan, LFPcutOff, finalSampR);
        elseif extractLFPFromWB == 0
            [LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_data_Plexon(allData(experiment).name,eventsChan, numChan, startChan);
        end
        
        % Extract segments of data and save
        
        disp(['Breaking up file ', allData(experiment).name])
        
        if length(allStartTimes) ==1
            onTime = allStartTimes{1};
        end
        
        if makeSnippits ==1
            if isempty(cellfun(@isempty,allStartTimes))
                dataSnippits= LFPData;
                save([dirOut, allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs')
            else
                [dataSnippits, finalTime] = extractSnippets_Plexon(LFPData, onTime, before, l, finalSampR, startBaseline);
                save([dirOut, allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalTime', 'finalSampR', 'LFPData', 'allStartTimes', 'fullTraceTime','plexInfoStuffs')
            end
        elseif makeSnippits ==0
            dataSnippits= LFPData;
            save([dirOut, allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalSampR', 'LFPData', 'fullTraceTime','plexInfoStuffs')
        end
        clearvars dataSnippits finalTime lfpSampRate LFPData allStartTimes fullTraceTime plexInfoStuffs
        
    end
    if useMultipleSubject ==1
        loadingWindow = waitbar(subject/length(allSubjects));
    elseif useMultipleSubject ==0
        loadingWindow = waitbar(experiment/length(allData));
    end
     
end
close(loadingWindow);