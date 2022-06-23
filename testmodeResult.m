function result = testmodeResult(Z, XData, PL)
    pN = size(PL,2);
    SIGNAL_MAGNITUDE = 1E5;

    switch pN
        case 1
            vp = PL(1);

            YData = squeeze(Z(:,vp,vp)).*SIGNAL_MAGNITUDE;
            result = testmode(XData,YData);
        case 2
            xp = PL(1);
            yp = PL(2);
            
            YData = squeeze(Z(:,yp,xp)).*SIGNAL_MAGNITUDE;
            result = testmode(XData,YData);
        case 3
            xp = PL(1);
            yp = PL(2);
            zp = PL(3);
            
            YData = squeeze(Z(:,zp,xp)).*SIGNAL_MAGNITUDE;
            
            result = testmode(XData,YData);
    end
end