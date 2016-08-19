-- Finite state machine design
-- EE 209 - Group 10
-- Authored by Jerry Fan

library ieee;
use ieee.std_logic_1164.all;

entity BaseStationFSM is
	port
	(
		clock								 : in std_logic := '0';

		Rx									 : in std_logic := '0';
		sample_5						 : in std_logic := '0';
		sample_7						 : in std_logic := '0';
		sample_13						 : in std_logic := '0';
		sample_15						 : in std_logic := '0';
		bit_9								 : in std_logic := '0';
		vote_3							 : in std_logic := '0';
		majority_Rx					 : in std_logic := '1';
		sync								 : in std_logic := '0';
		validation_error		 : in std_logic := '0';
		resync_delay				 : in std_logic := '0';

		sample_increment		 : out std_logic := '0';
		sample_reset				 : out std_logic := '0';
		bits_increment			 : out std_logic := '0';
		bits_shift					 : out std_logic := '0';
		bits_reset					 : out std_logic := '0';
		vote_increment			 : out std_logic := '0';
		vote_shift					 : out std_logic := '0';
		vote_reset					 : out std_logic := '0';
		display_update			 : out std_logic := '0';
		display_select_reset : out std_logic := '0';
		desync							 : out std_logic := '0';
		state                : out std_logic_vector(2 downto 0) := "000"
	);
end entity;

architecture rtl of BaseStationFSM is
	type states is
	(
		idle,
		start,
		start_vote,
		data,
		data_vote,
		validate
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
			CurrentState,
			Rx,
			sample_5,
			sample_7,
			sample_13,
			sample_15,
			bit_9,
			vote_3,
			majority_Rx,
			validation_error,
			resync_delay
		)
		begin
			case CurrentState is
				-- Idle state behavior:
        -- The idle state will keep checking the unfiltered Rx signal for logic
        -- '0' to attempt to detect a start bit. If successful, this will
        -- transition to the start state.
				when idle =>
				if (Rx = '0') then
					NextState <= start;
				else
					NextState <= idle;
				end if;

				-- Start state behavior:
        -- The start state waits until the sample counter is at 5 before passing
        -- the state to start_vote. This state is purely for delay purposes.
				when start =>
				if (sample_5 = '1') then
					NextState <= start_vote;
				else
					NextState <= start;
				end if;

				-- Start Voting state behavior:
        -- This state controls the voting for the start bit, using the
        -- combinational output majority_Rx to decide whether the start bit is
        -- valid or a noise signal. If valid, state is passed to data. Otherwise
        -- state will return to idle.
				when start_vote =>
				if (vote_3 = '1' and majority_Rx = '0') then
					NextState <= data;
				elsif (vote_3 = '1') then
					NextState <= idle;
				else
					NextState <= start_vote;
				end if;

				-- Data state behavior:
        -- The data state waits until the sample counter is at 12 before passing
        -- the state to data_vote. This state is purely for delay.
				when data =>
				if (sample_13 = '1') then
					NextState <= data_vote;
				else
					NextState <= data;
				end if;

				-- Data Voting state behavior:
        -- The data voting state behaves like the start_vote state, but only
        -- will cycle back to the data state to wait for the next bit. If bit_9
        -- has been reached on the bit counter, then it will change to the
        -- validate state.
				when data_vote =>
				if (bit_9 = '1' and vote_3 = '1') then
					NextState <= validate;
				elsif (vote_3 = '1') then
					NextState <= data;
				else
					NextState <= data_vote;
				end if;

				-- Validation state behavior:
        -- The validation state has complex behavior that is controlled by many
        -- input signals. On detection of a validation error, it will wait for
        -- the resync_delay signal to be triggered before passing on to idle
        -- state to automatically try to compensate for a frame mismatch.
				when validate =>
				if (validation_error = '0') then
					NextState <= idle;
				else
					if (resync_delay = '1') then
						NextState <= idle;
					else
						NextState <= validate;
					end if;
				end if;
			end case;
		end process;

		-- Sets output values
		OutputLogic: process
		(
			CurrentState,
			Rx,
			sample_5,
			sample_7,
			sample_13,
			sample_15,
			bit_9,
			vote_3,
			majority_Rx,
			validation_error,
			sync,
			resync_delay
		)
		begin
			-- Default outputs:
      -- These are asserted always to prevent latch behavior.
			sample_increment <= '0';
			sample_reset <= '0';
			bits_shift <= '0';
			bits_increment <= '0';
			bits_reset <= '0';
			vote_shift <= '0';
			vote_increment <= '0';
			vote_reset <= '0';
			display_update <= '0';
			display_select_reset <= '0';
			desync <= '0';
			state <= "000";

			-- State conditional outputs
			case CurrentState is
				-- Idle state behavior:
        -- When a logic low is detected on incoming Rx, the state starts the
        -- read process by resetting all counters to 0.
				when idle =>
				state <= "000";
				if (Rx = '0') then
					sample_reset <= '1';
					bits_reset <= '1';
					vote_reset <= '1';
				end if;

				-- Start state behavior:
        -- This state doesn't do much until sample_5 is recieved. This signal
        -- begins the voting process, as start will go to the start_vote state.
        -- In all cases, the sample count is incremented.
				when start =>
				state <= "001";
				if (sample_5 = '1') then
					sample_increment <= '1';
					vote_shift <= '1';
					vote_increment <= '1';
				else
					sample_increment <= '1';
				end if;

				-- Start Voting state behavior
        -- The start vote state will decide whether the start bit is valid or
        -- is caused by noise. In any case, if sample_7 is reached, this causes
        -- a sample reset to prepare for the data state. The state waits for
        -- the results from the three votes, and will issue a desync if the
        -- majority_Rx turns out to be a false start. If waiting for votes,
        -- vote shifting and counter incrementing occurs, and sample is also
        -- incremented. If successful, vote counter will be reset.
				when start_vote =>
				state <= "010";
				if (sample_7 = '1') then
					sample_reset <= '1';
				end if;
				if (vote_3 = '1' and majority_Rx = '0') then
					vote_reset <= '1';
					sample_increment <= '1';
				elsif (vote_3 = '1') then
					desync <= '1';
				else
					vote_shift <= '1';
					vote_increment <= '1';
					sample_increment <= '1';
				end if;

				-- Data state behavior
        -- This state doesn't do much until sample_13 is recieved. This signal
        -- begins the voting process, as data will go to the data_vote state.
        -- In all cases, the sample count is incremented.
				when data =>
				state <= "011";
				if (sample_13 = '1') then
					sample_increment <= '1';
					vote_shift <= '1';
					vote_increment <= '1';
				else
					sample_increment <= '1';
				end if;

				-- Data Voting state behavior
				when data_vote =>
				state <= "100";
				if (bit_9 = '1' and vote_3 = '1') then
					bits_shift <= '1';
					sample_increment <= '1';
					vote_reset <= '1';
				elsif (vote_3 = '1') then
					bits_shift <= '1';
					bits_increment <= '1';
					sample_increment <= '1';
					vote_reset <= '1';
				else
					vote_shift <= '1';
					vote_increment <= '1';
					sample_increment <= '1';
				end if;

				-- Validate state behavior
				when validate =>
				state <= "101";
				if (validation_error = '0') then
					display_update <= '1';
					if (sync = '1') then
						display_select_reset <= '1';
					end if;
				else
					desync <= '1';
					sample_increment <= '1';
					if (resync_delay = '0' and sample_15 = '1') then
						sample_increment <= '1';
						bits_increment <= '1';
					end if;
				end if;
			end case;
		end process;
end architecture;
