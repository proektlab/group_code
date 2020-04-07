%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   (c) 1999-2018 Plexon Inc. Dallas Texas 75206 USA
%   www.plexon.com / support@plexon.com
%
%   This code is provided for users of Plexon products. If you copy, disseminate, reproduce,
%   post or archive this code, please do not remove or alter this notice or the copyright above.
%   All sample code and libraries are provided as-is and Plexon cannot be responsible for errors 
%   or consequential damage caused by its use, including user code derived from or based on this code.  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  MultiSourceClient.m
%
%  A sample client for MATLAB which graphically displays OmniPlex data from multiple sources: 
%  wideband (WB), spike continuous (SPKC), field potential (FP) and spikes (SPK).  Note that the default
%  client sampling rate limit in OmniPlex is 1 kHz, which will not send WB or SPKC data to clients.  To
%  receive WB and SPKC in clients, increase the client rate limit to 40 kHz using the Online Client 
%  Options dialog in Server.  If the rate limit is the default 1 kHz, this client will only display FP 
%  and SPK.
%
%  OmniPlex online clients for MATLAB call functions in the files OPX_*.m (such as OPX_InitClient.m), 
%  which must be present in the MATLAB path, in addition to the interface mexOPXClient.mexw64.  
%  OmniPlex release 18 (1.18.0) or later is required.
%
%  For more information on OmniPlex online clients for MATLAB, refer to the document 
%  OmniPlexOnlineClientsForMATLAB.doc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we will display this channel across multiple sources, e.g. WB001, SPKC001, SPK001, FP001
channelOfInterest = 1;

% used with OPX_InitClient:
% source-relative format: channel numbers start at 1 for each source
% (e.g. WB, SPKC, SPK, EVT, AI)
OPX_CHANNEL_FORMAT_SOURCE_RELATIVE = 2;

% used with OPX_GetOPXSystemStatus
OPX_DAQ_STOPPED = 1;
OPX_DAQ_STARTED = 2;

% used with OPX_WaitForOPXDAQReady
OPX_ERROR_TIMEOUT = -13;

% used with OPX_GetNewData
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

% per-unit colors for spike waveforms
spikeColors = [
    1.0, 1.0, 1.0; % unsorted
    1.0, 1.0, 0.0; % unit a
    0.0, 1.0, 0.0; % unit b
    0.0, 0.0, 1.0;
    1.0, 0.0, 0.0;
    1.0, 1.0, 0.0;
    0.0, 1.0, 0.0]; % unit f

h = OPX_InitClient(OPX_CHANNEL_FORMAT_SOURCE_RELATIVE); 
if h <= 0
  fprintf('error: OPX_InitClient failed (%d) - is OmniPlex running?\n', h);
