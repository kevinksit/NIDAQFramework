classdef NIDAQController < handle
    % Parent class for creating controllers. Controllers interface with drivers to define the logic and method for which we use the driver. Think of controllers as function, and drivers as anatomy.

    % Written 02Mar2020 KS
    % Updated
    properties (Constant = true)
        FS = 1e5;
    end

	properties
		session
        clock
	end

	properties (Access = protected)
		output
	end

	methods
		function obj = NIDAQController()
			obj.session = daq.createSession('ni');
            obj.session.Rate = obj.FS;
		end

        function addClock(obj, terminal)
            % Adds a clock object for precise timing. This is necessary if you need really really tight timing (eg stepper motor control)
            if nargin < 2 || isempty(terminal)
                terminal = 0;
            end
            obj.clock = Clock();
            obj.startClock();
        end

        function startClock(obj)
            % Acutally linking the clock to our session and starting it
            obj.session.addClockConnection('External',['Dev1/' obj.clock.getClockTerminal()], 'ScanClock');
            obj.session.Rate = obj.clock.getFs();
            obj.clock.startClock();
        end

        function idx = addDigitalOutput(obj, channel)
            % Currently only support for digital I/O
        	[~, idx] = obj.session.addDigitalChannel('Dev1', channel, 'OutputOnly');
        end
        
        function report(obj)
            % Just an easy way to get everything out for us to see
        	disp(obj.session)
        end

        function digitalWrite(obj, line, val)
            % Simple write onto the line that you designate. The two step process is because you might have multiple ports on the same session, and you need to write to all ports simulatenously
        	obj.output(line) = val;
        	obj.session.outputSingleScan(obj.output);
        end

        function drive(obj)
            % after you queue data, you can use this to start stuff
            obj.session.startBackground();
        end

        function lockDrive(obj)
            % Locks terminal while doing stuff
            obj.session.startForeground();
        end

        function abort(obj)
            % Kills session and flushes the queue for new data to be added
            obj.session.stop();
            obj.session.release();
        end

        function queue(obj, duration, value)
            % A very basic queue for just putting in values. This will almost always be overwritten in specific Controllers
            n_samples = round(duration .* obj.session.Rate);
            drive_vector = repmat(value, n_samples, 1);
            obj.sendDataToDAQ(drive_vector);
        end

        function sendDataToDAQ(obj, data)
            % A quick wrapper for sending data to DAQ... just faster to type
            obj.session.queueOutputData(data);
        end
        
    end 
end