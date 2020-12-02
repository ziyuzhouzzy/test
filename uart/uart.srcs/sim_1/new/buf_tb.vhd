----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/01 22:33:49
-- Design Name: 
-- Module Name: buf_tb - tb
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity buf_tb is
--  Port ( );
end buf_tb;

architecture tb of buf_tb is

component vector_buffer is
port (
    trng_out : in STD_LOGIC;
    sampling : in STD_LOGIC;
    done : out std_logic;
    vector_out : out std_logic_vector(7 downto 0)
);
end component vector_buffer;

signal trng : std_logic := '0';
signal samplingclk : std_logic := '0';
signal done : std_logic := '0';
signal vector_out : std_logic_vector(7 downto 0):= (others => '0');


begin

buf_inst : vector_buffer 

port map (
    trng_out => trng,
    sampling => samplingclk,
    done => done,
    vector_out => vector_out
    );

trng <= not trng after 1.67 ns;   -- clk is 300Mhz
samplingclk <= not samplingclk after 133.33 us;



end tb;
