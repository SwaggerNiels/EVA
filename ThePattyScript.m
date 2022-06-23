function ThePattyScript(REMOVE, ...
    INTENSITY,...
    remove_start, ...
    remove_interval)
    %ThePattyScript
    %
    % REMOVE : boolean value that will indicate whether waves are removed
    % from the signal or not
    %
    % INTENSITY : float value (0-1) that indicates what fraction of each
    % pulse remains
    %
    % remove_start : integer value that indicates from which pulse number
    % to start removing pulses
    %
    % remove_interval : integer value that indicates interval at which
    % pulses are removed
    %
    %
    RN = 1;
    
    % set the size of the perfectly matched layer (PML)
    PML_X_SIZE = 20;            % [grid points]
    PML_Y_SIZE = 10;            % [grid points]
    PML_Z_SIZE = 10;            % [grid points]
    
    % create the computational grid
    Nx = 104 - 2*PML_X_SIZE;            % number of grid points in the x direction
    Ny = 84 - PML_Y_SIZE;           %   % number of grid points in the y direction[grid points]
    Nz = 84 - PML_Z_SIZE;             % number of grid points in the z direction
    dx = 0.05e-3;        % grid point spacing in the x direction [m]
    dy = 0.05e-3;        % grid point spacing in the y direction [m]
    dz = 0.05e-3;        % grid point spacing in the z direction [m]
    
    source_freq = 8.4e6;  % [Hz]
    source_mag = 1;     % [Pa]
    T = 1/source_freq;          %[s] 2e-7 s = 0.2 us
    
    BURST_NUMBER = 500;
    T_siggen = T*BURST_NUMBER;
    f_siggen = 1/T_siggen;
    
    kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);
    kgrid.dt = 0.01e-6;   %s = 0.01 us
    kgrid.Nt = floor(T_siggen / kgrid.dt)*RN;
    % created the time array (kgrid.t_array)
    
    % define the properties of the propagation medium
    medium.sound_speed = 1500 * ones(Nx, Ny, Nz);	% [m/s]
    medium.sound_speed(1:Nx/2, :, :) = 1540;        % [m/s]
    medium.density = 1000 * ones(Nx, Ny, Nz);       % [kg/m^3]
    medium.density(:, Ny/4:end, :) = 1200;          % [kg/m^3]
    
    
    % define a square source element
    source_radius = 2; %  [grid points]
    source.p_mask = zeros(Nx, Ny, Nz);
    source.p_mask(Nx/4, Ny/2 - source_radius : Ny/2 + source_radius, Nz/2 - source_radius : Nz/2 + source_radius) = 1;
     
    
    % define a time varying sinusoidal source
    vector_final = zeros(1, kgrid.Nt);
    
    Nt2=floor(kgrid.Nt/RN);
    wave = source_mag * sin(2 * pi * kgrid.t_array(:)/ T);
    vector = zeros(1, Nt2);
    vector(1 : Nt2) = wave;
                                                   
    i=0;
    indeces_per_T = T/kgrid.dt;
    
    if REMOVE
        for index_T =remove_start:remove_interval:500%floor(Nt2/indeces_per_T)  %ciclo for para tirar ondas random
        
            A = rand;  % gerar numero random from the uniform distribution in the interval (0,1)
            
            if A > 0  % se o numero de 0 a 1 for superior a 0.8 a onda desaparece- probabilidade de desaparecer=20%
                vector(1 + (index_T-1) * floor(indeces_per_T) : index_T * floor(indeces_per_T))=INTENSITY*vector(1 + (index_T-1) * floor(indeces_per_T) : index_T * floor(indeces_per_T));  
               
                i=i+1;
                
            end
        
            %500waves - 250,150,100,80,50, 150-50, 100-20, 10-20,100-8
    
            %500waves_5em5 - 100-90,  100-40, 100-28, 100-20, 100-16, 100-13,
            %100-11, 100-10, 50-10, 50-9, 50-7, 50-6, 30-5, 30-3
    
            %VER SE MUDA CONSONATE A POSITION- 250-100, 150-150, 50-200
    
            %Bigger steps- 
        end
        disp([int2str(i) ' waves changed'])
    end
    
    wave=vector;
    source.p = vector_final;
    
    
    % filter the source to remove high frequencies not supported by the grid
    source.p = filterTimeSeries(kgrid, medium, source.p);

    % Instrument Connection
    % Find a VISA-USB object.
    obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x1AB1::0x0641::DG4E214002010::0::INSTR', 'Tag', '');
    
    % Create the VISA-USB object if it does not exist
    % otherwise use the object that was found.
    if isempty(obj1)
        obj1 = visa('KEYSIGHT', 'USB0::0x1AB1::0x0641::DG4E214002010::0::INSTR','OutputBufferSize',1000000);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    
    fopen(obj1);
    try
        dg = @(command) fprintf(obj1, command);
    
        dg(':OUTP1:LOAD 50');
        dg(':OUTP2:LOAD 50');
        
        dg(':SOUR1:FUNC:ARB:MODE SRATE');
        dg(':SOUR1:APPL:ARB .001, 10, 0');
        dg(sprintf(':SOUR1:FREQ %0.2e',f_siggen));
        dg(':SOUR1:VOLT 10');
    
        cmd = [':SOUR1:TRACE:DATA:POINTS VOLATILE,' num2str(length(wave))]; dg(cmd);
        sig_str = sprintf(',%1.2f',wave);
        cmd = sprintf(':SOUR1:DATA VOLATILE%s', sig_str); fwrite(obj1,cmd);
        
    
        dg(':SOUR1:BURS ON');
        dg(':SOUR1:BURS:NCYC 1');
    %    dg(':SOUR1:BURS:INT:PER 1E-3')
    
    
        dg(':SOUR2:FUNC:ARB:MODE SRATE');
        dg(':SOUR2:APPL:ARB .001, 10, 0');
        dg(sprintf(':SOUR2:FREQ %0.2e',f_siggen));
        dg(':SOUR2:VOLT 10');
    
        cmd = [':SOUR2:TRACE:DATA:POINTS VOLATILE,' num2str(length(wave))]; dg(cmd);
        sig_str = sprintf(',%1.2f',wave);
        cmd = sprintf(':SOUR2:DATA VOLATILE%s', sig_str); fwrite(obj1,cmd);
        
    
        dg(':SOUR2:BURS ON');
        dg(':SOUR2:BURS:NCYC 1');
       % dg(':SOUR2:BURS:INT:PER 1E-3')
    
        dg(':OUTP1 ON');
        dg(':OUTP2 ON');
    
        dg(':SOUR1:PHAS:INIT');
        dg(':SOUR2:PHAS:SYNC');
    
    
    %     fprintf(obj1, ':SOURce1:VALue? VOLATILE,1' );
    %     query_CH1 = fscanf(obj1);
    %     display(query_CH1)
    
        fclose(obj1);
        delete(obj1);
        clear obj1;
    
    catch e
    
        disp('ERROR')
        fclose(obj1);
        delete(obj1);
        clear obj1;
        disp(e)
    end
end