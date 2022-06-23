function results = MeasureParams(ScopeObj, GenObj, PL, exp_params, measuring_speed, measuring_delay, averaging, averaging_count, testmode, nosource, stophandle, statusreport)
 % The loop that executes the measurement of parameters
    
    position = [0,0,0];
    if testmode
        [Z,XData] = testmodeZ();
    end

    %Scan over all parameter combinations provided
    pN = length(exp_params);
    N = length(PL);
    results = cell(N,1);
    try
        for mi = 1:N

            disp(strcat("Set parameters ",num2str(mi)));
            for pi = 1:pN
                %Change parameters (when first/different from last)
                if mi == 1
                    position = ChangeParam(GenObj, measuring_speed,position,exp_params(pi),PL(mi,pi),testmode,nosource);
                elseif PL(mi,pi) ~= PL(mi-1,pi)
                    position = ChangeParam(GenObj, measuring_speed,position,exp_params(pi),PL(mi,pi),testmode,nosource);
                end
            end

            %TODO: show params
%             disp(exp_params')
%             disp(num2str(PL(mi,:)'))
            statusreport.Value = strcat( ...
                num2str(mi),'/',num2str(N) );
            statusreport.FontColor = 'blue';

            pause(measuring_delay);
                
            % Measure
            disp(strcat("Measure ",num2str(mi)));
            if ~testmode
                result = Measure(ScopeObj, averaging, averaging_count);
            else
                result = testmodeResult(Z,XData,PL(mi,:));
            end
            
            results{mi} = result;

            pause(.02);
            if stophandle ~= -1
                if stophandle.Value
                    stophandle.Value = 0;
                    
                    statusreport.Value = 'Stopped measurement';
                    statusreport.FontColor = 'red';
                    disp('STOPPED loop with stophandle')
                    return
                end
            end
        end
        
        %Measurements done
        statusreport.Value = 'Finished measurement';
        statusreport.FontColor = 'green';

    catch e
        %Errored during measurement --> return to save results
        statusreport.Value = strcat('Canceled measurement at parameter combination index:', ...
            num2str(mi));
        statusreport.FontColor = 'red';
        disp(e)
        return
    end
end