# 🌱 Projeto de Banco de Dados: AgroConecta – Gestão de Armazéns e Distribuição de Sementes

[![Status](https://img.shields.io/badge/Status-Concluído-brightgreen)]()
[![Linguagem](https://img.shields.io/badge/Linguagem-SQL-blue)]()
[![SGBD](https://img.shields.io/badge/SGBD-MySQL-orange)]()

## 📘 Minimundo, Modelo Conceitual e Modelo Lógico – AgroConecta
## 🌱 1. Minimundo do Sistema AgroConecta

O AgroConecta é um sistema destinado a organizar e controlar a distribuição de sementes agrícolas entre armazéns e cooperativas. O sistema deve registrar gestores e operadores que administram os armazéns, além de cooperativas que solicitam sementes.

As sementes são armazenadas em lotes, cada um com data de entrada, data de vencimento, peso e tipo específico. Cada lote pertence a um único armazém.

As cooperativas podem realizar solicitações de sementes, informando a safra e a quantidade desejada. Uma solicitação pode envolver vários tipos de sementes, e o sistema registra essas quantidades individualmente. Cada solicitação possui um status (Pendente, Aprovada, Rejeitada etc.), e deve estar vinculada a uma cooperativa.

O sistema também armazena endereços e telefones, tanto de cooperativas quanto de gestores, garantindo que cada entidade tenha seus próprios dados de contato. Armazéns possuem endereço próprio e são administrados por um gestor.

As regras de negócio incluem validações de datas de lotes, quantidades solicitadas, unicidade de dados, prevenção de exclusão de entidades relacionadas e cálculos operacionais (dias para vencimento, total de lotes por armazém, peso por safra, etc.).

O sistema deve fornecer relatórios (via views e selects) sobre cooperativas, armazéns, solicitações, tipos de semente, lotes e safra.

---

## 🧩 Descrição das Relações Entre as Tabelas

O banco **AgroConecta** foi estruturado para representar o fluxo de sementes desde o armazém até as cooperativas.

### 1. Gestor, Armazém e Endereço

- **Gestor (CPF)** gerencia um ou mais **Armazéns (Armazem)** – relação **1:N**.  
- Cada armazém possui um **endereço** próprio (tabela **Endereco**) e também pode estar associado a um **operador de armazém** (OperadorArmazem).

> Há triggers que impedem, por exemplo, excluir um gestor que ainda possua armazéns ativos.

### 2. Cooperativa, Endereço e Telefone

- Uma **Cooperativa (CNPJ)** possui um endereço (Endereco) – relação **1:1**.  
- Cooperativas podem ter **vários telefones**, e cada telefone pertence a uma cooperativa ou a um gestor – relação **1:N** via tabela **Telefone**.   

Há triggers para impedir **telefones duplicados** por cooperativa/gestor. 

### 3. Armazém, Tipo de Semente, Lote e Safra

- A tabela **Lote** representa lotes físicos de sementes armazenados:
  - Cada lote está vinculado a **um Armazém** e **um TipoSemente** – relações **1:N**.
  - Lotes possuem **data de entrada**, **data de vencimento**, **peso** e um **QR Code** (`qr_payload`) único. 
- A tabela **Safra** registra o período/ano da safra e é usada nas solicitações. 

Triggers e procedures garantem, por exemplo:

- Que **data de vencimento > data de entrada**  
- Que não seja possível inserir **lotes com peso zero ou negativo**   

### 4. Solicitação, Status, Safra e Cooperativa

- **Solicitacao** registra um pedido de sementes feito por uma cooperativa:
  - Ligada a **Cooperativa**, **Safra** e **Status** (ex.: Pendente, Aprovada, Rejeitada).   
- Trigger garante que uma nova solicitação entre automaticamente como **“Pendente”**. 

### 5. SolicitaçãoTipoSemente e TipoSemente (N:N)

- Uma **solicitação** pode envolver **vários tipos de sementes**, e cada tipo de semente pode aparecer em várias solicitações.  
- Essa relação é modelada pela tabela **SolicitacaoTipoSemente**, que também armazena a **quantidade** de cada tipo.   

Trigger impede que a soma das quantidades por tipo **ultrapasse o total solicitado** na Solicitação. 

---

## 🛠️ Tecnologias Utilizadas

- **SGBD:** MySQL  
- **Modelagem e DDL:** MySQL Workbench :contentReference[oaicite:12]{index=12}  
- **Linguagem:** SQL (DDL, DML, DQL)  
- **Recursos extras:** Procedures, Functions, Triggers e Views   

---

## 📂 Estrutura do Repositório

```text
.
├── Script-Create.sql                 # Criação das tabelas, constraints e chaves estrangeiras
├── Script-insert.sql                 # Inserts de carga inicial nas principais tabelas
├── Script-procedure-function.sql     # Procedures e funções de negócio
├── Script-procedure-function-USO.sql # Exemplos de uso/teste das procedures e funções
├── Script-triggers.sql               # Triggers para regras de negócio e integridade
├── Script-Select.sql                 # Consultas (DQL) para relatórios e análises
├── views_agroconecta.sql             # Criação das views baseadas nas consultas
├── modelo-conceitual.png             # Diagrama Entidade-Relacionamento
├── modelo-logico.png                 # Modelo lógico relacional
└── modelo-logico.mwb                 # Arquivo do MySQL Workbench
```

## 🗺️ Modelagem
## Modelo Entidade-Relacionamento
![Modelo conceitual](Modelos/Imagens/modelo%20conceitual.png)
## Modelo Lógico
![Modelo lógico](Modelos/Imagens/modelo%20logico.png)



## ⚙️ Procedures e Funções de Negócio (Resumo)

Alguns exemplos de regras de negócio implementadas:

- cadLote – cadastra um lote validando peso, datas e existência de tipo de semente e QR Code único. 

- moverLote – movimenta um lote entre armazéns, garantindo que o lote e o armazém existem e que o lote não seja movido para o mesmo armazém. 

- caclSolicitacaoCoop – retorna quantas solicitações uma determinada cooperativa já realizou. 

- caclDiasVencimento – calcula quantos dias faltam para o vencimento de um lote. 

- calcLoteArmazem e calcTotalPeso – retornam, respectivamente, quantidade de lotes e soma do peso por armazém. 

- calcTotalLoteSemestre – conta lotes registrados em um determinado ano/semestre.

- caclTotalSolicitacoesSafra – calcula quantas solicitações de um certo status existem em uma safra. 

- calcPesoSafra – soma o peso dos lotes associados a uma safra. 

- qtdLotesPrestesVencer – retorna quantos lotes vencerão nos próximos X dias. 

- percLotesVencidosArmazem – calcula o percentual de lotes vencidos em um armazém. 



## 🧮 Triggers (Regras Automáticas)

Algumas das principais triggers:

- Impedir Lote com:

  - data de vencimento menor que a data de entrada

  - peso zero ou negativo

- Impedir Solicitação com quantidade menor ou igual a zero e garantir que entre com status “Pendente”. 

- Garantir que a soma das quantidades em SolicitacaoTipoSemente não ultrapasse o total solicitado. 

- Impedir alteração de CPF e usuário de Gestor após o cadastro. 

- Garantir unicidade de email e usuário para Operador de Armazém. 

- Impedir exclusão de:

  - Gestor com armazéns ativos

  - Cooperativa com solicitações pendentes/aprovadas

  - Safra com solicitações registradas

## 👀 Views

As views facilitam consultas recorrentes, por exemplo:

- vw_armazem_gestor – armazéns e seus gestores

- vw_cooperativas_endereco – cooperativas com dados de endereço

- vw_lotes_com_tipo_armazem – lotes com tipo de semente e armazém

- vw_qtd_lotes_por_armazem – quantidade de lotes por armazém

- vw_solicitacoes_por_cooperativa – total de solicitações por cooperativa

- vw_solicitacoes_aprovadas e vw_solicitacoes_pendentes – filtram por status

- vw_lotes_vencimento_60dias – lotes que vencem em menos de 60 dias

- vw_cooperativas_por_cidade e vw_cooperativas_sem_telefone

- vw_lotes_completos – visão consolidada de armazém, gestor, peso e data de entrada do lote


