library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity BaseStationDatapath is
  port
    (
      clock            : in std_logic := '0';

      Rx               : in std_logic := '1';
      sample_increment : in std_logic := '0';
      sample_reset     : in std_logic := '0';
      bits_increment   : in std_logic := '0';
      bits_reset       : in std_logic := '0';
      bits_shift       : in std_logic := '0';
      display_update   : in std_logic := '0';

      sample_take      : out std_logic := '0';
      sample_finish    : out std_logic := '0';
      bits_finish      : out std_logic := '0';
      bits_output      : out std_logic_vector(7 downto 0) := (others => '0');
      display_output   : out std_logic_vector(7 downto 0) := (others => '1');
      display_select   : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture rtl of BaseStationDatapath is
  signal display_select_reset    : std_logic := '0';
  signal display_select_temp     : std_logic_vector(3 downto 0) := (others => '0');
  signal sample_count            : std_logic_vector(3 downto 0) := (others => '0');
  signal bits_count              : std_logic_vector(2 downto 0) := (others => '0');
  signal bits                    : std_logic_vector(7 downto 0) := (others => '0');
  begin

  SCounter: process(clock, sample_reset, sample_increment)
  begin
    -- Count with clock rising edge
    if(rising_edge(clock)) then
      if (sample_reset = '1') then
        sample_count <= "0000";
      else
        if (sample_increment = '1') then
          if (sample_count = "1111") then
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
        if (bits_increment = '1') then
          if (bits_count = "111") then
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
    -- Default behavior
    sample_take <= '0';
    bits_finish <= '0';
    -- Conditional behavior
    if (sample_count = "0111") then
      sample_take <= '1';
    end if;
    if (bits_count = "111") then
      bits_finish <= '1';
    end if;
  end process;

  Comparator15: process(sample_count)
  begin
    -- Default behavior
    sample_finish <= '0';
    -- Conditional behavior
    if (sample_count = "1111") then
      sample_finish <= '1';
    end if;
  end process;

  Comparator255: process(bits)
  begin
    -- Default behavior
    display_select_reset <= '0';
    -- Conditional behavior
    if (bits = "00000000") then
      display_select_reset <= '1';
    end if;
  end process;

  BitShifter: process(clock, bits_shift, bits)
  begin
    -- Default behavior
    bits_output <= bits; -- Debug stream for bits
    -- Conditional behavior
    if(rising_edge(clock)) then
      if bits_shift = '1' then
        bits <= Rx & bits(7 downto 1);
      end if;
    end if;
  end process;

	HoldRegister : process(clock, bits, display_update)
	begin
    -- Conditional behavior
    if(rising_edge(clock)) then
      if (display_update = '1') then
        display_output <= bits;
      end if;
    end if;
  end process;

  DisplayShifter : process(clock, display_select_reset, display_select_temp, display_update)
  -- With integrated dual comparators to detect when to shift in '1'
  begin
    -- Default behavior
    display_select <= display_select_temp;
    -- Conditional behavior
    if (display_select_reset = '1') then
      display_select_temp <= "0000";
    else
      if (rising_edge(clock)) then
        if (display_update = '1') then
          if (display_select_temp = "0000" or display_select_temp = "1000") then
            display_select_temp <= display_select_temp(2 downto 0) & '1';
          else
            display_select_temp <= display_select_temp(2 downto 0) & '0';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
