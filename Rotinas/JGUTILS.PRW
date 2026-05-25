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

/*/{Protheus.doc} fDesStaTrf
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
User Function fDsStTrf(cOriStatus, cStatusTrf, lDescDet)
	Local cResStaTrf := "Status Indefinido"  // Descrição resumida/reduzida do status da transferência
	Local cDetStaTrf := "Status Indefinido." // Descrição detalhada do status da transferência

	Default lDescDet := .F.

    If cOriStatus == "O" // Status de Orçamento (SL1)
        Do Case
            Case cStatusTrf == JGTrOrNSA
                cResStaTrf := "Não se Aplica"
                cDetStaTrf := "Operação sem exigência de transferência imediata. A filial tem estoque próprio."
            Case cStatusTrf == JGTrOrEAb
                cResStaTrf := "Orç. Em Aberto"
                cDetStaTrf := "Orçamento em aberto, em manutenção pelo vendedor. A transferência ainda não foi iniciada."
            Case cStatusTrf == JGTrOrIni
                cResStaTrf := "Transf. Iniciada"
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
                cResStaTrf := "Transf. Concluída"
                cDetStaTrf := "O processo de transferência foi concluído."
            Case cStatusTrf == JGTrOrExD
                cResStaTrf := "NF de Entrada excluída"
                cDetStaTrf := "A NF de entrada foi excluída na filial solicitante. O orçamento não poderá ser finalizado."
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
            Case cStatusTrf == JGTrPVOK
                cResStaTrf := "Transf. Concluída"
                cDetStaTrf := "O processo de transferência foi concluído."
            Case cStatusTrf == JGTrPVExD
                cResStaTrf := "NF de Entrada excluída"
                cDetStaTrf := "A NF de entrada foi excluída na filial solicitante."
        EndCase
    EndIf

Return IIf(lDescDet,cDetStaTrf,cResStaTrf)
