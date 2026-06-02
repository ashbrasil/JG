#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} JGUTILS

    Biblioteca de rotinas personalizadas do cliente.

@type function
@version  
@author Jesus Ramos
@since 05/05/2026
/*/
User Function JGUTILS()
Return

/*/{Protheus.doc} xfTipoDb
Função para retornar o tipo do banco de dadso apontado no server, para o ambiente.

@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@return variant, return_description
/*/
User Function xfTipoDb()
	// Local cEnvServer := GetEnvServer()
    Local cDBType    := Upper(GetSrvProfString("dbdataBase", ""))
	Local cRetDb     := ""

    // Ajuste o nome da seção conforme configurado no seu ambiente.
    // O nome da seção pode ser [MSSQL] ou [ORACLE] ou similar.

    If "ORACLE" $ cDBType
        cRetDb := "ORACLE"
    ElseIf "DB2" $ cDBType
        cRetDb := "DB2"
    ElseIf "POSTGRES" $ Upper(cDBType)
        cRetDb := "POSTGRES"
    ElseIf "INFORMIX" $ Upper(cDBType)
        cRetDb := "INFORMIX"
    ElseIf "SQLITE" $ Upper(cDBType)
        cRetDb := "SQLITE"
    ElseIf "MYSQL" $ Upper(cDBType)
        cRetDb := "MYSQL"
    ElseIf "MARIADB" $ Upper(cDBType)
        cRetDb := "MARIADB"
    ElseIf "MSSQL" $ Upper(cDBType)
        cRetDb := "MSSQL"
    Else
        cRetDb := "MSSQL"
    EndIf

Return cRetDb

/*/{Protheus.doc} xfOpConc
Função para retornar o operador de concatenação de strings conforme o tipo do banco de dados do ambiente.

@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@return variant, return_description
/*/
User Function xfOpConc()
	Local cOperador := "||" // Padrão ANSI SQL (PostGreSQL, Oracle, SQLite, Informix)

    If xfTipoDb() == "MSSQL"
        Return "+"
    EndIf

Return cOperador

/*/{Protheus.doc} U_xfConcSt
description
    Função para concatenar strings conforme o tipo do banco de dados do ambiente.
    Para bancos que utilizam o operador de concatenação "+", as strings serão concatenadas utilizando este operador.
    Para bancos que utilizam a função CONCAT, a função será construída utilizando a sintaxe adequada para cada banco.

@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@param aStr, array, param_description
@return variant, return_description
/*/
User Function xfConcSt(p_Str)
    Local cStrConc := ""
    Local cTipoDb  := U_xfTipoDb()
    Local lConcat  := (!Empty(cTipoDb) .And. cTipoDb+";" $ "MYSQL;MSSQL;")
    Local aStr     := {}
    Local x

    Default p_Str := ""

    If !Empty(cTipoDb)
        If ValType(p_Str) == "C" .And. !Empty(p_Str)
            aStr := StrTokArr2(p_Str, ",")
        ElseIf ValType(p_Str) == "A"
            aStr := p_Str
        EndIf
        If Len(aStr) > 0
            If lConcat
                cStrConc := "Concat("
                For x:=1 To Len(aStr)
                    If x > 1
                        cStrConc += ", "
                    EndIf
                    cStrConc += AllTrim(aStr[x])
                Next x
                cStrConc += ")"
            Else
                cStrConc := ""
                For x:=1 To Len(aStr)
                    If x > 1
                        cStrConc += " || "
                    EndIf
                    cStrConc += AllTrim(aStr[x])
                Next x
            EndIf
        EndIf
    EndIf

Return cStrConc

/*/{Protheus.doc} xfForFil
description
    Função para retornar o código e loja do fornecedor relacionado à filial informada, conforme cadastro na tabela SA2.

@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cFil, variant, param_description
@return variant, return_description
/*/
User Function xfForFil(_cFil)
    Local cAliasAnt  := Alias()
    Local aArea      := FWGetArea()
    Local aRetForFil := {}
    Local cQuery     := ""
    Local cAliasFor

	cQuery := " SELECT " + CRLF
	cQuery += "     A2_COD, A2_LOJA " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSqlName("SA2") + " SA2 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     " + RetSqlDel("SA2") + " " + CRLF
	cQuery += "     AND A2_FILIAL = " + ValToSql(FWxFilial("SA2")) + " " + CRLF
	cQuery += "     AND A2_FILTRF = " + ValToSql(_cFil) + " " + CRLF
	cAliasFor := MPSysOpenQuery(cQuery)

	If (cAliasFor)->(!Eof()) .And. !Empty((cAliasFor)->A2_COD) .And. !Empty((cAliasFor)->A2_LOJA)
        aRetForFil := { (cAliasFor)->A2_COD, (cAliasFor)->A2_LOJA }
    EndIf

    (cAliasFor)->(DbCloseArea())

    DbSelectArea(cAliasAnt)
    FWRestArea(aArea)

Return aRetForFil

/*/{Protheus.doc} xfFilFor
description
    Função para retornar o código da filial correspondente/relacionada ao código e loja do fornecedor informados, conforme cadastro na tabela SA2.
