# NIDAQ Framework
## Purpose
The idea is to create a simple framework for interfacing and controlling a NIDAQ BNC-2110. This framework takes advantage of creating a bunch of sessions, and using each session as a separate instance to allow for fine grained control of many systems simultaneously.  

Currently only supports digital I/O.

## Contents
In general, the framework is split into two major players: drivers and controllers. Drivers are simple classes that interface on the hardware side between the physical object you're trying to control and the DAQ. Controllers use the information reported by the driver to do things to these physical objects. More information below.
  
### Drivers
The driver class is simply to create an interface between the physical object and the NIDAQ board. This defines things such as which ports on the NIDAQ are connected to the object. It also defines the possible connection that the object has. For example, for a simple driver like the LEDDriver, there only needs to be a single connection, a "control" connection which can turn on and off the LED. For the StepperDriver, there are a total of 5 required connections for much finer grained control. Use the NIDAQDriver parent class to develop more classes for additional hardware.

### Controllers
Controllers interface intimately with the drivers to make physical objects do things. Generally, the controller defines the "logic" that determines the pattern of pulses sent to the physical object through the driver to do what you intend. Because of the session-based interface of MATLAB's DAQ toolbox, each controller creates a session to control things independently. This can also cause issues if you share ports between controllers, so make sure you try to avoid that at all costs...
  
### Clock
When only using digital I/O and requiring precise timing, there needs to be an analog channel present in order to help sync everything and keep time. To make this easy, the Clock class is a simple way to add a Clock to your controller. The NIDAQController class contains methods for adding a clock, but not all controllers require a clock. For example, the LEDController wouldn't benefit much from a clock because the timing is not highly precise. On the other hand, the StepperController which needs microsecond level control requires a clock to function.

## Usage
When you have a physical object you want to connect to the DAQ, first identify its inputs and the nature of those inputs. Appropriately connect those to your DAQ, and create drivers (subclassing the NIDAQDriver class) to interface with them. Then create Controllers (subclassing NIDAQControllers) in order to define the logic that controls them. For a simple example, see the LEDDriver and LEDController. For a more complex example, see the Stepper stuff. In general, when designing a controller, you should have the driver to that controller be passed in as an input argument to the class constructor.