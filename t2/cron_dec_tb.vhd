--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:19:29 10/09/2025
-- Design Name:   
-- Module Name:   /home/ise/t2/cron_dec_tb.vhd
-- Project Name:  t2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cron_dec
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.mypack.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cron_dec_tb IS
END cron_dec_tb;
 
ARCHITECTURE cron_dec_tb OF cron_dec_tb IS 
 
   signal reset : std_logic;
   signal conta : std_logic;
   signal carga : std_logic;
   signal clock : std_logic := '0';
	signal sec, min : std_logic_vector (7 downto 0);
	signal EA: states;
   
 
BEGIN
 UUT: entity work.cron_dec port map (reset => reset, conta => conta, carga => carga, clock => clock, EA => EA, seg=>sec, min=>min);
 
	clock <= not clock after 10ns;
	reset <= '1', '0' after 3ns;
	carga <= '0' , '1' after 35ns;
	conta <= '0' , '1' after 45ns; 
	min <= x"00", x"0A" after 30ns, x"00" after 1000ns;
	sec <= x"00", x"3b" after 800ns, x"00" after 1000ns;
	
END cron_dec_tb;
