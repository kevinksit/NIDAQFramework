classdef LEDController < NIDAQController
% For controlling an LED (or really any simple thing that just has an on and off state)

% Written 05Feb2020 KS
% Updated

	properties
		led % LED driver
		control_idx
	end
	methods
		function obj = LEDController(led)
			obj.led = led;
			obj.addDigitalOutput(obj.led.getControlLine());
			obj.control_idx = 1;
		end

		function on(obj)
			obj.write(obj.control_idx(), 1);
		end

		function off(obj)
			obj.write(obj.control_idx(), 0);
		end
	end
end