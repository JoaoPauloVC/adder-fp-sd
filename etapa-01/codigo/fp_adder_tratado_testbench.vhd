-- Testbench do somador de ponto flutuante

library ieee;
use ieee.std_logic_1164.all;

entity fp_adder_tratado_testbench is
end fp_adder_tratado_testbench;

architecture tb_arch of fp_adder_tratado_testbench is

   -- Sinais usados como entradas do somador
   signal test_sign1, test_sign2 : std_logic;
   signal test_exp1, test_exp2   : std_logic_vector(3 downto 0);
   signal test_frac1, test_frac2 : std_logic_vector(7 downto 0);

   -- Sinais usados para observar as saidas
   signal test_sign_out : std_logic;
   signal test_exp_out  : std_logic_vector(3 downto 0);
   signal test_frac_out : std_logic_vector(7 downto 0);

   -- Indica o final dos casos de teste
   signal test_end : std_logic := '0';

begin

   -- Instancia o circuito sob teste
   -- uut = unit under test
   uut: entity work.fp_adder_tratado(arch)
      port map(
         sign1    => test_sign1,
         sign2    => test_sign2,
         exp1     => test_exp1,
         exp2     => test_exp2,
         frac1    => test_frac1,
         frac2    => test_frac2,
         sign_out => test_sign_out,
         exp_out  => test_exp_out,
         frac_out => test_frac_out
      );

   -- Gerador dos vetores de teste
   -- Para entender melhor os casos testados, confira o o arquivo diario.md
   process
   begin

      -------------------------------------------------------------
      -- Vetor de teste 1
      -- 0.10000000 * 2^3 + 0.10000000 * 2^2
      --
      -- Resultado esperado:
      -- sinal = 0, expoente = 0011, fracao = 11000000
      -------------------------------------------------------------
      test_sign1 <= '0';
      test_exp1  <= "0011";
      test_frac1 <= "10000000";

      test_sign2 <= '0';
      test_exp2  <= "0010";
      test_frac2 <= "10000000";

      wait for 200 ns;

      -------------------------------------------------------------
      -- Vetor de teste 2
      -- 0.11000000 * 2^3 - 0.10000000 * 2^3
      --
      -- Resultado esperado:
      -- sinal = 0, expoente = 0010, fracao = 10000000
      -------------------------------------------------------------
      test_sign1 <= '0';
      test_exp1  <= "0011";
      test_frac1 <= "11000000";

      test_sign2 <= '1';
      test_exp2  <= "0011";
      test_frac2 <= "10000000";

      wait for 200 ns;

      -------------------------------------------------------------
      -- Vetor de teste 3
      -- 0.10000001 * 2^0 - 0.10000000 * 2^0
      --
      -- Resultado esperado:
      -- expoente = 0000, fracao = 00000000
      -------------------------------------------------------------
      test_sign1 <= '0';
      test_exp1  <= "0000";
      test_frac1 <= "10000001";

      test_sign2 <= '1';
      test_exp2  <= "0000";
      test_frac2 <= "10000000";

      wait for 200 ns;

      -------------------------------------------------------------
      -- Vetor de teste 4
      -- 0.10000000 * 2^3 + 0.10000000 * 2^3
      --
      -- Resultado esperado:
      -- sinal = 0, expoente = 0100, fracao = 10000000
      -------------------------------------------------------------
      test_sign1 <= '0';
      test_exp1  <= "0011";
      test_frac1 <= "10000000";

      test_sign2 <= '0';
      test_exp2  <= "0011";
      test_frac2 <= "10000000";

      wait for 200 ns;
      
      -- Marca o fim do quarto caso, no instante de 800 ns
      test_end <= '1';

      wait;

   end process;

end tb_arch;