library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity dspl_drv is
	port (
		clock: in STD_LOGIC;
		reset: in STD_LOGIC;
		d3: in STD_LOGIC_VECTOR (5 downto 0);
		d2: in STD_LOGIC_VECTOR (5 downto 0);
		d1: in STD_LOGIC_VECTOR (5 downto 0);
		d0: in STD_LOGIC_VECTOR (5 downto 0);
		an: out STD_LOGIC_VECTOR (3 downto 0);
		dec_ddp: out STD_LOGIC_VECTOR (7 downto 0)
	);
end dspl_drv;

--}} End of automatically maintained section

architecture dspl_drv of dspl_drv is
signal ck_1KHz: std_logic;
signal dig_selection: std_logic_vector (1 downto 0);
signal selected_dig: std_logic_vector (4 downto 0);

begin
	-- 1KHz clock generation
Ck1KHz_gen:
	process (reset, clock)
	variable count_25K: integer range 0 to 25000;
	begin
		if reset='1' then
			count_25K := 0;
			ck_1KHz <= '0';
		elsif (clock'event and clock='1') then
			count_25K := count_25K + 1;
			if (count_25K = 24999) then
				count_25K := 0;
				ck_1KHz <= not ck_1KHz;
			end if;
		end if;
	end process;
	
	-- Driver state machine: Produces the counter dig_selection used to
	--	choose the digit to show at any moment (just one at a time)
Digit_choice:
	process (reset, ck_1KHz)
	begin
		if reset='1' then
			dig_selection <= (others => '0'); 
			an <= (others => '1'); 					-- Disable all displays
		elsif (ck_1KHz'event and ck_1KHz='1') then
			-- a 2-bit Johnson counter		
			dig_selection <= dig_selection(0)  & not dig_selection (1);
			
			if dig_selection="00" then
			    selected_dig <= d0(4 downto 0);
			    an <= "111"  & (not d0(5));
			elsif dig_selection="01" then
			    selected_dig <= d1(4 downto 0);
			    an <= "11" & (not d1(5)) & "1";
			elsif dig_selection="10" then
			    selected_dig <= d2(4 downto 0);
			    an <= "1"  & (not d2(5)) & "11";
			else
			    selected_dig <= d3(4 downto 0);
			    an <= (not d3(5)) & "111";
			end if;
		end if; 
	end process;
	
	-- The 4bit-to-Hexadecimal decoder
Muxed_4toHex_decod:
	with selected_dig (4 downto 1) select
	dec_ddp(7 downto 1) <=
		"0000001" when "0000", -- draws a 0 digit
		"1001111" when "0001", -- draws a 1 digit
		"0010010" when "0010", -- draws a 2 digit
		"0000110" when "0011", -- draws a 3 digit
		"1001100" when "0100", -- draws a 4 digit
		"0100100" when "0101", -- draws a 5 digit
		"0100000" when "0110", -- draws a 6 digit
		"0001111" when "0111", -- draws a 7 digit
		"0000000" when "1000", -- draws a 8 digit
		"0000100" when "1001", -- draws a 9 digit
		"0001000" when "1010", -- draws a A digit
		"1100000" when "1011", -- draws a B digit
		"0110001" when "1100", -- draws a C digit
		"1000010" when "1101", -- draws a D digit
		"0110000" when "1110", -- draws a E digit
		"0111000" when others; -- draws a F digit

	-- and the decimal point
	dec_ddp(0) <= selected_dig(0);

end dspl_drv;