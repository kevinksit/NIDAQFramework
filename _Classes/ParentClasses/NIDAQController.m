classdef NIDAQController < handle
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

        % function addClock(obj, terminal)
        %     obj.session.addAnalogInputChannel('Dev1', terminal, 'Voltage')
        %     obj.session.addlistener('DataAvailable', @(x) x); % random anonymous function t make this work
        % end

        function addClock(obj, terminal)
            if nargin < 2 || isempty(terminal)
                terminal = 0;
            end
            obj.clock = Clock();
            obj.startClock();
        end

        function startClock(obj)
            obj.session.addClockConnection('External',['Dev1/' obj.clock.getClockTerminal()], 'ScanClock');
            obj.session.Rate = obj.clock.getFs();
            obj.clock.startClock();
        end

        function idx = addDigitalOutput(obj, channel)
        	[~, idx] = obj.session.addDigitalChannel('Dev1', channel, 'OutputOnly');
        end
        
        function report(obj)
        	disp(obj.session)
        end

        function digitalWrite(obj, line, val)
        	obj.output(line) = val;
        	obj.session.outputSingleScan(obj.output);
        end

        function drive(obj)
            % Start driving motor
            obj.session.startBackground();
        end

        function backgroundDrive(obj)
            obj.session.startBackground();
        end

        function abort(obj)
            obj.session.stop();
            obj.flush();
        end

        function flush(obj)
            obj.session.release();
        end

        function queue(obj, duration, value)
            n_samples = round(duration .* obj.session.Rate);
            drive_vector = repmat(value, n_samples, 1);
            obj.sendDataToDAQ(drive_vector);
        end

        function sendDataToDAQ(obj, data)
            obj.session.queueOutputData(data);
        end
        
    end 
end