@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cCodFor, variant, param_description
@param _cLojFor, variant, param_description
@return variant, return_description
/*/
User Function xfFilFor(_cCodFor, _cLojFor)
    Local cAliasAnt  := Alias()
    Local aArea      := FWGetArea()
    Local cRetFilFor := {}
    Local cQuery     := ""
    Local cAliasFor

	cQuery := " SELECT " + CRLF
	cQuery += "     A2_FILTRF " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSqlName("SA2") + " SA2 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     " + RetSqlDel("SA2") + " " + CRLF
	cQuery += "     AND A2_FILIAL = " + ValToSql(FWxFilial("SA2")) + " " + CRLF
	cQuery += "     AND A2_COD    = " + ValToSql(_cCodFor) + " " + CRLF
	cQuery += "     AND A2_LOJA   = " + ValToSql(_cLojFor) + " " + CRLF
	cAliasFor := MPSysOpenQuery(cQuery)

	If (cAliasFor)->(!Eof()) .And. !Empty((cAliasFor)->A2_FILTRF)
        cRetFilFor := (cAliasFor)->A2_FILTRF
    EndIf

    (cAliasFor)->(DbCloseArea())

    DbSelectArea(cAliasAnt)
    FWRestArea(aArea)

Return cRetFilFor

/*/{Protheus.doc} xfCliFil
description
    Função para retornar o código e loja do cliente relacionado à filial informada, conforme cadastro na tabela SA1.

@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cFil, variant, param_description
@return variant, return_description
/*/
User Function xfCliFil(_cFil)
    Local cAliasAnt  := Alias()
    Local aArea      := FWGetArea()
    Local aRetCliFil := {}
    Local cQuery     := ""
    Local cAliasCli

	cQuery := " SELECT " + CRLF
	cQuery += "     A1_COD, A1_LOJA " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSqlName("SA1") + " SA1 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     " + RetSqlDel("SA1") + " " + CRLF
	cQuery += "     AND A1_FILIAL = " + ValToSql(FWxFilial("SA1")) + " " + CRLF
	cQuery += "     AND A1_FILTRF = " + ValToSql(_cFil) + " " + CRLF
	cAliasCli := MPSysOpenQuery(cQuery)

	If (cAliasCli)->(!Eof()) .And. !Empty((cAliasCli)->A1_COD)
        aRetCliFil := { (cAliasCli)->A1_COD, (cAliasCli)->A1_LOJA }
    EndIf

    (cAliasCli)->(DbCloseArea())

    DbSelectArea(cAliasAnt)
    FWRestArea(aArea)

Return aRetCliFil

/*/{Protheus.doc} xfFilCli
description
    Função para retornar o código da filial correspondente/relacionada ao código e loja do cliente informados, conforme cadastro na tabela SA1.
@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cCodCli, variant, param_description
@param _cLojCli, variant, param_description
@return variant, return_description
/*/
User Function xfFilCli(_cCodCli, _cLojCli)
    Local cAliasAnt  := Alias()
    Local aArea      := FWGetArea()
    Local cRetFilCli := {}
    Local cQuery     := ""
    Local cAliasCli

	cQuery := " SELECT " + CRLF
	cQuery += "     A1_FILTRF " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSqlName("SA1") + " SA1 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     " + RetSqlDel("SA1") + " " + CRLF
	cQuery += "     AND A1_FILIAL = " + ValToSql(FWxFilial("SA1")) + " " + CRLF
	cQuery += "     AND A1_COD    = " + ValToSql(_cCodCli) + " " + CRLF
	cQuery += "     AND A1_LOJA   = " + ValToSql(_cLojCli) + " " + CRLF
	cAliasCli := MPSysOpenQuery(cQuery)

	If (cAliasCli)->(!Eof()) .And. !Empty((cAliasCli)->A1_FILTRF)
        cRetFilCli := (cAliasCli)->A1_FILTRF
    EndIf

    (cAliasCli)->(DbCloseArea())

    DbSelectArea(cAliasAnt)
    FWRestArea(aArea)

Return cRetFilCli

/*/{Protheus.doc} fDsStTrf
description
	Essa função tem como finalidade retornar a descrição do status da transferência imediata no SIGALOJA - SL1/SLQ - Campo LQ_XMOVTRF/L1_XMOVTRF.
