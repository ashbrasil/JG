#INCLUDE "TOTVS.CH"

#DEFINE P_MARCA     1
#DEFINE P_PRODUTO   2
#DEFINE P_DESCRICAO 3
#DEFINE P_VALOR     4

/*/{Protheus.doc} User Function JGRT005
    Rotina responsável por mostrar o grid das últimas 3 (três) compras do produto informado, pelo cliente da operação.
    Utilizado no gatilho LR_PRODUTO -> LR_ITEM
    @type   Function
    @author Jesus Ramos
    @since 20/01/2026
    /*/
User Function JGRT005(_ItemPos)

    Local aArea		:= FwGetArea()

    // Local cPosITEM  := ""
    Local nSav		:= N //Guarda posição da linha do produto.
    // Local nPosItem 	:= GdFieldPos("LR_ITEM")

    DEFAULT _ItemPos := ""

    // cPosITEM := aCols[N,nPosItem]
    // If EMPTY( _ItemPos )
    //     _ItemPos := cPosITEM
    // EndIf

    N := nSav //Restaura posição da linha do produto.

    U_JGRT006(_ItemPos) //Últimas vendas do produto para o cliente.
    N := nSav //Restaura posição da linha do produto.
    //Fim das chamadas

    // N := nSav //Restaura posição da linha do produto.

    FwRestArea(aArea)

    // If oGetTlv:oBrowse:nAt <> N
    //     oGetTlv:oBrowse:nAt := N
    // EndIf

Return(.T.)
