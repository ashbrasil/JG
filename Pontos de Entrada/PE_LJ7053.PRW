#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} Ponto de entrada MA415MNU
Acrescentar botões no browse de orçamentos de vendas
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/

User Function LJ7053()
    Local cKey
    Local aRotina := {}

    cKey := SetKey(VK_F8, {|| U_ImpOrcPed()})    

    AAdd(aRotina,{"JG - Impressão do Orçamento",        "U_ImpOrcPed()" , 0 , 1, NIL, .F.})
    If FindFunction("U_JGRT010")
        AAdd(aRotina,{'JG - Liberação p/ Transferência',    "U_JGRT010()"   , 0 , 4, NIL, .F.})
    EndIf

Return aRotina
