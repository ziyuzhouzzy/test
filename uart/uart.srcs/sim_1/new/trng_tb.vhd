----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/02 21:29:32
-- Design Name: 
-- Module Name: trng_tb - tb
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

entity trng_tb is
--  Port ( );
end trng_tb;

architecture tb of trng_tb is

component elementary_rng is
port (
    phy1_out : OUT STD_LOGIC;
    phy2_out : OUT STD_LOGIC;
    n_reset          : IN  STD_LOGIC;                -- Reset signal
    n_sel            : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) -- Output MUX select
  );
end component elementary_rng;

signal reset : std_logic := '1';
signal sel : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
signal phy1_out : std_logic;
signal phy2_out : std_logic;

begin

rng_inst : elementary_rng
port map(
    phy1_out => phy1_out,
    phy2_out => phy2_out,
    n_reset  => reset,
    n_sel => sel
    );

end tb;
