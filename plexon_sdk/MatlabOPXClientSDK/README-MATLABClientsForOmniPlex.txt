MATLAB Native Client API and Sample Clients for Plexon OmniPlex Systems
Version 1.0
November 20, 2018
(c) 1999-2018 Plexon Inc. Dallas Texas 75206 USA
www.plexon.com / support@plexon.com

------ Contents ------

"doc" folder:

  Documentation (read this next):

    MATLABClientsForOmniPlex.pdf

"code" folder:

  Sample client source code:

    TimestampClient.m
    SpikeWaveformClient.m
    ContinuousDataClient.m
    MultiSourceClient.m
    InfoAndConversionsClient.m
    LowLatencyClient.m

  Runtime libraries needed by clients:

    mexOPXClient.mexw64
    OPXClient.dll

  Definitions of Native Client API functions:

    OPX_ClearData.m
    OPX_CloseClient.m
    OPX_ExcludeAllSourcesOfType.m
    OPX_ExcludeSourceByName.m
    OPX_ExcludeSourceByNumber.m
    OPX_GetBufferSize.m
    OPX_GetContLinearChanFilterInfo.m
    OPX_GetContSourceChanFilterInfoByName.m
    OPX_GetContSourceChanFilterInfoByNumber.m
    OPX_GetContSourceInfoByName.m
    OPX_GetContSourceInfoByNumber.m
    OPX_GetCurrentBufferRate.m
    OPX_GetGlobalParameters.m
    OPX_GetLastParameterUpdateTime.m
    OPX_GetLastWaitEventTime.m
    OPX_GetLinearChanInfo.m
    OPX_GetLocalMachineTime.m
    OPX_GetNewData.m
    OPX_GetNewDataRaw.m
    OPX_GetNewTimestamps.m
    OPX_GetNewTimestampsRaw.m
    OPX_GetOPXSystemStatus.m
    OPX_GetSourceChanInfoByName.m
    OPX_GetSourceChanInfoByNumber.m
    OPX_GetSourceInfoByName.m
    OPX_GetSourceInfoByNumber.m
    OPX_GetSpikeSourceInfoByName.m
    OPX_GetSpikeSourceInfoByNumber.m
    OPX_GetWaitHandle.m
    OPX_IncludeAllSourcesOfType.m
    OPX_IncludeSourceByName.m
    OPX_IncludeSourceByNumber.m
    OPX_InitClient.m
    OPX_LinearChanAndTypeToSourceChan.m
    OPX_SendClientDataWords.m
    OPX_SetBufferSize.m
    OPX_SetPrecision.m
    OPX_SourceChanToLinearChanAndType.m
    OPX_SourceNameChanToLinearChanAndType.m
    OPX_SourceNameToSourceNumber.m
    OPX_SourceNumberToSourceName.m
    OPX_WaitForNewData.m
    OPX_WaitForOPXDAQReady.m

  Predefined API constants, function error codes, etc:

    OPXConstants.m
