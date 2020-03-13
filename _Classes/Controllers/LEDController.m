classdef LEDController < NIDAQController
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
			obj.digitalWrite(obj.control_idx(), 1);
		end

		function off(obj)
			obj.digitalWrite(obj.control_idx(), 0);
		end
	end
end