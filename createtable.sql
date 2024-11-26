/* Criar table para manipulação e teste das consultas. Os testes foram realizados com MySQL e SQLite, mas no segundo caso foram adaptadas
as consultas por limitação de aceite de sintaxe do SQLite com DATE ADD, DATE_FORMAT, etc. Em todos os casos, as consultas entregaram as 
seleções com sucesso. */

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    transaction_amount DECIMAL(10, 2)
);
