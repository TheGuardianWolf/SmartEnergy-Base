library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity b_counter is
  port
    (
      clock          : in std_logic := '0';

      bits_increment : in std_logic := '0';
      bits_shift     : in std_logic := '0';
      bits_reset     : in std_logic := '0';

      bits_count     : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture behavior of b_counter is
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
end archtecture;
