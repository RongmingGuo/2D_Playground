function[] = plotRobo(q)
    l1 = 0.5;
    l2 = 0.25;
    % calculate positions
    x1 = l1 * cos(q(1));
    y1 = l1 * sin(q(1));
    x2 = x1 + l2 * cos(q(1) + q(2) - pi);
    y2 = y1 + l2 * sin(q(1) + q(2) - pi);
    % plot
    arm1 = plot([0, x1], [0, y1], 'b', 'LineWidth', 2);
    arm2 = plot([x1, x2], [y1, y2], 'b', 'LineWidth', 2);
    joint1 = plot(0, 0, 'r.', 'MarkerSize', 12); % active joint
    joint2 = plot(x1, y1, 'g.', 'MarkerSize', 12); % passive joint 
    pause(0.01);
    delete(arm1);
    delete(arm2);
    delete(joint1);
    delete(joint2);
end