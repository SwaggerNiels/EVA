function result = Measure(ScopeObj,averaging,averaging_count)
%     disp('start')
    % src: https://nl.mathworks.com/matlabcentral/fileexchange/28887-capturing-a-waveform-from-an-agilent-oscilloscope-over-a-standard-visa-interface
    % edits: 
    % WAV:POINTS:MODE NORM
    % ACQUIRE:TYPE AVER
    % ACQUIRE:COUNT <int>
    
    fopen(ScopeObj);
    if averaging
        pause(averaging_count*.002);
    end
    fprintf(ScopeObj,':STOP');
    % Specify data from Channel 1
    fprintf(ScopeObj,':WAVEFORM:SOURCE CHAN1'); 
    % Set timebase to main
    fprintf(ScopeObj,':TIMEBASE:MODE MAIN');
    % Set up acquisition type and count.
    if averaging
        fprintf(ScopeObj,':ACQUIRE:TYPE AVER');
        avg_count_cmd = strcat(':ACQUIRE:COUNT'," ",num2str(averaging_count));
        fprintf(ScopeObj,avg_count_cmd);
    else
        fprintf(ScopeObj,':ACQUIRE:TYPE NORM');
        disp('no averaging')
    end
    % Specify 5000 points at a time by :WAV:DATA?
    fprintf(ScopeObj,':WAV:POINTS:MODE NORM');
    fprintf(ScopeObj,':WAV:POINTS 16000');
    % Now tell the instrument to digitize channel1
    fprintf(ScopeObj,':DIGITIZE CHAN1');
    % Wait till complete
    operationComplete = str2double(query(ScopeObj,'*OPC?'));
    while ~operationComplete
        operationComplete = str2double(query(ScopeObj,'*OPC?'));
    end

    % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
    fprintf(ScopeObj,':WAVEFORM:FORMAT WORD');
    % Set the byte order on the instrument as well
    fprintf(ScopeObj,':WAVEFORM:BYTEORDER LSBFirst');
    % Get the preamble block
    preambleBlock = query(ScopeObj,':WAVEFORM:PREAMBLE?');
    % The preamble block contains all of the current WAVEFORM settings.  
    % It is returned in the form <preamble_block><NL> where <preamble_block> is:
    %    FORMAT        : int16 - 0 = BYTE, 1 = WORD, 2 = ASCII.
    %    TYPE          : int16 - 0 = NORMAL, 1 = PEAK DETECT, 2 = AVERAGE
    %    POINTS        : int32 - number of data points transferred.
    %    COUNT         : int32 - 1 and is always 1.
    %    XINCREMENT    : float64 - time difference between data points.
    %    XORIGIN       : float64 - always the first data point in memory.
    %    XREFERENCE    : int32 - specifies the data point associated with
    %                            x-origin.
    %    YINCREMENT    : float32 - voltage diff between data points.
    %    YORIGIN       : float32 - value is the voltage at center screen.
    %    YREFERENCE    : int32 - specifies the data point where y-origin
    %                            occurs.
    
    % Now send commmand to read data
    fprintf(ScopeObj,':WAV:DATA?');
    % read back the BINBLOCK with the data in specified format and store it in
    % the waveform structure. FREAD removes the extra terminator in the buffer
    waveform.RawData = binblockread(ScopeObj,'uint16'); fread(ScopeObj,1);
    
    % Read back the error queue on the instrument
    CheckError(ScopeObj);
    % Close the VISA connection.
    fprintf(ScopeObj,':RUN');

    % Maximum value storable in a INT16
    maxVal = 2^16; 

    %  split the preambleBlock into individual pieces of info
    preambleBlock = regexp(preambleBlock,',','split');
    disp(preambleBlock)

    % store all this information into a waveform structure for later use
    waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
    waveform.Type = str2double(preambleBlock{2});
    waveform.Points = str2double(preambleBlock{3});
    waveform.Count = str2double(preambleBlock{4});      % This is always 1
    waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
    waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
    waveform.XReference = str2double(preambleBlock{7});
    waveform.YIncrement = str2double(preambleBlock{8}); % V
    waveform.YOrigin = str2double(preambleBlock{9});
    waveform.YReference = str2double(preambleBlock{10});
    waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
    waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
    waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
    waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

    % Generate X & Y Data
    waveform.XData = waveform.XOrigin + (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
    waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin; 
    
%     disp('stop')
    disp('Measured')
    result = waveform;
    fclose(ScopeObj);
end

function CheckError(ScopeObj)
    instrumentError = query(ScopeObj,':SYSTEM:ERR?');
%     disp('Found errors:')
    while ~isequal(instrumentError,['+0,"No error"' char(10)])
        disp(['Instrument Error: ' instrumentError]);
        instrumentError = query(ScopeObj,':SYSTEM:ERR?');
    end
end