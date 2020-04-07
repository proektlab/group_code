function OPX_CloseClient(h)

% OPX_CloseClient: Call this function once, before terminating.
%
% Inputs: 
% - h: handle returned from OPX_InitClient
% Outputs: none

mexOPXClient(2, h);
