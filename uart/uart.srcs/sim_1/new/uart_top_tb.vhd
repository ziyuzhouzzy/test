----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/02 19:10:40
-- Design Name: 
-- Module Name: uart_top_tb - tb
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_top_tb is
end uart_top_tb;

architecture tb of uart_top_tb is

component uart_top is
port (
       i_Clk       : in  std_logic;
       i_RX_Serial : in  std_logic;   
              
       o_TX_Serial : out std_logic;
       
       o_TX_Active : out std_logic;
       o_TX_Done   : out std_logic        

);
end component uart_top;


signal r_clk : std_logic := '0';
signal r_rx_serial : std_logic := '0';

signal w_TX_SERIAL : std_logic;
signal w_TX_ACT   : std_logic;
signal w_TX_Done : std_logic;

constant c_BIT_PERIOD : time := 8680 ns;  -- 1 bit is 1/115200 s 
signal i : integer range 0 to 1000 := 0; 



  -- PC generate serial input data 
  procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;



begin

uart_top_inst : uart_top
port map (
       i_Clk       => r_clk,
       i_RX_Serial => r_rx_serial,
       
       o_TX_Serial => w_TX_SERIAL,
       o_TX_Active => w_TX_ACT,
       o_TX_Done   => w_TX_Done
    );



 r_clk <= not r_clk after 10 ns;   -- clk is 50Mhz, T=20 ns



  process is 
  begin
    wait until rising_edge(r_clk);
    UART_WRITE_BYTE(X"07", r_RX_SERIAL);
    wait until rising_edge(r_clk);
end process;

end tb;
