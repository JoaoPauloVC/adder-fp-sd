library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------
-- Entidade principal do circuito de teste.
--
-- Este circuito recebe valores físicos da placa:
--   - clk: clock da placa;
--   - sw: oito switches;
--   - btn: quatro botões;
--
-- E envia o resultado para quatro displays de sete segmentos:
--   - an: seleciona qual display está ativo;
--   - sseg: controla os segmentos do display ativo.
---------------------------------------------------------------------------

entity fp_adder_test is
    port (
        clk : in std_logic ;
        sw : in std_logic_vector (7 downto 0) ;
        btn : in std_logic_vector (3 downto 0) ;
        an : out std_logic_vector (3 downto 0) ;
        sseg : out std_logic_vector (7 downto 0)
    ) ;
end fp_adder_test ;

architecture arch of fp_adder_test is
    -----------------------------------------------------------------------
    -- Sinais que formarão os dois números de ponto flutuante.
    --
    -- Cada número possui:
    --   1 bit de sinal;
    --   4 bits de expoente;
    --   8 bits de fração.
    -----------------------------------------------------------------------
    signal sign1, sign2: std_logic;
    signal exp1, exp2: std_logic_vector(3 downto 0) ;
    signal frac1, frac2: std_logic_vector(7 downto 0) ;

    -----------------------------------------------------------------------
    -- Sinais que recebem o resultado produzido pelo somador.
    -----------------------------------------------------------------------    
    signal sign_out: std_logic ;
    signal exp_out: std_logic_vector(3 downto 0);
    signal frac_out: std_logic_vector(7 downto 0);

    -----------------------------------------------------------------------
    -- Cada sinal led representa o padrão dos segmentos de um dígito.
    --
    -- led0: expoente;
    -- led1: quatro bits menos significativos da fração;
    -- led2: quatro bits mais significativos da fração;
    -- led3: sinal do resultado.
    -----------------------------------------------------------------------    
    signal led3, led2, led1, led0: std_logic_vector(7 downto 0);

begin
    -- set up the fp adder input signals
    -----------------------------------------------------------------------
    -- Formação do primeiro operando.
    
    -- O primeiro número é parcialmente fixo:
    -- sinal:
    --   sempre positivo, pois sign1 = 0.

    -- expoente:
    --   sempre 1000, que corresponde a 8.

    -- fração:
    --   1 & sw(1) & sw(0) & 10101

    -- Portanto, apenas dois bits da fração são controlados pelos switches.
    -- O primeiro bit é forçado para 1 para manter a fração normalizada.
    -----------------------------------------------------------------------
    
    sign1 <= '0';
    exp1 <= "1000";
    frac1 <=
        '1'         &   -- bit mais significativo sempre igual a 1
        sw(1)       &   -- bit controlado pelo switch 1
        sw(0)       &   -- bits controlado pelo switch 0
        "10101";        -- cinco bits fixos

    -----------------------------------------------------------------------
    -- Formação do segundo operando.

    -- sinal:
    --   controlado pelo switch 7.
    --   sw(7) = 0: positivo;
    --   sw(7) = 1: negativo.

    -- expoente:
    --   controlado pelos quatro botões.

    -- fração:
    --   começa obrigatoriamente com 1 e os sete bits restantes são
    --   controlados pelos switches 6 até 0.
    -----------------------------------------------------------------------        
    
    sign2 <= sw (7) ;
    exp2 <= btn ;
    frac2 <= '1' & sw (6 downto 0) ;

    -- instantiate fp adder --
    -----------------------------------------------------------------------
    -- Instância do somador de ponto flutuante.
    --
    -- fp_add_unit é apenas o nome dado a esta instância.
    --
    -- A entidade fp_adder recebe os dois operandos formados acima
    -- e produz sign_out, exp_out e frac_out.
    -----------------------------------------------------------------------
    fp_add_unit : entity work.fp_adder(arch)
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

    -- instantiate three instances of hex decoders --
    -- exponent --
    -----------------------------------------------------------------------
    -- Conversão do expoente para display de sete segmentos.
    --
    -- exp_out possui quatro bits, portanto pode representar um dígito
    -- hexadecimal entre 0 e F.
    --
    -- A entidade hex_to_sseg converte esses quatro bits no padrão
    -- necessário para acender os segmentos do display.
    -----------------------------------------------------------------------
    sseg_unit_0 : entity work . hex_to_sseg --
        port map ( hex => exp_out , dp => '0' , sseg => led0 ) ; --


    -- 4 LSBs of fraction --
    -----------------------------------------------------------------------
    -- Conversão dos quatro bits menos significativos da fração.
    --
    -- frac_out(3 downto 0) corresponde à metade inferior da fração.
    -----------------------------------------------------------------------    
    sseg_unit_1 : entity work . hex_to_sseg --
        port map ( hex => frac_out (3 downto 0) , dp => '1' , sseg => led1 ) ; --


    -- 4 MSBs of fraction --
    -----------------------------------------------------------------------
    -- Conversão dos quatro bits mais significativos da fração.
    --
    -- frac_out(7 downto 4) corresponde à metade superior da fração.
    -----------------------------------------------------------------------
    sseg_unit_2 : entity work . hex_to_sseg --
        port map ( hex => frac_out (7 downto 4) , dp => '0' , sseg => led2 ) ; --


    -- sign --
    -----------------------------------------------------------------------
    -- Representação do sinal do resultado.
    --
    -- Quando sign_out = 1, o resultado é negativo.
    -- O padrão 11111110 foi escolhido para exibir um traço no display.
    --
    -- Quando sign_out = 0, o resultado é positivo.
    -- O padrão 11111111 mantém o display apagado.
    --
    -- Esses padrões pressupõem o tipo de ligação elétrica utilizado
    -- pela placa original.
    -----------------------------------------------------------------------    
    led3 <= "11111110" when sign_out = '1' else
        "11111111";


    -- instantiate 7 -seg LED display time - multiplexing module --
    -----------------------------------------------------------------------
    -- Multiplexação dos quatro displays.
    --
    -- A placa original aparentemente não possui uma conexão de segmentos
    -- independente para cada display. Os quatro dígitos compartilham o
    -- barramento sseg.
    --
    -- O componente disp_mux usa o clock para alternar rapidamente entre:
    --
    --   in0 = expoente;
    --   in1 = parte inferior da fração;
    --   in2 = parte superior da fração;
    --   in3 = sinal.
    --
    -- an seleciona qual dos quatro displays está ativo em cada instante.
    -- Como a troca ocorre rapidamente, visualmente os quatro parecem
    -- permanecer acesos simultaneamente.
    -----------------------------------------------------------------------    
    disp_unit : entity work . disp_mux
        port map (
            clk => clk ,
            reset => '0' ,
            in0 => led0 ,
            in1 => led1 ,
            in2 => led2 ,
            in3 => led3 ,
            an => an ,
            sseg => sseg
        );

end arch;