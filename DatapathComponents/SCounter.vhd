library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity s_counter is
  port
    (
      clock            : in std_logic := '0';

      sample_increment : in std_logic := '0';
      sample_reset     : in std_logic := '0';

      sample_count     : buffer std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture behavior of s_counter is
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
end architecture;
