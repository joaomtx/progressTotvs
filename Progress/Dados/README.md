# Projeto Hamburgueria XTudo

Sistema de gestão para a Hamburgueria XTudo, desenvolvido em Progress OpenEdge. O sistema controla o cadastro de clientes, produtos, cidades e a realização de pedidos.

## Tecnologias

*   Progress OpenEdge

## Funcionalidades

O sistema é composto pelos seguintes módulos:

*   **Cadastros:**
    *   [x] Cidades
    *   [ ] Produtos
    *   [ ] Clientes
    *   [ ] Pedidos e Itens
*   **Relatórios:**
    *   [ ] Relatório de Clientes
    *   [ ] Relatório de Pedidos
*   **Exportação:**
    *   [ ] Exportação de dados em JSON e CSV para integração.

## Estrutura do Banco de Dados

*   **Banco de Dados:** `xtudo.db`
*   **Tabelas Principais:**
    *   `Cidades`: Armazena as cidades para os endereços dos clientes.
    *   `Clientes`: Cadastro de clientes da hamburgueria.
    *   `Produtos`: Cadastro dos produtos vendidos.
    *   `Pedidos`: Registra os pedidos dos clientes.
    *   `Itens`: Detalha os produtos de cada pedido.
*   **Sequências:**
    *   `SeqCidade`
    *   `SeqCliente`
    *   `SeqProduto`
    `SeqPedido`

## Como Executar o Projeto

1.  **Pré-requisitos:** Ter um ambiente Progress OpenEdge configurado.
2.  **Banco de Dados:**
    *   Certifique-se de que o banco de dados `xtudo.db` está localizado no diretório `C:\Dados`.
    *   Conecte-se ao banco de dados através do Data Administration ou via código.
3.  **Execução:**
    *   Abra o Procedure Editor.
    *   Execute o arquivo `C:\Dados\MenuPrincipal.p` para iniciar o sistema.
