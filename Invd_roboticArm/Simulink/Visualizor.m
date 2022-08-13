classdef Visualizor <matlab.System & matlab.system.mixin.CustomIcon
    methods (Access = protected)
        function setupImpl(~)
            % Perform one-time calculations, such as computing constants
            figure(1)
            plot(0, 0, 'k.', 'MarkerSize', 20);
            xlim([-1, 1]);
            ylim([-1, 1]);
            hold on
            grid on
            axis equal
            title("2DOF Robotic Arm Simulation")
            xlabel("x(m)")
            ylabel("y(m)")
            hold on
        end

        function icon = getIconImpl(~)
            % Define icon for System block
            icon = matlab.system.display.Icon('C:\Users\guoro\Downloads\WeChat Image_20220811230359.jpg');
        end
        
        function[] = stepImpl(obj, q)
            coder.extrinsic('delete');
            l1 = 0.5;
            l2 = 0.25;
            % calculate positions
            x1 = l1 * cos(q(1));
            y1 = l1 * sin(q(1));
            x2 = x1 + l2 * cos(q(2) - q(1));
            y2 = y1 + l2 * sin(q(2) - q(1));
            % plot new
            arm1 = plot([0, x1], [0, y1], 'b', 'LineWidth', 2);
            arm2 = plot([x1, x2], [y1, y2], 'b', 'LineWidth', 2);
            joint1 = plot(0, 0, 'r.', 'MarkerSize', 12); % active joint
            joint2 = plot(x1, y1, 'g.', 'MarkerSize', 12); % passive joint 
            % Show plot
            figure(1);
            % Delete Shit
            delete(arm1);
            delete(arm2);
            delete(joint1);
            delete(joint2);
        end
        
    end
end