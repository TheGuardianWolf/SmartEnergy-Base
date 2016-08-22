library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity display_buffer is
  port
    (
      clock          : in std_logic := '0';

		bits : in std_logic_vector(9 downto 0) := (others => '0');
      display_update : in std_logic := '0';
      desync         : in std_logic := '0';

      display_output : out std_logic_vector(7 downto 0) := (others => '0')
    );
end entity;

architecture rtl of display_buffer is
signal display_output_temp : std_logic_vector(7 downto 0) := (others => '0');
begin
  -- Buffer for the display as we don't always want to display what we have
  -- recieved in case of desync. If desync is detected by the buffer, then we
  -- display "-" on the enabled displays.
	DisplayBuffer : process(clock, bits, display_update)
	begin
    -- Conditional behavior
    display_output <= display_output_temp;
    if(rising_edge(clock)) then
      if (desync = '1') then
        -- display_output <= "00000000";
        display_output_temp <= "00000001";
      elsif (display_update = '1') then
        display_output_temp <= bits(7 downto 0);
      end if;
    end if;
  end process;
end architecture;
