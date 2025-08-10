/* Cadastro de Pedidos e Itens */
CURRENT-WINDOW:WIDTH = 150.

/* --- All UI Widgets Defined First --- */
DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Adicionar Pedido".
DEFINE BUTTON bt-del LABEL "Eliminar Pedido".
DEFINE BUTTON bt-save LABEL "Salvar Pedido".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.
DEFINE BUTTON bt-add-item LABEL "Adicionar Item".
DEFINE BUTTON bt-mod-item LABEL "Modificar Item".
DEFINE BUTTON bt-del-item LABEL "Remover Item".

DEFINE QUERY qPed FOR Pedidos, cliente SCROLLING.
DEFINE QUERY qItens FOR Itens, Produtos SCROLLING.

DEFINE BROWSE br-itens QUERY qItens
    DISPLAY Itens.CodItem Itens.CodProduto Produtos.NomProduto Itens.NumQuantidade Itens.ValTotal
    WITH 10 DOWN WIDTH 140.

/* --- Monolithic Frame Definition --- */
DEFINE FRAME f-ped
    bt-pri  AT ROW 1.5 COL 2
    bt-ant  AT ROW 1.5 COL 10
    bt-prox AT ROW 1.5 COL 18
    bt-ult  AT ROW 1.5 COL 26
    bt-add  AT ROW 1.5 COL 40
    bt-del  AT ROW 1.5 COL 60
    bt-save AT ROW 1.5 COL 80
    bt-canc AT ROW 1.5 COL 98
    bt-sair AT ROW 1.5 COL 112
    SKIP(1)
    Pedidos.CodPedido  LABEL "Pedido"      AT ROW 4 COL 15
    Pedidos.DatPedido  LABEL "Data"        AT ROW 5 COL 15
    Pedidos.CodCliente LABEL "Cód. Cliente" AT ROW 6 COL 15
    cliente.NomCliente    LABEL "Nome Cliente"  VIEW-AS TEXT AT ROW 6 COL 50
    Pedidos.ValPedido  LABEL "Valor Total"   AT ROW 7 COL 15
    SKIP(1)
    br-itens AT ROW 9 COL 2
    SKIP(1)
    bt-add-item AT ROW 20 COL 5
    bt-mod-item AT ROW 20 COL 25
    bt-del-item AT ROW 20 COL 45
    WITH THREE-D VIEW-AS DIALOG-BOX TITLE "Cadastro de Pedidos" SIDE-LABELS.

/* ================== PROCEDURES ================== */
DEFINE BUFFER bProd FOR Produtos.
DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN Pedidos.DatPedido:SENSITIVE IN FRAME f-ped = pEnable
           Pedidos.CodCliente:SENSITIVE IN FRAME f-ped = pEnable.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN bt-pri:SENSITIVE IN FRAME f-ped = pEnable 
           bt-ant:SENSITIVE IN FRAME f-ped = pEnable
           bt-prox:SENSITIVE IN FRAME f-ped = pEnable 
           bt-ult:SENSITIVE IN FRAME f-ped = pEnable
           bt-add:SENSITIVE IN FRAME f-ped = pEnable 
           bt-del:SENSITIVE IN FRAME f-ped = pEnable
           bt-save:SENSITIVE IN FRAME f-ped = NOT pEnable 
           bt-canc:SENSITIVE IN FRAME f-ped = NOT pEnable
           bt-sair:SENSITIVE IN FRAME f-ped = pEnable
           bt-add-item:SENSITIVE IN FRAME f-ped = pEnable 
           bt-mod-item:SENSITIVE IN FRAME f-ped = pEnable
           bt-del-item:SENSITIVE IN FRAME f-ped = pEnable.
END PROCEDURE.

PROCEDURE piRecalculaTotal:
    DEFINE VARIABLE dTotal AS DECIMAL NO-UNDO.
    FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido: dTotal = dTotal + Itens.ValTotal. END.
    ASSIGN Pedidos.ValPedido = dTotal.
    DISPLAY Pedidos.ValPedido WITH FRAME f-ped.
END PROCEDURE.

PROCEDURE piMostra:
    IF AVAILABLE Pedidos THEN DO:
        DISPLAY Pedidos.CodPedido Pedidos.DatPedido Pedidos.CodCliente Pedidos.ValPedido cliente.NomCliente WITH FRAME f-ped.
        OPEN QUERY qItens FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido, EACH Produtos WHERE Produtos.CodProduto = Itens.CodProduto.
        br-itens:REFRESH().
    END.
    ELSE CLEAR FRAME f-ped ALL.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE Pedidos THEN rRecord = ROWID(Pedidos).
    OPEN QUERY qPed FOR EACH Pedidos, EACH cliente WHERE cliente.CodCliente = Pedidos.CodCliente.
    REPOSITION qPed TO ROWID rRecord NO-ERROR.
    RUN piMostra.
END PROCEDURE.

/* ================== ITEM HANDLING ================== */

