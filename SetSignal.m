function SetSignal(GenObj, param, freq, burstN, volt)
    fopen(GenObj);
%     disp('in generator')
    try
        dg = @(command) fprintf(GenObj, command);
    
        dg(':SYST:POW')

        dg(':OUTP1:LOAD 50');
        dg(':OUTP2:LOAD 50');
    
        switch param
            case 'f'
                dg([':SOUR1:FREQ ' num2str(freq) 'E6']);

                dg([':SOUR2:FREQ ' num2str(freq) 'E6']);
            case 'b'
                dg(':SOUR1:BURS ON');
                dg([':SOUR1:BURS:NCYC ' num2str(burstN)]);

                dg(':SOUR2:BURS ON');
                dg([':SOUR2:BURS:NCYC ' num2str(burstN)]);
            case 'v'
                num2str(volt)
                dg([':SOUR1:VOLT ' num2str(volt)]);

                dg([':SOUR2:VOLT ',num2str(10)]);
        end

        dg(':SOUR1:BURS:INT:PER 1E-3');
        dg(':SOUR2:BURS:INT:PER 1E-3');

        dg(':OUTP1 ON');
        dg(':OUTP2 ON');
    
        dg(':SOUR1:PHAS:INIT');
        dg(':SOUR2:PHAS:SYNC');
         
    catch e
        fclose(GenObj);
        delete(GenObj);
        clear GenObj;
        disp(e)
        return
    end
    
    pause(0.1); %For reaction time of the Signal change
    fclose(GenObj);
%     disp('out generator')
end