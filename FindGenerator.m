function GenObj = FindGenerator()
    %Find the Signal Generator
    % Find a VISA-USB object.
    USB_code_1 = 'USB0::0x1AB1::0x0641::DG4E214001984::0::INSTR'; 
    USB_code_2 = 'USB0::0x1AB1::0x0641::DG4E214002006::0::INSTR';
    USB_code_3 = 'USB0::0x1AB1::0x0641::DG4E214002010::0::INSTR';
    generator = USB_code_3;
    obj1 = instrfind('Type', 'visa-usb', 'RsrcName', generator, 'Tag', '');
    
    % Create the VISA-USB object if it does not exist
    % otherwise use the object that was found.
    if isempty(obj1)
        obj1 = visa('KEYSIGHT', generator);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    
    % Connect to instrument object, obj1.
    fopen(obj1);
    fclose(obj1);
    
    GenObj = obj1;
end

