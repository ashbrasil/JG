#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} Ponto de entrada MA415MNU
Acrescentar botões no browse de orçamentos de vendas
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
@Fonte https://tdn.totvs.com/display/public/PROT/MA415MNU

Exemplo:
aadd(aRotina,{'TEXTO DO BOTÃO','NOME DA FUNÇÃO' , 0 , 3,0,NIL})
ONDE:
Parametros do array a Rotina:
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada (Chamada da rotina)
3. Reservado
4. Tipo de Transação a ser efetuada:
     1 - Pesquisa e Posiciona em um Banco de Dados
     2 - Simplesmente Mostra os Campos
     3 - Inclui registros no Bancos de Dados
     4 - Altera o registro corrente
     5 - Remove o registro corrente do Banco de Dados
5. Nivel de acesso
6. Habilita Menu Funcional

/*/

User Function MA415MNU()
    Local cKey

    cKey := SetKey(VK_F8, {|| U_ImpOrcPed()})    
    aadd(aRotina,{'Impressão JG'            , 'U_ImpOrcPed()' , 0, 1, 0, NiL})
    aAdd(aRotina,{"Consulta de Produtos JG" , "U_JGRT001()"   , 0, 1, 0, Nil} )


Return
