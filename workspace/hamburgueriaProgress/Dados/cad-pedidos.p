/* Cadastro de Pedidos e Itens */
CURRENT-WINDOW:WIDTH = 180.
CURRENT-WINDOW:HEIGHT = 40.

/* Botões para Pedidos */
DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Adicionar".
DEFINE BUTTON bt-mod LABEL "Modificar".
DEFINE BUTTON bt-del LABEL "Eliminar".
DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-export LABEL "Exportar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

/* Botões para Itens */
DEFINE BUTTON bt-add-item LABEL "Adicionar Item".
DEFINE BUTTON bt-mod-item LABEL "Modificar Item".
DEFINE BUTTON bt-del-item LABEL "Eliminar Item".
DEFINE BUTTON bt-save-item LABEL "Salvar Item".
DEFINE BUTTON bt-canc-item LABEL "Cancelar Item".

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.
DEFINE VARIABLE cActionItem AS CHARACTER NO-UNDO.
DEFINE VARIABLE iPedidoAtual AS INTEGER NO-UNDO.

DEFINE QUERY qPed FOR Pedidos SCROLLING.
DEFINE QUERY qItens FOR Itens SCROLLING.

/* Buffers para validação */
DEFINE BUFFER bCliente FOR cliente.
DEFINE BUFFER bProduto FOR Produtos.
DEFINE BUFFER bItens FOR Itens.

DEFINE FRAME f-ped
    /* Linha 1 - Navegação Pedidos */
    bt-pri     AT ROW 1.5 COL 2
    bt-ant     AT ROW 1.5 COL 10
    bt-prox    AT ROW 1.5 COL 18
    bt-ult     AT ROW 1.5 COL 26
    bt-add     AT ROW 1.5 COL 38
    bt-mod     AT ROW 1.5 COL 52
    bt-del     AT ROW 1.5 COL 66
    /* Linha 2 - Ações Pedidos */
    bt-save    AT ROW 2.5 COL 2
    bt-canc    AT ROW 2.5 COL 14
    bt-export  AT ROW 2.5 COL 28
    bt-sair    AT ROW 2.5 COL 42
    SKIP(1)
    /* Dados do Pedido */
    Pedidos.CodPedido   LABEL "Código"      AT ROW 4 COL 15
    Pedidos.CodCliente  LABEL "Cod. Cliente" AT ROW 5 COL 15
    Pedidos.DatPedido   LABEL "Data"        AT ROW 6 COL 15
    Pedidos.ValPedido   LABEL "Valor Total" AT ROW 7 COL 15
    Pedidos.Observacao  LABEL "Observação"  AT ROW 8 COL 15 VIEW-AS FILL-IN SIZE 80 BY 1
    SKIP(1)
    /* Botões para Itens */
    bt-add-item  AT ROW 10 COL 2 LABEL "Adicionar Item"
    bt-mod-item  AT ROW 10 COL 20 LABEL "Modificar Item"
    bt-del-item  AT ROW 10 COL 38 LABEL "Eliminar Item"
    bt-save-item AT ROW 11 COL 2 LABEL "Salvar Item"
    bt-canc-item AT ROW 11 COL 16 LABEL "Cancelar Item"
    WITH SIDE-LABELS THREE-D
    VIEW-AS DIALOG-BOX TITLE "Cadastro de Pedidos e Itens"
    SIZE 150 BY 30.

DEFINE FRAME f-itens
    Itens.CodItem       LABEL "Item"        AT ROW 1 COL 5
    Itens.CodProduto    LABEL "Cod. Produto" AT ROW 1 COL 20
    Itens.NumQuantidade LABEL "Quantidade"  AT ROW 1 COL 40
    Itens.ValTotal      LABEL "Valor Total" AT ROW 1 COL 60
    WITH DOWN SCROLLABLE SIZE 140 BY 8 SIDE-LABELS
    OVERLAY AT ROW 15 COL 5.

/* ===== PROCEDURES PARA PEDIDOS ===== */

