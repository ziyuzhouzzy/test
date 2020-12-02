----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/11/28 13:44:35
-- Design Name: 
-- Module Name: uart_top - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_top is

port (
       i_Clk       : in  std_logic;
       i_RX_Serial : in  std_logic;   
              
       o_TX_Serial : out std_logic;
       
       o_TX_Active : out std_logic;
       o_TX_Done   : out std_logic        

);
end uart_top;


architecture rtl of uart_top is

 CONSTANT  CLKS_PER_BIT   : NATURAL := 434;     -- number of clk period in one bit

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


component elementary_rng is 
  PORT (
    phy1_out : OUT STD_LOGIC;
    phy2_out: OUT STD_LOGIC;
    n_reset : IN  STD_LOGIC;                      -- Reset signal
    n_sel   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0)   -- Output MUX select
  );
end component;

component vector_buffer is
port (
    trng_out : in STD_LOGIC;
    sampling : in STD_LOGIC;
    done : out std_logic;
    vector_out : out std_logic_vector(7 downto 0)
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

signal n_enable : std_logic;
signal n_select : std_logic_vector(1 downto 0);

signal ro2_out_sample : std_logic;
signal ro1_out_trng : std_logic;

signal buf_done : std_logic;
signal buf_vector : std_logic_vector(7 downto 0);

--signal in_tx_byte : std_logic_vector(7 downto 0);

signal in_tx_dv : std_logic;
--signal out_tx_done : std_logic;
--signal zero_vector : std_logic_vector(6 downto 0) := (others => '0');

begin

uart_rx_inst : UART_RX
  GENERIC MAP (
   g_CLKS_PER_BIT => CLKS_PER_BIT 
  )
  PORT MAP(     
    i_Clk       =>  i_Clk,
    i_RX_Serial => i_RX_Serial,
    
    o_RX_DV    => out_rx_datavalid,
    o_RX_Byte  => out_rx_byte
  );


PROCESS( out_rx_datavalid )
  BEGIN
    IF rising_edge(out_rx_datavalid) THEN
      n_enable <= out_rx_byte(0);
      n_select <= out_rx_byte(2 downto 1);
    END IF;
 END PROCESS;


trng_inst :  elementary_rng
  PORT MAP(
    phy1_out   => ro2_out_sample,                       -- send to transmitter
    phy2_out   => ro1_out_trng,                       -- send to transmitter
    n_reset =>  n_enable,                      -- Reset signal, from uart_reciver
    n_sel   => n_select                        -- Output MUX select, from uart_reciver
  );

buf_inst : vector_buffer
port map (
    trng_out => ro1_out_trng,
    sampling => ro2_out_sample,
    done => buf_done,
    vector_out => buf_vector
    );

    
  process(buf_done)
   begin
    if rising_edge(buf_done) then   -- and  out_tx_done = '1' then
        in_tx_dv <= '1';
    end if;
    end process;


uart_tx_inst : UART_TX
  generic map (
    g_CLKS_PER_BIT => CLKS_PER_BIT 
    )
  port map(
    i_Clk       => i_Clk,
    i_TX_DV     => in_tx_dv,
    i_TX_Byte   => buf_vector,
    
    o_TX_Active => o_TX_Active,
    o_TX_Serial => o_TX_Serial,
    o_TX_Done   => o_TX_Done
    );


end rtl;
