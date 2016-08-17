library ieee;
use ieee.std_logic_1164.all;

entity BaseStationFSM is
  port
  (
    clock                : in std_logic := '0';

    Rx                   : in std_logic := '0';
    sample_5             : in std_logic := '0';
    sample_7             : in std_logic := '0';
    sample_12            : in std_logic := '0';
    sample_15            : in std_logic := '0';
    bit_9                : in std_logic := '0';
    vote_3               : in std_logic := '0';
    majority_Rx          : in std_logic := '1';
    sync                 : in std_logic := '0';
    validation_error     : in std_logic := '0';
    resync_delay         : in std_logic := '0';

    sample_increment     : out std_logic := '0';
    sample_reset         : out std_logic := '0';
    bits_increment       : out std_logic := '0';
    bits_shift           : out std_logic := '0';
    bits_reset           : out std_logic := '0';
    vote_increment       : out std_logic := '0';
    vote_shift           : out std_logic := '0';
    vote_reset           : out std_logic := '0';
    display_update       : out std_logic := '0';
    display_select_reset : out std_logic := '0';
    desync               : out std_logic := '0'
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
      sample_12,
      sample_15,
      bit_9,
      vote_3,
      majority_Rx,
		  validation_error,
      resync_delay
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
        if (sample_5 = '1') then
          NextState <= start_vote;
        else
          NextState <= start;
        end if;

        -- Start Voting state behavior
        when start_vote =>
        if (vote_3 = '1' and majority_Rx = '0') then
          NextState <= data;
        else
          NextState <= start_vote;
        end if;

        -- Data state behavior
        when data =>
        if (sample_12 = '1') then
          NextState <= data_vote;
        else
          NextState <= data;
        end if;

        -- Data Voting state behavior
        when data_vote =>
        if (bit_9 = '1' and vote_3 = '1') then
          NextState <= validate;
        elsif (vote_3 = '1') then
          NextState <= data;
        else
          NextState <= data_vote;
        end if;

        -- Validation state behavior
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
      sample_12,
      sample_15,
      bit_9,
      vote_3,
      majority_Rx,
  		validation_error,
  		sync,
      resync_delay
    )
    begin
      -- Default outputs
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

      -- State conditional outputs
      case CurrentState is
        -- Idle state behavior
        when idle =>
        -- state <= "000";
        if (Rx = '0') then
          sample_reset <= '1';
          bits_reset <= '1';
    			vote_reset <= '1';
        end if;

        -- Start state behavior
        when start =>
        -- state <= "001";
        if (sample_5 = '1') then
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Start Voting state behavior
        when start_vote =>
        -- state <= "010";
        if (sample_7 = '1') then
          sample_reset <= '1';
        end if;
        if (vote_3 = '1' and majority_Rx = '0') then
          vote_reset <= '1';
        elsif (vote_3 = '1') then
          desync <= '1';
          vote_reset <= '1';
        else
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        end if;

        -- Data state behavior
        when data =>
        -- state <= "011";
        if (sample_12 = '1') then
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Data Voting state behavior
        when data_vote =>
        -- state <= "100";
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
        -- state <= "101";
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
