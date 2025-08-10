/* Cadastro de Cidades */
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

DEFINE QUERY qCid FOR cidades SCROLLING.

DEFINE BUFFER bCliente FOR cliente. /* Para validacao */

DEFINE FRAME f-cid
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
    cidades.CodCidade LABEL "Código" AT ROW 4 COL 15
    cidades.NomCidade LABEL "Cidade" AT ROW 5 COL 15
    cidades.CodUF     LABEL "UF"     AT ROW 6 COL 15
    WITH SIDE-LABELS THREE-D
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Cidades".

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
       bt-pri:SENSITIVE IN FRAME f-cid  = pEnable
       bt-ant:SENSITIVE IN FRAME f-cid  = pEnable
       bt-prox:SENSITIVE IN FRAME f-cid = pEnable
       bt-ult:SENSITIVE IN FRAME f-cid  = pEnable
       bt-sair:SENSITIVE IN FRAME f-cid = pEnable
       bt-add:SENSITIVE IN FRAME f-cid  = pEnable
       bt-mod:SENSITIVE IN FRAME f-cid  = pEnable
       bt-del:SENSITIVE IN FRAME f-cid  = pEnable
       bt-save:SENSITIVE IN FRAME f-cid = NOT pEnable
       bt-canc:SENSITIVE IN FRAME f-cid = NOT pEnable.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
        cidades.NomCidade:SENSITIVE IN FRAME f-cid = pEnable
        cidades.CodUF:SENSITIVE IN FRAME f-cid     = pEnable.
END PROCEDURE.

PROCEDURE piMostra:
    IF AVAILABLE cidades THEN
        DISPLAY cidades.CodCidade cidades.NomCidade cidades.CodUF WITH FRAME f-cid.
    ELSE
        CLEAR FRAME f-cid ALL.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE cidades THEN
        rRecord = ROWID(cidades).

    OPEN QUERY qCid FOR EACH cidades.
    REPOSITION qCid TO ROWID rRecord NO-ERROR.
    RUN piMostra.
END PROCEDURE.

ON CHOOSE OF bt-pri IN FRAME f-cid DO:
    GET FIRST qCid.
    RUN piMostra.
END.

ON CHOOSE OF bt-ant IN FRAME f-cid DO:
    GET PREV qCid.
    RUN piMostra.
END.

ON CHOOSE OF bt-prox IN FRAME f-cid DO:
    GET NEXT qCid.
    RUN piMostra.
END.

ON CHOOSE OF bt-ult IN FRAME f-cid DO:
    GET LAST qCid.
    RUN piMostra.
END.

ON CHOOSE OF bt-add IN FRAME f-cid DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
    
    CREATE cidades.
    ASSIGN
        cidades.CodCidade = NEXT-VALUE(seqCidade).
    DISPLAY cidades.CodCidade WITH FRAME f-cid.
    cidades.NomCidade:SCREEN-VALUE IN FRAME f-cid = "".
    cidades.CodUF:SCREEN-VALUE IN FRAME f-cid = "".
END.

ON CHOOSE OF bt-mod IN FRAME f-cid DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
END.

ON CHOOSE OF bt-del IN FRAME f-cid DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    FIND FIRST bCliente WHERE bCliente.CodCidade = cidades.CodCidade NO-LOCK NO-ERROR.
    IF AVAILABLE(bCliente) THEN DO:
        MESSAGE "Não é possivel eliminar a cidade, pois ela está¡ sendo utilizada por um cliente." VIEW-AS ALERT-BOX.
        RETURN.
    END.

    MESSAGE "Confirma a eliminação da cidade" cidades.NomCidade "?"
        UPDATE lConf
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".

    IF lConf THEN DO:
        DELETE cidades.
        RUN piOpenQuery.
    END.
END.

ON CHOOSE OF bt-save IN FRAME f-cid DO:
   DO TRANSACTION:
       IF cAction = "mod" THEN DO:
           FIND CURRENT cidades EXCLUSIVE-LOCK.
       END.

       ASSIGN
          cidades.NomCidade = cidades.NomCidade:SCREEN-VALUE IN FRAME f-cid
          cidades.CodUF     = cidades.CodUF:SCREEN-VALUE IN FRAME f-cid.
   END. /* TRANSACTION */

   RUN piHabilitaBotoes(TRUE).
   RUN piHabilitaCampos(FALSE).
   RUN piOpenQuery.
END.

ON CHOOSE OF bt-canc IN FRAME f-cid DO:
    IF cAction = "add" THEN
        DELETE cidades.

    RUN piHabilitaBotoes(TRUE).
    RUN piHabilitaCampos(FALSE).
    RUN piMostra.
END.

ENABLE ALL WITH FRAME f-cid.

RUN piOpenQuery.
RUN piHabilitaBotoes(TRUE).
RUN piHabilitaCampos(FALSE).

WAIT-FOR WINDOW-CLOSE OF FRAME f-cid.
