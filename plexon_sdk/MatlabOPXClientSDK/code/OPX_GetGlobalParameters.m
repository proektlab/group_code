function [ret, sysType, version, numSources, sourceIds, numSpike, numCont, numEvent, tsFreq, rateLimit] = OPX_GetGlobalParameters(h)

% OPX_GetGlobalParameters: Returns global information about the current OmniPlex configuration.
%
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs: 
% - ret: return code; 0 = success, nonzero = error code
% - sysType: OmniPlex hardware type: 
%     OPXSYSTEM_TESTADC    = 1 (TestADC software A/D simulator)
%     OPXSYSTEM_AD64       = 2 (OmniPlex-A system)
%     OPXSYSTEM_DIGIAMP    = 4 (DigiAmp or MiniDigi OmniPlex-D system)
%     OPXSYSTEM_DHSDIGIAMP = 8 (Digital Headstage Processor (DHP) 
%                               OmniPlex-D system)                       
% - version: version of OmniPlex software, e.g. 1160 = version 1.16.0
% - numSources: total number of sources available to client
% - sourceIds: an array of source numbers, e.g. (4,1,3,6,10,11...)
% - numSpike: total number of channels of SPIKE_TYPE
% - numCont: total number of channels of CONTINUOUS_TYPE
% - numEvent: total number of channel of EVENT_TYPE
% - tsFreq: frequency of timestamp "ticks";
%           currently either 40000 Hz (default) or 1000000 Hz, 
%           i.e. one tick = either 25 microseconds or 1 microsecond
% - rateLimit: Server only sends continuous data to clients if the sample
%              rate is this frequency or less; by default, 1000 Hz

[ret, sysType, version, numSources, sourceIds, numSpike, numCont, numEvent, tsFreq, rateLimit] = mexOPXClient(3, h);