library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sync_register is
  port
    (
      clock         : in std_logic := '0';

      sync   : in std_logic := '0';
      desync_signal : in std_logic := '0';

      desync        : out std_logic := '0'
    );
end entity;

architecture rtl of sync_register is
  signal desync_temp : std_logic := '0';
  -- Stores the desync flag. Required to prevent an inferred latch from a
  -- constant assertion from FSM otherwise.
  begin
  SyncRegister: process(clock, desync_signal, sync, desync_temp)
  begin
    desync <= desync_temp;
    if(rising_edge(clock)) then
      if desync_signal = '1' then
        desync_temp <= '1';
      end if;
      if (sync = '1') then
        desync_temp <= '0';
      end if;
    end if;
  end process;
end architecture;
