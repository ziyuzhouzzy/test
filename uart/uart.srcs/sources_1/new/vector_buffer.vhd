----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2020/12/01 22:15:47
-- Design Name: 
-- Module Name: vector_buffer - rtl
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

entity vector_buffer is
--  Port ( );
port (
    trng_out : in STD_LOGIC;
    sampling : in STD_LOGIC;
    done : out std_logic;
    vector_out : out std_logic_vector(7 downto 0)
    );

end vector_buffer;

architecture rtl of vector_buffer is

signal count : integer range 0 to 7 := 0;
signal tmp : std_logic_vector(7 downto 0):= (others => '0');


begin

 process (sampling)
 begin
 if rising_edge(sampling) then
 
          if count < 7 then
            count <= count + 1;
            done <= '0';
            tmp(count)   <= trng_out;
          else
            count <= 0;
            vector_out <= tmp;
            done <= '1';
          end if;
end if;
end process;

end rtl;