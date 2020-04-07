%% Making preprocessing pictures

close all
clear

dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirPic = '/data/adeeti/ecog/images/IsoPropMultiStim/preProcessing/';

identifier = '2018*.mat';
START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirOut1)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for i = START_AT:length(allData)
    load(allData(i).name, 'info', 'meanSubData', 'aveTrace', 'finalTime', 'finalSampR', 'latency', 'indexSeries', 'uniqueSeries')
    
    [indices] = getStimIndices(info.stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    
    %Single trial images
    [currentFig] = plotSingleTrials(useMeanSubData, finalTime, info);
    suptitle(['Single trials, Experiment ', num2str(info.exp), ', ', info.TypeOfTrial, ' Delay: ', num2str(info.interStimInterval), ', Drug: ',  info.AnesType, ', Conc: ', num2str(info.AnesLevel)]);
    saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, '_singletrials.png'])
    close all;
    
    for a = 1:size(aveTrace, 1)
    
    stimIndex = uniqueSeries(a,:);
    [stimIndexSeriesString] = stimIndex2string4saving(stimIndex, finalSampR);
    
    % Plot on onset of latency on averages
    [currentFig] = plotAverages(squeeze(aveTrace(a,:,:)), finalTime, info, [], [], [], squeeze(latency(a,:)), before, after, flashOn, finalSampR);
    suptitle(['Average with Latency, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
    saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString '_aveLat.png'])
    close all
    
    % Plot latency heat map on grid
    [currentFig, colorMatrix, gridData]=PlotOnECoG(squeeze(latency(a,:)), info, 1);
    title({['Latency: Experiment ',  num2str(info.exp), ', Series ', strrep(stimIndexSeriesString, '_', '\_')],
        ['Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel)]})
    saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString 'heatLat.png'])
    close all
    end
    
    waitbar(i/totalExp)
end

close(loadingWindow);