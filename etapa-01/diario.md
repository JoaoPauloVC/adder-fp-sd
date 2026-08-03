# Passo a passo feito para conclusão da Etapa 01

## Correção do código

Análise e correção do código VHDL disponibilizado no PDF. Foram corrigidos detalhes do arquivo como:
    - Substituição de apóstrofes (’) por aspas simples (');
    - = > por => (sem espaço);
    - remoção de alguns espaços no início do código (exemplo: use ieee . std_logic_1164 .all ; --)

## Funcionamento de números binários com vírgula

Da mesma forma que números decimais, onde números à esquerda representam potências de 10 (ex: 123 = 1x10^2 + 2x10^1 + 3x10^0), os binários que tem números à esquerda podem ser convertidos em decimais usando este esquema de potência, ou seja:

1001 = 1x2^3 0x2^2 + 0x2^1 + 1x2^0 = 9

Números à direita (números com vírgula), se comportam da mesma forma, ou seja:

Decimal: 0,123 = 1x10^-1 + 2x10^-2 + 3x10^-3
Binário: 0.101 = 1x2^-1 + 0x2^-2 + 1x2^-3

## Testbench para teste

Teremos 4 casos de teste, que terão os objetivos explicados abaixo.

### Caso 1 - Alinhamento de Expoentes

Binários de Teste:
0.10000000 x 2^3
0.10000000 x 2^2

Transformando em decimal, temos:
0.1 x 2^3 => Aumenta o número 3 casas (expoente) => (100)_2 = (4)_10
0.1 x 2^2 => Aumenta o número 2 casas (expoente) => (10)_2 = (2)_10

Com isso, tiramos facilmente que 4 + 2 = 6 (resultado que queremos chegar).

Em binário, temos que igualar as casas decimais para depois fazer a soma. O passo a passo fica:

  0.10000000 x 2^3
+ 0.10000000 x 2^2

----------------

  0.10000000 x 2^3
+ 0.01000000 x 2^3    <<< Aumento de 1 no expoente (vírgula para esquerda)

Com expoentes iguais, fazemos a soma
----------------
0.11000000 x 2^3

O resultado fica sendo
0.11 x 2^3 = (110)_2 = (6)_10

Com tudo em binário, o esperado é:

#### Sinal Positivo
sinal = 0

#### Expoente (3)_10
expoente = 0011

#### Fração (Número em binário de 8 bits)
fração = 11000000

### Caso 2 - Normalização com deslocamento à esquerda

0.11000000 x 2^3 - 0.10000000 x 2^3

Isso é igual a 6 - 4 = 2 em decimal.

Em binário, considerando que os expoente são iguais, temos:

  0.11000000 x 2^3
- 0.10000000 x 2^3
------------
  0.01000000 x 2^3

Temos 0.01000000 x 2^3. Precisamos normalizar (começar primeira casa decimal com 1).

Ficamos então com 0.10000000 x 2^2.

#### Sinal Positivo
sinal = 0

#### Expoente (2)_10
expoente = 0010

#### Fração (Número em binário de 8 bits)
fração = 10000000

### Caso 3 - Resultado muito pequeno

0.10000001 × 2^0 - 0.10000000 × 2^0

Os números em decimal equivalem a
0.10000001 × 2^0 = 1 x 2^-1 + 1 x 2^-8  = 1/2 + 1/256
0.10000000 × 2^0 = 1 x 2^-1             = 1/2

Em binário o resultado fica

  0.10000001 x 2^0
- 0.10000000 x 2^0
------------------
  0.00000001 x 2^0

Deveríamos normalizar o número até termos 0.10000000, porém neste caso o expoente seria -7. O expoente da potência de 2 é somente positivo. O código considera este resultado muito pequeno para ser representado e o converte para zero, ou seja.

#### Expoente (0)_10
expoente = 0000

#### Fração (Número em binário de 8 bits)
fração = 00000000

### Caso 4 - Soma com carry

0.10000000₂ × 2³ + 0.10000000₂ × 2³

Em decimal, temos 4 + 4 = 8

  0.10000000 × 2³
+ 0.10000000 × 2³
--------------
  1.00000000 × 2³

Lembrando, o número sempre inicia em 0,1, ou seja, precisamos fazer um carry, aumentanto a potência em 1, e "andando" com a vírgula para a esquerda. Assim, teremos

0.10000000 x 2^4

#### Sinal Positivo
sinal = 0

#### Expoente (4)_10
expoente = 0100

#### Fração (Número em binário de 8 bits)
fração = 10000000

## Compilação dos arquivos para análise
Observações iniciais:

OBS: Dentro da pasta "codigo" (etapa-01/codigo), rodar no terminal:

    ```bash
        ghdl -a fp_adder_tratado.vhd
        ghdl -a fp_adder_tratado_testbench.vhd
        ghdl -e fp_adder_tratado_testbench
        ghdl -r fp_adder_tratado_testbench --vcd=resposta.vcd
        gtkwave resposta.vcd
    ```

### Análise inicial (Sinais de onda do TestBench)
Após isso, o programa irá abrir. Selecione na área superior esquerda o SST testbench.

![GtkWave Signals](./images\01-gtkwave-signals.png)

Dentro, selecionei os sinais que quer ver (todos os do TestBench, neste primeiro momento).

![GtkWave Signals Selected](./images\02-gtkwave-signals-selected.png)

Dê zoom Fit para exibir todo o intervalo (Opção na barra superior) e altere o Data Format para Binary, para substituir tudo para binário. Fica como na imagem abaixo.

![GtkWave Signals Formatted](./images\03-gtkwave-signal-formatted.png)

### Conclusão Inicial

Pelas imagens, vemos que as saídas batem com o esperado, considerando critérios de Carry, valores muito pequenos, normalização e alinhamento dos expoentes.

### Análise Secundária (Sinais de onda do fp_adder)

Vamos agora analisar os sinais vindo do fp_adder. Para isto, selecione os outros sinais, dentro do uut.

Os sinais analisados serão:

expb        -> maior expoente
exps        -> menor expoente
exp_diff    -> diferença do expoente

fracb       -> maior fração
fracs       -> menor fração
fraca       -> fração menor após alinhamento

sum         -> resultado de 9 bits. Bit adicional para armazenar o carry, se necessário

leado       -> nºs de deslocamentos para a esquerda necessários
sum_norm    -> fração pós-deslocamento
expn        -> expoente normalizado
fracn       -> fração noramlizada

Analisando a imagem abaixo, verificamos que expn e fracn condizem com o esperado do testbench.

![GtkWave Signals fp_adder](./images\04-gtkwave-signals-fp-adder.png)

### Conclusão

Comparando os sinais de TestBench com os sinais do fp_adder, concluímos que, para os casos de teste analisados, o algoritmo produziu os resultados esperados e realizou corretamente os deslocamentos observados no quarto estágio.

## Análise de um quinto caso

Percebemos que não analisamos um caso em que a segunda entrada é o número de maior magnitude. Devido a isto, vamos fazer um quinto caso de teste, a seguir.

### Caso 5 - Segunda entrada com maior magnitude

0.10000000 × 2^3 - 0.10000000 × 2^3

Em decimal, temos 2 - 4 = -2

O segundo número possui maior magnitude. Por isso, o expoente usado para o alinhamento será 3.

O primeiro número deve ser representado com esse mesmo expoente:

Logo, temos

0.01000000 × 2^3 - 0.10000000 × 2^3

Como o segundo número é maior que o primeiro, fazemos a diferença em módulo e preservamos o sinal do número de maior valor

  0.10000000 × 2^3
- 0.01000000 × 2^3
------------------
  0.01000000 x 2^3

Lembrando de adicionar o sinal, temos -0.01000000 x 2^3. Com a normalização, temos -0.10000000 x 2^2.

#### Sinal Negativo
sinal = 1

#### Expoente (2)_10
expoente = 0010

#### Fração (Número em binário de 8 bits)
fração = 10000000

![GtkWave Second Number Bigger](./images\05-gtkwave-signal-second-bigger.png)

## Conclusão

Agora com este último caso tendo sido atentido como esperado, continuamos com a conclusão de que, para os casos de teste analisados, o algoritmo produziu os resultados esperados e realizou corretamente os deslocamentos observados no quarto estágio.