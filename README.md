# Objetivo:

Analisar uma base com transações realizadas ao longo de 2023, com um total de aproximadamente 20 milhões de linhas. O código desse projeto foi construído com linguagem SQL e fornece visões relacionadas à retenção mensal de TPV (total payment value, em português - volume total de pagamento), TPV rolling (utilizada para calcular a soma do TPV nos últimos dias para cada dia presente na base de dados), e Churn (utilizada para medir a quantidade de clientes que deixaram de fazer transações por um período determinado - no caso desse projeto, 28 dias).

# Descrição dos dados:

- `transaction_id` (INT): Identificador único da transação
- `customer_id` (INT): Identificador único do cliente
- `transaction_date` (DATE): Data da transação
- `transaction_amount` (DECIMAL): Valor da transação
- `activate_month` (DATE): Mês da primeira transação do cliente
- `safra` (INT): Número de meses desde a primeira transação
- `retained_tpv` (FLOAT): Percentual do TPV retido em cada mês subsequente à primeira
- `ref_date` (DATE): Data de referência
- `rolling_tpv_7` (FLOAT): Soma do TPV nos últimos 7 dias
- `active_costumers_7` (INT): número de clientes ativos nos últimos 7 dias transação
- `reference_month` (DATE): Mês de referência
- `churned_customers` (INT): Número de clientes que não realizaram transações nos
últimos 28 dias dentro do mês de referência

# Visões criadas e possibilidades de análise:

- Visão safrada: a partir dela, temos como objetivo identificar padrões de retenção de TPV ao longo do tempo, assim como, avaliar a eficácia de estratégias de retenção de clientes ao analisar como o TPV retido evolui mês a mês.
- TPV Rolling: com ela, podemos avaliar tendências de curto prazo no volume de transações, sazonalidade ou eventos específicos que impactam positiva ou negativamente o TPV diário de cada cliente.
- Visão de churn: com o range de 28 dias proposto pelo filtro, há uma definição mais assertiva de clientes inativos, o que nos possibilita o acompanhamento sazonal de aumentos ou diminuições da taxa de churn, e de eficácia das estratégias adotadas pelo time para diminuição de churn e aumento de vida útil de cada customer_id.
