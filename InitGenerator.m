function InitGenerator(GenObj)
    % Connect to instrument object GenObj
    fopen(GenObj);
    try
        dg = @(command) fprintf(GenObj, command);
    
        dg(':OUTP1:LOAD 50');
        dg(':OUTP2:LOAD 50');
        
        dg(':OUTP1 ON');
        dg(':OUTP2 ON');
    
        dg(':SOUR1:PHAS:INIT');
        dg(':SOUR2:PHAS:SYNC');
%         dg(':SOUR1:APPLY:SQU');
        dg(':SOUR1:APPLY:SIN');
%         dg(':SOUR2:APPLY:SQU');
        dg(':SOUR2:APPLY:SIN');

        dg(':SOUR1:VOLT:UNIT VPP');
    
        
        fclose(GenObj);

    catch e
        fclose(GenObj);
        delete(GenObj);
        clear GenObj;
        disp(e)
    end
end