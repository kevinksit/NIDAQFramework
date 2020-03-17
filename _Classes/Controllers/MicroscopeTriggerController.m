classdef MicroscopeTriggerController < NIDAQController
	properties
		trig % MicroscopeTriggerDriver
	end

	methods
		function obj = MicroscopeTriggerController(trig)
			obj.trig = trig; % assign driver
			obj.addAnalogOutput(obj.trig.getTriggerLine());
		end

		function start(obj)
			obj.write(1, 5);
		end

		function stop(obj)
			obj.write(1, 0);
		end
	end
end