@type function
@version  
@author Jesus Ramos
@since 06/03/2026
@param cOriStatus, string, Indica se o status é de um orçamento (SL1) ou de um pedido de venda (SC5).
@param cStatusTrf, string, Status informado para interpretação/descrição.
@param lDescDet, logical, Indica se a descrição retornada deve ser detalhada (com informações adicionais sobre o status) ou resumida (apenas o status em si).
@return string, Descrição do status da transferência, conforme o status informado e o nível de detalhe solicitado.
/*/
User Function fDsStTrf( cOriStatus, cStatusTrf, lDescDet )
	Local cResStaTrf := "Status Indefinido"  // Descrição resumida/reduzida do status da transferência
	Local cDetStaTrf := "Status Indefinido." // Descrição detalhada do status da transferência

	Default lDescDet := .F.

    If cOriStatus == "O" // Status de Orçamento (SL1)
        Do Case
            Case cStatusTrf == JGTrOrNSA
                cResStaTrf := "Não se Aplica"
                cDetStaTrf := "Operação sem exigência de transferência imediata. A filial tem estoque próprio."
            Case cStatusTrf == JGTrOrEAb
                cResStaTrf := "Orçamento Em Aberto"
                cDetStaTrf := "Orçamento em aberto, em manutenção pelo vendedor. A transferência ainda não foi iniciada."
            Case cStatusTrf == JGTrOrIni
                cResStaTrf := "Transferência Iniciada"
                cDetStaTrf := "O processo de transferência já foi iniciado."
            Case cStatusTrf == JGTrOrPPS
                cResStaTrf := "PV Transf. Pend. Separação"
                cDetStaTrf := "O pedido de venda foi gerado, mas encontra-se pendente de separação."
            Case cStatusTrf == JGTrOrPPF
                cResStaTrf := "PV Transf. Pend. Faturamento"
                cDetStaTrf := "O pedido de venda está aguardando seu faturamento."
            Case cStatusTrf == JGTrOrNPA
                cResStaTrf := "NF Saída Pendente Autorização"
                cDetStaTrf := "A NF de saída foi gerada, mas ainda não foi autorizada pela SEFAZ."
            Case cStatusTrf == JGTrOrNPE
                cResStaTrf := "NF Pendente Entrada Destino"
                cDetStaTrf := "A NF de saída foi autorizada pela SEFAZ, mas ainda não foi lançada na filial solicitante."
            Case cStatusTrf == JGTrOrOK
                cResStaTrf := "Transferência Concluída"
                cDetStaTrf := "O processo de transferência foi concluído."
            Case cStatusTrf == JGTrOrExD
                cResStaTrf := "NF de Entrada excluída"
                cDetStaTrf := "A NF de entrada foi excluída na filial solicitante. O orçamento não poderá ser finalizado."
            Case cStatusTrf == JGTrOrExO
                cResStaTrf := "NF de Saída excluída"
                cDetStaTrf := "A NF de saída foi excluída na filial de origem."
            Case cStatusTrf == JGTrOrOS
                cResStaTrf := "PV não cancelado - O.S."
                cDetStaTrf := "O PV não foi cancelado - Existem Ordens de Separação vinculadas."
            Case cStatusTrf == JGTrOrCan
                cResStaTrf := "Transferência Cancelada"
                cDetStaTrf := 'O PV foi residuado e a transferência cancelada. O orçamento voltará para o status de <b>"Orçamento em Aberto"</b> e poderá ser editado normalmente.'
        EndCase
    ElseIf cOriStatus == "P" // Status de Pedido de Venda (SC5)
        Do Case
            Case cStatusTrf == JGTrPVNor
                cResStaTrf := "PV Normal"
                cDetStaTrf := "Pedido de Venda normal, não associado ao processo de transferência automática."
            Case cStatusTrf == JGTrPVPSp
                cResStaTrf := "PV Transf. Pend. Separação"
                cDetStaTrf := "O pedido de venda foi gerado, mas encontra-se pendente de separação."
            Case cStatusTrf == JGTrPVPFt
                cResStaTrf := "PV Transf. Pend. Faturamento"
                cDetStaTrf := "O pedido de venda está aguardando seu faturamento."
            Case cStatusTrf == JGTrPVNPA
                cResStaTrf := "NF Saída Pendente Autorização"
                cDetStaTrf := "A NF de saída foi gerada, mas ainda não foi autorizada pela SEFAZ."
            Case cStatusTrf == JGTrPVNPE
                cResStaTrf := "NF Pendente Entrada Destino"
                cDetStaTrf := "A NF de saída foi autorizada pela SEFAZ, mas ainda não foi lançada na filial solicitante."
            Case cStatusTrf == JGTrPVEPL
                cResStaTrf := "Entrada OK - Pendente Liberação do Estoque"
                cDetStaTrf := "A entrada foi efetuada na filial de destino, mas o estoque ainda não foi liberado para venda."
            Case cStatusTrf == JGTrPVOK
                cResStaTrf := "Transf. Concluída"
                cDetStaTrf := "O processo de transferência foi concluído."
            Case cStatusTrf == JGTrPVExD
                cResStaTrf := "NF de Entrada excluída"
                cDetStaTrf := "A NF de entrada foi excluída na filial solicitante."
            Case cStatusTrf == JGTrPVExO
                cResStaTrf := "NF de Saída excluída"
                cDetStaTrf := "A NF de saída foi excluída na filial de origem."
            Case cStatusTrf == JGTrPVOS
                cResStaTrf := "PV não cancelado - O.S."
                cDetStaTrf := "O PV não foi cancelado - Existem Ordens de Separação vinculadas."
            Case cStatusTrf == JGTrPVCan
                cResStaTrf := "Transferência Cancelada"
                cDetStaTrf := 'O PV foi residuado e a transferência cancelada. O orçamento voltará para o status de <b>"Orçamento em Aberto"</b> e poderá ser editado normalmente.'
        EndCase
    EndIf

Return IIf( lDescDet, cDetStaTrf, cResStaTrf )


/*/{Protheus.doc} fStTrfCB

	Essa função tem como finalidade retornar a lista de opções para o combobox dos campos L1_XMOVTRF e C5_XMOVTRF.

