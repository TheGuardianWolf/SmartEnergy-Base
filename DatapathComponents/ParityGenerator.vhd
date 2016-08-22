library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity parity_generator is
  port
    (
      bits     : in std_logic_vector(9 downto 0) := (others => '0');

      data_xor : out std_logic := '0'
    );
end entity;

architecture rtl of parity_generator is
begin
  ParityGenerator: process(bits)
  begin
    data_xor <= xor_reduce(bits(7 downto 0));
  end process;
end architecture;
