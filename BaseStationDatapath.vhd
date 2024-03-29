library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity BaseStationDatapath is
  port
    (
      clock                : in std_logic := '0';

      Rx                   : in std_logic := '1';
      sample_increment     : in std_logic := '0';
      sample_reset         : in std_logic := '0';
      bits_increment       : in std_logic := '0';
      bits_shift           : in std_logic := '0';
      bits_reset           : in std_logic := '0';
      vote_increment       : in std_logic := '0';
      vote_shift           : in std_logic := '0';
      vote_reset           : in std_logic := '0';
      display_update       : in std_logic := '0';
      display_select_reset : in std_logic := '0';
      desync               : in std_logic := '0';

      sample_5             : out std_logic := '0';
      sample_7             : out std_logic := '0';
      sample_13            : out std_logic := '0';
      sample_15            : out std_logic := '0';
      bit_9                : out std_logic := '0';
      vote_3               : out std_logic := '0';
      majority_Rx          : out std_logic := '1';
      sync                 : out std_logic := '0';
      validation_error     : out std_logic := '0';
      resync_delay         : out std_logic := '0';
      display_output       : out std_logic_vector(7 downto 0) := (others => '0');
      display_select       : out std_logic_vector(3 downto 0) := (others => '0')
		  -- bits_debug        : out std_logic_vector(8 downto 0) := (others => '1')
    );
end entity;

architecture rtl of BaseStationDatapath is
  signal majority_vote       : std_logic := '1';
  signal data_xor            : std_logic := '0';
  signal packet_invalid      : std_logic := '0';
  signal desync_temp         : std_logic := '0';
  signal sync_temp           : std_logic := '0';
  signal display_output_temp : std_logic_vector(7 downto 0) := (others => '0');
  signal display_select_temp : std_logic_vector(3 downto 0) := (others => '0');
  signal sample_count        : std_logic_vector(3 downto 0) := (others => '0');
  signal bits_count          : std_logic_vector(3 downto 0) := (others => '0');
  signal vote_count          : std_logic_vector(1 downto 0) := (others => '0');
  signal votes               : std_logic_vector(2 downto 0) := (others => '1');
  signal bits                : std_logic_vector(9 downto 0) := (others => '0');
  begin

  -- Samples counter:
  -- Counter has limit at "1111" and a reset that can be triggered by FSM.
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

  -- Bit counter:
  -- Counter has limit at "1001" and a reset that can be triggered by FSM.
  BCounter: process(clock, bits_reset, bits_increment)
  begin
    -- Count with clock rising edge
    if(rising_edge(clock)) then
      if (bits_reset = '1') then
        bits_count <= "0000";
      else
        if (bits_increment = '1') then
          if (bits_count = "1001") then
            bits_count <= "0000";
          else
            bits_count <= bits_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Vote counter:
  -- Counter has limit at "11" and a reset that can be triggered by FSM.
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

  -- Trigger to stop the FSM delay when data validation fails.
  AutoSyncDelay: process(bits_count)
  begin
    -- Default behavior
    resync_delay <= '0';
    -- Conditional behavior
    if (bits_count = "0001") then
      resync_delay <= '1';
    end if;
  end process;

  -- Validates packets by comparing the odd parity generated from combinational
  -- circuit with the parity sent over UART, and compares the stop bit logic to
  -- a logic high signal. If either checks fail, the packet is invalid.
  PacketValidator: process(bits, data_xor, sample_count, packet_invalid)
  begin
    -- Default behavior
    packet_invalid <= '0';
    validation_error <= packet_invalid;
    -- Conditional behavior
    if (bits(9) = '0' or bits(8) = data_xor) then
      packet_invalid <= '1';
    end if;
  end process;

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

  -- Majority vote combinational circuit to decide whether the bit is a 1 or 0.
  MajorityVote: process(votes, majority_vote)
  begin
    majority_vote <= (votes(0) and votes(1)) or (votes(0) and votes(2)) or (votes(2) and votes(1));
    majority_Rx <= majority_vote;
  end process;

  -- Generates a parity bit from the recieved data bits, intended to be compared
  -- with the parity bit sent over UART. Generates an odd parity bit.
  ParityGenerator: process(bits)
  begin
    data_xor <= xor_reduce(bits(7 downto 0));
  end process;

  -- Detects if a sync packet was sent. If packet is invalid, this is
  -- disregarded.
  SyncDetect: process(bits, sync_temp, packet_invalid)
  begin
    -- Default behavior
    sync_temp <= '0';
    sync <= sync_temp;
    -- Conditional behavior
    if ( (bits(7 downto 0) = "11100000" or bits(7 downto 0) = "11000010") and packet_invalid = '0') then
      sync_temp <= '1';
    end if;
  end process;

  -- Stores the voting samples.
  VoteRegister: process(clock, vote_shift)
  begin
    if(rising_edge(clock)) then
      if vote_shift = '1' then
        votes <= Rx & votes(2 downto 1);
      end if;
    end if;
  end process;

  -- Stores the desync flag. Required to prevent an inferred latch from a
  -- constant assertion from FSM otherwise.
  SyncRegister: process(clock, desync, sync_temp)
  begin
    if(rising_edge(clock)) then
      if desync = '1' then
        desync_temp <= '1';
      end if;
      if (sync_temp = '1') then
        desync_temp <= '0';
      end if;
    end if;
  end process;

  -- Shift register stores the bits coming over UART, after being decided by the
  -- majority voter.
  BitShifter: process(clock, bits_shift, bits)
  begin
    -- Conditional behavior
	--  bits_debug <= bits;
    if(rising_edge(clock)) then
      if bits_shift = '1' then
        bits <= majority_vote & bits(9 downto 1);
      end if;
    end if;
  end process;

  -- Buffer for the display as we don't always want to display what we have
  -- recieved in case of desync. If desync is detected by the buffer, then we
  -- display "-" on the enabled displays.
	DisplayBuffer : process(clock, bits, display_update, display_output_temp)
	begin
    display_output <= display_output_temp;
    -- Conditional behavior
    if(rising_edge(clock)) then
      if (desync_temp = '1') then
        -- display_output <= "00000000";
        display_output_temp <= "11111111";
      elsif (display_update = '1') then
        display_output_temp <= bits(7 downto 0);
      end if;
    end if;
  end process;

  -- Cyclic shift register that keeps a '1' stored somewhere in its bits to
  -- enable at least 1 display in normal operation. When reset, the pointer is
  -- not placed on a display so the next incoming packet will be displayed on
  -- the first display. Each packet moves the pointer one to the left. When
  -- desync is detected, all displays are active to display the "-" character.
  DisplayShifter : process(clock, display_select_reset, display_select_temp, display_update)
  -- With integrated comparators to detect when to shift in '1'
  begin
    -- Default behavior
    display_select <= display_select_temp;
    -- Conditional behavior
    if (rising_edge(clock)) then
      if (display_select_reset = '1') then
        display_select_temp <= "0000";
      elsif (desync_temp = '1') then
        display_select_temp <= "1111";
      else
        if (display_update = '1') then
          if (display_select_temp = "0000") then
            display_select_temp <= display_select_temp(2 downto 0) & '1';
          else
            display_select_temp <= display_select_temp(2 downto 0) & display_select_temp(3);
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
