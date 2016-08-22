library ieee;
use ieee.std_logic_1164.all;

entity counter_comparators is
  port
    (
      sample_count : in std_logic_vector(3 downto 0) := (others => '0');
      bits_count   : in std_logic_vector(3 downto 0) := (others => '0');
      vote_count   : in std_logic_vector(1 downto 0) := (others => '0');

      sample_5     : out std_logic := '0';
      sample_7     : out std_logic := '0';
      sample_13    : out std_logic := '0';
      sample_15    : out std_logic := '0';
      bit_9        : out std_logic := '0';
      vote_3       : out std_logic := '0'
    );
end entity;

architecture behavior of counter_comparators is
begin
  -- General purpose comparator for decimal 3.
  Comparator3: process(vote_count)
  begin
    -- Default behavior
    vote_3 <= '0';
    -- Conditional behavior
    if (vote_count = "11") then
      vote_3 <= '1';
    end if;
  end process;

  -- General purpose comparator for decimal 5.
  Comparator5: process(sample_count)
  begin
    -- Default behavior
    sample_5 <= '0';
    -- Conditional behavior
    if (sample_count = "0101") then
      sample_5 <= '1';
    end if;
  end process;

  -- General purpose comparator for decimal 7.
  Comparator7: process(sample_count)
  begin
    -- Default behavior
    sample_7 <= '0';
    -- Conditional behavior
    if (sample_count = "0111") then
      sample_7 <= '1';
    end if;
  end process;

  -- General purpose comparator for decimal 9.
  Comparator9: process(bits_count)
  begin
    -- Default behavior
    bit_9 <= '0';
    if (bits_count = "1001") then
      bit_9 <= '1';
    end if;
  end process;

  -- General purpose comparator for decimal 13.
  Comparator13: process(sample_count)
  begin
    -- Default behavior
    sample_13 <= '0';
    -- Conditional behavior
    if (sample_count = "1101") then
      sample_13 <= '1';
    end if;
  end process;

  -- General purpose comparator for decimal 15.
  Comparator15: process(sample_count)
  begin
    -- Default behavior
    sample_15 <= '0';
    -- Conditional behavior
    if (sample_count = "1111") then
      sample_15 <= '1';
    end if;
  end process;
end architecture;
