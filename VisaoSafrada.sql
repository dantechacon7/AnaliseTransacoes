/*Pergunta: Crie uma query que mostre a visão de safra mensal de retenção de TPV, onde a data da primeira transação de cada cliente 
serve como ponto de partida. A visão deve incluir activate_month, safra e retained_tpv */

/* Inicialmente, será determinada a data da primeira transação relacionada a cada customer_id, de acordo com seu mês de ativação, 
ou seja, o mês que foi feita a primeira transação. Para isso, defino um alias para a menor data de transação, 
e outro para o mês da menor data de transação. Os dados devem ser agrupados por customer_id para puxar as datas de transações 
relacionadas a um mesmo cliente. */

WITH first_transaction AS (
  SELECT customer_id, 
  MIN(transaction_date) AS first_transaction_date, 
  DATE_FORMAT(MIN(transaction_date), '%Y-%m') AS activate_month --date_format em gcp pode ser substituído por format_date ou parse_date, por ex.
FROM transactions 
GROUP BY customer_id), monthly_tpv AS (
  
/* A seguir, é hora de calcular o tpv mensal por cliente, ou seja, a soma mensal dos valores de todas as transações feitas por cada cliente. 
Novamente, definimos alias para agregações dos dados como a soma dos valores das transações e para a função date_format utilizada 
para trazer os valores de data por mês. Por fim, agrupamos os dados por clientes e mês, ou seja, a soma das transações devem 
ser feitas entre valores que pertencam a um mesmo cliente e a um mesmo mês. */

SELECT t.customer_id, 
DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month, 
SUM(t.transaction_amount) AS monthly_tpv
FROM transactions t 
  GROUP BY t.customer_id, DATE_FORMAT(t.transaction_date, '%Y-%m')), tpv_with_safra AS (

/* A partir dos dados gerados na visão de TPV mensal, nós calculamos a diferença de meses entre a data da primeira transação 
(first_transaction_date) e o início do mês correspondente a cada transaction_month, o que nos concede o período de 
safra - o número de meses desde a primeira transação. Repare também que há um filtro para o campo "safra", requisitando que sejam 
trazidos somente resultados = zero. Isso significa que estamos olhando para o mês em que a primeira transação ocorreu para cada cliente, 
como funcionaria num MDIFF = 0. */
  
SELECT mt.customer_id, 
  ft.activate_month, 
  TIMESTAMPDIFF(MONTH, ft.first_transaction_date, STR_TO_DATE(mt.transaction_month, '%Y-%m-01')) AS safra,
  mt.monthly_tpv, 
  ft.first_transaction_date
FROM monthly_tpv mt 
  JOIN first_transaction ft 
  ON mt.customer_id = ft.customer_id), totaltpv_por_activate_month AS (SELECT activate_month, SUM(monthly_tpv) AS total_tpv
FROM tpv_with_safra 
  WHERE safra = 0 GROUP BY activate_month)
  
/* Por fim, na seleção final, definimos o campo de retained_tpv - calculado pela soma do tpv mensal, e a representatividade do r
etained_tpv em percentual. Perceba que, nesse cenário que tratamos de valores de transações, utilizamos a função COALESCE para evitar 
divisões por valores nulos que possam existir em períodos que um ou mais clientes não realizaram transações. 
Sendo assim, se o total_tpv ou montlhy_tpv forem nulos, o percentual não será afetado. */
  
SELECT t.activate_month, 
  t.safra, 
  SUM(t.monthly_tpv) AS retained_tpv, 
  (SUM(t.monthly_tpv) / COALESCE(tt.total_tpv, 1)) * 100 AS retained_tpv_percentage --calculando o tpv retido em percentual com apoio do coalesce para evitar divisões por zero
FROM tpv_with_safra t
JOIN totaltpv_por_activate_month tt 
  ON t.activate_month = tt.activate_month
GROUP BY t.activate_month, t.safra, tt.total_tpv 
  ORDER BY t.activate_month, t.safra;
