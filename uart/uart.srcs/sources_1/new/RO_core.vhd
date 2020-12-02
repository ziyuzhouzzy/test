


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RO_core is
 GENERIC (
    length : INTEGER := 4
  );
  PORT( 
    ena           : IN  STD_LOGIC := '1';       -- Enables oscillator output
    osc_out       : OUT STD_LOGIC  -- Oscillator output
    );
end RO_core;

architecture Behavioral of RO_core is

COMPONENT buff_wrp
  PORT (
    i : IN  STD_LOGIC;
    o : OUT STD_LOGIC
  );
END COMPONENT;

ATTRIBUTE keep : BOOLEAN;

SIGNAL del     : STD_LOGIC_VECTOR(length-1 DOWNTO 0):= ('1', OTHERS => '0');

ATTRIBUTE keep OF del : SIGNAL IS TRUE;
attribute ALLOW_COMBINATORIAL_LOOPS : string;
attribute ALLOW_COMBINATORIAL_LOOPS of del : signal is "TRUE";
------------------------------------------------------------------------------- 
begin

ASSERT (length >= 2)
  REPORT "RO must contain at least 2 elements. Current length="&integer'image(length)
  SEVERITY ERROR;
------------------------------------------------------------------------------- 

-- NAND gate
  del(0) <= NOT ( del(length-1) AND ena );
--nand_i : AND2
--  PORT MAP  
--  (
--    del(length-1), 
--    ena,
--    and_out
--  );
--
--  del(0) <= NOT and_out;

-- BUFFERS
gen_buff : FOR ii IN 0 TO length-2 GENERATE
  buff_i : buff_wrp
    PORT MAP 
    (
      i => del(ii),
      o => del(ii+1)
    );
END GENERATE gen_buff;


osc_out <= del(0);


end Behavioral;