else
  fprintf('Waiting for data acquisition to start in OmniPlex (60 second timeout)...\n');
  [ret] = OPX_WaitForOPXDAQReady(h, 60000);
  if ret == OPX_ERROR_TIMEOUT
    fprintf('Timed out waiting for OmniPlex to start data acquisition!\n');
  else
    fprintf('Reading from OmniPlex Server...\n');
    
    [ret, sysType, version, numSources, sourceIds, numSpikeChans, numContChans, numEventChans, timestampFreq, rateLimit] = OPX_GetGlobalParameters(h);
    assert(ret == 0);
    fprintf('%d sources, %d spike channels, %d continuous channels, %d event channels, client continuous rate limit = %d Hz\n', ...
            numSources, numSpikeChans, numContChans, numEventChans, rateLimit);
      
    % if we aren't receiving "fast" (40 kHz sampling rate) continuous, 
    % leave out the plots for WB and SPKC
    if (rateLimit < 40000)
      fprintf('Note: client rate limit = %d; WB and SPKC channels will not be displayed\n', rateLimit);
      numPlots = 2;
      FPPlot = 1; % top graph
      SPKPlot = 2; % bottom graph
    else
      numPlots = 4;
      FPPlot = 1; % top graph
      WBPlot = 2; % second graph
      SPKCPlot = 3; % third graph
      SPKPlot = 4; % bottom graph
    end
  
    % get the source info for the WB, SPKC and FP continuous sources, 
    % in particular the source numbers and source sampling rates
    [ret, sourceNumFP, sourceType, numFPChans, linearStartChan] = OPX_GetSourceInfoByName(h, 'FP');
    assert(ret == 0);
    [ret, sourceNum, rateFP] = OPX_GetContSourceInfoByName(h, 'FP');
    assert(ret == 0);
    [ret, sourceNum, rateSPK, trodality, ptsPerWaveform, preThreshPts] = OPX_GetSpikeSourceInfoByName(h, 'SPK');
    assert(ret == 0);
    if numPlots == 4
      [ret, sourceNumWB, sourceType, numWBCChans, linearStartChan] = OPX_GetSourceInfoByName(h, 'WB');
      assert(ret == 0);
      [ret, sourceNum, rateWB] = OPX_GetContSourceInfoByName(h, 'WB');
      assert(ret == 0);
      [ret, sourceNumSPKC, sourceType, numSPKCChans, linearStartChan] = OPX_GetSourceInfoByName(h, 'SPKC');
      assert(ret == 0);
      [ret, sourceNum, rateSPKC] = OPX_GetContSourceInfoByName(h, 'SPKC');
      assert(ret == 0);
    end
    
    % interval between samples for each source
    dtWB = 1.0/double(rateWB);
    dtSPKC = 1.0/double(rateSPKC);
    dtFP = 1.0/double(rateFP);
    dtSPK = 1.0/double(rateSPK);
  
    % spike pre and post threshold intervals
    tPreThresh = double(preThreshPts)*dtSPK;
    tPostThresh = double(ptsPerWaveform-preThreshPts)*dtSPK;
  
    OPX_ClearData(h, 1000); % clear any backlogged data
  
    while 1 % run until interrupted by Ctrl-C, or data acquisition stops
      % read new data from OmniPlex Server 
      [retFromGetData, numSpikes, spikeHeaders, spikeTimes, spikeWaveforms, ...
                       numCont, contHeaders, contTimes, contSamples, ...
                       numEvents, events, eventTimes] = OPX_GetNewData(h);
      if (numSpikes > 0) || (numCont > 0) || (numEvents > 0)
        fprintf('%d spikes, %d continuous channels, %d events\n', numSpikes, numCont, numEvents);    
      end
  
      % draw spikes
      cla
      subplot(numPlots,1,SPKPlot);
      for i = 1:numSpikes
        channel = spikeHeaders(i,2);
        if channel == channelOfInterest
          numPts = spikeHeaders(i,6);
          t = spikeTimes(i);
          unit = spikeHeaders(i,3);
          unit = min(unit,6); % per-unit colors for first six units per channel 
          color = spikeColors(unit+1,:);   
          x = 0.0:double(ptsPerWaveform-1);
          x = x*dtSPK+(t-tPreThresh); % sample times 
          plot(x,spikeWaveforms(i,:),'Color',color);
          %xlabel(sprintf('SPK%03d', channel)); % warning, xlabel is slow
          hold on
        end
      end

      set(gca,'Color','k');
      hold off

      % draw continuous data
      for i = 1:numCont
        source = contHeaders(1,i);
        channel = contHeaders(2,i);
        numSamples = contHeaders(3,i);
        startTime = contTimes(i);
        if source == sourceNumWB % draw wideband
          if channel == channelOfInterest
            subplot(numPlots,1,WBPlot);
            x = 0.0:double(numSamples)-1.0;
            x = (x*dtWB)+startTime; % sample times
            plot(x,contSamples(1:numSamples,i),'Color','k');
            %xlabel(sprintf('WB%03d', channel)); % warning, xlabel is slow
          end
        elseif source == sourceNumSPKC % draw spike continuous
          if channel == channelOfInterest
            subplot(numPlots,1,SPKCPlot);
            x = 0.0:double(numSamples)-1.0;
            x = (x*dtSPKC)+startTime; % sample times
            plot(x,contSamples(1:numSamples,i),'Color','k');
            %xlabel(sprintf('SPKC%03d', channel)); % warning, xlabel is slow
          end
        elseif source == sourceNumFP % draw FP
          if channel == channelOfInterest
            subplot(numPlots,1,FPPlot);
            x = 0.0:double(numSamples)-1.0;
            x = (x*dtFP)+startTime; % sample times
            plot(x,contSamples(1:numSamples,i),'Color','k');
            %xlabel(sprintf('FP%03d', channel)); % warning, xlabel is slow
          end
        end
      end
    
      % if we didn't read all the available data, don't wait before the next read
      if (retFromGetData == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED)
        fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
      elseif (retFromGetData == 0)
        pause(0.1); 
        % check whether OmniPlex has stopped
        [ret, OPXStatus] = OPX_GetOPXSystemStatus(h);
        assert(ret == 0);
        if OPXStatus == OPX_DAQ_STOPPED
          fprintf('OmniPlex data acquisition was stopped, exiting...\n');
          pause(1.0);
          break;
        end
      else
        assert(retFromGetData == 0);
      end
    end    
  end
end
  
OPX_CloseClient(h);
