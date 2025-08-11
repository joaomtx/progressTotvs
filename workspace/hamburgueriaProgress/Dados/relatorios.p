/* Sistema de Relatórios */
CURRENT-WINDOW:WIDTH = 100.
CURRENT-WINDOW:HEIGHT = 15.

DEFINE BUTTON bt-rel-clientes LABEL "Relatório de Clientes".
DEFINE BUTTON bt-rel-pedidos LABEL "Relatório de Pedidos".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE FRAME f-relatorios
    SKIP(2)
    bt-rel-clientes AT ROW 3 COL 20
    bt-rel-pedidos  AT ROW 5 COL 20
    bt-sair         AT ROW 7 COL 20
    WITH SIDE-LABELS CENTERED THREE-D
    VIEW-AS DIALOG-BOX TITLE "RELATÓRIOS - X-TUDO HAMBURGUERIA"
    SIZE 80 BY 12.

/* ===== RELATÓRIO DE CLIENTES ===== */
ON CHOOSE OF bt-rel-clientes IN FRAME f-relatorios DO:
    RUN relatorio-clientes.
END.

/* ===== RELATÓRIO DE PEDIDOS ===== */
ON CHOOSE OF bt-rel-pedidos IN FRAME f-relatorios DO:
    RUN relatorio-pedidos.
END.

ON CHOOSE OF bt-sair IN FRAME f-relatorios DO:
    APPLY "END-ERROR" TO SELF.
END.

/* ===== PROCEDURE RELATÓRIO DE CLIENTES ===== */
PROCEDURE relatorio-clientes:
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCidade AS CHARACTER NO-UNDO.
    
    ASSIGN cArquivo = "c:\dados\relatorio-clientes.txt".
    
    OUTPUT TO VALUE(cArquivo).
    
    PUT UNFORMATTED 
        "RELATÓRIO DE CLIENTES - X-TUDO HAMBURGUERIA" SKIP
        "================================================" SKIP(2)
        "Código Nome                          Endereço                                         Cidade               Observação" SKIP
        "------ ------------------------------ ------------------------------------------------ -------------------- ------------------------------------------------------------" SKIP.
    
    FOR EACH cliente NO-LOCK,
        FIRST cidades WHERE cidades.CodCidade = cliente.CodCidade NO-LOCK:
        
        ASSIGN cCidade = STRING(cliente.CodCidade) + "-" + TRIM(cidades.NomCidade).
        
        PUT UNFORMATTED
            STRING(cliente.CodCliente, ">>>>9") " "
            STRING(cliente.NomCliente, "x(30)") " "
            STRING(cliente.CodEndereco, "x(48)") " "
            STRING(cCidade, "x(20)") " "
            STRING(cliente.Observacao, "x(60)") SKIP.
    END.
    
    PUT UNFORMATTED SKIP "Fim do Relatório" SKIP.
    
    OUTPUT CLOSE.
    
    MESSAGE "Relatório de Clientes gerado em:" SKIP cArquivo 
        VIEW-AS ALERT-BOX INFORMATION.
        
    /* Exibe o relatório na tela */
    RUN VALUE("notepad " + cArquivo) NO-ERROR.
END PROCEDURE.

/* ===== PROCEDURE RELATÓRIO DE PEDIDOS ===== */
PROCEDURE relatorio-pedidos:
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCliente AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCidade AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cProduto AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dTotalPedido AS DECIMAL NO-UNDO.
    
    ASSIGN cArquivo = "c:\dados\relatorio-pedidos.txt".
    
    OUTPUT TO VALUE(cArquivo).
    
    PUT UNFORMATTED 
        "RELATÓRIO DE PEDIDOS - X-TUDO HAMBURGUERIA" SKIP
        "===========================================" SKIP(2).
    
    FOR EACH Pedidos NO-LOCK,
        FIRST cliente WHERE cliente.CodCliente = Pedidos.CodCliente NO-LOCK,
        FIRST cidades WHERE cidades.CodCidade = cliente.CodCidade NO-LOCK
        BY Pedidos.CodPedido:
        
        ASSIGN 
            cCliente = STRING(Pedidos.CodCliente) + "-" + TRIM(cliente.NomCliente)
            cCidade = TRIM(cidades.NomCidade) + "-" + TRIM(cidades.CodUF)
            dTotalPedido = 0.
        
        PUT UNFORMATTED
            "Pedido: " STRING(Pedidos.CodPedido) "  Data: " STRING(Pedidos.DatPedido, "99/99/9999") SKIP
            "Nome: " cCliente SKIP
            "Endereço: " TRIM(cliente.CodEndereco) " / " cCidade SKIP
            "Observação: " TRIM(Pedidos.Observacao) SKIP(1)
            "Item Produto                         Quantidade    Valor Unit.    Valor Total" SKIP
            "---- ------------------------------ ----------- -------------- --------------" SKIP.
        
        FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido NO-LOCK,
            FIRST Produtos WHERE Produtos.CodProduto = Itens.CodProduto NO-LOCK
            BY Itens.CodItem:
            
            ASSIGN 
                cProduto = STRING(Itens.CodProduto) + "-" + TRIM(Produtos.NomProduto)
                dTotalPedido = dTotalPedido + Itens.ValTotal.
            
            PUT UNFORMATTED
                STRING(Itens.CodItem, ">>>9") " "
                STRING(cProduto, "x(30)") " "
                STRING(Itens.NumQuantidade, ">>>>>>>>>>9") " "
                STRING(Produtos.ValProduto, ">>>>>>>9.99") " "
                STRING(Itens.ValTotal, ">>>>>>>9.99") SKIP.
        END.
        
        PUT UNFORMATTED 
            "                                                                    --------------" SKIP
            "                                                     Total Pedido = "
            STRING(dTotalPedido, ">>>>>>>9.99") SKIP(3).
    END.
    
    PUT UNFORMATTED SKIP "Fim do Relatório" SKIP.
    
    OUTPUT CLOSE.
    
    MESSAGE "Relatório de Pedidos gerado em:" SKIP cArquivo 
        VIEW-AS ALERT-BOX INFORMATION.
        
    /* Exibe o relatório na tela */
    RUN VALUE("notepad " + cArquivo) NO-ERROR.
END PROCEDURE.

/* ===== INICIALIZAÇÃO ===== */
ENABLE ALL WITH FRAME f-relatorios.

WAIT-FOR WINDOW-CLOSE OF FRAME f-relatorios.
