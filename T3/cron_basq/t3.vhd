library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.all;

use work.all;

entity cron_basq_PI is
 generic (MAXCOUNT: integer := 500000);
 -- Generic para instanciação do módulo
 -- usado pelo Contador cont_1cent apenas
 port (clock, reset : in STD_LOGIC;
 
	para_continua, modo_novoquarto, carga : in STD_LOGIC;
	qua : in STD_LOGIC_VECTOR (1 downto 0);
	min : in STD_LOGIC_VECTOR (3 downto 0);
	seg : in STD_LOGIC_VECTOR (5 downto 0);
	
	quarto : out STD_LOGIC_VECTOR (1 downto 0); -- 4 leds
	minutos : out STD_LOGIC_VECTOR (3 downto 0); -- 4 leds
	segundos : out STD_LOGIC_VECTOR (5 downto 0); -- 2 displays
	centesimos : out STD_LOGIC_VECTOR (6 downto 0) -- 2 displays
	
	);
end cron_basq_PI;

 
architecture cron_basq_PI of cron_basq_PI is
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
		 
type states is (MODE_SET, IDLE, COUNTING, STOPPED);
signal EA, PE : states;
signal i: integer range 1 to 500_000;
signal pronto_cent, pronto_seg, pronto_min, pronto_quarto: std_logic;
signal cent_int : integer range 0 to 99;
signal seg_int : integer range 0 to 59;
signal min_int : integer range 0 to 12;
signal quarto_int: integer range 0 to 3;
signal d0, d1, d2, d3: std_logic_vector(5 downto 0);
signal modo, fim_jogo : std_logic;

begin

controll: process(clock, reset)
	begin
		if reset = '1' then 
			EA <= MODE_SET;
		elsif falling_edge(clock) then
			EA <= PE;
		end if;
	end process controll;
	
combinational: process(EA, para_continua, modo_novoquarto, carga, pronto_quarto)
	begin
		modo <= modo;
		case EA is
			when MODE_SET =>
				if reset = '1' and modo_novoquarto ='1' then
					PE <= IDLE;
					modo <= '1';
				elsif reset = '1' and modo_novoquarto ='0' then
					PE <= IDLE;
					modo <= '0';
				end if;
			when IDLE =>
				if para_continua = '1' then
					PE <= COUNTING;
				else
					PE <= IDLE;
				end if;
			when COUNTING =>
				if para_continua = '1' or pronto_quarto = '1' then
					PE <= STOPPED;
				else 
					PE <= COUNTING;
				end if;
			when STOPPED =>
				if para_continua = '1'  then
					PE <= COUNTING;
				else 
					PE <= STOPPED;
				end if;
		end case;
	end process combinational;
			
contador: process(clock, reset)
	begin 
		if reset = '1' then 
			i <= 1;
			pronto_cent <= '0';
		elsif falling_edge(clock) then
			if EA = COUNTING then
				if i = MAXCOUNT then
					i <= 1;
					pronto_cent <= '1';
				else 
					i <= i + 1;
					pronto_cent <= '0';
				end if;
			end if;
		end if;
	end process contador;
	
cont_cent: process(clock, reset)
	begin
		if reset = '1' then
			cent_int <= 0;
			pronto_seg <= '0';
		elsif falling_edge(clock) and pronto_cent = '1' then
			if cent_int = 0 then
				cent_int <= 99;
				pronto_seg <= '1';
			else
				cent_int <= cent_int - 1;
				pronto_seg <= '0';					
		end if;
	end if;			
end process cont_cent;

cont_seg: process(clock, reset, carga)
	begin
		if reset = '1' then
			seg_int <= 0;
			pronto_min <= '0';
		elsif falling_edge(clock) then 
			pronto_min <= '0';
			if carga = '1' then
				seg_int <= to_integer(unsigned(seg));
			elsif pronto_cent = '1' and pronto_seg = '1' then
				if seg_int = 0 then 
					seg_int <= 59;
					pronto_min <= '1';
				else 
					seg_int <= seg_int - 1;
				end if;
			end if;
		end if;
	end process cont_seg;
				
cont_min: process(clock, reset)
	begin		
		if reset = '1' then
			min_int <= 0;
			pronto_quarto <= '0';
		elsif falling_edge(clock) then
			pronto_quarto <= '0';
			if carga = '1' then
            min_int <= to_integer(unsigned(min));
			elsif EA = MODE_SET then
				if modo = '1' then 
					min_int <= 12;
				else
					min_int <= 10;
				end if;
			elsif EA = COUNTING and pronto_cent = '1' and pronto_seg = '1' and pronto_min = '1' then
				if min_int = 0 and seg_int = 0 and cent_int = 0 then 
					pronto_quarto <= '1';
				elsif min_int > 0 then 
					min_int <= min_int - 1;
				end if;
			end if;
		end if;
	end process cont_min;

cont_quartos: process(clock,reset)
	begin
		if reset = '1' then
			quarto_int <=  0;
		elsif falling_edge(clock) then
			if carga = '1' then
				quarto_int <= to_integer(unsigned(qua));
			elsif pronto_quarto = '1' then
				if quarto_int = 3 then
					fim_jogo <= '1';
				elsif quarto_int < 3 then
				quarto_int <= quarto_int + 1;
				end if;
			end if;
		end if;
	end process cont_quartos;
	
minutos <= std_logic_vector(to_unsigned(min_int, minutos'length)); 
segundos <= std_logic_vector(to_unsigned(seg_int, segundos'length));
centesimos <= std_logic_vector(to_unsigned(cent_int, centesimos'length));
quarto <= std_logic_vector(to_unsigned(quarto_int, quarto'length));
		
end cron_basq_PI;