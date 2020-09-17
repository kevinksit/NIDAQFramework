classdef StepperMotorDriver < NIDAQDriver
	% Updated 15Sep2020 KS | Added steps_per_rev from the StepperController, because it fits here better...
	
	properties
		step_line
		dir_line
		microstep_lines

		steps_per_rev
	end
		
	methods
		function obj = StepperMotorDriver(lines, steps_per_rev)
			if nargin < 1 || isempty(lines)
				lines = obj.inputPorts({'step', 'direction'});
			end

			if nargin < 2 || isempty(steps_per_rev)
				steps_per_rev = 200;
			end
			obj.steps_per_rev = steps_per_rev;
			obj.step_line = lines{1};
			obj.dir_line = lines{2};
			obj.microstep_lines = lines(3:end);
			obj.state = zeros(1, length(lines));
		end

		function out = getStepLine(obj)
			out = obj.step_line;
		end

		function out = getDirLine(obj)
			out = obj.dir_line;
		end

		function out = getMicrostepLine(obj, n)
			if nargin < 2 || isempty(n)
				out = obj.microstep_lines;
			else
				out = obj.microstep_lines{n};
			end
		end

		function out = getStepsPerRev(obj)
			out = obj.steps_per_rev;
		end
	end
end