@type function
@version  
@author Jesus Ramos
@since 06/03/2026
@param cOrigem, string, Indica se o status é de um orçamento (SL1) ou de um pedido de venda (SC5).
/*/
User Function fStTrfCB(cOrigem)
	Local cCBox := "" // Lista de opções para a propriedade X3_CBOX dos campos de status da transferência (L1_XMOVTRF, C5_XMOVTRF).

    Default cOrigem := "P"

    If cOrigem == "O" // Status de Orçamento (SL1)
        cCBox +=     JGTrOrNSA+"=Não se Aplica"
        cCBox += ";"+JGTrOrEAb+"=Orçamento Em Aberto"
        cCBox += ";"+JGTrOrIni+"=Transferência Iniciada"
        cCBox += ";"+JGTrOrPPS+"=PV Transf. Pend. Separação"
        cCBox += ";"+JGTrOrPPF+"=PV Transf. Pend. Faturamento"
        cCBox += ";"+JGTrOrNPA+"=NF Saída Pendente Autorização"
        cCBox += ";"+JGTrOrNPE+"=NF Pendente Entrada Destino"
        cCBox += ";"+JGTrOrOK +"=Transferência Concluída"
        cCBox += ";"+JGTrOrExD+"=NF de Entrada excluída"
        cCBox += ";"+JGTrOrExO+"=NF de Saída excluída"
        cCBox += ";"+JGTrOrOS +"=PV não cancelado - OS"
        cCBox += ";"+JGTrOrCan+"=Transferência Cancelada"
    Else // Status de Pedido de Venda (SC5)
        cCBox +=     JGTrPVNor+"=PV Normal"
        cCBox += ";"+JGTrPVPSp+"=PV Transf. Pend. Separação"
        cCBox += ";"+JGTrPVPFt+"=PV Transf. Pend. Faturamento"
        cCBox += ";"+JGTrPVNPA+"=NF Saída Pendente Autorização"
        cCBox += ";"+JGTrPVNPE+"=NF Pendente Entrada Destino"
        cCBox += ";"+JGTrPVEPL+"=Entrada OK - Pendente Liberação do Estoque"
        cCBox += ";"+JGTrPVOK +"=Transferência Concluída"
        cCBox += ";"+JGTrPVExD+"=NF de Entrada excluída"
        cCBox += ";"+JGTrPVExO+"=NF de Saída excluída"
        cCBox += ";"+JGTrPVOS +"=PV não cancelado - OS"
        cCBox += ";"+JGTrPVCan+"=Transferência Cancelada"
    EndIf

Return cCBox

/*/{Protheus.doc} xfNfDest
Função para verificar se a nota de transferência já foi incluída na filial de destino, 
verificando se a nota existe na SF2 da loja de origem e se a mesma já foi incluída na SF1 da filial de destino.

