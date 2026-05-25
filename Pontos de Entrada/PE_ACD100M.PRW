#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} Ponto de entrada MA410MNU
Acrescentar botões no browse de pedidos de vendas
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/

User Function ACD100M()
    Local cKey
    Local nPosImp   := aScan(aRotina,{|X| X[2] == 'ACDA100Re'})

    cKey := SetKey(VK_F8, {|| U_RelMapSe()})    
    //aadd(aRotina,{'Mapa de Separação','U_RelMapSe()' , 0 , 1,0,NIL})
    aRotina[nPosImp][2] := "U_RelMapSe()"

Return
