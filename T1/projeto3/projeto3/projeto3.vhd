library IEEE;
use IEEE.std_logic_1164.all;
entity transmissor is
port (clock, send, reset: in std_logic;
		palavra: in std_logic_vector(7 downto 0);
		busy, linha: out std_logic);
end entity transmissor;
	
architecture transmissor of transmissor is
	type STATES is(S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10);
	signal atual, prox: STATES;
begin
	control: process(clock, reset)
	begin
		if reset = '1' then 
			atual <= S0;
		elsif rising_edge(clock) then 
			atual <= prox;
		end if;
	end process control;
	
	combinational: process(atual,send, palavra)
	begin
		prox <= atual;
		linha <= '1';
		case atual is
			when S0 => if send = '1' then prox <= S1;
				end if;
			when S1 => linha <= '0'; 
				prox <= S2;
			when S2 => linha <= palavra(7); 
				prox <= S3;
			when S3 => linha <= palavra(6); 
				prox <= S4;
			when S4 => linha <= palavra(5);
				prox <= S5;
			when S5 => linha <= palavra(4);
				prox <= S6;
			when S6 => linha <= palavra(3);
				prox <= S7;
			when S7 => linha <= palavra(2);
				prox <= S8;
			when S8 => linha <= palavra(1);
				prox <= S9;
			when S9 => linha <= palavra(0);
				prox <= S10;
			when S10 => linha <= '0'; 
				prox <= S0;
		end case;
	end process combinational;
	
	busy <= '1' when atual /= S0 else '0';
end architecture transmissor;
		
	