PROCEDURE piHabilitaBotoesPed:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
       bt-pri:SENSITIVE IN FRAME f-ped     = pEnable
       bt-ant:SENSITIVE IN FRAME f-ped     = pEnable
       bt-prox:SENSITIVE IN FRAME f-ped    = pEnable
       bt-ult:SENSITIVE IN FRAME f-ped     = pEnable
       bt-sair:SENSITIVE IN FRAME f-ped    = pEnable
       bt-add:SENSITIVE IN FRAME f-ped     = pEnable
       bt-mod:SENSITIVE IN FRAME f-ped     = pEnable
       bt-del:SENSITIVE IN FRAME f-ped     = pEnable
       bt-export:SENSITIVE IN FRAME f-ped  = pEnable
       bt-save:SENSITIVE IN FRAME f-ped    = NOT pEnable
       bt-canc:SENSITIVE IN FRAME f-ped    = NOT pEnable.
       
    /* Botões de itens */
    IF pEnable AND AVAILABLE Pedidos THEN DO:
        ASSIGN
           bt-add-item:SENSITIVE IN FRAME f-ped  = TRUE
           bt-mod-item:SENSITIVE IN FRAME f-ped  = AVAILABLE Itens
           bt-del-item:SENSITIVE IN FRAME f-ped  = AVAILABLE Itens.
    END.
    ELSE DO:
        ASSIGN
           bt-add-item:SENSITIVE IN FRAME f-ped  = FALSE
           bt-mod-item:SENSITIVE IN FRAME f-ped  = FALSE
           bt-del-item:SENSITIVE IN FRAME f-ped  = FALSE.
    END.
END PROCEDURE.

PROCEDURE piHabilitaBotoesItem:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
       bt-save-item:SENSITIVE IN FRAME f-ped = pEnable
       bt-canc-item:SENSITIVE IN FRAME f-ped = pEnable.
END PROCEDURE.

PROCEDURE piHabilitaCamposPed:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
        Pedidos.CodCliente:SENSITIVE IN FRAME f-ped = pEnable
        Pedidos.DatPedido:SENSITIVE IN FRAME f-ped  = pEnable
        Pedidos.Observacao:SENSITIVE IN FRAME f-ped = pEnable.
END PROCEDURE.

PROCEDURE piHabilitaCamposItem:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
        Itens.CodProduto:SENSITIVE IN FRAME f-itens    = pEnable
        Itens.NumQuantidade:SENSITIVE IN FRAME f-itens = pEnable.
END PROCEDURE.

PROCEDURE piMostraPed:
    IF AVAILABLE Pedidos THEN DO:
        DISPLAY Pedidos.CodPedido Pedidos.CodCliente Pedidos.DatPedido 
                Pedidos.ValPedido Pedidos.Observacao WITH FRAME f-ped.
        ASSIGN iPedidoAtual = Pedidos.CodPedido.
        RUN piOpenQueryItens.
    END.
    ELSE DO:
        CLEAR FRAME f-ped ALL.
        ASSIGN iPedidoAtual = 0.
        CLEAR FRAME f-itens ALL.
    END.
END PROCEDURE.

PROCEDURE piMostraItem:
    IF AVAILABLE Itens THEN
        DISPLAY Itens.CodItem Itens.CodProduto Itens.NumQuantidade Itens.ValTotal 
                WITH FRAME f-itens.
    ELSE
        CLEAR FRAME f-itens ALL.
END PROCEDURE.

PROCEDURE piOpenQueryPed:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE Pedidos THEN
        rRecord = ROWID(Pedidos).

    OPEN QUERY qPed FOR EACH Pedidos.
    REPOSITION qPed TO ROWID rRecord NO-ERROR.
    RUN piMostraPed.
END PROCEDURE.

PROCEDURE piOpenQueryItens:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE Itens THEN
        rRecord = ROWID(Itens).

    OPEN QUERY qItens FOR EACH Itens WHERE Itens.CodPedido = iPedidoAtual.
    REPOSITION qItens TO ROWID rRecord NO-ERROR.
    RUN piMostraItem.
END PROCEDURE.

PROCEDURE piCalculaTotal:
    DEFINE VARIABLE dTotal AS DECIMAL NO-UNDO.
    
    FOR EACH bItens WHERE bItens.CodPedido = iPedidoAtual NO-LOCK:
        dTotal = dTotal + bItens.ValTotal.
    END.
    
    FIND CURRENT Pedidos EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE Pedidos THEN DO:
        ASSIGN Pedidos.ValPedido = dTotal.
        DISPLAY Pedidos.ValPedido WITH FRAME f-ped.
    END.
END PROCEDURE.

/* ===== EVENTOS NAVEGAÇÃO PEDIDOS ===== */

