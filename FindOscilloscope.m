function ScopeObj = FindOscilloscope()
    %Find the Oscilloscope
    % Find a VISA-USB object.
    obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0957::0x17A5::MY50510864::0::INSTR', 'Tag', '');
    
    % Create the VISA-USB object if it does not exist
    % otherwise use the object that was found.
    if isempty(obj1)
        obj1 = visa('KEYSIGHT', 'USB0::0x0957::0x17A5::MY50510864::0::INSTR');
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    
    % Set the buffer size
    obj1.InputBufferSize = 100000;
    % Set the timeout value
    obj1.Timeout = 10;
    % Set the Byte order
    obj1.ByteOrder = 'littleEndian';
    
    % Connect to instrument object, obj1.
    fopen(obj1);
    fclose(obj1);
    
    ScopeObj = obj1;
end

