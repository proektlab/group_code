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
%  LowLatencyClient.m
%
%  A sample online client for MATLAB which shows how to wait on the Server event to minimize latency,
%  Only timestamps and digital events are read, not continuous data, but the Server event can be used 
%  in any client.  The rate at which the Server event is signaled (triggered) depends on whether the 
%  "lowest latency" and "minimize client latency" options are enabled in Server, and ranges from a 
%  default of 50-100 Hz (10-20 ms) to a maximum of 2 kHz (0.5 ms).
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

% used with OPX_InitClient:
% linear format: channel numbers start at 1 for each source type
% (spike, continuous, event)
OPX_CHANNEL_FORMAT_LINEAR = 1;

% used with OPX_WaitForOPXDAQReady
OPX_ERROR_TIMEOUT = -13;

% used with OPX_GetNewTimestamps
OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED = -16;

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

    [ret, hWait] = OPX_GetWaitHandle(h);
    assert(ret == 0 && h ~= 0);
    
    OPX_ClearData(h, 1000); % clear any backlogged data before entering loop
 
    loopCount = 1;
  
    while 1 % run until interrupted by Ctrl-C, or data acquisition stops
      [ret, numSpikes, spikeHeaders, spikeTimes, numEvents, events, eventTimes] = OPX_GetNewTimestamps(h);
      assert(ret == 0 || ret == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED)
      if (loopCount > 1)
        [ret, updateTime] = OPX_GetLastWaitEventTime(h);
        if ret ~= 0
          ret = 0;
          updateTime = 0.0;
        end
      end
      if numSpikes > 0 || numEvents > 0
        if (numSpikes > 0 && numEvents == 0)
          fprintf('[%u : %.3f sec] %d spikes\n', loopCount, updateTime, numSpikes);
        elseif (numSpikes == 0 && numEvents > 0)
          fprintf('[%u : %.3f sec] %d events\n', loopCount, updateTime, numEvents);
        else
          fprintf('[%u : %.3f sec] %d spikes, %d events\n', loopCount, updateTime, numSpikes, numEvents);
        end
      else % this fprintf will output on every wait event, even when there are no spikes or events
        ; % fprintf('[%u : %.3f sec] (no spikes or events)\n', loopCount, updateTime);
      end
    
      % if we didn't read all the available data, don't wait before the next read
      if ret == OPX_ERROR_NOT_ALL_DATA_WAS_RETURNED
        fprintf('buffer was full - need to poll more frequently (shorter pause)\n');
      elseif (ret == 0)
        [ret] = OPX_WaitForNewData(h, hWait, 1000);
        assert(ret == 0 || ret == OPX_ERROR_TIMEOUT);
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
      loopCount = loopCount+1;
    end
  end
  
  OPX_CloseClient(h);
end


