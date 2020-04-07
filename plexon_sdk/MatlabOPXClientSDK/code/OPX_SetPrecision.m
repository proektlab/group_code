function ret = OPX_SetPrecision(h, floatPrecision)

% OPX_SetPrecision - Sets the precision for floating 
% point spike waveform and continuous data returned by 
% OPX_Get* functions.
%
% Inputs:
% - h: handle returned from OPX_InitClient
% - floatPrecision:
%
%   floatPrecision = 1 : spike waveforms and continuous data 
%   will be returned as 32 bit (single) floating point values
%
%   floatPrecision = 2 : spike waveforms and continuous data 
%   will be returned as 64 bit (double) floating point values
%
% Outputs:
% - ret: return code; 0 = success, nonzero = error code
%
% Notes:
% The default is single precision, which uses 50% less memory 
% bandwidth than double precision, and loses no accuracy in the 
% acquired spike and continuous data transferred from OmniPlex 
% Server.  Most MATLAB functions support single-precision arguments
% and can mix single and double precision values in expressions. 
% However, double precision can be enabled if desired, and if in 
% doubt, users may wish to compare the results of calculations as 
% performed in single vs double precision.
%
% Note that timestamp values are always returned as double precision
% values, and are unaffected by calls to OPX_SetPrecision.
% 
ret = mexOPXClient(44, h, floatPrecision);
