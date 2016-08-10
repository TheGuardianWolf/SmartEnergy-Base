library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity BaseStationFSM is
  port
  (
    clock            : in std_logic := '0';

<<<<<<< HEAD
    Rx               : in std_logic := '0';
    sample_take      : in std_logic := '0';
    sample_finish    : in std_logic := '0';
    bits_finish      : in std_logic := '0';

    sample_increment : out std_logic := '0';
    sample_reset     : out std_logic := '0';
    bits_shift       : out std_logic := '0';
    bits_increment   : out std_logic := '0';
    bits_reset       : out std_logic := '0';
    display_update   : out std_logic := '0'
=======
    Rx               : in std_logic;
    sample_take      : in std_logic; --s7
    sample_finish    : in std_logic; --s15
    bits_finish      : in std_logic; --n7
	 

    sample_increment : out std_logic; -- en_s
    sample_reset     : out std_logic; -- res_s
    bits_shift       : out std_logic; -- en_shi
    bits_increment   : out std_logic; -- en_n
    bits_reset       : out std_logic; -- res_n
	 
	 sample6				: in std_logic; --s6
	 ChosenRx			: out std_logic
	 
>>>>>>> origin/master
  );
end entity;

architecture rtl of BaseStationFSM is
	--signal cntbit0: std_logic_vector(2 downto 0) := "000";
	--signal cntbit1: std_logic_vector(2 downto 0) := "000";
  type states is
  (
    idle,
    start,
    data,
	 check,
    stop
  );
  signal CurrentState, NextState : states:= idle;
 
  begin
    -- Changes the state to NextState
    StateProcess: process(clock)
    begin
      if rising_edge(clock) then
        CurrentState <= NextState;
      end if;
    end process;

    -- Determines what the next state is
    NextStateLogic: process
    (
		clock,
      CurrentState,
      Rx,
      sample_take,
      sample_finish,
      bits_finish, 
		sample6 -- Scounter at count 6
    )
    begin
      case CurrentState is
        -- Idle state behavior
        when idle =>
        if (Rx = '0') then
		    NextState <= start;
        else
          NextState <= idle;
        end if;

        -- Start state behavior
        when start =>
        if (sample_take = '1') then
          NextState <= data;
        else
          NextState <= start;
        end if;

        -- Data state behavior
        when data =>
		  if (sample_finish = '1') then -- when sampling for a bit is finsihed
			 NextState <= check; -- we need to check this bit to confirm this is correct
		  else -- if the sampling is not finished
			 NextState <= data; -- stay at data state and keep sampling
		  end if;

		  -- check state behavior
		  when check =>
		  if (sample6 = '1') then -- if counter count to 6
			 if (bits_finish = '1') then -- if this is the last bit of 8bit data
				NextState <= stop;
			 else -- if this is not the last bit of 8bit data
				NextState <= data;
			 end if;
		  else -- if counter is not at 6 yet
			 NextState <= check;
		  end if;
		  
        -- Stop state behavior
        when stop =>
        if (sample_finish = '1') then
          NextState <= idle;
<<<<<<< HEAD
        else
          NextState <= stop;
	      end if;
=======
	     end if;
			
>>>>>>> origin/master
      end case;
    end process;

    -- Sets output values
    OutputLogic: process
    (
		clock,
      CurrentState,
      Rx,
      sample_take,
      sample_finish,
      bits_finish,
		sample6 -- Scounter at count 6
    )
	 variable cntbit1: Integer range 0 to 7:= 0;
	 variable cntbit0: Integer range 0 to 7:= 0;
	 
    begin
      -- Default outputs
      sample_increment <= '0';
      sample_reset <= '0';
      bits_shift <= '0';
      bits_increment <= '0';
      bits_reset <= '0';
<<<<<<< HEAD
		display_update <= '0';
=======
		ChosenRx <= Rx;
>>>>>>> origin/master

      -- State conditional outputs
      case CurrentState is
        -- Idle state behavior
        when idle =>
        if (Rx = '0') then
          sample_reset <= '1';
        end if;

        -- Start state behavior
        when start =>
        if (sample_take = '1') then
          sample_reset <= '1';
          bits_reset <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Data state behavior
        when data =>
		  cntbit0 := 0; -- initial cntbit0 and cntbit1
		  cntbit1 := 0;
        if (sample_finish = '1') then -- if counter is at 15, we are at the middle of the bit, will go to check state
			 sample_reset <= '1'; -- reset the counter
			 ChosenRx <= Rx; -- remember the bit in the middle
			 
        else
          sample_increment <= '1'; -- count 1 in Scounter
        end if;

		  when check =>
		  if (sample6 = '1') then -- if counter count to 6
			 if (cntbit1 > cntbit0) then -- if bit1 appears more after the middle bit
				ChosenRx <= '1';	 -- we determine the correct bit is 1
			 elsif (cntbit1 < cntbit0) then -- if bit0 appears more after the middle bit
				ChosenRx <= '0';	 -- we determine the correct bit is 1
										 -- if numbers of bit1 and bit0 are equal
										 -- we will shift the bit in the middle
			 end if;
			 bits_shift <= '1';
			 cntbit0 := 0; --reset both cntbit0 and cntbit1
			 cntbit1 := 0;
			 if (bits_finish = '1') then -- if this is the last bit of 8bit data
				bits_reset <= '1';
				sample_reset <= '1'; -- reset Scounter
			 else -- if this is not the last bit of 8bit data
				bits_increment <= '1'; -- the we go back to data stage and count 1 in Bcounter
				sample_increment <= '1'; -- count 1 in Scounter
			 end if;
			 
		  else -- if counter is not at 6 yet
			 if (Rx = '1') then -- if the input bit is 1
				
				cntbit1 := cntbit1 + 1;
				
			 else -- if the input bit is 0
				
				cntbit0 := cntbit0 + 1;
				
			 end if;
			 sample_increment <= '1'; -- count 1 in Scounter
		  end if;
		  
		  
        -- Stop state behavior
        when stop =>
        if (sample_finish = '1') then
          display_update <= '1';
        else
          sample_increment <= '1';
	     end if;
		  
      end case;
    end process;
end architecture;
