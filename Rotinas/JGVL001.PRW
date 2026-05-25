#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function JGVL001
description
    Totalizar os itens do pedido para uso no preenchimento do campo customizado C5_XVALOR, para apresentação no browse de pedidos.
@type user function
@author Jesus Ramos
@since 08/03/2026
@version P12
/*/
User Function JGVL001(cFilPed, cNumPed)
    Local cAliasAnt    := Alias()
    Local aArea        := FwGetArea()
    Local nTotalPedido := 0
    Local cQuery       := "" 

    Default cFilPed := IIf(Type("SC5->C5_FILIAL") == "C", SC5->C5_FILIAL, " ")
    Default cNumPed := IIf(Type("SC5->C5_NUM") == "C", SC5->C5_NUM, " ")

    cQuery := " SELECT " + CRLF
    cQuery += "     SUM(C6_VALOR) AS nTOTALPED " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     "+RetSqlDel("SC6")+" AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" "

    nTotalPedido := MpSysExecScalar(cQuery, "nTOTALPED")
    RestArea(aArea)
    DbSelectArea(cAliasAnt)

Return nTotalPedido
