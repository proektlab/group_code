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
%  ContinuousDataClient.m
%
%  A sample online client for MATLAB which reads continuous data from one continuous channel and 
%  displays it graphically.
%
%  OmniPlex online clients for MATLAB call functions in the files OPX_*.m (such as OPX_InitClient.m), 
%  which must be present in the MATLAB path, in addition to the interface mexOPXClient.mexw64.  
%  OmniPlex release 18 (1.18.0) or later is required.
%
%  For more information on OmniPlex online clients for MATLAB, refer to the document 
%  OmniPlexOnlineClientsForMATLAB.doc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% only interested in this continuous source
contSourceToDraw = 'FP';

% channel to draw within the continuous source
contChanToDraw = 1;

% used with OPX_GetOPXSystemStatus
OPX_DAQ_STOPPED = 1;
OPX_DAQ_STARTED = 2;

% used with OPX_ExcludeAllSourcesOfType - the three source types
SPIKE_TYPE = 1;
EVENT_TYPE = 4;
CONT_TYPE = 5;

% used with OPX_WaitForOPXDAQReady
OPX_ERROR_TIMEOUT = -13;

% used with OPX_GetNewData
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

% used with OPX_InitClient:
% source-relative format: channel numbers start at 1 for each source
% (e.g. WB, SPKC, SPK, EVT, AI)
OPX_CHANNEL_FORMAT_SOURCE_RELATIVE = 2;

h = OPX_InitClient(OPX_CHANNEL_FORMAT_SOURCE_RELATIVE); 
if h <= 0
  fprintf('error: OPX_InitClient failed (%d) - is OmniPlex running?\n', h);
else
  fprintf('Waiting for data acquisition to start in OmniPlex (60 second timeout)...\n');
  [ret] = OPX_WaitForOPXDAQReady(h, 60000);
  if ret == OPX_ERROR_TIMEOUT
    fprintf('Timed out waiting for OmniPlex to start data acquisition!\n');
  else
    % exclude all online data except the FP (field potential) continuous source
    [ret] = OPX_ExcludeAllSourcesOfType(h, SPIKE_TYPE);
    assert(ret == 0);
    [ret] = OPX_ExcludeAllSourcesOfType(h, EVENT_TYPE);
    assert(ret == 0);
    [ret] = OPX_ExcludeAllSourcesOfType(h, CONT_TYPE);
    assert(ret == 0);
    [ret] = OPX_IncludeSourceByName(h, contSourceToDraw);
    assert(ret == 0);
  
    [ret, sourceNum, rateFP] = OPX_GetContSourceInfoByName(h, contSourceToDraw);
    assert(ret == 0);
    dtFP = 1.0/double(rateFP);

    fprintf('Reading from OmniPlex Server...\n');
    OPX_ClearData(h, 1000); % clear any backlogged data
  
    while 1 % run until interrupted by Ctrl-C, or data acquisition stops
      [retFromGetData, numSpikes, spikeHeaders, spikeTimes, spikeWaveforms, ...
                       numCont, contHeaders, contTimes, contSamples, ...
                       numEvents, events, eventTimes] = OPX_GetNewData(h);
      if numCont > 0 % if we have at least one channel of continuous data
        for chanIndex = 1:numCont
          % excluded all but one source, so we only need to find the right channel
          channel = contHeaders(2, chanIndex);
          if channel == contChanToDraw 
            numSamples = contHeaders(3,chanIndex); 
            x = 0.0:double(numSamples)-1.0;
            x = (x*dtFP)+contTimes(chanIndex); % sample times
            plot(x,contSamples(1:numSamples,chanIndex),'Color','k');
            xlabel(sprintf('%s%03d', contSourceToDraw, contChanToDraw));
            break;
          end
        end
      end
      % if we didn't read all the available data, don't wait before the next read
      if ret == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED
        fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
      elseif retFromGetData == 0
        pause(0.1); 
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
