library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bit_shifter is
  port
    (
      clock         : in std_logic := '0';

      majority_vote : in std_logic := '1';
      bits_shift    : in std_logic := '0';

      bits          : out std_logic_vector(9 downto 0) := (others => '0')
    );
end entity;

architecture rtl of bit_shifter is
  signal bits_temp : std_logic_vector(9 downto 0) := (others => '0');
  -- Shift register stores the bits coming over UART, after being decided by the
  -- majority voter.
  begin
  BitShifter: process(clock, bits_shift, bits_temp, majority_vote)
  begin
    -- Conditional behavior
	--  bits_debug <= bits;
    bits <= bits_temp;
    if(rising_edge(clock)) then
      if bits_shift = '1' then
        bits_temp <= majority_vote & bits_temp(9 downto 1);
      end if;
    end if;
  end process;
end architecture;
