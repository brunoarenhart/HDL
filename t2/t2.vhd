--package mypack is
--	type states is (REP, LOAD, COUNT);
--end mypack;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.all;

use work.mypack.all;

entity cron_dec is
generic ( CLOCK_FREQ : integer := 25_000_000 );
port (
		reset, conta, carga, clock: in std_logic;
		chaves: in std_logic_vector(6 downto 0);
		an, dec_dpp: out std_logic_vector(7 downto 0);
		min, seg : out std_logic_vector(7 downto 0)
);
end cron_dec;

architecture cron_dec of cron_dec is
	type ROM is array (0 to 99) of std_logic_vector (7 downto 0);
		constant conv_to_BCD : ROM:=(
		 "00000000", "00000001", "00000010", "00000011", "00000100",
		 "00000101", "00000110", "00000111", "00001000", "00001001",
		 "00010000", "00010001", "00010010", "00010011", "00010100",
		 "00010101", "00010110", "00010111", "00011000", "00011001",
		 "00100000", "00100001", "00100010", "00100011", "00100100",
		 "00100101", "00100110", "00100111", "00101000", "00101001",
		 "00110000", "00110001", "00110010", "00110011", "00110100",
		 "00110101", "00110110", "00110111", "00111000", "00111001",
		 "01000000", "01000001", "01000010", "01000011", "01000100",
		 "01000101", "01000110", "01000111", "01001000", "01001001",
		 "01010000", "01010001", "01010010", "01010011", "01010100",
		 "01010101", "01010110", "01010111", "01011000", "01011001",
		 "01100000", "01100001", "01100010", "01100011", "01100100",
		 "01100101", "01100110", "01100111", "01101000", "01101001",
		 "01110000", "01110001", "01110010", "01110011", "01110100",
		 "01110101", "01110110", "01110111", "01111000", "01111001",
		 "10000000", "10000001", "10000010", "10000011", "10000100",
		 "10000101", "10000110", "10000111", "10001000", "10001001",
		 "10010000", "10010001", "10010010", "10010011", "10010100",
		 "10010101", "10010110", "10010111", "10011000", "10011001");
 
 signal EA, PE : states;
 signal i: integer range 1 to 25_000_000;
 signal pronto: std_logic;
 signal seg_int : integer range 0 to 59;
 signal min_int : integer range 0 to 99;
 signal ck1seg: std_logic;
 signal Segundos_BCD: std_logic_vector(7 downto 0);
 
 begin
--P1: divisor de clock para gerar o ck1seg
div_clk: process(clock, reset)
	begin
		if reset = '1' then
			i <= 1;
			ck1seg <= '0';
		elsif rising_edge(clock) then
			if i = 25_000_000 then
				i <= 1;
				ck1seg <= not ck1seg;
			else
				i <= i + 1;
			end if;
		end if;
			
	end process div_clk;
	
--P2/P3: máquina de estados para determinar o estado atual (EA)
fme_control: process(ck1seg, reset)
	begin
	
	if reset = '1' then
		EA <= REP;
	elsif rising_edge(ck1seg) then
		EA <= PE;
	end if;
	
end process fme_control;

fme_combinational: process(conta, carga, EA)
	begin
	EA <= PE;
	
	case EA is
	
		when REP => 
			if carga = '1' then 
				PE <= lOAD;
			end if;
			
		when LOAD => 
			if conta = '1' then 
				PE <= COUNT;
			end if;
			
		when COUNT => 
			if (seg_int = 0) AND (min_int = 0) then
				PE <= REP;
			end if;
			
		end case;
		
	end process fme_combinational;
	
	
--P4: contador de segundos

segundos : process(ck1seg, reset)
	begin
		if reset = '1' then 
			seg_int <= 0;
			pronto <= '0';
		elsif rising_edge(ck1seg) then 
			if EA = LOAD then
            seg_int <= 0;
				pronto <= '0';
			elsif EA = COUNT then 
				if seg_int = 0 then
					pronto <= '1';
				else 
					pronto <= '0';
				end if;
				if seg_int = 0 then
					seg_int <= 59;
				else
					seg_int <= seg_int - 1;
				end if;
			end if;
		end if;
	end process segundos;
	pronto <= '1' when seg_int = 0 else '0';
	
--P5: contador de minutos
minutos: process(ck1seg,reset)
	begin
		if reset = '1' then
			min_int <= 0;
		elsif rising_edge(ck1seg) then
			if EA = LOAD then 
				min_int <= to_integer(unsigned(chaves));
			elsif EA = COUNT then
				if pronto = '1' then
					min_int <= min_int - 1;
				end if;
			else
				pronto <= '0';
			end if;
		end if;
	end process minutos;
	
			
-- instanciação das ROMs
seg <= conv_to_BCD(seg_int);
min <= conv_to_BCD(min_int);
---- display driver
--d1 <= '1' & seg(3 downto 0) & '1';
--d2 <= '1' & seg(2 downto 0) & '1';
--d3 <= '1' & min(4 downto 0) & '1';
--d4 <= '1' & min(4 downto 0) & '1';
--...
--display_driver : entity work.dspl_drv port map (
--...
--);
end cron_dec; 