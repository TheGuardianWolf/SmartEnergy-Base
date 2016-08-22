library ieee;
use ieee.std_logic_1164.all;

entity auto_sync_delay is
  port
    (
      bits_count   : in std_logic_vector(3 downto 0) := (others => '0');

      resync_delay : out std_logic := '0'
    );
end entity;

architecture behavior of auto_sync_delay is
begin
  -- Trigger to stop the FSM delay when data validation fails.
  AutoSyncDelay: process(bits_count)
  begin
    -- Default behavior
    resync_delay <= '0';
    -- Conditional behavior
    if (bits_count = "0001") then
      resync_delay <= '1';
    end if;
  end process;
end architecture;