ON CHOOSE OF bt-add-item, bt-mod-item DO:
    DEFINE VARIABLE iCodProd AS INTEGER NO-UNDO.
    DEFINE VARIABLE iQuant AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaxItem AS INTEGER NO-UNDO.
    DEFINE VARIABLE cActionItem AS CHARACTER NO-UNDO.
    
    ASSIGN cActionItem = IF SELF = bt-add-item THEN "add" ELSE "mod".

    IF cActionItem = "mod" THEN DO:
        GET CURRENT qItens.
        IF NOT AVAILABLE Itens THEN RETURN.
        ASSIGN iCodProd = Itens.CodProduto iQuant = Itens.NumQuantidade.
    END.

    RUN piManutItem (INPUT-OUTPUT iCodProd, INPUT-OUTPUT iQuant).

    IF iCodProd > 0 THEN DO:
        FIND FIRST bProd WHERE bProd.CodProduto = iCodProd NO-LOCK NO-ERROR.
        IF NOT AVAILABLE bProd THEN RETURN.

        DO TRANSACTION:
            IF cActionItem = "add" THEN DO:
                CREATE Itens.
                FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido: iMaxItem = MAX(iMaxItem, Itens.CodItem). END.
                ASSIGN Itens.CodItem = iMaxItem + 1.
            END.
            ELSE FIND CURRENT Itens EXCLUSIVE-LOCK.
            
            ASSIGN Itens.CodPedido = Pedidos.CodPedido
                   Itens.CodProduto = iCodProd
                   Itens.NumQuantidade = iQuant
                   Itens.ValTotal = iQuant * bProd.ValProduto.
        END.
        RUN piRecalculaTotal.
        br-itens:REFRESH().
    END.
END.

ON CHOOSE OF bt-del-item DO:
    GET CURRENT qItens.
    IF NOT AVAILABLE Itens THEN RETURN.
    DELETE Itens.
    RUN piRecalculaTotal.
    br-itens:REFRESH().
END.

PROCEDURE piManutItem:
    DEFINE INPUT-OUTPUT PARAMETER piCodProd AS INTEGER.
    DEFINE INPUT-OUTPUT PARAMETER piQuant AS INTEGER.

    DEFINE VARIABLE cCodProd AS CHARACTER.
    DEFINE VARIABLE cQuant AS CHARACTER.

    ASSIGN cCodProd = STRING(piCodProd) cQuant = STRING(piQuant).

    DEFINE FRAME f-item-dialog
        cCodProd LABEL "Cód. Produto"
        bProd.NomProduto LABEL "Nome"
        cQuant LABEL "Quantidade"
        WITH SIDE-LABELS VIEW-AS DIALOG-BOX TITLE "Item".

    ON VALUE-CHANGED OF cCodProd IN FRAME f-item-dialog DO:
        FIND bProd WHERE bProd.CodProduto = INTEGER(cCodProd) NO-LOCK NO-ERROR.
        DISPLAY bProd.NomProduto WITH FRAME f-item-dialog.
    END.

    UPDATE cCodProd cQuant WITH FRAME f-item-dialog.
    
    ASSIGN piCodProd = INTEGER(cCodProd) NO-ERROR
           piQuant = INTEGER(cQuant) NO-ERROR.
END PROCEDURE.

/* ================== MAIN TRIGGERS ================== */

ON CHOOSE OF bt-pri DO: GET FIRST qPed. RUN piMostra. END.
ON CHOOSE OF bt-ant DO: GET PREV qPed. RUN piMostra. END.
ON CHOOSE OF bt-prox DO: GET NEXT qPed. RUN piMostra. END.
ON CHOOSE OF bt-ult DO: GET LAST qPed. RUN piMostra. END.

ON CHOOSE OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
    CREATE Pedidos.
    ASSIGN Pedidos.CodPedido = NEXT-VALUE(seqPedido) Pedidos.DatPedido = TODAY.
    DISPLAY Pedidos.CodPedido Pedidos.DatPedido WITH FRAME f-ped.
END.

ON CHOOSE OF bt-del DO:
    IF NOT AVAILABLE Pedidos THEN RETURN.
    DO TRANSACTION:
        FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido: DELETE Itens. END.
        DELETE Pedidos.
    END.
    RUN piOpenQuery.
END.

ON CHOOSE OF bt-save DO:
    DEFINE VARIABLE iCodCli AS INTEGER NO-UNDO.
    ASSIGN iCodCli = INTEGER(Pedidos.CodCliente:SCREEN-VALUE IN FRAME f-ped) NO-ERROR.

    FIND FIRST cliente WHERE cliente.CodCliente = iCodCli NO-LOCK NO-ERROR.
    IF NOT AVAILABLE cliente THEN DO:
        MESSAGE "Cliente não encontrado!" VIEW-AS ALERT-BOX. RETURN.
    END.

    DO TRANSACTION:
        IF cAction = "add" THEN ASSIGN Pedidos.CodCliente = cliente.CodCliente.
        ELSE FIND CURRENT Pedidos EXCLUSIVE-LOCK.
        RUN piRecalculaTotal.
    END.
    RUN piHabilitaBotoes(TRUE).
    RUN piHabilitaCampos(FALSE).
    RUN piOpenQuery.
END.

ON CHOOSE OF bt-canc DO:
    IF cAction = "add" THEN DELETE Pedidos.
    RUN piHabilitaBotoes(TRUE).
    RUN piHabilitaCampos(FALSE).
    RUN piMostra.
END.

/* ================== INITIALIZATION ================== */

ENABLE ALL WITH FRAME f-ped.
RUN piOpenQuery.
RUN piHabilitaBotoes(TRUE).
RUN piHabilitaCampos(FALSE).

WAIT-FOR WINDOW-CLOSE OF FRAME f-ped.
