library ieee;
use ieee.std_logic_1164.all;

-----------------------------------------------------------------------
-- Decodificador hexadecimal para display de sete segmentos
-- da placa DE10-Lite.

-- Entrada:
--   hex: valor binário de 4 bits, entre 0000 e 1111.

-- Saída:
--   seg: sete segmentos do display, na ordem:
--
--        seg(0) = 0 (segmento superior)
--        seg(1) = 1 (segmento superior direito)
--        seg(2) = 2 (segmento inferior direito)
--        seg(3) = 3 (segmento inferior)
--        seg(4) = 4 (segmento inferior esquerdo)
--        seg(5) = 5 (segmento superior esquerdo)
--        seg(6) = 6 (segmento central)

-- Os segmentos da DE10-Lite são ativos em nível baixo:

--   0 = segmento aceso
--   1 = segmento apagado
-----------------------------------------------------------------------

entity hex_to_7seg_de10_lite is
    port (
        hex : in  std_logic_vector(3 downto 0);
        seg : out std_logic_vector(0 to 6)
    );
end hex_to_7seg_de10_lite;

architecture arch of hex_to_7seg_de10_lite is
begin

    with hex select
        seg <=
            "0000001" when "0000", -- 0
            "1001111" when "0001", -- 1
            "0010010" when "0010", -- 2
            "0000110" when "0011", -- 3
            "1001100" when "0100", -- 4
            "0100100" when "0101", -- 5
            "0100000" when "0110", -- 6
            "0001111" when "0111", -- 7
            "0000000" when "1000", -- 8
            "0000100" when "1001", -- 9
            "0001000" when "1010", -- A
            "1100000" when "1011", -- b
            "0110001" when "1100", -- C
            "1000010" when "1101", -- d
            "0110000" when "1110", -- E
            "0111000" when others; -- F

end arch;