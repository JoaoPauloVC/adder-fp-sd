# Passo a passo planejado para a Etapa 03

> **Observação inicial:** este roteiro foi preparado de forma teórica antes do acesso à placa DE10-Lite. O objetivo é adiantar a configuração do projeto e reduzir o tempo necessário no laboratório. As etapas de gravação e validação física somente poderão ser concluídas quando houver acesso à placa.

## Resumo do procedimento no laboratório

1. Abrir o Quartus Prime Lite.
2. Criar um projeto vazio.
   1. nome: adder_fp_de10_lite
3. Adicionar os três arquivos VHDL.
   1. `fp_adder.vhd`;
   2. `hex_to_7seg_de10_lite.vhd`;
   3. `fp_adder_test_de10_lite.vhd`.
4. Selecionar a família MAX 10 e o dispositivo 10M50DAF484C7G.
5. Importar o arquivo DE10_LITE.qsf.
6. Definir arquivo fp_adder_test_de10_lite como Top-Level Entity.
7. Verificar a referência ao DE10_LITE.SDC (se der algum problema).
8. Compilar o projeto.
9.  Corrigir eventuais erros antes de prosseguir.
10. Conectar e ligar a placa.
11. Abrir o Programmer.
12. Selecionar USB-Blaster e modo JTAG.
13. Confirmar ou adicionar o arquivo .sof.
14. Marcar Program/Configure e clicar em Start.
15. Aguardar Progress: 100% (Successful).
16. Testar os quatro casos.
17. Fotografar os resultados e as telas do Quartus.

## Evidências da placa em cada Caso de Teste

Os valores esperados para os casos de teste evidenciados abaixo são os seguintes (já discutidos na etapa-02):

| Caso         | SW           | KEY  | Resultado esperado |
| ------------ | ------------ | ---- | ------------------ |
| Alinhamento  | `0011100000` | `11` | `d58`              |
| Carry out    | `0100000000` | `11` | `8A9`              |
| Negativo     | `1100000000` | `00` | `-967`             |
| Deslocamento | `1100010100` | `11` | `801`              |

### Caso de Teste 1 - Alinhamento dos operandos

![Caso 1 na DE10-Lite](images/de10-lite-caso-01.png)

### Caso de Teste 2 - Soma com Carry

![Caso 2 na DE10-Lite](images/de10-lite-caso-02.png)

### Caso de Teste 3 - Operando 2 negativo e maior em magnitude (valor maior em absoluto)

![Caso 3 na DE10-Lite](images/de10-lite-caso-03.png)

### Caso de Teste 4 - Grande deslocamento na normalização

![Caso 4 na DE10-Lite](images/de10-lite-caso-04.png)


## Conclusão da Etapa 03

Os quatro casos previamente validados em simulação foram reproduzidos fisicamente por meio dos switches e botões da placa.

Os resultados apresentados em HEX3, HEX2, HEX1 e HEX0 coincidiram com os valores esperados para os casos de alinhamento de expoentes, carry out, resultado negativo e grande deslocamento na normalização. Portanto, o circuito adaptado foi validado também em hardware.