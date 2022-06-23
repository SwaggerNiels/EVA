function FindXYZcontroller()
    %Find the XYZ controller
    addpath('../')                                                          % to find the xyz.dll (and called from this ftd2xx.dll)
    
    loadlibrary('xyz','xyz.h');                                             % load dll
    calllib('xyz','xyz_init');                                              
    calllib('xyz','open_usb','GAFR');                                       % open USB connection (NAME = 'GAFR')
    usb_is_open=calllib('xyz','is_open');                                   % check USB connection status
    if ~usb_is_open
        error("Cannot open the XYZ controller")
    else
        calllib('xyz','close_usb');
        disp('Found XYZ controller');
    end
end

