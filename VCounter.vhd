library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity v_counter is
  port
    (
      clock          : in std_logic := '0';

      vote_increment : in std_logic := '0';
      vote_shift     : in std_logic := '0';
      vote_reset     : in std_logic := '0';

      vote_count     : out std_logic_vector(1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of v_counter is
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
end archtecture;