@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cFil, variant, param_description
@param _cNota, variant, param_description
@param __cSerieNf, variant, param_description
@param _dEmis, variant, param_description
@return variant, return_description
/*/
User Function xfNfDest(_cFil, _cNota, __cSerieNf, _dEmis)

	Local cAliasAnt  := Alias()
	Local aArea      := FWGetArea()
	Local aAreaSF2   := SF2->(FWGetArea())
	Local aAreaSF1   := SF1->(FWGetArea())
	Local lRetorno   := .F.
	Local cFilCli    := ""
	Local aForFil	 := {}
	Local cChaveNota := ""

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(MsSeek(_cFil + _cNota + __cSerieNf)) .And. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == _cFil + _cNota + __cSerieNf .And. DToS(SF2->F2_EMISSAO) == _dEmis

		//Validação para notas de transferência entre filiais
		cFilCli := U_xfFilCli(SF2->F2_CLIENTE, SF2->F2_LOJA)
		aForFil := U_xfForFil(_cFil)

		If !Empty(cFilCli) .And. Len(aForFil) >= 2

			cChaveNota := cFilCli+SF2->(F2_DOC+F2_SERIE)+aForFil[1]+aForFil[2]
			DbSelectArea("SF1")
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(cChaveNota)) .And. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == cChaveNota
				lRetorno := .T.
			EndIf

		EndIf
	EndIf

	FWRestArea(aAreaSF1)
	FWRestArea(aAreaSF2)
	FWRestArea(aArea)
	DbSelectArea(cAliasAnt)

	FwFreeArray(aForFil)
	FwFreeArray(aAreaSF1)
	FwFreeArray(aAreaSF2)
	FwFreeArray(aArea)

Return(lRetorno)


/*/{Protheus.doc} xfNfOrig

    Função para pesquisar a existência da nota de entrada na filial de origem.

@type function
@version  
@author Jesus Ramos
@since 13/03/2026
@param _cFil, variant, param_description
@param _cNota, variant, param_description
@param __cSerieNf, variant, param_description
@param _dEmis, variant, param_description
@return variant, return_description
/*/
User Function xfNfOrig(_cFil, _cNota, __cSerieNf, _cFornecedor, _cLojaFor, _dEmis)

	Local cAliasAnt  := Alias()
	Local aArea      := FWGetArea()
	Local aAreaSF1   := SF1->(FWGetArea())
	Local aAreaSF2   := SF2->(FWGetArea())
	Local aAreaSC5   := SC5->(FWGetArea())
	Local aRetorno   := {"", "", 0, 0, ""} // 1 - Filial do Fornecedor, 2 - Cliente/Loja da Filial do Fornecedor, 3 - Recno da SC5, 4 - Recno da SF2, 5 - Armazém final da transferência
	Local cFilFor    := ""
	Local aCliFil	 := {}
	// Local cChaveNota := ""

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
	If SF1->(MsSeek(_cFil + _cNota + __cSerieNf + _cFornecedor + _cLojaFor)) .And.;
        SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == _cFil + _cNota + __cSerieNf + _cFornecedor + _cLojaFor .And. SF1->F1_EMISSAO == _dEmis

		//Validação para notas de transferência entre filiais
		cFilFor := U_xfFilFor(SF1->F1_FORNECE, SF1->F1_LOJA)
		aCliFil := U_xfCliFil(SF1->F1_FILIAL)

        aRetorno[1] := cFilFor
        aRetorno[2] := AClone(aCliFil)

		If !Empty(cFilFor) .And. Len(aCliFil) >= 2

            DbSelectArea("SC5")
            SC5->(DbOrderNickName("XNFSERCLLJ")) //C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI
            If SC5->(DbSeek(cFilFor+SF1->(F1_DOC+F1_SERIE)+aCliFil[1]+aCliFil[2])) ;
                    .And. SC5->(C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI) == cFilFor+SF1->(F1_DOC+F1_SERIE)+aCliFil[1]+aCliFil[2]
                aRetorno[3] := SC5->(Recno())
                aRetorno[5] := SC5->C5_XLOCFIN

                DbSelectArea("SF2")
                SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
                If SF2->(DbSeek(SC5->(C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI))) ;
                        .And. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SC5->(C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI)
                    aRetorno[4] := SF2->(Recno())
                EndIf

            EndIf

		EndIf
	EndIf

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSF2)
	FWRestArea(aAreaSF1)
	FWRestArea(aArea)
	DbSelectArea(cAliasAnt)

	FwFreeArray(aCliFil)
	FwFreeArray(aAreaSF1)
	FwFreeArray(aAreaSF2)
	FwFreeArray(aAreaSC5)
	FwFreeArray(aArea)

Return aRetorno
