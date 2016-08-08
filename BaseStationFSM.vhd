library ieee;
use ieee.std_logic_1164.all;

entity BaseStationFSM is
  port
  (
    clock            : in std_logic;

    Rx               : in std_logic;
    sample_take      : in std_logic;
    sample_finish    : in std_logic;
    bits_finish      : in std_logic;

    sample_increment : out std_logic;
    sample_reset     : out std_logic;
    bits_shift       : out std_logic;
    bits_increment   : out std_logic;
    bits_reset       : out std_logic
  );
end entity;

architecture rtl of BaseStationFSM is
  type states is
  (
    idle,
    start,
    data,
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
      sample_take,
      sample_finish,
      bits_finish
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
        if (sample_finish = '1' and bits_finish = '1') then
          NextState <= stop;
        else
          NextState <= data;
        end if;

        -- Stop state behavior
        when stop =>
        if (sample_finish = '0') then
          NextState <= stop;
        else
          NextState <= idle;
	      end if;
      end case;
    end process;

    -- Sets output values
    OutputLogic: process
    (
      CurrentState,
      Rx,
      sample_take,
      sample_finish,
      bits_finish
    )
    begin
      -- Default outputs
      sample_increment <= '0';
      sample_reset <= '0';
      bits_shift <= '0';
      bits_increment <= '0';
      bits_reset <= '0';

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
        if (sample_finish = '1') then
          if (bits_finish = '1') then
            sample_reset <= '1';
            bits_shift <= '1';
          else
            sample_reset <= '1';
            bits_shift <= '1';
            bits_increment <= '1';
          end if;
        else
          sample_increment <= '1';
        end if;

        -- Stop state behavior
        when stop =>
        if (sample_finish = '0') then
          sample_increment <= '1';
	      end if;
      end case;
    end process;
end architecture;
