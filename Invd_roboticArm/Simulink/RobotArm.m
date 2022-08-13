classdef RobotArm <matlab.System & matlab.system.mixin.CustomIcon & matlab.system.mixin.Propagates
    properties(Access = private, Constant)
        %Spring Joint Parameters
        Ks = 100;
        Bs = 10;
        thetaEq = 2/3 * pi;
        % Simulation Parameters
        stepTime = 0.01;
    end
    
    properties(Access = private)
       q = zeros(4, 1);
       dq = zeros(4, 1);
    end
    
    methods (Access = protected)
        
        function[q] = stepImpl(obj, q, cmdTorque)
            
            A = [2.1875 - 0.625 * cos(2 * q(1) - q(2)), 0.104167 + 0.3125 * cos(2 * q(1) - q(2)); 
                -0.104167 + 0.3125 * cos(2 * q(1) -q(2)), 0.104167];

            b0 = [- 25.025 * cos(q(1)) + 0.125 * cos(q(1) - q(2)) - 0.625 * sin(2 * q(1) - q(2)) * q(3) ^ 2 + 0.625 * sin(2 * q(1) - q(2)) * q(3) * q(4) - 0.3125 * sin(2 * q(1) - q(2)) * q(4)^2;
            -0.125 * cos(q(1) - q(2)) + 0.3125 * sin(2 * q(1) - q(2)) * q(3)^2];
        
            % Calculate Spring Force
            springForce = [0; -1 * obj.Ks * (q(2) - obj.thetaEq) - obj.Bs * q(4)];
            
            % Estimate Ground Reaction Force
        
            b = b0 + springForce + cmdTorque;
            
            % Update
            obj.dq(1:2) = q(3:4);
            obj.dq(3:4) = A\b;
            obj.q = obj.q + obj.dq * obj.stepTime;   
            
            % Return
            q = obj.q;
        end

        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.q = [1/2 * pi; 2/3 * pi; 0; 0];
            obj.dq = [0; 0; 0; 0];
        end

        function icon = getIconImpl(~)
            % Define icon for System block
            icon = matlab.system.display.Icon('C:\Users\guoro\Downloads\WeChat Image_20220811224032.jpg');
        end
        
        function [size] = getOutputSizeImpl(~)
            size = [4 1];
        end
        
        function [flag1] = isOutputFixedSizeImpl(~)
           flag1 = true; 
        end
        
        function [type] = getOutputDataTypeImpl(~)
           type = 'double';
        end
        
        function [flag1] = isOutputComplexImpl(~)
           flag1 = false; 
        end
    end 
end