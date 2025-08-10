/* Cadastro de Clientes */
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

DEFINE QUERY qCli FOR cliente SCROLLING.

/* Buffers para validacao */
DEFINE BUFFER bCid FOR cidades.
DEFINE BUFFER bPed FOR pedidos.

DEFINE FRAME f-cli
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
    cliente.CodCliente LABEL "Codigo"    AT ROW 4 COL 15
    cliente.NomCliente LABEL "Nome"      AT ROW 5 COL 15
    cliente.CodEndereco LABEL "Endereço"  AT ROW 6 COL 15
    cliente.CodCidade  LABEL "Cod. Cidade" AT ROW 7 COL 15
    cliente.Observacao LABEL "Observação" AT ROW 8 COL 15 VIEW-AS EDITOR SIZE 40 BY 3
    WITH SIDE-LABELS THREE-D
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Clientes".

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
       bt-pri:SENSITIVE IN FRAME f-cli  = pEnable
       bt-ant:SENSITIVE IN FRAME f-cli  = pEnable
       bt-prox:SENSITIVE IN FRAME f-cli = pEnable
       bt-ult:SENSITIVE IN FRAME f-cli  = pEnable
       bt-sair:SENSITIVE IN FRAME f-cli = pEnable
       bt-add:SENSITIVE IN FRAME f-cli  = pEnable
       bt-mod:SENSITIVE IN FRAME f-cli  = pEnable
       bt-del:SENSITIVE IN FRAME f-cli  = pEnable
       bt-save:SENSITIVE IN FRAME f-cli = NOT pEnable
       bt-canc:SENSITIVE IN FRAME f-cli = NOT pEnable.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    ASSIGN
        cliente.NomCliente:SENSITIVE IN FRAME f-cli = pEnable
        cliente.CodEndereco:SENSITIVE IN FRAME f-cli = pEnable
        cliente.CodCidade:SENSITIVE IN FRAME f-cli  = pEnable
        cliente.Observacao:SENSITIVE IN FRAME f-cli = pEnable.
END PROCEDURE.

PROCEDURE piMostra:
    IF AVAILABLE cliente THEN
        DISPLAY cliente.CodCliente cliente.NomCliente cliente.CodEndereco cliente.CodCidade cliente.Observacao WITH FRAME f-cli.
    ELSE
        CLEAR FRAME f-cli ALL.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE cliente THEN
        rRecord = ROWID(cliente).

    OPEN QUERY qCli FOR EACH cliente.
    REPOSITION qCli TO ROWID rRecord NO-ERROR.
    RUN piMostra.
END PROCEDURE.

ON CHOOSE OF bt-pri IN FRAME f-cli DO: GET FIRST qCli. RUN piMostra. END.
ON CHOOSE OF bt-ant IN FRAME f-cli DO: GET PREV qCli. RUN piMostra. END.
ON CHOOSE OF bt-prox IN FRAME f-cli DO: GET NEXT qCli. RUN piMostra. END.
ON CHOOSE OF bt-ult IN FRAME f-cli DO: GET LAST qCli. RUN piMostra. END.

ON CHOOSE OF bt-add IN FRAME f-cli DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
    
    CREATE cliente.
    ASSIGN
        cliente.CodCliente = NEXT-VALUE(seqCliente).
    DISPLAY cliente.CodCliente WITH FRAME f-cli.
    
    /* Limpa campos da tela */
    ASSIGN
        cliente.NomCliente:SCREEN-VALUE IN FRAME f-cli = ""
        cliente.CodEndereco:SCREEN-VALUE IN FRAME f-cli = ""
        cliente.CodCidade:SCREEN-VALUE IN FRAME f-cli = "0"
        cliente.Observacao:SCREEN-VALUE IN FRAME f-cli = "".
END.

ON CHOOSE OF bt-mod IN FRAME f-cli DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes(FALSE).
    RUN piHabilitaCampos(TRUE).
END.

ON CHOOSE OF bt-del IN FRAME f-cli DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    FIND FIRST bPed WHERE bPed.CodCliente = cliente.CodCliente NO-LOCK NO-ERROR.
    IF AVAILABLE(bPed) THEN DO:
        MESSAGE "Não é possivel eliminar o cliente, pois ele possui pedidos." VIEW-AS ALERT-BOX.
        RETURN.
    END.

    MESSAGE "Confirma a eliminação do cliente" cliente.NomCliente "?" UPDATE lConf
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".

    IF lConf THEN DO:
        DELETE cliente.
        RUN piOpenQuery.
    END.
END.

ON CHOOSE OF bt-save IN FRAME f-cli DO:
   /* Valida se a cidade existe */
   DEFINE VARIABLE iCodCidade AS INTEGER NO-UNDO.
   ASSIGN iCodCidade = INTEGER(cliente.CodCidade:SCREEN-VALUE IN FRAME f-cli).
   
   FIND FIRST bCid WHERE bCid.CodCidade = iCodCidade NO-LOCK NO-ERROR.
   IF NOT AVAILABLE(bCid) THEN DO:
       MESSAGE "Código da Cidade não encontrado!" VIEW-AS ALERT-BOX.
       RETURN.
   END.

   DO TRANSACTION:
       IF cAction = "mod" THEN DO:
           FIND CURRENT cliente EXCLUSIVE-LOCK.
       END.

       ASSIGN
          cliente.NomCliente  = cliente.NomCliente:SCREEN-VALUE IN FRAME f-cli
          cliente.CodEndereco = cliente.CodEndereco:SCREEN-VALUE IN FRAME f-cli
          cliente.CodCidade   = iCodCidade
          cliente.Observacao  = cliente.Observacao:SCREEN-VALUE IN FRAME f-cli.
   END. /* TRANSACTION */

   RUN piHabilitaBotoes(TRUE).
   RUN piHabilitaCampos(FALSE).
   RUN piOpenQuery.
END.

ON CHOOSE OF bt-canc IN FRAME f-cli DO:
    IF cAction = "add" THEN
        DELETE cliente.

    RUN piHabilitaBotoes(TRUE).
    RUN piHabilitaCampos(FALSE).
    RUN piMostra.
END.

ENABLE ALL WITH FRAME f-cli.

RUN piOpenQuery.
RUN piHabilitaBotoes(TRUE).
RUN piHabilitaCampos(FALSE).

WAIT-FOR WINDOW-CLOSE OF FRAME f-cli.