ON CHOOSE OF bt-pri IN FRAME f-ped DO: 
    GET FIRST qPed. 
    RUN piMostraPed. 
    RUN piHabilitaBotoesPed(TRUE).
END.

ON CHOOSE OF bt-ant IN FRAME f-ped DO: 
    GET PREV qPed. 
    RUN piMostraPed.
    RUN piHabilitaBotoesPed(TRUE). 
END.

ON CHOOSE OF bt-prox IN FRAME f-ped DO: 
    GET NEXT qPed. 
    RUN piMostraPed.
    RUN piHabilitaBotoesPed(TRUE). 
END.

ON CHOOSE OF bt-ult IN FRAME f-ped DO: 
    GET LAST qPed. 
    RUN piMostraPed.
    RUN piHabilitaBotoesPed(TRUE). 
END.

/* ===== EVENTOS CRUD PEDIDOS ===== */

ON CHOOSE OF bt-add IN FRAME f-ped DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoesPed(FALSE).
    RUN piHabilitaCamposPed(TRUE).
    
    CREATE Pedidos.
    ASSIGN
        Pedidos.CodPedido = NEXT-VALUE(seqPedido)
        Pedidos.DatPedido = TODAY
        Pedidos.ValPedido = 0.00
        iPedidoAtual = Pedidos.CodPedido.
    
    DISPLAY Pedidos.CodPedido Pedidos.DatPedido Pedidos.ValPedido WITH FRAME f-ped.
    
    ASSIGN
        Pedidos.CodCliente:SCREEN-VALUE IN FRAME f-ped = "0"
        Pedidos.Observacao:SCREEN-VALUE IN FRAME f-ped = "".
        
    CLEAR FRAME f-itens ALL.
END.

ON CHOOSE OF bt-mod IN FRAME f-ped DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoesPed(FALSE).
    RUN piHabilitaCamposPed(TRUE).
END.

ON CHOOSE OF bt-del IN FRAME f-ped DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    MESSAGE "Confirma a eliminação do pedido" Pedidos.CodPedido "?" 
            "Todos os itens também serão eliminados!" UPDATE lConf
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".

    IF lConf THEN DO:
        DO TRANSACTION:
            /* Elimina itens em cascata */
            FOR EACH bItens WHERE bItens.CodPedido = Pedidos.CodPedido:
                DELETE bItens.
            END.
            /* Elimina o pedido */
            DELETE Pedidos.
        END.
        RUN piOpenQueryPed.
        RUN piHabilitaBotoesPed(TRUE).
    END.
END.

ON CHOOSE OF bt-save IN FRAME f-ped DO:
   /* Valida se o cliente existe */
   DEFINE VARIABLE iCodCliente AS INTEGER NO-UNDO.
   ASSIGN iCodCliente = INTEGER(Pedidos.CodCliente:SCREEN-VALUE IN FRAME f-ped).
   
   FIND FIRST bCliente WHERE bCliente.CodCliente = iCodCliente NO-LOCK NO-ERROR.
   IF NOT AVAILABLE(bCliente) THEN DO:
       MESSAGE "Código do Cliente não encontrado!" VIEW-AS ALERT-BOX.
       RETURN.
   END.

   DO TRANSACTION:
       IF cAction = "mod" THEN DO:
           FIND CURRENT Pedidos EXCLUSIVE-LOCK.
       END.

       ASSIGN
          Pedidos.CodCliente = iCodCliente
          Pedidos.DatPedido  = DATE(Pedidos.DatPedido:SCREEN-VALUE IN FRAME f-ped)
          Pedidos.Observacao = Pedidos.Observacao:SCREEN-VALUE IN FRAME f-ped.
   END. /* TRANSACTION */

   RUN piHabilitaBotoesPed(TRUE).
   RUN piHabilitaCamposPed(FALSE).
   RUN piOpenQueryPed.
END.

ON CHOOSE OF bt-canc IN FRAME f-ped DO:
    IF cAction = "add" THEN DO:
        /* Remove itens criados para este pedido */
        FOR EACH bItens WHERE bItens.CodPedido = iPedidoAtual:
            DELETE bItens.
        END.
        DELETE Pedidos.
    END.

    RUN piHabilitaBotoesPed(TRUE).
    RUN piHabilitaCamposPed(FALSE).
    RUN piMostraPed.
END.

/* ===== EVENTOS CRUD ITENS ===== */

