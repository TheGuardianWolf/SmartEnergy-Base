library ieee;
use ieee.std_logic_1164.all;

entity majority_vote is
  port
    (
      votes         : in std_logic_vector(2 downto 0) := (others => '1');
      
      vote_result : out std_logic := '1'
    );
end entity;

architecture rtl of majority_vote is
begin
  MajorityVote: process(votes)
  begin
    vote_result <= (votes(0) and votes(1)) or (votes(0) and votes(2)) or (votes(2) and votes(1));
  end process;
end architecture;
