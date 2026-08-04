-- Testbench do circuito adaptado para a placa DE10-Lite

library ieee;
use ieee.std_logic_1164.all;

entity fp_adder_test_de10_lite_testbench is
end fp_adder_test_de10_lite_testbench;

architecture tb_arch of fp_adder_test_de10_lite_testbench is

    -- Controles físicos simulados
    signal test_SW : std_logic_vector(9 downto 0);

    -- OBS: os botões ficam em nível alto (1) quando soltos.
    -- frac2 usa not KEY para inverter o sinal:

    -- botão solto       => KEY = 1 => bit 0 em frac2
    -- botão pressionado => KEY = 0 => bit 1 em frac2
    signal test_KEY : std_logic_vector(1 downto 0);

    -- Displays simulados
    signal test_HEX3 : std_logic_vector(0 to 6);
    signal test_HEX2 : std_logic_vector(0 to 6);
    signal test_HEX1 : std_logic_vector(0 to 6);
    signal test_HEX0 : std_logic_vector(0 to 6);

    -- Fim da simulação
    signal test_end : std_logic := '0';

begin

    -- Circuito adaptado que será testado
    uut : entity work.fp_adder_test_de10_lite(arch)
        port map (
            SW   => test_SW,
            KEY  => test_KEY,
            HEX3 => test_HEX3,
            HEX2 => test_HEX2,
            HEX1 => test_HEX1,
            HEX0 => test_HEX0
        );

    process
    begin

        -------------------------------------------------------------
        -- Caso 1: alinhamento dos expoentes
        --
        -- KEY = 11: botões soltos

        -- Operando 1:
        -- sinal = 0
        -- exp1  = 1000
        -- frac1 = 10010101

        -- Operando 2:
        -- sinal = 0
        -- exp2  = 0111
        -- frac2 = 10000000

        -- Resultado esperado:
        -- sinal = 0
        -- exp   = 1000
        -- frac  = 11010101

        -- Displays esperados: [apagado] d 5 8
        
        test_SW  <= "0011100000";
        test_KEY <= "11";
        -------------------------------------------------------------

        wait for 200 ns;

        -------------------------------------------------------------
        -- Caso 2: soma com carry out
        --
        -- KEY = 11: botões soltos

        -- Operando 1:
        -- sinal = 0
        -- exp1  = 1000
        -- frac1 = 10010101

        -- Operando 2:
        -- sinal = 0
        -- exp2  = 1000
        -- frac2 = 10000000

        -- Resultado esperado:
        -- sinal = 0
        -- exp   = 1001
        -- frac  = 10001010

        -- Displays esperados: [apagado] 8 A 9
        
        test_SW  <= "0100000000";
        test_KEY <= "11";
        -------------------------------------------------------------

        wait for 200 ns;

        -------------------------------------------------------------
        -- Caso 3: Operando 2 negativo e de maior magnitude (maior em absoluto)

        -- KEY = 00: botões pressionados

        -- Operando 1:
        -- sinal = 0
        -- exp1  = 1000
        -- frac1 = 10010101

        -- Operando 2:
        -- sinal = 1
        -- exp2  = 1000
        -- frac2 = 11100000

        -- Resultado esperado:
        -- sinal = 1
        -- exp   = 0111
        -- frac  = 10010110

        -- Displays esperados: - 9 6 7
        
        test_SW  <= "1100000000";
        test_KEY <= "00";
        -------------------------------------------------------------

        wait for 200 ns;

        -------------------------------------------------------------
        -- Caso 4: muitos deslocamentos na normalização

        -- KEY = 11: os dois botões estão soltos

        -- Configuração dos switches:

        -- Operando 1:
        -- sinal = 0
        -- exp1  = 1000
        -- frac1 = 10010101

        -- Operando 2:
        -- sinal = 1
        -- exp2  = 1000
        -- frac2 = 10010100

        -- Resultado esperado:
        -- sinal = 0
        -- exp   = 0001
        -- frac  = 10000000

        -- Displays esperados: [apagado] 8 0 1
        
        test_SW  <= "1100010100";
        test_KEY <= "11";
        -------------------------------------------------------------

        wait for 200 ns;

        -- Marca o fim do quarto caso, no instante de 800 ns
        test_end <= '1';

        wait;

    end process;

end tb_arch;