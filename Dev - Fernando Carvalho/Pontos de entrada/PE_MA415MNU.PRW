#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} Ponto de entrada MA415MNU
Acrescentar botões no browse de orçamentos de vendas
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/

User Function MA415MNU()
    Local cKey

    cKey := SetKey(VK_F8, {|| U_ImpOrcPed()})    
    aadd(aRotina,{'Impressão JG'            , 'U_ImpOrcPed()' , 0, 1, 0, NiL})
    aAdd(aRotina,{"Consulta de Produtos JG" , "U_JGRT001()"   , 0, 4, 0, Nil} )


Return
