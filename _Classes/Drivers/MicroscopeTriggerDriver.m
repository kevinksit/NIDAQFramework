classdef MicroscopeTriggerDriver < NIDAQDriver
	properties
		trigger_line
	end

	methods
		function obj = MicroscopeTriggerDriver(line)
			if nargin < 1 || isempty(line)
				line = obj.inputPorts({'trigger'});
			end

			obj.trigger_line = line;
		end

		function out = getTriggerLine(obj)
			out = obj.trigger_line;
		end
	end
end