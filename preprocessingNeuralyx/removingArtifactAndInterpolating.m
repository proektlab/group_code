%% Removing artifact region in LFP singal and interpolating over signal 

% dirIn =  '/data/adeeti/ecog/forkingBrainMouseWithBrenna/';
% cd(dirIn)
% allData = dir('*2.mat');
% 
% for experiment = 1:length(allData)
%     load(allData(experiment).name, 'dataSnippits');
%     disp(allData(experiment).name);
%     
%     data = dataSnippits;
%     
%     artifactRegion = 1000:1015;
%     data(:,:,artifactRegion) = [];
%     
%     time1 = [1:999, 1016:3001];
%     time2 = 1:size(dataSnippits,3);
%     
%     for i = 1:size(data, 1)
%         for j = 1:size(data,2)
%             dataSnippits(i,j,:) = interp1(time1, squeeze(data(i, j, :)), time2);
%         end
%     end
%     
%     save(allData(experiment).name, 'dataSnippits', '-append')
% end

%% Clean data, mean subtract make average pictures 

close all
%dirPic = 'D:\Images\ECoGwith2Prong\';
dirIn = '/data/adeeti/ecog/forkingBrainMouseWithBrenna/';


identifier = '*2.mat';
START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

%mkdir(dirPic)

cd(dirIn)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    
    dirName = allData(experiment).name;
    load(dirName)
    disp(['Converting data ', allData(experiment).name])
    
    % Cleaning data and subtracting the mean
    
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    meanSubData = nan(size(dataSnippits));
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
    end
    
    % to mean subtract ecog data only 
    eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
    
    meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
    
    % to mean subtract shanks data only 
    
    for f = 1:size(info.forkChannels,1)
        forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
        meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
        
    end    

    %meanSubData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(meanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(meanSubData(ch,:,:), 2));
            
            standError(i, ch,:) = squeeze(nanstd(meanSubData(ch,:,:), 1, 2)/sqrt(size(meanSubData(ch,:,:), 2)));
            
            %lowerCIBound(i, ch,:) = squeeze(quantile(meanSubData(ch,:,:), 0.05, 2));
            %upperCIBound(i, ch,:) =  squeeze(quantile(meanSubData(ch,:,:), 0.95, 2));
        end
    end
    
    save([dirIn, dirName], 'cleanedData', 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
      
    % Single trial images
    
    %[currentFig] = plotSingleTrials(meanSubData, finalTime, info);

    %saveas(currentFig, [dirPic, dirName, 'singletrials.png'])
    %close all;
    
    % Flash triggered average images
    
    %[currentFig] = plotAverages(aveTrace, finalTime, info, [], [], [], [], before, after, flashOn);
    
    %[currentFig] = plotAverages(plotData, finalTime, info, yAxis, lowerCIBound, upperCIBound, latency,  before, after, flashOn, finalSampR)
    
    %saveas(currentFig, [dirPic, allData(experiment).name, 'average.png'])
    close all;
end
