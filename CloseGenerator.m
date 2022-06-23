function CloseGenerator(GenObj)
    try
%         disp('Close GENOBJ')
        dg = @(command) fprintf(GenObj, command);
        
        fopen(GenObj);
        dg(':OUTP1 OFF');
        dg(':OUTP2 OFF');
        fclose(GenObj);
%         disp('Closed GENOBJ')
    catch
        fclose(GenObj);
        delete(GenObj);
        clear GenObj;
    end
end
