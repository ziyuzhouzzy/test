library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE ieee.numeric_std.ALL;

--LIBRARY work;
--USE work.lab_hc_pkg.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity elementary_rng is 
--  Port ( );
  PORT (
    phy1_out : OUT STD_LOGIC;
    phy2_out : OUT STD_LOGIC;
    n_reset          : IN  STD_LOGIC;                -- Reset signal
    n_sel            : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) -- Output MUX select
  );
end elementary_rng;


architecture Behavioral of elementary_rng is
  
    CONSTANT K_VAL    : NATURAL := 20000;
    CONSTANT RO1_SIZE : NATURAL := 5;
    CONSTANT RO2_SIZE : NATURAL := 5;
  
    ATTRIBUTE keep : BOOLEAN;

  COMPONENT RO_core IS
    GENERIC (
      length  : INTEGER := 4
    );
    PORT( 
      ena     : IN  STD_LOGIC := '1';       -- Enables oscillator output
      osc_out : OUT STD_LOGIC  -- Oscillator output
    );
  END COMPONENT;
  
  COMPONENT obuf_wrp IS
    PORT (
      i   : IN  STD_LOGIC;
      --o_p : OUT STD_LOGIC;
      o : OUT STD_LOGIC
    );
  END COMPONENT obuf_wrp;

  SIGNAL ro1_out_s    : STD_LOGIC;
  SIGNAL ro2_out_s    : STD_LOGIC;
  SIGNAL sampling_clk : STD_LOGIC := '0';
  SIGNAL cnt          : STD_LOGIC_VECTOR ( 23 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL rng_out      : STD_LOGIC := '0';
--  SIGNAL phy1_out     : STD_LOGIC := '0';
--  SIGNAL phy2_out     : STD_LOGIC := '0';
  

begin

-- Sampled RO
ro1_inst : RO_core
  GENERIC MAP (
    length  => RO1_SIZE
  )
  PORT MAP( 
    ena     => n_reset,     -- Enables oscillator output
    osc_out => ro1_out_s    -- Oscillator output
  );

-- Sampling RO
ro2_inst : RO_core
  GENERIC MAP (
    length  => RO2_SIZE
  )
  PORT MAP( 
    ena     => n_reset,     -- Enables oscillator output
    osc_out => ro2_out_s    -- Oscillator output
  );

-- Sampling period generation
  PROCESS( ro2_out_s )
  BEGIN
    IF rising_edge(ro2_out_s) THEN
      IF ( unsigned(cnt) = K_VAL ) THEN
        cnt          <= (OTHERS => '0');
        sampling_clk <= '1';
      ELSE
        cnt          <= STD_LOGIC_VECTOR( UNSIGNED( cnt ) + 1 );
        sampling_clk <= '0';
      END IF;
    END IF;
  END PROCESS;

-- Sampling flip-flop
  PROCESS ( sampling_clk )
  BEGIN
    IF rising_edge(sampling_clk) THEN
      rng_out <= ro1_out_s;
    END IF;
  END PROCESS;

-- Output 1 MUX
WITH n_sel SELECT
    phy1_out <= sampling_clk  WHEN "11",
               ro2_out_s WHEN "10",
                '0'          WHEN OTHERS;

-- Output 2 MUX
WITH n_sel SELECT
    phy2_out <=  rng_out WHEN "11",
                 ro1_out_s  WHEN "10",
                 '0'      WHEN OTHERS;
  
-- Output 1 buffer
--      phy1_inst : obuf_wrp
--        PORT MAP (
--          i   => phy1_out,
--          o => phy1_p
--         -- o_n => phy1_n
--        );
        
--    -- Output 2 buffer
--      phy2_inst : obuf_wrp
--        PORT MAP (
--          i   => phy2_out,
--          o => phy2_p
--         -- o_n => phy2_n
--        );

end Behavioral;

