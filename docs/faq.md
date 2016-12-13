# FAQ

#### After few hours of Internet search, I have found about 20 BDM pods available. Why are you trying to augment existing chaos by another pod?

In present time (2004), I haven't found any BDM interface with freely available construction plans, ie. schematics and eventually a firmware, other than pod of [Malte Avenhaus](http://www.avenhaus.de/Malte/BDM12/), which, however, could be used only after much stronger effort (to write a support to debugger), than contruction of whole podex.

#### Why did you copy Kevin Ross' protocol? Don't you think it is morally wrong?

By all means it is better to use existing, although a bit dumb, protocol, if it is sufficient, than to plague the world with another incompatible pod, moreover, to add another support code to gdb for the very same, only camouflaged thing -- to waste efforts to write a debugger port, debug the debugger... By all means it is better to unify with existing gdb port and to try to improve this port, which will help users of both pods.

This solution also means to be supported by other debuggers, which supports Kevin Ross for a long time. I don't think, it is immoral, I haven't stole anything of Kevin Ross, I haven't ever seen his BDM pod, neither his debugger db12.exe. Anyway, many thanks to him for publishing his communication protocol.

#### Why have you used AVR MCU? Why not HC08, HC11, HC(S)12? Why not PIC,...?

AVR processors are cheap and little, they have very nice and consistent assembler, they aren't so fancy, as messy family of PIC, they have great and effective support of GNU tools. Firmware of podex isn't fixed to any specific AVR model, it works with AT90S2313 (well, not very fresh meat...), so it will work in other AVR as well.

#### Where can I buy podex? How much does it cost?

You cannot (at least at this moment). Podex is a construction plan published for free use. I don't know, if I would like somebody to sell it -- if you are interrested in production of PCB's, selling components or final pods, let me mail, we can think about it.

#### What is podex able to? Which debuggers are able to work with?

Podex can program and debug processors of Motorola 68HC12 and HCS12 family, at this moment operating at 5V voltage and crystal frequency up to cca 20MHz, maybe also a higher. Podex is intended to be used with debugger GNU gdb, but it should work also with NoICE and StingRay.

#### What isn't podex able to?

To work with processors, other than HC(S)12 family, with other interfaces, than their BDM. Podex doesn't know JTAG, podex won't talk with HC08, HC11, neither M68300, neither with your mother-in-law...

#### Why writing to my FLASH doesn't work?

Are you using gdb? If you are, then make sure, you have a correct routines for erasing and writing to FLASH. Are you using some another debugger? Mail to the vendor, your podex is OK.

#### When trying to connect with gdb to target bdm12, I get a communication error (bdm12_put_packet RTS1->CTS1: Couldn't communicate with BDM12 pod)

Do you have podex plugged directly into a serial port? If not, does your serial cable have wires even for both signals RTS and CTS? Are you trying to connect to right port? In a hopeless case, you can try to enlarge timeout constants in `bdm12.h`, if you think your computer/bus is running out of resources.
