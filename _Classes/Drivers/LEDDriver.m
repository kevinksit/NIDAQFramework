classdef LEDDriver < NIDAQDriver
	properties
		control_line
	end
	methods
		function obj = LEDDriver(lines)
			if nargin < 1 || isempty(lines)
				lines = obj.inputPorts({'control'});
			end
			obj.control_line = lines{1};
			obj.state = zeros(1, length(lines));
		end

		function out = getControlLine(obj)
			out = obj.control_line;
		end
	end
end