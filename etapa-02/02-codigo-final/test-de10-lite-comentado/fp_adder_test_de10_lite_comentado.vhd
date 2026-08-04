library ieee ; --
use ieee.std_logic_1164 .all ; --
use ieee.numeric_std .all ; --

entity fp_adder_test_de10_lite is --
    port (
        ------------------ Parte Removida do código pois não é necessária na DE10-Lite--------------
        -- Clock não será utilizado pois os displays da FPGA DE10-Lite possuem saídas independentes,
        -- eliminando a necessidade de multiplexação.
        -- clk : in std_logic ;
        -- Selecionava qual display mostrar no momento (não necessário na DE10-Lite).
        -- an : out std_logic_vector (3 downto 0) ;
        -- Determinava quais segmentos acender no display selecionado por an.
        -- Na DE10-Lite, esse barramento compartilhado é substituído pelas saídas individuais HEX0 a HEX3.
        -- sseg : out std_logic_vector (7 downto 0)
        ---------------------------------------------------------------------------------------------

        -- Dez switches físicos da DE10-Lite
        SW : in std_logic_vector(9 downto 0);
        -- sw : in std_logic_vector (7 downto 0);
        
        -- Dois botões físicos da DE10-Lite
        KEY : in std_logic_vector(1 downto 0);
        -- btn : in std_logic_vector (3 downto 0) ;

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
    -- Antes era necessário preparar 4 padrões de 8 bits e enviá-los ao multiplexador.
    -- Na DE10-Lite, os padrões são ligados diretamente às saidas HEX0, HEX1, HEX2, HEX3.
    -- signal led3 , led2 , led1 , led0 : std_logic_vector (7 downto 0) ; --

begin
    -----------------------------------------------------------------------
    -- Formação do primeiro operando.
    --
    -- Mantém a mesma organização do circuito original:
    -- sinal e expoente fixos, com dois bits variáveis na fração.
    -----------------------------------------------------------------------

    -- set up the fp adder input signals --
    -- sign1 <= '0';
    -- exp1 <= "1000";
    -- frac1 <= '1' & sw(1) & sw(0) & "10101";     

    sign1 <= '0';
    exp1  <= "1000";

    frac1 <=
        '1' &
        SW(1) &
        SW(0) &
        "10101";

    -----------------------------------------------------------------------
    -- Formação do segundo operando.
    --
    -- SW(9)          : sinal
    -- SW(8 downto 5): expoente
    -- KEY(1), KEY(0): dois bits da fração
    -- SW(4 downto 0): cinco bits da fração
    -----------------------------------------------------------------------
    
    -- sign2 <= sw (7) ; --
    -- exp2 <= btn ; --
    -- frac2 <= '1' & sw (6 downto 0) ; --
        
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
    
    -- instantiate three instances of hex decoders --
    -- exponent --
    -- sseg_unit_0 : entity work . hex_to_sseg --
    --     port map ( hex => exp_out , dp => '0' , sseg => led0 ) ; --
    
    hex_unit_0 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => exp_out,
            seg => HEX0
        );

    -----------------------------------------------------------------------
    -- Exibição dos quatro bits menos significativos da fração em HEX1.
    -----------------------------------------------------------------------
    
    -- 4 LSBs of fraction --
    -- sseg_unit_1 : entity work . hex_to_sseg --
    --     port map ( hex => frac_out (3 downto 0) , dp => '1' , sseg => led1 ) ; --
    
    hex_unit_1 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => frac_out(3 downto 0),
            seg => HEX1
        );

    -----------------------------------------------------------------------
    -- Exibição dos quatro bits mais significativos da fração em HEX2.
    -----------------------------------------------------------------------
    
    -- 4 MSBs of fraction --
    -- sseg_unit_2 : entity work . hex_to_sseg --
    --     port map ( hex => frac_out (7 downto 4) , dp => '0' , sseg => led2 ) ; --
    
    hex_unit_2 : entity work.hex_to_7seg_de10_lite(arch)
        port map (
            hex => frac_out(7 downto 4),
            seg => HEX2
        );

    -----------------------------------------------------------------------
    -- Exibição do sinal em HEX3.
    --
    -- sign_out = 1: acende somente o segmento central 6, formando "-".
    -- sign_out = 0: apaga todos os segmentos.
    -----------------------------------------------------------------------
    
    -- sign --
    -- led3 <= "11111110" when sign_out = '1' else -- middle bar --
    --     "11111111"; -- blank --
    
    HEX3 <=
        "1111110" when sign_out = '1' else
        "1111111";


    -- Não utilizado pois não é necessária multiplexação
    -- instantiate 7 -seg LED display time - multiplexing module --
    -- disp_unit : entity work . disp_mux --
    --     port map ( --
    --         clk => clk , reset => '0' , --
    --         in0 => led0 , in1 => led1 , in2 => led2 , in3 => led3 , --
    --         an => an , sseg => sseg --
    --     ) ; --
end arch ; --