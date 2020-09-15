classdef StepperController < NIDAQController
    % This class is used to control the stepper motors. It is a huge controller that also requires the creation of AuxControllers to help split the work.

    % Written 05Mar2020 KS
    % Updated 14Sep2020 KS | Moved the constants to the driver because they can be different for each motor...

    properties
        MAX_SPEED = 400;
    end

    properties
        motors
        step_idx

        aux_controller
    end

    methods
        function obj = StepperController(motors)
            obj.motors = motors;

            % Add lines
            ct = 1;
            for m = obj.motors
                obj.step_idx(ct) = obj.addDigitalOutput(m.getStepLine());
                if ct == 1
                    obj.aux_controller = AuxController(m); % to keep it simple, auxiliary controls are relegated to a second controller
                else
                    obj.aux_controller(ct) = AuxController(m);
                end
                ct = ct + 1;
            end

        	% Set up time
        	obj.addClock(0); % because of the necessity of precise timing, this controller requires the addition of a clock
        end

        function output = queue(obj, speed, input_type, value)
            % For queueing data into the DAQ for controlling the motors... Can either put values in in "steps" or "seconds", generally recommend using "seconds"...

            if strcmp(input_type, 'steps') && (length(speed) ~= length(obj.motors) || length(value) ~= length(obj.motors))
				%error('Input the same number of speed/values as motors');
                value = repmat(value, 1, length(obj.motors));
            end
            
            obj.checkSpeed(max(speed))

            switch input_type % Calculating the other parameter based on what we got
            case 'steps'
                for n = 1:length(obj.motors)
                    n_steps(n) = (value(n) .* speed(n));
                    duration(n) = obj.getDuration(n, n_steps(n), speed(n));
                end
            case 'seconds'
                duration = value;
                for n = 1:length(obj.motors)
                    n_steps(n) = round(obj.getSteps(n, duration, speed(n))); 
                end
            end

            % When steps are 0, then time is 0, get rid of these errors
            duration(isnan(duration)) = 0;
            duration = max(duration);

            % Generate output vector
	        n_samples = round(duration .* obj.session.Rate); % Getting the length of the output vector
	        output = zeros(n_samples, length(obj.motors));
	        for n = 1:length(obj.motors)
	        	step_vec = round(linspace(1, n_samples - 1, n_steps(n)));
	        	drive_vector = false(1, n_samples);
	        	drive_vector(step_vec) = true;
	        	output(:, n) = drive_vector;
	        end

            % Send to the DAQ
	        obj.sendDataToDAQ(output);
	    end

	    function wait(obj, duration)
            % Just pausing if needed
	    	obj.queue(zeros(1, length(obj.motors)), 'seconds', duration);
	    end

	    function out = rotate(obj, motor_num, angle, speed)
            % This is a manually controlled rotation of the motor of a certain degree
	    	if nargin < 4 || isempty(speed)
	    		speed = 3;
	    	end
	    	speeds = zeros(1, length(obj.motors));
	    	steps = speeds;
	    	speeds(motor_num) = speed;
	    	steps(motor_num) = round((angle/360) *  obj.motors(motor_num).getStepsPerRev()) * obj.aux_controller(motor_num).getMicrostepScale();
	    	out = obj.queue(speeds, 'steps', steps);
	    end
        
        function changeDirection(obj, motor_num, direction)
            % Calling on the aux controller to change the motor direction
        	if nargin < 2 || isempty(direction)
        		direction = questdlg('Choose your direction: ', 'Direction', 'cw', 'ccw', 'cw');
        	end

        	if nargin < 3 || isempty(motor_num)
        		motor_num = 1;
        	end

        	obj.aux_controller(motor_num).setDirection(direction)
        end

        function changeMicrostep(obj, motor_num, microstep)
            % Calling on the aux cotnroller to change the microstep value.
        	if nargin  < 3 || isempty(motor_num)
        		motor_num = 1;
        	end

        	obj.aux_controller(motor_num).setMicrostep(microstep);
        end

        function step(obj, motor_num, dir, slow_flag)
            % Single step (or really a couple quick steps)
            if slow_flag 
                speed = 5;
            else
                speed = 50;
            end
            obj.changeDirection(motor_num, dir);
            output = zeros(1, length(obj.motors));
            output(motor_num) = 1;
            for i = 1:speed
                obj.session.outputSingleScan(output)
                obj.session.outputSingleScan(zeros(1, length(obj.motors)))
            end
        end
    end

    methods (Access = protected)
    	function checkSpeed(obj, speed)
            % Ensure speed isn't too high
            if speed > obj.MAX_SPEED
            	error('Speed is too high, limited to 400RPM')
            end
        end

        function duration = getDuration(obj, moton_num, n_steps, speed) 
            % Convert from n_steps and speed to time (in seconds)
            duration = (n_steps/(obj.motor(motor_num).getStepsPerRev() * obj.aux_controller(1).getMicrostepScale())) * (60/speed); % to account for microstepping
        end

        function n_steps = getSteps(obj, motor_num, duration, speed)
            % Convert from speed and duration to number steps
            n_steps = (speed./60) .* duration .* (obj.motor(motor_num).getStepsPerRev() * obj.aux_controller(1).getMicrostepScale());
        end
    end
end