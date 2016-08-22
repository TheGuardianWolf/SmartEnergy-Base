library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity display_shifter is
  port
    (
      clock                : in std_logic := '0';

      display_update       : in std_logic := '0';
      display_select_reset : in std_logic := '0';
		desync               : in std_logic := '0';

      display_select       : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture rtl of display_shifter is
  signal display_select_temp : std_logic_vector(3 downto 0) := (others => '0');
  -- Cyclic shift register that keeps a '1' stored somewhere in its bits to
  -- enable at least 1 display in normal operation. When reset, the pointer is
  -- not placed on a display so the next incoming packet will be displayed on
  -- the first display. Each packet moves the pointer one to the left. When
  -- desync is detected, all displays are active to display the "-" character.
  begin
  DisplayShifter : process(clock, display_select_reset, display_select_temp, display_update)
  -- With integrated dual comparators to detect when to shift in '1'
  begin
    -- Default behavior
    display_select <= display_select_temp;
    -- Conditional behavior
    if (rising_edge(clock)) then
      if (display_select_reset = '1') then
        display_select_temp <= "0000";
      elsif (desync = '1') then
        display_select_temp <= "1111";
      else
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
