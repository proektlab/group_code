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
%  InfoAndConversionsClient.m
%
%  A sample online client for MATLAB which shows how to query information about an OmniPlex system, its 
%  configuratio and data sources, and how to use conversion functions to work with both linear and 
%  source-relative channel numbers.  Linear channel numbers are 1..n for each of the three channel types 
%  (SPIKE_TYPE, EVENT_TYPE and CONT_TYPE), while source-relative channel numbers are 1..n for each 
%  source (e.g. WB, SPKC, SPK, FP, EVT...).
%
%  OmniPlex online clients for MATLAB call functions in the files OPX_*.m (such as OPX_InitClient.m), 
%  which must be present in the MATLAB path, in addition to the interface mexOPXClient.mexw64.  
%  OmniPlex release 18 (1.18.0) or later is required.
%
%  For more information on OmniPlex online clients for MATLAB, refer to the document 
%  OmniPlexOnlineClientsForMATLAB.doc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% used with OPX_GetOPXSystemStatus
OPX_DAQ_STOPPED = 1;
OPX_DAQ_STARTED = 2;

% the three source types for OPX_CHANNEL_FORMAT_LINEAR
SPIKE_TYPE = 1;
EVENT_TYPE = 4;
CONT_TYPE = 5;

% source-relative format: channel numbers start at 1 for each source
% (e.g. WB, SPKC, SPK, EVT, AI)
OPX_CHANNEL_FORMAT_SOURCE_RELATIVE = 2;

h = OPX_InitClient(OPX_CHANNEL_FORMAT_SOURCE_RELATIVE); 
if h <= 0
  fprintf('error: OPX_InitClient failed (%d)\n', h);
