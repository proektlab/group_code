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
%  TimestampClient.m
%
%  A sample online client for MATLAB which reads spike and event timestamps from Server and prints them
%  in the MATLAB command window.  This is a very simple client which uses linear channel numbers and does
%  not read continuous data or spike waveforms, only spike timestamps. 
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

% used with OPX_WaitForOPXDAQReady
OPX_ERROR_TIMEOUT = -13;

% used with OPX_GetNewTimestamps
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

% used with OPX_InitClient:
% linear format: channel numbers start at 1 for each source type
% (spike, continuous, event)
OPX_CHANNEL_FORMAT_LINEAR = 1;

h = OPX_InitClient(OPX_CHANNEL_FORMAT_LINEAR); 
if h <= 0
  fprintf('error: OPX_InitClient failed (%d) - is OmniPlex running?\n', h);
else
  fprintf('Waiting for data acquisition to start in OmniPlex (60 second timeout)...\n');
  [ret] = OPX_WaitForOPXDAQReady(h, 60000);
  if ret == OPX_ERROR_TIMEOUT
    fprintf('Timed out waiting for OmniPlex to start data acquisition!\n');
  else
    fprintf('Reading from OmniPlex Server...\n');
    OPX_ClearData(h, 1000); % clear any backlogged data before entering loop
  
    while 1 % run until interrupted by Ctrl-C, or data acquisition stops
      [ret, numSpikes, spikeHeaders, spikeTimes, numEvents, events, eventTimes] = OPX_GetNewTimestamps(h);
    
      % dump spike timestamps
      if numSpikes > 0
        fprintf('numSpikes = %d\n', numSpikes);
      end
      for k = 1:numSpikes
        spikeChan = spikeHeaders(k, 1);
        unit = spikeHeaders(k, 2);
        t = spikeTimes(k);
        fprintf('  spike %d: chan = %d, unit = %d, t = %f\n', k, spikeChan, unit, t);
      end
    
      % dump event timestamps
      if numEvents > 0
        fprintf('numEvents = %d\n', numEvents);
      end
      for k = 1:numEvents
        eventChan = events(k, 1);
        eventData = events(k, 2);
        t = eventTimes(k);
        fprintf('  event %d: chan = %d, data = %d, t = %f\n', k, eventChan, eventData, t);      
      end
    
      % if we didn't read all the available data, don't wait before the next read
      if ret == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED
        fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
      elseif (ret == 0)
        pause(0.1);
        [ret, OPXStatus] = OPX_GetOPXSystemStatus(h);
        assert(ret == 0);
        if OPXStatus == OPX_DAQ_STOPPED
          fprintf('OmniPlex data acquisition was stopped, exiting...\n');
          pause(1.0);
          break;
        end
      else
        assert(ret == 0);
      end
    end
  
    OPX_CloseClient(h);
  end
end


