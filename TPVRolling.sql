/* Pergunta: Crie uma query que mostre o TPV rolling 7 para cada dia na tabela de transações baseada na ‘transaction_date’. 
A visão deve incluir ref_date, soma do tpv nos últimos 7 dias e número de clientes ativos nos últimos 7 dias. */

/* Comentários sobre otimização do código: 
Foram utilizadas ctes para calcular rolling_tpv_7 e active_customers_7 separadamente, evitando 
repetir os cálculos para cada linha de cada table. O join utilizado foi o LEFT JOIN, para garantir que todas as datas de t1 sejam 
consideradas, mesmo que não haja correspondência em t2, o que pode ser ajustado dependendo do objetivo (haver nulidade nos resultados ou não).
Apesar de um inner join ser mais eficiente que um outer join, principalmente pra uma base de 20M de linhas, se usássemos o inner,
os resultados excluiriam datas referenciais que não têm dados correspondentes de transações nos últimos 7 dias.*/

/* Detalhamento das linhas de código: 
No primeiro momento, definimos a data de referência para ser trazida no resultado da consulta, a qual é atribuída pela data da transação, 
de acordo com o intervalos que definirmos na subquery. Após isso, calculamos o tpv para as transações dos últimos 7 dias. 
Para fins de documentação mais clara, o date_add surge como uma opção para tornar a janela móvel de dias mais explícita na consulta: 
'INTERVAL 6 DAY' que seria um intervalo de 6 dias entre uma info e outra. */

WITH rolling_tpv AS (
  SELECT t1.transaction_date AS ref_date,
    SUM(t2.transaction_amount) AS rolling_tpv_7
  FROM transactions t1
  LEFT JOIN transactions t2 ON t2.transaction_date BETWEEN t1.transaction_date AND DATE_ADD(t1.transaction_date, INTERVAL 6 DAY)
  GROUP BY t1.transaction_date
), active_customers AS (
  SELECT t1.transaction_date AS ref_date,
    COUNT(DISTINCT t2.customer_id) AS active_customers_7
  FROM transactions t1
  LEFT JOIN transactions t2 ON t2.transaction_date BETWEEN t1.transaction_date AND DATE_ADD(t1.transaction_date, INTERVAL 6 DAY) /*em alguns ambientes de teste como sqlite, o date_add não é aceito, vale trocar para um 'date' com a soma do intervalo de dias*/
  GROUP BY t1.transaction_date )
SELECT ref_date,
  rolling_tpv_7,
  active_customers_7
FROM rolling_tpv
JOIN active_customers USING (ref_date) 
ORDER BY ref_date DESC;

/* É interessante notar também, que ao ordenarmos por ref_date DESC, trazemos as informações mais recentes no topo, e as mais antigas depois.
No uso dessa query em ferramentas como looker datastudio e/ou google sheets, por exemplo, em que integraríamos a consulta via BigQuery, 
conseguimos trazer um limite de rows menor, deixar a visualização mais leve, e trazer dados mais recentes - com maior relevância numa 
análise do dia a dia - para o topo do dashboard. Um limit de rows no código também seria uma alternativa para tornar o código mais leve. */
