classdef RobotController <matlab.System & matlab.system.mixin.CustomIcon
    properties(Access = protected)
        Kp = 1;
        Kd = 1;
    end
    
    methods(Access = protected)
       function[cmdTorque] = stepImpl(obj, q_ref, q)
          cmdTorque = zeros(2, 1);
          cmdTorque(1) = obj.Kp * (q_ref(1) - q(1));
          cmdTorque(2) = obj.Kp * (q_ref(2) - q(2));
       end

       function icon = getIconImpl(~)
           % Define icon for System block
           icon = matlab.system.display.Icon('C:\Users\guoro\Downloads\WeChat Image_20220811225038.jpg');
       end
    end
end