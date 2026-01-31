#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} Ponto de entrada CRM980MDef
Acrescentar botões no browse de clientes SA1
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/

User Function CRM980MDef()
    Local aRotina := {}
    Local cKey
    cKey := SetKey(VK_F8, {|| U_PesqDina()})
    //----------------------------------------------------------------------------------------------------------
    // [n][1] - Nome da Funcionalidade
    // [n][2] - Função de Usuário
    // [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
    // [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
    //----------------------------------------------------------------------------------------------------------
    aAdd(aRotina,{"Pesquisa Dinamica","U_PesqDina()",1,0})
    
Return( aRotina )
