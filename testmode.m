classdef testmode
   properties
      XData
      YData
   end
   methods        
    function obj = testmode(XData,YData)
        if nargin == 2
            obj.XData = XData;
            obj.YData = YData;
        end
    end
   end
end