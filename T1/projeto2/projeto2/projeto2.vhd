library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity n_bit_d is
generic (N: integer := 2);

port (input: in std_logic_vector (N-1 downto 0);
output: out std_logic_vector ((2**N)-1 downto 0));

end entity n_bit_d;

architecture n_bit_d of n_bit_d is
begin
process (input)
variable int_input : integer;

begin

output <= (others => '0');
int_input := to_integer(unsigned(input));
output(int_input) <= '1';

end process;
end architecture n_bit_d; 

architecture n_bit_d_Fg of n_bit_d is
begin
	g1: for i in 0 to (2**N)-1 generate
		output(i) <= '1' when to_integer(unsigned(input)) = i else '0';
	end generate g1;
end architecture n_bit_d_Fg;