ON CHOOSE OF bt-add-item IN FRAME f-ped DO:
    ASSIGN cActionItem = "add".
    RUN piHabilitaBotoesItem(TRUE).
    RUN piHabilitaCamposItem(TRUE).
    
    CREATE Itens.
    ASSIGN
        Itens.CodPedido = iPedidoAtual.
    
    /* Calcula próximo número do item */
    DEFINE VARIABLE iProxItem AS INTEGER NO-UNDO.
    FOR EACH bItens WHERE bItens.CodPedido = iPedidoAtual NO-LOCK:
        IF bItens.CodItem > iProxItem THEN
            iProxItem = bItens.CodItem.
    END.
    ASSIGN 
        Itens.CodItem = iProxItem + 1
        Itens.ValTotal = 0.00.
    
    DISPLAY Itens.CodItem Itens.ValTotal WITH FRAME f-itens.
    
    ASSIGN
        Itens.CodProduto:SCREEN-VALUE IN FRAME f-itens = "0"
        Itens.NumQuantidade:SCREEN-VALUE IN FRAME f-itens = "1".
END.

ON CHOOSE OF bt-mod-item IN FRAME f-ped DO:
    ASSIGN cActionItem = "mod".
    RUN piHabilitaBotoesItem(TRUE).
    RUN piHabilitaCamposItem(TRUE).
END.

ON CHOOSE OF bt-del-item IN FRAME f-ped DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    MESSAGE "Confirma a eliminação do item" Itens.CodItem "?" UPDATE lConf
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".

    IF lConf THEN DO:
        DELETE Itens.
        RUN piCalculaTotal.
        RUN piOpenQueryItens.
    END.
END.

ON CHOOSE OF bt-save-item IN FRAME f-ped DO:
   /* Valida se o produto existe */
   DEFINE VARIABLE iCodProduto AS INTEGER NO-UNDO.
   DEFINE VARIABLE iQuantidade AS INTEGER NO-UNDO.
   
   ASSIGN 
       iCodProduto = INTEGER(Itens.CodProduto:SCREEN-VALUE IN FRAME f-itens)
       iQuantidade = INTEGER(Itens.NumQuantidade:SCREEN-VALUE IN FRAME f-itens).
   
   FIND FIRST bProduto WHERE bProduto.CodProduto = iCodProduto NO-LOCK NO-ERROR.
   IF NOT AVAILABLE(bProduto) THEN DO:
       MESSAGE "Código do Produto não encontrado!" VIEW-AS ALERT-BOX.
       RETURN.
   END.

   DO TRANSACTION:
       IF cActionItem = "mod" THEN DO:
           FIND CURRENT Itens EXCLUSIVE-LOCK.
       END.

       ASSIGN
          Itens.CodProduto    = iCodProduto
          Itens.NumQuantidade = iQuantidade
          Itens.ValTotal      = iQuantidade * bProduto.ValProduto.
   END. /* TRANSACTION */

   RUN piHabilitaBotoesItem(FALSE).
   RUN piHabilitaCamposItem(FALSE).
   RUN piCalculaTotal.
   RUN piOpenQueryItens.
   RUN piHabilitaBotoesPed(TRUE).
END.

ON CHOOSE OF bt-canc-item IN FRAME f-ped DO:
    IF cActionItem = "add" THEN
        DELETE Itens.

    RUN piHabilitaBotoesItem(FALSE).
    RUN piHabilitaCamposItem(FALSE).
    RUN piMostraItem.
    RUN piHabilitaBotoesPed(TRUE).
END.

ON CHOOSE OF bt-export IN FRAME f-ped DO:
    RUN exportar-pedidos.p.
END.

/* ===== NAVEGAÇÃO ENTRE ITENS COM MOUSE ===== */
ON MOUSE-SELECT-CLICK OF FRAME f-itens DO:
    GET NEXT qItens.
    RUN piMostraItem.
END.

/* ===== INICIALIZAÇÃO ===== */
ENABLE ALL WITH FRAME f-ped.

VIEW FRAME f-itens.

RUN piOpenQueryPed.
RUN piHabilitaBotoesPed(TRUE).
RUN piHabilitaBotoesItem(FALSE).
RUN piHabilitaCamposPed(FALSE).
RUN piHabilitaCamposItem(FALSE).

WAIT-FOR WINDOW-CLOSE OF FRAME f-ped.
