/* Cadastro de Produtos */
CURRENT-WINDOW:WIDTH = 130.

DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Adicionar".
DEFINE BUTTON bt-mod LABEL "Modificar".
DEFINE BUTTON bt-del LABEL "Eliminar".
DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY qProd FOR Produtos SCROLLING.

/* Buffer para validacao */
DEFINE BUFFER bItens FOR Itens.

DEFINE FRAME f-prod
    /* Linha 1 */
    bt-pri  AT ROW 1.5 COL 2
    bt-ant  AT ROW 1.5 COL 10
    bt-prox AT ROW 1.5 COL 18
    bt-ult  AT ROW 1.5 COL 26
    bt-add  AT ROW 1.5 COL 38
    bt-mod  AT ROW 1.5 COL 52
    bt-del  AT ROW 1.5 COL 66
    /* Linha 2 */
    bt-save AT ROW 2.5 COL 2
    bt-canc AT ROW 2.5 COL 14
    bt-sair AT ROW 2.5 COL 28
    SKIP(1)
    Produtos.CodProduto LABEL "Código" AT ROW 4 COL 15
    Produtos.NomProduto LABEL "Nome"   AT ROW 5 COL 15 VIEW-AS FILL-IN SIZE 40 BY 1
    Produtos.ValProduto LABEL "Valor"  AT ROW 6 COL 15
    WITH SIDE-LABELS THREE-D
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Produtos".

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
       bt-pri:SENSITIVE IN FRAME f-prod  = pEnable
       bt-ant:SENSITIVE IN FRAME f-prod  = pEnable
       bt-prox:SENSITIVE IN FRAME f-prod = pEnable
       bt-ult:SENSITIVE IN FRAME f-prod  = pEnable
       bt-sair:SENSITIVE IN FRAME f-prod = pEnable
       bt-add:SENSITIVE IN FRAME f-prod  = pEnable
       bt-mod:SENSITIVE IN FRAME f-prod  = pEnable
       bt-del:SENSITIVE IN FRAME f-prod  = pEnable
       bt-save:SENSITIVE IN FRAME f-prod = NOT pEnable
       bt-canc:SENSITIVE IN FRAME f-prod = NOT pEnable.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
        Produtos.NomProduto:SENSITIVE IN FRAME f-prod = pEnable
        Produtos.ValProduto:SENSITIVE IN FRAME f-prod = pEnable.
END PROCEDURE.

PROCEDURE piMostra:
    IF AVAILABLE Produtos THEN
        DISPLAY Produtos.CodProduto Produtos.NomProduto Produtos.ValProduto WITH FRAME f-prod.
    ELSE
        CLEAR FRAME f-prod ALL.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE Produtos THEN
        rRecord = ROWID(Produtos).

    OPEN QUERY qProd FOR EACH Produtos.
    REPOSITION qProd TO ROWID rRecord NO-ERROR.
    RUN piMostra.
END PROCEDURE.

ON CHOOSE OF bt-pri IN FRAME f-prod DO: GET FIRST qProd. RUN piMostra. END.
ON CHOOSE OF bt-ant IN FRAME f-prod DO: GET PREV qProd. RUN piMostra. END.
ON CHOOSE OF bt-prox IN FRAME f-prod DO: GET NEXT qProd. RUN piMostra. END.
ON CHOOSE OF bt-ult IN FRAME f-prod DO: GET LAST qProd. RUN piMostra. END.

ON CHOOSE OF bt-add IN FRAME f-prod DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
    
    CREATE Produtos.
    ASSIGN
        Produtos.CodProduto = NEXT-VALUE(seqProduto).
    DISPLAY Produtos.CodProduto WITH FRAME f-prod.
    
    ASSIGN
        Produtos.NomProduto:SCREEN-VALUE IN FRAME f-prod = ""
        Produtos.ValProduto:SCREEN-VALUE IN FRAME f-prod = "0.00".
END.

ON CHOOSE OF bt-mod IN FRAME f-prod DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
END.

ON CHOOSE OF bt-del IN FRAME f-prod DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    FIND FIRST bItens WHERE bItens.CodProduto = Produtos.CodProduto NO-LOCK NO-ERROR.
    IF AVAILABLE(bItens) THEN DO:
        MESSAGE "Não é possivel eliminar o produto, pois ele está¡ sendo usado em um pedido." VIEW-AS ALERT-BOX.
        RETURN.
    END.

    MESSAGE "Confirma a eliminação do produto" Produtos.NomProduto "?" UPDATE lConf
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".

    IF lConf THEN DO:
        DELETE Produtos.
        RUN piOpenQuery.
    END.
END.

ON CHOOSE OF bt-save IN FRAME f-prod DO:
   DO TRANSACTION:
       IF cAction = "mod" THEN DO:
           FIND CURRENT Produtos EXCLUSIVE-LOCK.
       END.

       ASSIGN
          Produtos.NomProduto = Produtos.NomProduto:SCREEN-VALUE IN FRAME f-prod
          Produtos.ValProduto = DECIMAL(Produtos.ValProduto:SCREEN-VALUE IN FRAME f-prod).
   END. /* TRANSACTION */

   RUN piHabilitaBotoes(TRUE).
   RUN piHabilitaCampos(FALSE).
   RUN piOpenQuery.
END.

ON CHOOSE OF bt-canc IN FRAME f-prod DO:
    IF cAction = "add" THEN
        DELETE Produtos.

    RUN piHabilitaBotoes(TRUE).
    RUN piHabilitaCampos(FALSE).
    RUN piMostra.
END.

ENABLE ALL WITH FRAME f-prod.

RUN piOpenQuery.
RUN piHabilitaBotoes(TRUE).
RUN piHabilitaCampos(FALSE).

WAIT-FOR WINDOW-CLOSE OF FRAME f-prod.

