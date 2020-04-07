FolderHome = 'D:\Brenna\ForkingTheBrain\';
ExpDate = '2018-12-10';

mkdir([FolderHome, ExpDate, '\matlab']);
D = dir([FolderHome, ExpDate, '\', ExpDate(1:4), '*.pl2']);

for x = 2:size(D,1)
    name = D(x).name;
    myExperiment = [FolderHome, ExpDate, '\', name];
    eventsChan{1} = 'EVT01';
    numChannels = 64;
    startChan = 1;
    
    [gridData, lfpSampRate, eventTimes, fullTraceTime, plexInfoStuffs] = ...
        ExtractPL2_LFP_data_Plexon(myExperiment,eventsChan, numChannels, startChan);
    save([FolderHome, ExpDate, '\matlab\', name(1:end-4), '.mat'])
end