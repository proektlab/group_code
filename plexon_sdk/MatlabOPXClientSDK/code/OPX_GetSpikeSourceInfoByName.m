function [ret, sourceNum, rate, trodality, ptsPerWaveform, preThreshPts] = OPX_GetSpikeSourceInfoByName(h, sourceName)

% OPX_GetSpikeSourceInfoByName: Given a spike source name, returns spike-source specific info.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceName: null-terminated string containing the source's name, e.g. "SPK"
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceNum: source number
% - rate: sample rate of the spike source 
% - trodality: 1 = single electrode, 2 = stereotrode, 4 = tetrode
% - ptsPerWaveform: number of points in each spike waveform
% - preThreshPts: number of waveform points before the threshold crossing

[ret, sourceNum, rate, trodality, ptsPerWaveform, preThreshPts] = mexOPXClient(7, h, sourceName);
