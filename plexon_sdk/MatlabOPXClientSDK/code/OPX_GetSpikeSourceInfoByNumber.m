function [ret, sourceName, rate, trodality, ptsPerWaveform, preThreshPts] = OPX_GetSpikeSourceInfoByNumber(h, sourceNum)

% OPX_GetSpikeSourceInfoByName: Given a spike source name, returns spike-source specific info.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% - sourceNum: source number
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
% - sourceName: string containing the source name
% - rate: sample rate of the spike source 
% - trodality: 1 = single electrode, 2 = stereotrode, 4 = tetrode
% - ptsPerWaveform: number of points in each spike waveform
% - preThreshPts: number of waveform points before the threshold crossing

[ret, sourceName, rate, trodality, ptsPerWaveform, preThreshPts] = mexOPXClient(6, h, sourceNum);
