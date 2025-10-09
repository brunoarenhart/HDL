library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;

entity n_bit_d_tb is

end entity n_bit_d_tb;

architecture n_bit_d_tb of n_bit_d_tb is


signal input: std_logic_vector(1 downto 0);
signal output: std_logic_vector(3 downto 0);

begin


UUT: entity work.n_bit_d(n_bit_d_Fg) port map(input => input, output => output);

input <= "00", "01" after 10 ns, "10" after 20 ns, "11" after 30 ns;


end architecture n_bit_d_tb;