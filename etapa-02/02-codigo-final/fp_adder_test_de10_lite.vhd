library ieee ; --
use ieee.std_logic_1164 .all ; --
use ieee.numeric_std .all ; --

entity fp_adder_test_de10_lite is --
    port (
        -- Dez switches físicos da DE10-Lite
        SW : in std_logic_vector(9 downto 0);
        
        -- Dois botões físicos da DE10-Lite
        KEY : in std_logic_vector(1 downto 0);

        -- Quatro displays usados para mostrar o resultado
        HEX3 : out std_logic_vector(0 to 6); -- sinal (1 bit)
        HEX2 : out std_logic_vector(0 to 6); -- 4 bits mais significativos
        HEX1 : out std_logic_vector(0 to 6); -- 4 bits menos significativos
        HEX0 : out std_logic_vector(0 to 6)  -- expoente de 4 bits
    ) ; --
end fp_adder_test_de10_lite ; --

architecture arch of fp_adder_test_de10_lite is --
    signal sign1 , sign2 : std_logic ; --
    signal exp1 , exp2 : std_logic_vector (3 downto 0) ; --
    signal frac1 , frac2 : std_logic_vector (7 downto 0) ; --
    signal sign_out : std_logic ; --
    signal exp_out : std_logic_vector (3 downto 0) ; --
    signal frac_out : std_logic_vector (7 downto 0) ; --

begin
    sign1 <= '0';
    exp1  <= "1000";

    frac1 <=
        '1' &
        SW(1) &
        SW(0) &
        "10101";
        
    sign2 <= SW(9);
    exp2 <= SW(8 downto 5);

    frac2 <=
        '1' &
        (not KEY(1)) &
        (not KEY(0)) &
        SW(4 downto 0);

    -- instantiate fp adder --
    fp_add_unit : entity work.fp_adder(arch) --
        port map ( --
            sign1 => sign1 ,
            sign2 => sign2 ,
            exp1 => exp1 ,
            exp2 => exp2 ,
            frac1 => frac1 ,
            frac2 => frac2 ,
            sign_out => sign_out ,
            exp_out => exp_out ,
            frac_out => frac_out
        ) ; --


    -----------------------------------------------------------------------
    -- Exibição do expoente no display HEX0.
    -----------------------------------------------------------------------

    hex_unit_0 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => exp_out,
            seg => HEX0
        );

    -----------------------------------------------------------------------
    -- Exibição dos quatro bits menos significativos da fração em HEX1.
    -----------------------------------------------------------------------
    
    hex_unit_1 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => frac_out(3 downto 0),
            seg => HEX1
        );

    -----------------------------------------------------------------------
    -- Exibição dos quatro bits mais significativos da fração em HEX2.
    -----------------------------------------------------------------------

    hex_unit_2 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => frac_out(7 downto 4),
            seg => HEX2
        );

    -----------------------------------------------------------------------
    -- Exibição do sinal em HEX3.
    --
    -- sign_out = 1: acende somente o segmento central g, formando "-".
    -- sign_out = 0: apaga todos os segmentos.
    -----------------------------------------------------------------------
    
    HEX3 <=
        "1111110" when sign_out = '1' else
        "1111111";
end arch ; --