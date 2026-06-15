CREATE OR REPLACE PROCEDURE transferir(
    origem INT,
    destino INT,
    valor NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    saldo_origem NUMERIC;
BEGIN

    SELECT saldo
    INTO saldo_origem
    FROM conta
    WHERE conta_id = origem;

    IF saldo_origem < valor THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;

    UPDATE conta
