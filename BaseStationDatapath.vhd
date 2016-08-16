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
      bits_shift       : in std_logic := '0';
      bits_reset       : in std_logic := '0';
      vote_increment   : in std_logic := '0';
      vote_shift       : in std_logic := '0';
      vote_reset       : in std_logic := '0';
      display_update   : in std_logic := '0';

      sample_start      : out std_logic := '0'; -- Triggers on Sample 5
      sample_finish    : out std_logic := '0'; -- Triggers on Sample 14
      bits_finish      : out std_logic := '0'; -- Triggers after bit 7
      vote_finish      : out std_logic := '0';
      majority_Rx      : out std_logic := '1';
      display_output   : out std_logic_vector(7 downto 0) := (others => '1');
      display_select   : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture rtl of BaseStationDatapath is
  signal display_select_reset : std_logic := '0';
  signal majority_vote        : std_logic := '1';
  signal display_select_temp  : std_logic_vector(3 downto 0) := (others => '0');
  signal sample_count         : std_logic_vector(3 downto 0) := (others => '0');
  signal bits_count           : std_logic_vector(2 downto 0) := (others => '0');
  signal vote_count           : std_logic_vector(1 downto 0) := (others => '0');
  signal votes                : std_logic_vector(2 downto 0) := (others => '1');
  signal bits                 : std_logic_vector(7 downto 0) := (others => '0');
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

  VCounter: process(clock, vote_reset, vote_increment)
  begin
    -- Count with clock rising edge
    if(rising_edge(clock)) then
      if (vote_reset = '1') then
        vote_count <= "00";
      else
        if (vote_increment = '1') then
          if (vote_count = "11") then
            vote_count <= "00";
          else
            vote_count <= vote_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  Comparator3: process(vote_count)
  begin
    -- Default behavior
    vote_finish <= '0';
    -- Conditional behavior
    if (vote_count = "11") then
      vote_finish <= '1';
    end if;
  end process;

  Comparator5: process(sample_count)
  begin
    -- Default behavior
    sample_start <= '0';
    -- Conditional behavior
    if (sample_count = "0011") then
      sample_start <= '1';
    end if;
  end process;

  Comparator7: process(bits_count)
  begin
    -- Default behavior
    bits_finish <= '0';
    -- Conditional behavior
    if (bits_count = "111") then
      bits_finish <= '1';
    end if;
  end process;

  Comparator14: process(sample_count)
  begin
    -- Default behavior
    sample_finish <= '0';
    -- Conditional behavior
    if (sample_count = "1110") then
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

  VoteRegister: process(clock, vote_shift)
  begin
    if(rising_edge(clock)) then
      if vote_shift = '1' then
        votes <= Rx & votes(2 downto 1);
      end if;
    end if;
  end process;

  MajorityVote: process(votes, majority_vote)
  begin
    majority_vote <= (votes(0) and votes(1)) or (votes(0) and votes(2)) or (votes(2) and votes(1));
    majority_Rx <= majority_vote;
  end process;

  BitShifter: process(clock, bits_shift, bits)
  begin
    -- Conditional behavior
    if(rising_edge(clock)) then
      if bits_shift = '1' then
        bits <= majority_vote & bits(7 downto 1);
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
