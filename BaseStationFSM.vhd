library ieee;
use ieee.std_logic_1164.all;

entity BaseStationFSM is
  port
  (
    clock            : in std_logic := '0';

    Rx               : in std_logic := '0';
    sample_start      : in std_logic := '0';
    sample_finish    : in std_logic := '0';
    bits_finish      : in std_logic := '0';
    vote_finish      : in std_logic := '0';
    majority_Rx      : in std_logic := '1';

    sample_increment : out std_logic := '0';
    sample_reset     : out std_logic := '0';
    bits_increment   : out std_logic := '0';
    bits_shift       : out std_logic := '0';
    bits_reset       : out std_logic := '0';
    vote_increment   : out std_logic := '0';
    vote_shift       : out std_logic := '0';
    vote_reset       : out std_logic := '0';
    display_update   : out std_logic := '0'
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
      CurrentState,
      Rx,
      sample_start,
      sample_finish,
      bits_finish,
      vote_finish,
      majority_Rx
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
        if (sample_start = '1') then
          NextState <= start_vote;
        else
          NextState <= start;
        end if;

        -- Start Voting state behavior
        when start_vote =>

        if (vote_finish = '1' and majority_Rx = '0') then
          NextState <= data;
        elsif (vote_finish = '1') then
          NextState <= idle;
        else
          NextState <= start_vote;
        end if;

        -- Data state behavior
        when data =>
        if (sample_finish = '1') then
          NextState <= data_vote;
        else
          NextState <= data;
        end if;

        -- Data Voting state behavior
        when data_vote =>
        if (bits_finish = '1' and vote_finish = '1') then
          NextState <= stop;
        elsif (vote_finish = '1') then
          NextState <= data;
        else
          NextState <= data_vote;
        end if;

        -- Stop state behavior
        when stop =>
        if (sample_finish = '1') then
          NextState <= idle;
        else
          NextState <= stop;
	      end if;
      end case;
    end process;

    -- Sets output values
    OutputLogic: process
    (
      CurrentState,
      Rx,
      sample_start,
      sample_finish,
      bits_finish,
      vote_finish,
      majority_Rx
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

      -- State conditional outputs
      case CurrentState is
        -- Idle state behavior
        when idle =>
        if (Rx = '0') then
          sample_reset <= '1';
          bits_reset <= '1';
    			vote_reset <= '1';
        end if;

        -- Start state behavior
        when start =>
        if (sample_start = '1') then
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Start Voting state behavior
        when start_vote =>
        if (vote_finish = '1' and majority_Rx = '0') then
          sample_reset <= '1';
          vote_reset <= '1';
        elsif (vote_finish = '1') then
          sample_reset <= '1';
          vote_reset <= '1';
        else
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        end if;

        -- Data state behavior
        when data =>
        if (sample_finish = '1') then
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
        else
          sample_increment <= '1';
        end if;

        -- Data Voting state behavior
        when data_vote =>
        if (bits_finish = '1' and vote_finish = '1') then
          bits_shift <= '1';
          sample_increment <= '1';
          vote_reset <= '1';
        elsif (vote_finish = '1') then
          bits_shift <= '1';
          bits_increment <= '1';
          sample_increment <= '1';
          vote_reset <= '1';
        else
          vote_shift <= '1';
          vote_increment <= '1';
          sample_increment <= '1';
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
