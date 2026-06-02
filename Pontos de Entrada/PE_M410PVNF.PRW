#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*______________________________________________________________________
   ¦Autor     ¦ Alfredo Sueira                      ¦ Data ¦ 12/02/26 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Bloqueia Emissão de Nota sem peso                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function M410PVNF()

    Local cAliasAnt  := Alias()
    Local aArea      := FWGetArea()
    Local lRet       := .T.
    Local cMsgValid  := ""
    // Local nItensPed  := 0
    // Local nSemOrdSep := 0
    // Local nOrdNaoFin := 0
    Local nItemMsg   := 0

    // Validação abrangente
    If !Empty(SC5->C5_NOTA)
        If "XXX" $ SC5->C5_NOTA
            cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") O pedido foi residuado. Não poderá ser faturado."
        Else
            cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") O pedido já foi faturado."
        EndIf
    EndIf

    // Validação somente para o tipo "N" (Normal)
    If AllTrim(SC5->C5_TIPO) == "N"

        If SC5->C5_PESOL   <= 0 .Or. ;
            SC5->C5_PBRUTO  <= 0 .Or. ;
            SC5->C5_VOLUME1 <= 0 .Or. ;
            Empty(AllTrim(SC5->C5_ESPECI1))

            cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") Os campos de peso, volume e espécie não foram preenchidos corretamente."
        EndIf

        // If FWIsAdmin() // Verificar sobre a liberação das validação deste bloco. Por enquanto, a validação será executada apenas para o grupo de administradores.
        //     nItensPed  := fItensPed(SC5->C5_FILIAL, SC5->C5_NUM)
        //     nSemOrdSep := fSemOrdSep(SC5->C5_FILIAL, SC5->C5_NUM)
        //     nOrdNaoFin := fOrdNaoFin(SC5->C5_FILIAL, SC5->C5_NUM)
        //     If nSemOrdSep = nItensPed
        //         cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") Não foram geradas ordens de separação para o pedido."
        //     ElseIf nSemOrdSep > 0 .And. nSemOrdSep < nItensPed
        //         cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") Há "+cValToChar(nSemOrdSep)+" item(ns) sem ordem de separação gerada."
        //     ElseIf nOrdNaoFin = nItensPed
        //         cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") A separação do pedido ainda não foi finalizada."
        //     ElseIf nOrdNaoFin > 0
        //         cMsgValid += IIf(Empty(cMsgValid),"",CRLF+CRLF)+cValToChar(++nItemMsg)+") Há "+cValToChar(nOrdNaoFin)+" item(ns) com separação ainda não finalizada."
        //     EndIf
        // EndIf

    EndIf

    If !Empty(cMsgValid)
        lRet := .F.
        If IsBlind()
            U_FLOGJG("Lista de validação para faturamento do pedido "+SC5->C5_FILIAL+"-"+SC5->C5_NUM+":"+CRLF+cMsgValid)
        Else
            FWAlertInfo("Lista de validação para faturamento do pedido <b>"+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"</b>:"+CRLF+CRLF+cMsgValid, "Validação para Faturamento")
        EndIf
    EndIf

    FWRestArea(aArea)
    DbSelectArea(cAliasAnt)

Return lRet

/*/{Protheus.doc} fItensPed
description
    Verifica a quantidade de itens existentes no pedido.
@type function
@version  
@author Jesus Ramos
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fItensPed(cFilPed, cNumPed)

    Local nCount  := 0
    Local cQuery  := ""

    cQuery := " SELECT " + CRLF
    cQuery += "     COUNT(*) AS NCOUNT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SC6.D_E_L_E_T_ <> '*' AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount

/*/{Protheus.doc} fSemOrdSep
description
    Verifica a quantidade de itens do pedido que não possuem ordem de separação gerada.
@type function
@version  
@author Jesus Ramos
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fSemOrdSep(cFilPed, cNumPed)

    Local nCount  := 0
    Local cQuery  := ""

    // Legendas da CB7 - Ordens de Separação - ACDA100:
    // aCores := {	{ "CB7->CB7_DIVERG == '1'", "DISABLE"  },;
    //             { "CB7->CB7_STATPA == '1'", "BR_CINZA" },;
    //             { "CB7->CB7_STATUS == '9'", "ENABLE"   },;
    //             { "CB7->CB7_STATUS $ '12345678'","BR_AMARELO" },;
    //             { "CB7->CB7_STATUS == '0'", "BR_AZUL"  } }

    cQuery := " SELECT " + CRLF
    cQuery += "     COUNT(*) AS NCOUNT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SC6.D_E_L_E_T_ <> '*' AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" " + CRLF
    cQuery += "     AND NOT EXISTS(" + CRLF
    cQuery += "         SELECT " + CRLF
    cQuery += "             1 " + CRLF
    cQuery += "         FROM " + CRLF
    cQuery += "             "+RetSqlName("CB8")+" CB8 " + CRLF
    cQuery += "             INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "                 AND CB7.CB7_FILIAL = CB8.CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7.CB7_PEDIDO = CB8.CB8_PEDIDO " + CRLF
    cQuery += "         WHERE " + CRLF
    cQuery += "             CB8.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "             AND CB8.CB8_FILIAL = SC6.C6_FILIAL AND CB8.CB8_PEDIDO = SC6.C6_NUM AND CB8.CB8_ITEM = SC6.C6_ITEM " + CRLF
    cQuery += "     ) " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount

/*/{Protheus.doc} fOrdNaoFin
description
    Verifica a quantidade de itens do pedido que possuem ordem de separação gerada mas não finalizada.
@type function
@version  
@author Jesus Ramos
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fOrdNaoFin(cFilPed, cNumPed)
    cQuery := " SELECT " + CRLF
    cQuery += "     COUNT(*) AS NCOUNT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SC6.D_E_L_E_T_ <> '*' AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" " + CRLF
    cQuery += "     AND NOT EXISTS(" + CRLF
    cQuery += "         SELECT DISTINCT " + CRLF
    cQuery += "             1 " + CRLF
    cQuery += "         FROM " + CRLF
    cQuery += "             "+RetSqlName("CB8")+" CB8 " + CRLF
    cQuery += "             INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "                 AND CB7.CB7_FILIAL = CB8.CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7.CB7_PEDIDO = CB8.CB8_PEDIDO AND CB7.CB7_STATUS = '9' " + CRLF
    cQuery += "         WHERE " + CRLF
    cQuery += "             CB8.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "             AND CB8.CB8_FILIAL = SC6.C6_FILIAL AND CB8.CB8_PEDIDO = SC6.C6_NUM AND CB8.CB8_ITEM = SC6.C6_ITEM " + CRLF
    cQuery += "     ) " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount
