----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_top_led is

port (
       i_Clk       : in  std_logic;
       i_RX_Serial : in  std_logic;   
       
       led : out std_logic_vector(2 downto 0);    -- how many bytes received
              
       o_TX_Serial : out std_logic
       
      -- o_TX_Active : out std_logic;
      -- o_TX_Done   : out std_logic        

);
end uart_top_led;


architecture rtl of uart_top_led is

CONSTANT  CLKS_PER_BIT   : NATURAL := 434;     -- number of clk period in one bit
CONSTANT div_param : integer:=2;



component UART_RX IS
  generic (
    g_CLKS_PER_BIT : integer := 434  
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;


component UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 434
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;
 
-- define signal 
signal out_rx_datavalid : std_logic;
signal out_rx_byte : std_logic_vector(7 downto 0);
signal  o_TX_Active : std_logic;
signal  o_TX_Done   : std_logic ; 

signal  q : STD_LOGIC_VECTOR(2 DOWNTO 0):=(OTHERS=>'0');
signal div : std_logic;
signal cnt :integer range 0 to div_param :=0;

begin

uart_rx_inst : UART_RX
  GENERIC MAP (
   g_CLKS_PER_BIT => CLKS_PER_BIT 
  )
  PORT MAP(     
    i_Clk       => i_Clk,
    i_RX_Serial => i_RX_Serial,
    
    o_RX_DV    => out_rx_datavalid,
    o_RX_Byte  => out_rx_byte
  );


	process(out_rx_datavalid)
	begin
		if rising_edge(out_rx_datavalid) then
			cnt<=cnt+1;
			if cnt=div_param-1 then
				div <=not div;
				cnt<=0;
			end if;
		end if;
	end process;


PROCESS(div)
	BEGIN
		IF(div'EVENT AND div='1')THEN
			IF(q = "111")THEN
				q <= "000";
			ELSE
				q <= q+1;
			END IF;
		END IF;
end process;

--PROCESS(out_rx_datavalid)
--	BEGIN
--		IF(out_rx_datavalid'EVENT AND out_rx_datavalid='1')THEN
--			IF(q = "111")THEN
--				q <= "000";
--			ELSE
--				q <= q+1;
--			END IF;
--		END IF;
--end process;

process(q) BEGIN
	CASE q IS 
		WHEN "000" => LED <= "000";  
		WHEN "001" => LED <= "001";  
		WHEN "010" => LED <= "010";   
		WHEN "011" => LED <= "011";
		WHEN "100" => LED <= "100";
		WHEN "101" => LED <= "101";
		WHEN "110" => LED <= "110";
		WHEN "111" => LED <= "111";
		when others=>  LED <= "000";
		
		END CASE ;
	end process;


uart_tx_inst : UART_TX
  generic map (
    g_CLKS_PER_BIT => CLKS_PER_BIT 
    )
  port map(
    i_Clk       => i_Clk,
    i_TX_DV     => out_rx_datavalid,
    i_TX_Byte   => out_rx_byte,
    
    o_TX_Active => o_TX_Active,
    o_TX_Serial => o_TX_Serial,
    o_TX_Done   => o_TX_Done
    );


end rtl;

