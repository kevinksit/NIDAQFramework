classdef AuxController < NIDAQController
    % This controller works in tandem with the StepperController to provide full control of a stepper motor. Whereas the StepperController is in charge of stepping the motor, this controls everything else, ie direction and microstep level

    % Written 02Mar2020 KS
    % Updated

	properties
		dir_idx
		microstep_idx

		microstep_value
		motor

	end

	methods
		function obj = AuxController(motor)
			obj.motor = motor; % Aux controller needs to know which motor to work with, this is passing in the driver

			obj.dir_idx = obj.addDigitalOutput(obj.motor.getDirLine()); % Direction line

			for l = 1:3
				obj.microstep_idx(l) = obj.addDigitalOutput(obj.motor.getMicrostepLine(l)); % Microstep lines
			end
			obj.output = zeros(1, 4);
			obj.setMicrostep('Sixteenth') % Setting our "default" micrestop values
		end

		function setMicrostep(obj, microstep_amount)
			if nargin < 2 || isempty(microstep_amount)
                % Stupid MATLAB doesn't let us have more than 3 buttons...
                choices = {'Full', 'Half', 'Quarter', 'Eighth', 'Sixteenth'};
                val = listdlg('PromptString', 'Choose microstep amount:',... 
                	'ListString',choices, 'SelectionMode', 'single');
                microstep_amount = choices{val};
            end
            switch microstep_amount
            case 'Full'
            	obj.write(obj.microstep_idx(1), 0);
            	obj.write(obj.microstep_idx(2), 0);
            	obj.write(obj.microstep_idx(3), 0);
            case 'Half'
            	obj.write(obj.microstep_idx(1), 1);
            	obj.write(obj.microstep_idx(2), 0);
            	obj.write(obj.microstep_idx(3), 0);
            case 'Quarter'
            	obj.write(obj.microstep_idx(1), 0);
            	obj.write(obj.microstep_idx(2), 1);
            	obj.write(obj.microstep_idx(3), 0);
            case 'Eighth'
            	obj.write(obj.microstep_idx(1), 1);
            	obj.write(obj.microstep_idx(2), 1);
            	obj.write(obj.microstep_idx(3), 0);
            case 'Sixteenth'
            	obj.write(obj.microstep_idx(1), 1);
            	obj.write(obj.microstep_idx(2), 1);
            	obj.write(obj.microstep_idx(3), 1);
            otherwise
                error('Wrong value, choices: Full, Half, Quarter, Eighth, Sixteenth')
            end
            
            obj.microstep_value = microstep_amount;
        end

        function setDirection(obj, direction)
        	switch direction
        	case 'cw'
        		obj.write(obj.dir_idx, 0);
        	case 'ccw'
        		obj.write(obj.dir_idx, 1);
        	end
        end

        function out = getMicrostepScale(obj)
        	switch obj.microstep_value
        	case 'Full'
        		out = 1;
        	case 'Half'
        		out = 2;
        	case 'Quarter'
        		out = 4;
        	case 'Eighth'
        		out = 8
        	case 'Sixteenth'
        		out = 16;
        	end
        end

    end
end
