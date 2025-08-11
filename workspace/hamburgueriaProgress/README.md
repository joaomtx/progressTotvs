# Hamburgueria XTudo

Este é um projeto de sistema de gestão para uma hamburgueria, desenvolvido como trabalho final para o treinamento de Progress OpenEdge.

## Funcionalidades

O sistema permite o gerenciamento completo das operações de uma hamburgueria, incluindo:

*   **Cadastro de Cidades:** Gerenciamento de cidades, com validação para evitar exclusão de cidades em uso.
*   **Cadastro de Clientes:** Gerenciamento de clientes, com validação de cidade e impedimento de exclusão se houver pedidos associados.
*   **Cadastro de Produtos:** Gerenciamento de produtos, com validação para evitar exclusão se houver itens de pedido associados.
*   **Cadastro de Pedidos e Itens:** Criação e gerenciamento de pedidos, incluindo a adição e remoção de itens, cálculo automático do valor total e validações de cliente e produto.
*   **Relatórios:** Geração de relatórios em formato texto (.txt), CSV (.csv) e JSON (.json) para Clientes, Cidades, Produtos e Pedidos.

## Tecnologias Utilizadas

*   **Linguagem:** Progress OpenEdge ABL
*   **Banco de Dados:** Progress OpenEdge Database (`xtudo.db`)

## Configuração e Execução

Para configurar e executar o projeto:

1.  **Clone o Repositório:**
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd Hamburgueria-XTudo
    ```
2.  **Configuração do Banco de Dados:**
    Certifique-se de que o banco de dados `xtudo.db` esteja configurado e acessível. O projeto espera que ele esteja no caminho `C:\Dados\xtudo.db` ou que o ambiente Progress esteja configurado para encontrá-lo.
    *(Nota: Durante o desenvolvimento, os arquivos .p foram testados com o banco de dados em `C:\Users\Joao Pedro\Progress\Dados\xtudo.db`.)*
3.  **Compilação:**
    Compile todos os arquivos `.p` localizados na pasta `C:\Users\Joao Pedro\Progress\Dados\` usando o compilador Progress OpenEdge.
    Exemplo (via linha de comando Progress):
    ```abl
    COMPILE C:\Users\Joao Pedro\Progress\Dados\cad-cidades.p.
    COMPILE C:\Users\Joao Pedro\Progress\Dados\cad-clientes.p.
    COMPILE C:\Users\Joao Pedro\Progress\Dados\cad-produtos.p.
    COMPILE C:\Users\Joao Pedro\Progress\Dados\cad-pedidos.p.
    COMPILE C:\Users\Joao Pedro\Progress\Dados\relatorios.p.
    COMPILE C:\Users\Joao Pedro\Progress\Dados\MenuPrincipal.p.
    ```
4.  **Execução:**
    Após a compilação, execute o programa principal:
    ```abl
    RUN C:\Users\Joao Pedro\Progress\Dados\MenuPrincipal.p.
    ```

## Estrutura do Banco de Dados

O banco de dados `xtudo.db` possui as seguintes tabelas:

*   **Cidades:**
    *   `CodCidade` (Integer, Primary Key)
    *   `NomCidade` (Character)
    *   `CodUF` (Character)

*   **Clientes:**
    *   `CodCliente` (Integer, Primary Key)
    *   `NomCliente` (Character)
    *   `CodEndereco` (Character)
    *   `CodCidade` (Integer, Foreign Key para Cidades)
    *   `Observacao` (Character)

*   **Produtos:**
    *   `CodProduto` (Integer, Primary Key)
    *   `NomProduto` (Character)
    *   `ValProduto` (Decimal)

*   **Pedidos:**
    *   `CodPedido` (Integer, Primary Key)
    *   `DatPedido` (Date)
    *   `CodCliente` (Integer, Foreign Key para Clientes)
    *   `ValPedido` (Decimal)
    *   `Observacao` (Character)

*   **Itens:**
    *   `CodPedido` (Integer, Primary Key, Foreign Key para Pedidos)
    *   `CodItem` (Integer, Primary Key)
    *   `CodProduto` (Integer, Foreign Key para Produtos)
    *   `NumQuantidade` (Integer)
    *   `ValTotal` (Decimal)

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## Licença 

Este projeto está licenciado sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
