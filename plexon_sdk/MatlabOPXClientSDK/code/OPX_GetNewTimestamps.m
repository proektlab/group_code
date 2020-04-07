function [ret, nspikes, spikehdrs, spikets, nevents, events, eventts] = OPX_GetNewTimestamps(h)

% OPX_GetNewTimestamps - Get spikes and digital events. This function is 
% similar to OPX_GetNewData except that no spike waveform points or 
% continuous data are returned.
% 
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
%
% ***** Spikes - Overview: *****
%   spikehdrs(i;) and spikets(i) together represent one spike
%
% - nspikes: number of new spikes
%
% - spikehdrs: spike headers; nspikes rows, each row represents one spike:
%   spikehdrs(;1) = source (not present if format is linear)
%   spikehdrs(;2) = channel (source-relative or linear)
%   spikehdrs(;3) = unit (0 = unsorted, 1 = unit a, 2 = unit b, etc)
%   spikehdrs(;4) = blocks per waveform 
%                   (1 = single, 2 = stereotrode, 4 = tetrode)
%   spikehdrs(;5) = block number for wf (0-based)
%   
%   Note that if the channel format (see OPX_SetChannelFormat) is
%   linear, the source is not included in the spike header 
%   and all elements of the header "move up one," i.e.
%     spikehdrs(;1) = channel,
%     spikehdrs(;2) = unit, etc.
%
% - spikets: spike timestamps in seconds
%
%
% ***** Digital Events - Overview: *****
%   events(i;) and eventts(i) together represent one digital event
%
% - nevents: number of digital events
%
% - events: digital events
%   events(;1) = source (not present if format is linear)
%   events(;2) = channel (source-relative or linear)
%   events(;3) = event data (strobed word value or 0)
%
%   Note that if the channel format (see OPX_SetChannelFormat) is
%   channel-type-relative, the source is not included and all elements 
%   "move up one," i.e.
%    events(;1) = channel
%    events(;2) = event data (strobed word value or 0)
%
% - eventts = event timestamps in seconds

[ret, nspikes, spikehdrs, spikets, nevents, events, eventts] = mexOPXClient(22, h);