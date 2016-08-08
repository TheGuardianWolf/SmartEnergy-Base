library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity BaseStationDatapath is
  port
    (
      clock            : in std_logic;

      Rx               : in std_logic;
      sample_increment : in std_logic;
      sample_reset     : in std_logic;
      bits_increment   : in std_logic;
      bits_reset       : in std_logic;
      bits_shift       : in std_logic;

      sample_take      : out std_logic;
      sample_finish    : out std_logic;
      bits_finish      : out std_logic;
      bits_output      : out std_logic_vector(7 downto 0)
    );
  end entity;

  architecture rtl of BaseStationDatapath is
    signal sample_count: std_logic_vector(3 downto 0) := "0000";
    signal bits_count: std_logic_vector(2 downto 0) := "000";
    signal bits: std_logic_vector(7 downto 0) := (others => '0');
    begin

      SCounter: process(clock, sample_reset, sample_increment)
      begin
        -- Count with clock rising edge
        if(rising_edge(clock)) then
          if (sample_reset = '1') then
            sample_count <= "0000";
          else
            if sample_increment = '1' then
              if sample_count = "1111" then
                sample_count <= "0000";
              else
                sample_count <= sample_count + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

      BCounter: process(clock, bits_reset, bits_increment)
      begin
        -- Count with clock rising edge
        if(rising_edge(clock)) then
          if (bits_reset = '1') then
            bits_count <= "000";
          else
            if bits_increment = '1' then
              if bits_count = "111" then
                bits_count <= "000";
              else
                bits_count <= bits_count + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

      Comparator7: process(sample_count, bits_count)
      begin
        -- Default output
        sample_take <= '0';
        bits_finish <= '0';
        -- Conditional output
        if sample_count = "0111" then
          sample_take <= '1';
        end if;
        if bits_count = "111" then
          bits_finish <= '1';
        end if;
      end process;

      Comparator15: process(sample_count)
      begin
        -- Default output
        sample_finish <= '0';
        -- Conditional output
        if sample_count = "1111" then
          sample_finish <= '1';
        end if;
      end process;

      BitShifter: process(clock, bits_shift, bits)
      begin
        bits_output <= bits;
        if(rising_edge(clock)) then
          if bits_shift = '1' then
            bits <= Rx & bits(7 downto 1);
          end if;
        end if;
      end process;

  end architecture;
