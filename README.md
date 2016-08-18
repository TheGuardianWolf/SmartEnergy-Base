# SmartEnergy-Base
Repository containing the VHDL code and other components required for the operation of the base station.

# TODO
- <s>Verify framing (Discard packets if stop is incorrect and wait for sync)
http://electronics.stackexchange.com/questions/196553/detecting-start-bit-in-software-uart</s>
- <s>Enable parity check (Discard packets if parity is incorrect and wait for sync)
http://www.cs.umd.edu/class/sum2003/cmsc311/Notes/BitOp/xor.html</s>
- <s>Enstate break response (Discard packets when no packets are recieved for 1s and wait for sync)
https://en.wikipedia.org/wiki/Universal_asynchronous_receiver/transmitter#Break_condition</s>
- <s>Create timedelay such that the device can automatically resync if desync detected.</s>
- Testing... always testing...

# Known Bugs
- If display sync packet is not coded to be "000000000", it does not sync correctly.
