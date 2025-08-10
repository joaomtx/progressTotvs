/* ===============================
   Programa: relatorios.p
   Autor: João Pedro & Sarah Dev
   Descrição: Relatórios gerais do sistema X-Tudo Hamburgueria
   =============================== */

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

/* ==== BOTÕES ==== */
DEF BUTTON bt-clientes LABEL "Relatório Clientes".
DEF BUTTON bt-cidades  LABEL "Relatório Cidades".
DEF BUTTON bt-produtos LABEL "Relatório Produtos".
DEF BUTTON bt-pedidos  LABEL "Relatório Pedidos".
DEF BUTTON bt-voltar   LABEL "Voltar" AUTO-ENDKEY.

/* ==== FRAME ==== */
DEF FRAME f-rel
    bt-clientes AT ROW 2 COL 5
    bt-cidades  AT ROW 3 COL 5
    bt-produtos AT ROW 4 COL 5
    bt-pedidos  AT ROW 5 COL 5
    bt-voltar   AT ROW 7 COL 5
    WITH NO-LABELS CENTERED THREE-D
    VIEW-AS DIALOG-BOX TITLE "RELATÓRIOS - X-TUDO HAMBURGUERIA"
    SIZE 40 BY 15.

/* ==== GERA TXT ==== */
PROCEDURE geraTXT:
    DEFINE INPUT PARAMETER pTabela AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.

    ASSIGN cArq = SESSION:TEMP-DIRECTORY + pTabela + ".txt".
    OUTPUT TO VALUE(cArq).

    CASE pTabela:
        WHEN "Clientes" THEN DO:
            FOR EACH Clientes NO-LOCK:
                PUT UNFORMATTED Clientes.CodCliente " - " Clientes.NomCliente SKIP.
            END.
        END.
        WHEN "Cidades" THEN DO:
            FOR EACH Cidades NO-LOCK:
                PUT UNFORMATTED Cidades.CodCidade " - " Cidades.NomCidade SKIP.
            END.
        END.
        WHEN "Produtos" THEN DO:
            FOR EACH Produtos NO-LOCK:
                PUT UNFORMATTED Produtos.CodProduto " - " Produtos.NomProduto SKIP.
            END.
        END.
        WHEN "Pedidos" THEN DO:
            FOR EACH Pedidos NO-LOCK:
                PUT UNFORMATTED Pedidos.CodPedido " - " Pedidos.DatPedido SKIP.
            END.
        END.
    END CASE.

    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
END PROCEDURE.

/* ==== GERA CSV ==== */
PROCEDURE geraCSV:
    DEFINE INPUT PARAMETER pTabela AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.

    ASSIGN cArq = SESSION:TEMP-DIRECTORY + pTabela + ".csv".
    OUTPUT TO VALUE(cArq).

    CASE pTabela:
        WHEN "Clientes" THEN DO:
            PUT UNFORMATTED "CodCliente;Nome" SKIP.
            FOR EACH Clientes NO-LOCK:
                PUT UNFORMATTED Clientes.CodCliente ";" Clientes.NomCliente SKIP.
            END.
        END.
        WHEN "Cidades" THEN DO:
            PUT UNFORMATTED "CodCidade;NomCidade" SKIP.
            FOR EACH Cidades NO-LOCK:
                PUT UNFORMATTED Cidades.CodCidade ";" Cidades.NomCidade SKIP.
            END.
        END.
        WHEN "Produtos" THEN DO:
            PUT UNFORMATTED "CodProduto;NomeProduto;ValProduto" SKIP.
            FOR EACH Produtos NO-LOCK:
                PUT UNFORMATTED Produtos.CodProduto ";" Produtos.NomProduto ";" Produtos.ValProduto SKIP.
            END.
        END.
        WHEN "Pedidos" THEN DO:
            PUT UNFORMATTED "CodPedido;DatPedido;CodCliente" SKIP.
            FOR EACH Pedidos NO-LOCK:
                PUT UNFORMATTED Pedidos.CodPedido ";" Pedidos.DatPedido ";" Pedidos.CodCliente SKIP.
            END.
        END.
    END CASE.

    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
END PROCEDURE.

/* ==== GERA JSON ==== */
PROCEDURE geraJSON:
    DEFINE INPUT PARAMETER pTabela AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oObj AS JsonObject NO-UNDO.
    DEFINE VARIABLE aArr AS JsonArray  NO-UNDO.

    ASSIGN cArq = SESSION:TEMP-DIRECTORY + pTabela + ".json".
    aArr = NEW JsonArray().

    CASE pTabela:
        WHEN "Clientes" THEN DO:
            FOR EACH Clientes NO-LOCK:
                oObj = NEW JsonObject().
                oObj:Add("CodCliente", Clientes.CodCliente).
                oObj:Add("Nome", Clientes.NomCliente).
                aArr:Add(oObj).
            END.
        END.
        WHEN "Cidades" THEN DO:
            FOR EACH Cidades NO-LOCK:
                oObj = NEW JsonObject().
                oObj:Add("CodCidade", Cidades.CodCidade).
                oObj:Add("NomeCidade", Cidades.NomCidade).
                aArr:Add(oObj).
            END.
        END.
        WHEN "Produtos" THEN DO:
            FOR EACH Produtos NO-LOCK:
                oObj = NEW JsonObject().
                oObj:Add("CodProduto", Produtos.CodProduto).
                oObj:Add("NomeProduto", Produtos.NomProduto).
                oObj:Add("ValProduto", Produtos.ValProduto).
                aArr:Add(oObj). 
            END.
        END.
        WHEN "Pedidos" THEN DO:
            FOR EACH Pedidos NO-LOCK:
                oObj = NEW JsonObject().
                oObj:Add("CodPedido", Pedidos.CodPedido).
                oObj:Add("DataPedido", Pedidos.DataPedido).
                oObj:Add("CodCliente", Pedidos.CodCliente).
                aArr:Add(oObj).
            END.
        END.
    END CASE.

    aArr:WriteFile(cArq, TRUE, "UTF-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
END PROCEDURE.

/* ==== EVENTOS ==== */
ON CHOOSE OF bt-clientes DO:
    RUN geraTXT("Clientes").
    RUN geraCSV("Clientes").
    RUN geraJSON("Clientes").
END.

ON CHOOSE OF bt-cidades DO:
    RUN geraTXT("Cidades").
    RUN geraCSV("Cidades").
    RUN geraJSON("Cidades").
END.

ON CHOOSE OF bt-produtos DO:
    RUN geraTXT("Produtos").
    RUN geraCSV("Produtos").
    RUN geraJSON("Produtos").
END.

ON CHOOSE OF bt-pedidos DO:
    RUN geraTXT("Pedidos").
    RUN geraCSV("Pedidos").
    RUN geraJSON("Pedidos").
END.

/* ==== HABILITA TELA ==== */
ENABLE bt-clientes bt-cidades bt-produtos bt-pedidos bt-voltar
    WITH FRAME f-rel.

WAIT-FOR ENDKEY OF FRAME f-rel.
