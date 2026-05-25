#include "totvs.ch"

User Function PEDPARCIAL()
    Local nQtdItem  := 0
    Local nQtdFat   := 0
    Local nQtdRes   := 0
    Local lParcial  := .F.
    Local aArea       := GetArea()
	Local aAreaSC5    := SC5->(FWGetArea())

    // Pedido Faturado Parcial
    SC6->(DbSetOrder(1))
    SC6->(DbSeek(xFilial("SC6",SC5->C5_FILIAL)+SC5->C5_NUM))
    While SC6->( !Eof() .And. C6_FILIAL+C6_NUM == xFilial("SC6",SC5->C5_FILIAL)+SC5->C5_NUM )
        nQtdItem += SC6->C6_QTDVEN
        If SC6->C6_QTDENT > 0
            nQtdFat += SC6->C6_QTDENT
        EndIf
        If Alltrim(SC6->C6_BLQ) == "R"
            nQtdRes += SC6->C6_QTDVEN - SC6->C6_QTDENT
        EndIf
        SC6->(DbSkip())
    EndDo

    lParcial := nQtdFat > 0 .And. (nQtdFat+nQtdRes) < nQtdItem

    FWRestArea(aAreaSC5)
	RestArea(aArea)
REturn lParcial
