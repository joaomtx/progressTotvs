TRIGGER PROCEDURE FOR CREATE OF Clientes.
ASSIGN clientes.CodCliente = NEXT-VALUE(SeqCliente).
