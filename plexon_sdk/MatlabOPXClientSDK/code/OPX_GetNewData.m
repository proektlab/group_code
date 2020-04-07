function [ret, nspikes, spikehdrs, spikets, spikewfs, ncont, conthdrs, contts, contsamples, nevents, events, eventts] = OPX_GetNewData(h)

[ret, nspikes, spikehdrs, spikets, spikewfs, ncont, conthdrs, contts, contsamples, nevents, events, eventts] = mexOPXClient(20, h, 0);

% OPX_GetNewData - Get spikes, continuous data, and digital events.
% 
% Inputs:
% - h: handle returned from OPX_InitClient
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
%
% ***** Spikes - Overview: *****
%   spikehdrs(i;), spikets(i), and spikwfs(i;) together represent one spike
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
%   spikehdrs(;6) = number of wf pts for this spike
%   
%   Note that if the channel format (see OPX_SetChannelFormat) is
%   channel-type-relative, the source is not included in the spike header 
%   and all elements of the header "move up one," i.e.
%     spikehdrs(;1) = channel,
%     spikehdrs(;2) = unit, etc.
%
% - spikets: spike timestamps in seconds
%
% - spikewfs: spike waveform points; each row is one spike's points
%   spikeswfs(i;) = points for spike i
%
%   The number of points for spike i is either
%     spikehdrs(i,6) if channel format is source-relative (see above)
%   or
%     spikehdrs(i,5) if channel format is linear
%
% ***** Continuous Data - Overview: *****
%   conthdrs(;i), contts(i), and contsamples(i;) together represent one 
%   continuous channel's data; channels with no samples are not included
%
% - ncont: number of continuous channels with data
%
% - conthdrs: continuous data headers; ncont columns, one for each channel 
%   with data; conthdrs(;i) = header for continuous channel with data i
%                      
%   conthdrs(1;) = source (not present if format is linear)
%   conthdrs(2;) = channel (source-relative or linear)
%   conthdrs(3;) = number of new samples for this channel
%
%   Note that if the channel format (see OPX_SetChannelFormat) is
%   channel-type-relative, the source is not included in the cont header 
%   and all elements of the header "move up one," i.e.
%     conthdrs(1;) = channel
%     conthdrs(2;) = number of new samples
%
% - contts: timestamp of first new sample in seconds; contts(i) = timestamp
%   for first sample of continuous channel with data i
%
% - contsamples: continuous data samples for channels with data
%   contsamples(;i) = samples for channel with data i; the corresponding 
%   source (if source-relative), channel, and number of samples are given
%   by conthdrs(;i)
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