else
  [ret, OPXstatus] = OPX_GetOPXSystemStatus(h);
  while OPXstatus == OPX_DAQ_STOPPED
    fprintf('Waiting for OmniPlex data acquisition to start...\n');
    pause(1.0);
    [ret, OPXstatus] = OPX_GetOPXSystemStatus(h);
  end
    
  [ret, sysType, version, numSources, sourceIds, numSpikeChans, numContChans, numEventChans, tsFreq, rateLimit] = OPX_GetGlobalParameters(h); 
  assert(ret == 0);
  fprintf('\nCurrent OmniPlex configuration info:\n');
  fprintf('systype = %d, version = %d\n', sysType, version);
  fprintf('%d sources, %d spike channels, %d continuous channels, %d event channels\n', numSources, numSpikeChans, numContChans, numEventChans);
  fprintf('timestamp freq = %d Hz, client continuous rate limit = %d Hz\n\n', tsFreq, rateLimit);
  fprintf('------------- linear channel info -------------\n');
      
  for linChan = 1:numSpikeChans
    [ret, chanName, rate, enabled] = OPX_GetLinearChanInfo(h, SPIKE_TYPE, linChan);   
    assert(ret == 0);
    fprintf('spike chan %d: chanName = %s, rate = %d, enabled = %d\n', ...
      linChan, chanName, rate, enabled);
    [ret, sourceName, sourceNum, sourceChan] = OPX_LinearChanAndTypeToSourceChan(h, SPIKE_TYPE, linChan); 
    assert(ret == 0);
    [ret, linChanType, linChan2] = OPX_SourceChanToLinearChanAndType(h, sourceNum, sourceChan); 
    assert(ret == 0);
    [ret, linChanType2, linChan3] = OPX_SourceNameChanToLinearChanAndType(h, sourceName, sourceChan);             
    assert(ret == 0);
  end
  fprintf('\n');
      
  for linChan = 1:numContChans
    [ret, chanName, rate, enabled] = OPX_GetLinearChanInfo(h, CONT_TYPE, linChan); 
    assert(ret == 0);
    fprintf('cont chan %d: chanName = %s, rate = %d, enabled = %d\n', ...
      linChan, chanName, rate, enabled); 
    [ret, sourceName, sourceNum, sourceChan] = OPX_LinearChanAndTypeToSourceChan(h, CONT_TYPE, linChan); 
    assert(ret == 0);
    [ret, linChanType, linChan2] = OPX_SourceChanToLinearChanAndType(h, sourceNum, sourceChan); 
    assert(ret == 0);
    [ret, linChanType2, linChan3] = OPX_SourceNameChanToLinearChanAndType(h, sourceName, sourceChan);            
    assert(ret == 0);

    [ret, filterInfo] = OPX_GetContLinearChanFilterInfo(h, linChan);
    assert(ret == 0);
    fprintf('                           filterInfo = %f %f %f %f %f %f %f %f %f %f %f %f\n', ...
        filterInfo(1), filterInfo(2), filterInfo(3), filterInfo(4), ...
        filterInfo(5), filterInfo(6), filterInfo(7), filterInfo(8), ...
        filterInfo(9), filterInfo(10), filterInfo(11), filterInfo(12));    
  end
  fprintf('\n');
  
  if numEventChans >= 32 % if digital input card is present, i.e. not using TestADC file playback mode
    for linChan = 1:32 % first 32 event channels from digital input card
      [ret, chanName, rate, enabled] = OPX_GetLinearChanInfo(h, EVENT_TYPE, linChan);  
      assert(ret == 0);
      fprintf('event chan %d: chanName = %s, rate = %d, enabled = %d\n', ...
        linChan, chanName, rate, enabled);
      [ret, sourceName, sourceNum, sourceChan] = OPX_LinearChanAndTypeToSourceChan(h, EVENT_TYPE, linChan); 
      assert(ret == 0);
      [ret, linChanType, linChan2] = OPX_SourceChanToLinearChanAndType(h, sourceNum, sourceChan); 
      assert(ret == 0);
      [ret, linChanType2, linChan3] = OPX_SourceNameChanToLinearChanAndType(h, sourceName, sourceChan);            
      assert(ret == 0);
    end
    fprintf('\n');
  end
  
  fprintf('------------- per source info -------------\n');
      
  for srcNum = 1:numSources
    srcId = sourceIds(srcNum);
    fprintf('\n---------------------------------------------------------------------\n\n');
    fprintf('general source info (source %d, sourceId = %d)\n', srcNum, srcId);
    [ret, sourceName, sourceType, numChans, linearStartChan] = OPX_GetSourceInfoByNumber(h, sourceIds(srcNum)); 
    assert(ret == 0);
    fprintf('  src %d: srcId = %d, name = %s, type = %d, nchans = %d, startch = %d\n', ...
            srcNum, srcId, sourceName, sourceType, numChans, linearStartChan);
    [ret, sourceNum2, sourceType2, numChans2, linearStartChan2] = OPX_GetSourceInfoByName(h, sourceName);  
    assert(ret == 0);
    fprintf('  src %f: sourceNum = %d, type = %d, nchans = %d, startch = %d\n', ...
            srcNum, sourceNum2, sourceType2, numChans2, linearStartChan2); 
    [ret, sourceNum3] = OPX_SourceNameToSourceNumber(h, sourceName);  
    assert(ret == 0);
    [ret, sourceName2] = OPX_SourceNumberToSourceName(h, sourceNum3);  
    assert(ret == 0);
    fprintf('\nsource chan info (source %d, sourceId = %d)\n', srcNum, srcId);
        
    for srcCh = 1:numChans2
      [ret, chanName, rate, enabled] = OPX_GetSourceChanInfoByNumber(h, srcId, srcCh); 
      assert(ret == 0);
      fprintf('  src = %d, ch = %d: chName = %s, rate = %d, enabled = %d\n', ...
              srcId, srcCh, chanName, rate, enabled);    
      [ret, chanName2, rate2, enabled2] = OPX_GetSourceChanInfoByName(h, sourceName, srcCh); 
      assert(ret == 0);
      fprintf('  src = %d, ch = %d: chName = %s, rate = %d, enabled = %d\n', ...
              srcId, srcCh, chanName2, rate2, enabled2);  
    end
    fprintf('\n');

    fprintf('source type specific info (source %d, sourceId = %d)\n', srcNum, srcId);
       
    if (sourceType == SPIKE_TYPE)
      [ret, sourceName, rate, trodality, ptsPerWaveform, preThreshPts] = OPX_GetSpikeSourceInfoByNumber(h, srcId);
      assert(ret == 0);
      fprintf('  spike source (by number): sourceName = %s, rate = %d, trod = %d, ptsPerWf = %d, preThr = %d\n', ...
              sourceName, rate, trodality, ptsPerWaveform, preThreshPts);
      [ret, sourceNum, rate2, trodality2, ptsPerWaveform2, preThreshPts2] =  OPX_GetSpikeSourceInfoByName(h, sourceName);
      assert(ret == 0);
      fprintf('  spike source (by name): sourceNum = %d, rate = %d, trod = %d, ptsPerWf = %d, preThr = %d\n', ...
              sourceNum, rate2, trodality2, ptsPerWaveform2, preThreshPts2);     
    elseif (sourceType == CONT_TYPE)
      [ret, sourceName, rate] = OPX_GetContSourceInfoByNumber(h, srcId); 
      assert(ret == 0);
      fprintf('  cont source (by number): sourceName = %s, rate = %d\n', sourceName, rate); 
      if ~strcmp(sourceName,'WB')
        for srcCh = 1:numChans2
          [ret, filterInfo] = OPX_GetContSourceChanFilterInfoByNumber(h, srcId, srcCh);
          assert(ret == 0);
          if (filterInfo(1) == 1 || filterInfo(5) == 1 || filterInfo(9) == 1) % if any filter is enabled
            fprintf('    src = %d, ch = %d: filterInfo (by number) = %d %d %d %f %d %d %d %f %d %d %d %d\n', srcId, srcCh, ...
              filterInfo(1), filterInfo(2), filterInfo(3), filterInfo(4), ...
              filterInfo(5), filterInfo(6), filterInfo(7), filterInfo(8), ...
              filterInfo(9), filterInfo(10), filterInfo(11), filterInfo(12));
          end
          [ret, filterInfo] = OPX_GetContSourceChanFilterInfoByName(h, sourceName, srcCh);
          assert(ret == 0);
          if (filterInfo(1) == 1 || filterInfo(5) == 1 || filterInfo(9) == 1) % if any filter is enabled
            fprintf('    %s%d: filterInfo (by name) = %d %d %d %f %d %d %d %f %d %d %d %d\n', sourceName, srcCh, ...
              filterInfo(1), filterInfo(2), filterInfo(3), filterInfo(4), ...
              filterInfo(5), filterInfo(6), filterInfo(7), filterInfo(8), ...
              filterInfo(9), filterInfo(10), filterInfo(11), filterInfo(12));
          end
        end
      end
    elseif (sourceType == EVENT_TYPE)
      fprintf('  (no source type specific info)\n');
    end        
  end 
      
  OPX_CloseClient(h);
  fprintf('\n');
end


