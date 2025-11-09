-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cron_basq_PI_tb IS
END cron_basq_PI_tb;

ARCHITECTURE cron_basq_PI_tb OF cron_basq_PI_tb IS 
	 signal clock   : STD_LOGIC := '0';
    signal reset   : STD_LOGIC;
    signal para_continua : STD_LOGIC;
    signal modo_novoquarto : STD_LOGIC;
    signal carga   : STD_LOGIC;
    signal qua  : STD_LOGIC_VECTOR (1 downto 0);
    signal min  : STD_LOGIC_VECTOR (3 downto 0);
    signal seg  : STD_LOGIC_VECTOR (5 downto 0);
	 signal quarto : STD_LOGIC_VECTOR (1 downto 0);
    signal minutos : STD_LOGIC_VECTOR (3 downto 0);
    signal segundos : STD_LOGIC_VECTOR (5 downto 0);
    signal centesimos : STD_LOGIC_VECTOR (6 downto 0);

begin
	UUT : entity work.cron_basq_PI generic map( MAXCOUNT => 50) port map (clock=>clock, reset=>reset, para_continua=>para_continua, modo_novoquarto=>modo_novoquarto,
	seg=>seg, min=>min, qua=>qua, carga=>carga, quarto=>quarto, minutos=>minutos, segundos=>segundos, centesimos=>centesimos);
	process
		begin
			clock <= '1' after 5ns, '0' after 10ns;
			wait for 10ns;
		end process;
		
	reset <= '1', '0' after 22ns;
	modo_novoquarto <= '1', '0' after 30ns, '1' after 130ns, '0' after 141ns, '1' after 250ns, '0' after 261ns, '1' after 390ns;
	para_continua <= '1', '0' after 61ns, '1' after 99ns,'0' after 109ns, '1' after 142ns, '0' after 165ns,'1' after 239ns, '0' after 249ns, '1' after 282ns, '0' after 305ns, '1' after 379ns, '0' after 389ns, '1' after 422ns, '0' after 445ns, '1' after 519ns, '0' after 529ns;
	min <= "1100", "0000" after 99ns, "1100" after 142ns, "0000" after 239ns, "1100" after 282ns, "0000" after 379ns, "1100" after 422ns, "0000" after 519ns;
	qua <= "00", "01" after 130ns, "10" after 250ns, "11" after 390ns;
	
END cron_basq_PI_tb;
