library ieee;
use ieee.std_logic_1164.all;

entity sync_detect is
  port
    (
      bits           : in std_logic_vector(9 downto 0) := (others => '0');
      packet_invalid : in std_logic := '0';

      sync           : out std_logic := '0'
    );
end entity;

architecture rtl of sync_detect is
begin
  -- Detects if a sync packet was sent. If packet is invalid, this is
  -- disregarded.
  SyncDetect: process(bits, packet_invalid)
  begin
    -- Default behavior
    sync <= '0';
    -- Conditional behavior
    if (bits(7 downto 0) = "00000000" and packet_invalid = '0') then
      sync <= '1';
    end if;
  end process;
end architecture;
