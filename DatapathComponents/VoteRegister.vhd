library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vote_register is
  port
    (
      clock      : in std_logic := '0';

      Rx         : in std_logic := '1';
      vote_shift : in std_logic := '0';

      votes      : out std_logic_vector(2 downto 0) := (others => '1')
    );
end entity;

architecture rtl of vote_register is
  signal votes_temp : std_logic_vector(2 downto 0) := (others => '1');
  begin
  -- Stores the voting samples.
  VoteRegister: process(clock, vote_shift, Rx)
  begin
    votes <= votes_temp;
    if(rising_edge(clock)) then
      if vote_shift = '1' then
        votes_temp <= Rx & votes_temp(2 downto 1);
      end if;
    end if;
  end process;
end architecture;
