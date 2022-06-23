function [Z,XData] = testmodeZ()
    xN = 14240;
    XData = linspace(0,1E-3,xN);
    XData = XData(1:end); %similar time values

    T = XData;
    sr = .1;
    xx = (0:sr:1);
    yy = (0:sr:1);

    [X,Y] = meshgrid(xx , yy);
    
    %peak
    x0 = .5;
    y0 = .5;
    sigma = .1;
    spd = 2*length(X) ;
    
    Z = zeros(length(T),length(X),length(Y));
    for ti=1:length(T)
        t = T(ti);
        x = x0+t*spd;
        y = y0;
    
        XG = normpdf(X,x,sigma)';
        YG = normpdf(Y,y,sigma)';
        
        Z(ti,:,:) = XG.*YG.*sin(t*spd*2*pi);
    end
end