/* ===============================
   Programa: menu-principal.p
   Autor: João Pedro & Sarah Dev
   Descrição: Menu principal do sistema X-Tudo Hamburgueria
   =============================== */

CURRENT-WINDOW:WIDTH = 80.
CURRENT-WINDOW:HEIGHT = 20.

DEF BUTTON bt-cidades LABEL "Cadastro de Cidades".
DEF BUTTON bt-produtos LABEL "Cadastro de Produtos".
DEF BUTTON bt-clientes LABEL "Cadastro de Clientes".
DEF BUTTON bt-pedidos LABEL "Pedidos".
DEF BUTTON bt-relatorios LABEL "Relatórios".
DEF BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

/* FRAME DO MENU */
DEF FRAME f-menu
    SKIP(1)
    bt-cidades AT 20
    bt-produtos AT 20
    bt-clientes AT 20
    bt-pedidos AT 20
    bt-relatorios AT 20
    bt-sair AT 20
    WITH NO-LABELS CENTERED THREE-D
    VIEW-AS DIALOG-BOX   TITLE "MENU PRINCIPAL - X-TUDO HAMBURGUERIA"
    SIZE 60 BY 15.

/* ===== EVENTOS DOS BOTÕES ===== */

ON CHOOSE OF bt-cidades DO:
    RUN cad-cidades.p.
END.

ON CHOOSE OF bt-produtos DO:
    RUN cad-produtos.p.
END.

ON CHOOSE OF bt-clientes DO:
    RUN cad-clientes.p.
END.

ON CHOOSE OF bt-pedidos DO:
    RUN cad-pedidos.p.
END.

ON CHOOSE OF bt-relatorios DO:
    RUN relatorios.p.
END.

ON CHOOSE OF bt-sair DO:
    MESSAGE "Deseja realmente sair do sistema?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE lResp AS LOGICAL.
    IF lResp = YES THEN
        APPLY "END-ERROR" TO SELF.
END.

/* ===== INICIALIZAÇÃO ===== */
ENABLE bt-cidades bt-produtos bt-clientes bt-pedidos bt-relatorios bt-sair
    WITH FRAME f-menu.

WAIT-FOR ENDKEY OF FRAME f-menu.
