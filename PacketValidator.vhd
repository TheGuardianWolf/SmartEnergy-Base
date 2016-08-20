library ieee;
use ieee.std_logic_1164.all;

entity packet_validator is
  port
    (
      data_xor         : in std_logic := '0';
      sample_count     : in std_logic_vector(3 downto 0) := (others => '0');
      bits             : in std_logic_vector(9 downto 0) := (others => '0');

      validation_error : out std_logic := '0'
    );
end entity;

architecture behavior of packet_validator is
  -- Validates packets by comparing the odd parity generated from combinational
  -- circuit with the parity sent over UART, and compares the stop bit logic to
  -- a logic high signal. If either checks fail, the packet is invalid.
  PacketValidator: process(bits, data_xor, sample_count)
  begin
    -- Default behavior
    validation_error <= '0';
    -- Conditional behavior
    if (bits(9) = '0' or bits(8) = data_xor) then
      validation_error <= '1';
    end if;
  end process;
end architecture;
