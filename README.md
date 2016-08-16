# SmartEnergy-Base
Repository containing the VHDL code and other components required for the operation of the base station.

# TODO
https://en.wikipedia.org/wiki/Universal_asynchronous_receiver/transmitter#Parity_error
- Verify framing (Discard packets if stop is incorrect and wait for sync)
- Enable parity check (Discard packets if parity is incorrect and wait for sync)
- Enstate break response (Discard packets when no packets are recieved for 1s and wait for sync)
