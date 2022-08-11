%% Mathematica to Matlab
mathematica = "{(x^\[Prime])[t]-Sin[\[Theta]1[t]+\[Theta]2[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t])+Sin[\[Theta]1[t]+\[Theta]2[t]-\[Theta]3[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t]-(\[Theta]3^\[Prime])[t])+0.1 Sin[\[Theta]1[t]+\[Theta]2[t]-\[Theta]3[t]-\[Theta]4[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t]-(\[Theta]3^\[Prime])[t]-(\[Theta]4^\[Prime])[t]),(y^\[Prime])[t]+Cos[\[Theta]1[t]+\[Theta]2[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t])-Cos[\[Theta]1[t]+\[Theta]2[t]-\[Theta]3[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t]-(\[Theta]3^\[Prime])[t])-0.1 Cos[\[Theta]1[t]+\[Theta]2[t]-\[Theta]3[t]-\[Theta]4[t]] ((\[Theta]1^\[Prime])[t]+(\[Theta]2^\[Prime])[t]-(\[Theta]3^\[Prime])[t]-(\[Theta]4^\[Prime])[t]),(\[Theta]1^\[Prime])[t]-(\[Theta]2^\[Prime])[t]+(\[Theta]3^\[Prime])[t]+(\[Theta]4^\[Prime])[t]}";
%% Replacement Starts
% Sin and Cos
matlab = strrep(mathematica, "Sin", "sin");
matlab = strrep(matlab, "Cos", "cos");
% q
matlab = strrep(matlab, "x[t]", "q(1)");
matlab = strrep(matlab, "y[t]", "q(2)");
matlab = strrep(matlab, "\[Theta]1[t]", "q(3)");
matlab = strrep(matlab, "\[Theta]2[t]", "q(4)");
matlab = strrep(matlab, "\[Theta]3[t]", "q(5)");
matlab = strrep(matlab, "\[Theta]4[t]", "q(6)");
% dq
matlab = strrep(matlab, "(x^\[Prime])[t]", "q(7)");
matlab = strrep(matlab, "(y^\[Prime])[t]", "q(8)");
matlab = strrep(matlab, "(\[Theta]1^\[Prime])[t]", "q(9)");
matlab = strrep(matlab, "(\[Theta]2^\[Prime])[t]", "q(10)");
matlab = strrep(matlab, "(\[Theta]3^\[Prime])[t]", "q(11)");
matlab = strrep(matlab, "(\[Theta]4^\[Prime])[t]", "q(12)");
% add multiplications
matlab = strrep(matlab, " ", "*");
% Miscel
matlab = strrep(matlab, "[", "(");
matlab = strrep(matlab, "]", ")");
matlab = strrep(matlab, "{", "");
matlab = strrep(matlab, "}", "");

%% MATLAB to Mathematica
mathematica = strrep(matlab, "cos", "Cos");
mathematica = strrep(mathematica, "sin", "Sin");
mathematica = strrep(mathematica, "q(1)", "x[t]");
mathematica = strrep(mathematica, "q(2)", "y[t]");
mathematica = strrep(mathematica, "q(3)", "\[Theta]1[t]");
mathematica = strrep(mathematica, "q(4)", "\[Theta]2[t]");
mathematica = strrep(mathematica, "q(5)", "\[Theta]3[t]");
mathematica = strrep(mathematica, "q(6)", "\[Theta]4[t]");

mathematica = strrep(mathematica, "q(7)", "(x'[t]");
mathematica = strrep(mathematica, "q(8)", "(y'[t]");
mathematica = strrep(mathematica, "q(9)", "(\[Theta]1'[t]");
mathematica = strrep(mathematica, "q(10)", "(\[Theta]2'[t]");
mathematica = strrep(mathematica, "q(11)", "(\[Theta]3'[t]");
mathematica = strrep(mathematica, "q(12)", "(\[Theta]4'[t]");