#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

Static _TPOPERTRANSF := "04"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JGRT013   ºAutor  ³Lorran Gomes        º Data ³  09/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Pre Nota de Entrada com Base na Nota Fiscal de saída. º±±
±±º          ³ Transferência entre filiais								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function JGRT013(_cNumNf,_cNumSerie,_dEmissao)

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                 Declara as Variaveis Utilizadas na Rotina                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	Local aArea		:= GetArea()
	Local _lOk := .T.
	Local cNota		:= _cNumNf
	Local cSerieNf	:= _cNumSerie
	Local dEmissao	:= _dEmissao
	Local cFilOrig	:= cFilAnt
	Local cCnpjOri	:= ""
	Local cCCPad		:= "" //GetMv("JG_CCPAD",.F.,.T.)
	Local cCCusto		:= ""
	// Local lPerg := .F.
	Local  oSay
    Local aInfSM0   := {}

	Private lJGGERNFE	:= GetMv("JG_GERNFE",.F.,.T.)  //.F. - Gera Pre-Nota | .T. - Gera Nota de entrada sem pre-nota
	// Private cPulaLinha 	:= chr(13)+chr(10)
	Private _MSG	    := {| cStr | Iif(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), U_FLOGJG(cStr)) }
	Private cMsgTipo    := "Doc.Entrada"

	IF Empty(cNota) .Or. Empty(cSerieNf) .And. Empty(dEmissao)
		Return()
	EndIf

	If Empty(cCCusto)
		cCCusto := cCCPad
	EndIf

	// U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )
	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL
	cFilOrig := cFilAnt

	aInfSM0  := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, { "M0_CGC" } )
	cCnpjOri := aInfSM0[1][2]
	ASize(aInfSM0,0)

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³     Inicia o processamento     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If _lOk
		If !IsBlind()
			FWMsgRun(, {|oSay| xDados( cNota, cSerieNf, dEmissao, cFilOrig, cCnpjOri, cCCusto, @oSay ) }, "Processando - Nota de Entrada", "Aguarde, processando a rotina" )
		Else
			U_FLOGJG("Processando - Nota de Entrada")
			xDados( cNota, cSerieNf, dEmissao, cFilOrig, cCnpjOri, cCCusto, @oSay )
		EndIf
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se a NF pode ser gerada, pela origem, fora do processo º±±
±±º          ³ padrao da rotina RFATA25A           							 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function JGRT13A(oSay, cFil, cNota, cSerie)

	// Local cStatus := ""
	// Local lUpdNFe := .F.
	Local _MSG	  := {| cStr | Iif(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), U_FLOGJG(cStr)) }
	Local lRet    := .T. //Lorran Ferreira 09/05/2019 - Retorno para as rotinas do marketplace
	// Local oSay1

	// If cFilAnt <> cFil
	// 	cFilAnt := cFil
		U_JGRT11_F(cFil) //Ajuste cFilAnt <> M0_CODFIL
	// EndIf

	Eval(_MSG,"Verificando NF: "+cNota)

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))	//-- F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	If SF2->(MsSeek(FWxFilial("SF2") + cNota + cSerie)) .And. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == FWxFilial("SF2") + cNota + cSerie

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³             Verifica se a nf ja esta na filial de destino                    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If U_xfNfDest( cFilAnt, SF2->F2_DOC, SF2->F2_SERIE, DtoS(SF2->F2_EMISSAO) )
			If !IsBlind()
				FWAlertInfo("A NFe "+SF2->F2_DOC+" ja foi incluida na filial de destino!", "SPED - JGRT13A")
			Else
				U_FLOGJG("A NFe "+SF2->F2_DOC+" ja foi incluida na filial de destino!")
			EndIf
			Return(.T.)
		EndIf

        If !(SF2->F2_FIMP == "S")
            If !IsBlind()
                FWAlertWarning("A NFe "+SF2->F2_DOC+" ainda consta como não autorizada na SEFAZ!" +CRLF+ "A NF de entrada não será gerada na filial de destino!", "SPED - JGRT13A")
            Else
                U_FLOGJG("A NFe "+SF2->F2_DOC+" ainda consta como não autorizada na SEFAZ!" +CRLF+ "A NF de entrada não será gerada na filial de destino!")
            EndIf
            Return(.F.)
        EndIf

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³                 Gera Nota Fiscal de entrada na filial de destino			     ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        If Empty(SF2->F2_CHVNFE)
            If !IsBlind()
                FWAlertWarning("A NFe "+SF2->F2_DOC+" ainda não teve suas informações de autorização atualizadas!" +CRLF+ "A NF de entrada não será gerada na filial de destino!", "SPED - JGRT13A")
            Else
                U_FLOGJG("A NFe "+SF2->F2_DOC+" ainda não teve suas informações de autorização atualizadas!" +CRLF+ "A NF de entrada não será gerada na filial de destino!")
            EndIf
            Return(.F.)
        EndIf

        U_JGRT013(SF2->F2_DOC,SF2->F2_SERIE,DtoS(SF2->F2_EMISSAO))

        lRet := U_xfNfDest(cFilAnt,SF2->F2_DOC,SF2->F2_SERIE,DtoS(SF2->F2_EMISSAO))

		// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³             Verifica Status da NFe, tem que esta autorizada para gerar       ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		// Eval(_MSG,"NF: "+cNota + " Verificando Status" )
		// cStatus := U_RFATA25D(,SF2->F2_DOC,SF2->F2_SERIE,"2")

		// If Empty(cStatus)

		// 	If !IsBlind() //Lorran - 06/11/2018
		// 		If !MsgBox("A NF "+SF2->F2_DOC+ " não foi enviada ao Sefaz! Deseja enviar agora?"+CRLF+"Caso a resposta seja NÃO >>A NF de entrada não será gerada na filial de destino ","Atenção","YESNO")
		// 			Return(.f.)
		// 		EndIf
		// 	EndIf

		// 	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// 	³                 		Envia e valida nfe no sefaz				            ³
		// 	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		// 	If !IsBlind()
		// 		FWMsgRun(, {|oSay1| lGeraNfe := U_RFATA25D(@oSay1,SF2->F2_DOC,SF2->F2_SERIE,"1") }, "Processando - Nota de Saida NFESEFAZ", "Aguarde, processando a rotina" )
		// 	Else
		// 		U_FLOGJG("Processando - Nota de Saida NFESEFAZ")
		// 		lGeraNfe := U_RFATA25D(@oSay1,SF2->F2_DOC,SF2->F2_SERIE,"1")
		// 	EndIf
		// 	cStatus := U_RFATA25D(,SF2->F2_DOC,SF2->F2_SERIE,"2")

		// EndIf

		// If !Empty(cStatus)

		// 	If SubStr(cStatus,1,1) == "6" //[6] NFe autorizada

		// 		If Empty(SF2->F2_CHVNFE)
		// 			//Atualiza as tabelas com os dados da NFE
		// 			Eval(_MSG,"NF: "+cNota + " - Atualizando as tabelas com os dados da NFE" )
		// 			lUpdNFe := U_RFATA25D(,SF2->F2_DOC,SF2->F2_SERIE,"3")
		// 		EndIf

		// 		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// 		³                 Gera Nota Fiscal de entrada na filial de destino			     ³
		// 		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		// 		If !Empty(SF2->F2_CHVNFE)
		// 			U_RFATA25C(SF2->F2_DOC,SF2->F2_SERIE,DtoS(SF2->F2_EMISSAO))

		// 			lRet := U_xfNfDest(cFilAnt,SF2->F2_DOC,SF2->F2_SERIE,DtoS(SF2->F2_EMISSAO))

		// 		ElseIf !lUpdNFe
		// 			If !IsBlind()
		// 				Aviso("SPED - RFAT25C_A","Os dados da Nfe não foram atualizados! "+CRLF+ "A NF de entrada não será gerada na filial de destino!",{"Ok"},3)
		// 			Else
		// 				U_FLOGJG("Os dados da Nfe não foram atualizados! "+CRLF+ "A NF de entrada não será gerada na filial de destino!")
		// 			EndIf
		// 			lRet := .f.
		// 		Else
		// 			lRet := .f.
		// 		EndIf

		// 	Else
		// 		If !IsBlind()
		// 			Aviso("SPED - RFAT25C_A","A NFe não foi autorizada! " +CRLF+ "Status da Sefaz: "+cStatus,{"Ok"},3)
		// 		Else
		// 			U_FLOGJG("A NFe não foi autorizada! " +CRLF+ "Status da Sefaz: "+cStatus)
		// 		EndIf
		// 		lRet := .f.
		// 	EndIf
		// Else
		// 	If !IsBlind()
		// 		Aviso("SPED - RFAT25C_A","Doc.: "+SF2->F2_DOC+" O Status da NFe não foi localizado!! " +CRLF+ "A NF de entrada não será gerada na filial de destino!",{"Ok"},3)
		// 	Else
		// 		U_FLOGJG("Doc.: "+SF2->F2_DOC+" O Status da NFe não foi localizado!! " +CRLF+ "A NF de entrada não será gerada na filial de destino!")
		// 	EndIf
		// 	lRet := .f.
		// EndIf

	Else
		If !IsBlind()
			FWAlertWarning("Doc.: "+cNota+" NFe não foi localizada!! " +CRLF+ "A NF de entrada não será gerada na filial de destino!", "SPED - JGRT13A")
		Else
			U_FLOGJG("Doc.: "+cNota+" NFe não foi localizada!! " +CRLF+ "A NF de entrada não será gerada na filial de destino!")
		EndIf
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} xfNfDest
Função para verificar se a nota de transferência já foi incluída na filial de destino, 
verificando se a nota existe na SF2 da loja de origem e se a mesma já foi incluída na SF1 da filial de destino.

@type function
@version  
@author Samsung
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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATA022  ºAutor  ³Lorran Gomes        º Data ³  21/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Seleciona as Notas Fiscais de Saida para a Geracao da Pre  º±±
±±º          ³ Nota de Entrada.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xDados( cNota, cSerieNf, dEmissao, cFilOrig, cCnpjOri, cCCusto, oSay )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                 Declara as Variaveis Utilizadas na Rotina                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	Local aArea		  := GetArea()
	Local aAreaSD1    := SD1->(GetArea())
	Local cQuery      := ""
	Local cAliasNF
	Local cInfEmp     := cEmpAnt // SM0->M0_CODIGO
	// Local aInf       := {}
	Local cCnpjForn	  := ""
	Local cCliente    := ""
	Local cLoja       := ""
	Local cDocumento  := ""
	Local cSerie      := ""
	Local aCabec      := {}
	Local aItens      := {}
	Local aLinha      := {}
	//Local aOcorr    := {}
	Local cCnpjDes    := ""
	Local cFilDest	  := ""
	Local cCodFor     := ""
	Local cLojFor     := ""
	Local cTes		  := ""
	// Local aCCusto	:= {}
	// Local _nPos := 0
	Local _nItem      := 0
	Local aCriaSB2	  := {}
	//Local nItem	:= 0
	//Local n,nUsado,NY,aHeader,aCols
	// Local Ny := 1
    Local aInfSM0     := {}

	Local aProd       := {}

	Private nSC5RECNO := 0
	Private lLocVirt  := .F.

	Default oSay := Nil

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                   Query para Selecao de Pessoas Juridicas                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cQuery := " SELECT " + CRLF
	cQuery += "     SF2.F2_CHVNFE, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_UM, " + CRLF
	cQuery += "     SD2.D2_LOCAL AS LOCAL_ORIG, SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, " + CRLF
	cQuery += "     SD2.D2_LOTECTL, SD2.D2_NUMLOTE, SD2.D2_DTVALID, " + CRLF
	cQuery += "     SC5.C5_XLOCDES AS LOCAL_DEST, SC5.C5_CONDPAG, SC5.R_E_C_N_O_ AS SC5RECNO " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     "+RetSqlName("SD2")+" SD2 " + CRLF
	cQuery += "     INNER JOIN "+RetSqlName("SF2")+" SF2 ON "+RetSqlDel("SF2")+" " + CRLF
	cQuery += "         AND F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "     INNER JOIN "+RetSqlName("SC5")+" SC5 ON "+RetSqlDel("SC5")+" " + CRLF
	cQuery += "         AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND SC5.C5_XMOVTRF = "+ValToSql(IIf(FWIsInCallStack("U_JGRT11_B"), JGTrPVExD, JGTrPVNPE)) + " " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     "+RetSqlDel("SD2")+" " + CRLF
	cQuery += "     AND SD2.D2_FILIAL  = "+ValToSql(cFilOrig)+" " + CRLF
	cQuery += "     AND SD2.D2_DOC     = "+ValToSql(cNota   )+" " + CRLF
	cQuery += "     AND SD2.D2_SERIE   = "+ValToSql(cSerieNf)+" " + CRLF
	cQuery += "     AND SD2.D2_EMISSAO = "+ValToSql(dEmissao)+" " + CRLF
	cQuery += " ORDER BY " + CRLF
	cQuery += "     D2_ITEM ASC " + CRLF

	If IsBlind()
		U_FLOGJG("JGRT013 - DOC:"+cNota+" SERIE:"+cSerieNf+ " FILIAL_ORIG:"+cFilOrig+" EMISSAO:"+cValToChar(dEmissao))
		U_FLOGJG("_______________________________________________________")
		U_FLOGJG("cQuery: "+cQuery)
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                Chama a Funcao que Readequa a Query                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	cQuery :=  ChangeQuery( cQuery )


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	//Memowrite("C:\Temp\RFATA25C.Sql" , cQuery )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                 Abre o Resultado da Query no Alias QRY                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Eval(_MSG,"Criando tabela temporária...")
	cAliasNF := MPSysOpenQuery( cQuery )
	Eval(_MSG,"Preparando dados de trabalho...")

	If (cAliasNF)->(Eof())
		If !IsBlind()
			FWAlertInfo("Nota fiscal não localizada!","Atenção")
		Else
			U_FLOGJG("Nota fiscal não localizada!")
		EndIf
		(cAliasNF)->( dbCloseArea() )
		Return()
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                Ajusta os Campos Apos a Execucao da Query                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	TcSetField( cAliasNF, "D2_EMISSAO", "D", 08, 0 )
	TcSetField( cAliasNF, "D2_QUANT"  , "N", 14, 2 )
	TcSetField( cAliasNF, "D2_PRCVEN" , "N", 14, 5 )
	TcSetField( cAliasNF, "D2_TOTAL"  , "N", 14, 2 )
	TcSetField( cAliasNF, "D2_DTVALID", "D", 08, 0 )

	DbSelectArea(cAliasNF)
	(cAliasNF)->(DbGotop())

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	//Validação para notas de transferência entre filiais
	cFilDest := U_xfFilCli((cAliasNF)->D2_CLIENTE, (cAliasNF)->D2_LOJA)
	cCnpjDes := Posicione("SA1",1,FWxFilial("SA1")+(cAliasNF)->D2_CLIENTE+(cAliasNF)->D2_LOJA,"A1_CGC")

	If Len(aFornece := U_xfForFil(cFilOrig)) >= 2
		cCodFor   := aFornece[1]
		cLojFor   := aFornece[2]
		cCnpjForn := POSICIONE("SA2",1,FWxFilial("SA2")+cCodFor+cLojFor,"A2_CGC")
	EndIf

	aInfSM0  := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, { "M0_CGC" } )
	cCnpjPos := aInfSM0[1][2]
	ASize(aInfSM0,0)

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Localiza código da empresa origem como fornecedor					³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	// cCodFor   := POSICIONE("SA2",3,XFILIAL("SA2")+cCnpjOri,"A2_COD")
	// cLojFor   := POSICIONE("SA2",3,XFILIAL("SA2")+cCnpjOri,"A2_LOJA")
	// cCnpjForn := POSICIONE("SA2",3,XFILIAL("SA2")+cCnpjOri,"A2_CGC")

	If Empty(cCodFor)
		If !IsBlind()
			FWAlertInfo("O CNPJ " + Transf(cCnpjOri,"@R 99.999.999/9999-99") + " não está cadastrado como fornecedor na filial destino.","AtençÃo")
		Else
			U_FLOGJG("O CNPJ " + Transf(cCnpjOri,"@R 99.999.999/9999-99") + " não está cadastrado como fornecedor na filial destino.")
		EndIf
		(cAliasNF)->( dbCloseArea() )
		Return()
	EndIf

	If cCnpjPos == cCnpjForn
		IF !(cFilOrig == cFilAnt)
			If !IsBlind()
				FWAlertError("Erro de FILIAL!!"+CRLF+"Entre em contato com departamento de suporte a TI.","ERRO!!")
			Else
				U_FLOGJG("Erro de FILIAL!!"+CRLF+"Entre em contato com departamento de suporte a TI.")
			EndIf
			(cAliasNF)->( dbCloseArea() )
			Return()
		EndIf
	Else
		If !IsBlind()
			FWAlertError("O fornecedor da filial de destino não foi encontrado!!"+CRLF+"Entre em contato com departamento de suporte a TI.","ERRO!!")
		Else
			U_FLOGJG("O fornecedor da filial de destino não foi encontrado!!"+CRLF+"Entre em contato com departamento de suporte a TI.")
		EndIf
		(cAliasNF)->( dbCloseArea() )
		Return()
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                      Localiza o código da filial de Destino		                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	// cCnpjDes := Posicione("SA1",1,xFilial("SA1")+(cAliasNF)->D2_CLIENTE+(cAliasNF)->D2_LOJA,"A1_CGC")

	// cFilDest := xRetFilial(cCnpjDes) //Pega a filial de destino

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                       Verifica se é uma franquia	                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	/*If U_FILMICROV(cFilDest) //Não Gera Nf para franquia
	NFS_QRY->( dbCloseArea() )
	Return()
	EndIf*/

	IF Empty(cFilDest)
		If !IsBlind()
			FWAlertInfo("O CNPJ " + Transf(cCnpjDes,"@R 99.999.999/9999-99") + " não é uma filial.","AtençÃo")
		Else
			U_FLOGJG("O CNPJ " + Transf(cCnpjDes,"@R 99.999.999/9999-99") + " não é uma filial.")
		EndIf
		(cAliasNF)->( dbCloseArea() )
		Return()
	EndIf

	If !(Alltrim(POSICIONE("SA2",1,FWxFilial("SA2")+cCodFor+cLojFOr,"A2_CGC")) == Alltrim(xRetCGCFil(cFilOrig)))
		If !IsBlind()
			FWAlertError("O fornecedor na filial de destino não foi encontrado!!";
			+CRLF+"Utilize a rotina de Gerar "+cMsgTipo+" Transferência, caso esteja na rotina tente novamente.","ERRO!!")
		Else
			U_FLOGJG("O fornecedor na filial de destino não foi encontrado!!";
			+CRLF+"Utilize a rotina de Gerar "+cMsgTipo+" Transferência, caso esteja na rotina tente novamente.")
		EndIf
		(cAliasNF)->( dbCloseArea() )
		Return()
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                       Centro de Custo			                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	// SX6->(dbSetOrder(1))
	// If SX6->(dbSeek(cFilDest+"PT_TRANSCC"))
	// 	cCCusto := Alltrim(SX6->X6_CONTEUD)
	// 	If !Empty(cCCusto)
	// 		If !(Posicione("CTT", 1, xFilial("CTT")+PadR(cCCusto,TamSx3("CTT_CUSTO")[1]), "CTT_BLOQ") <> "1")
	// 			If !IsBlind()
	// 				MsgBox("Atenção o Centro de custo "+cCCusto+ " está bloquado!!";
	// 				+CRLF+"Após o ajuste do Centro de Custo, utilize a rotina de Gerar "+cMsgTipo+" Transferência.",""+cMsgTipo+" NÃO GERADO - ERRO!!","INFO")
	// 			Else
	// 				U_FLOGJG("Atenção o Centro de custo "+cCCusto+ " está bloquado!!";
	// 				+CRLF+"Após o ajuste do Centro de Custo, utilize a rotina de Gerar "+cMsgTipo+" Transferência.",""+cMsgTipo+" NÃO GERADO - ERRO!!")
	// 			EndIf
	// 			NFS_QRY->( dbCloseArea() )
	// 			Return()
	// 		EndIf
	// 	Else
	// 		If !IsBlind()
	// 			MsgBox("Não foi informado um Centro de Custo no parâmetro PT_TRANSCC!";
	// 			+CRLF+"O Centro de Custo deve ser informado para gerar a "+cMsgTipo+".";
	// 			+CRLF+"Após o ajuste do parâmetro, utilize a rotina de Gerar "+cMsgTipo+" Transferência.",""+cMsgTipo+" NÃO GERADO - ERRO!!","INFO")
	// 		Else
	// 			U_FLOGJG("Não foi informado um Centro de Custo no parâmetro PT_TRANSCC!";
	// 			+CRLF+"O Centro de Custo deve ser informado para gerar a "+cMsgTipo+".";
	// 			+CRLF+"Após o ajuste do parâmetro, utilize a rotina de Gerar "+cMsgTipo+" Transferência.",""+cMsgTipo+" NÃO GERADO - ERRO!!")
	// 		EndIF
	// 		NFS_QRY->( dbCloseArea() )
	// 		Return()
	// 	EndIf
	// Else
	// 	If !IsBlind()
	// 		MsgBox("Não foi informado um Centro de Custo no parâmetro PT_TRANSCC!";
	// 		+CRLF+"O Centro de Custo deve ser informado para gerar a "+cMsgTipo+".";
	// 		+CRLF+"Após o ajuste do parâmetro, utilize a rotina de Gerar "+cMsgTipo+" Transferência.","Pré-Nota NÃO GERADO - ERRO!!","INFO")
	// 	Else
	// 		U_FLOGJG("Não foi informado um Centro de Custo no parâmetro PT_TRANSCC!";
	// 		+CRLF+"O Centro de Custo deve ser informado para gerar a "+cMsgTipo+".";
	// 		+CRLF+"Após o ajuste do parâmetro, utilize a rotina de Gerar "+cMsgTipo+" Transferência.")
	// 	EndIf
	// 	NFS_QRY->( dbCloseArea() )
	// 	Return()
	// EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                       Appenda a Query na Tabela                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DbSelectArea((cAliasNF))
	(cAliasNF)->(DbGotop())
	ProcRegua( (cAliasNF)->( Reccount() ) )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                     Processa os Itens da Nota Fiscal                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                    Adiciona a Regua de Processamento                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	//IncProc( "Gerando a Pré-Nota Número : " + NFS_QRY->D2_DOC )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³               Guarda os Dados da Nota que Sera Processada                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	cDocumento := (cAliasNF)->D2_DOC
	cSerie     := (cAliasNF)->D2_SERIE
	cCliente   := (cAliasNF)->D2_CLIENTE
	cLoja      := (cAliasNF)->D2_LOJA
	aItens     := {}
	aCabec     := {}
	aLinha     := {}
	nSC5RECNO  := (cAliasNF)->SC5RECNO

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                       Verifica se é uma franquia	                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	// If U_FILMICROV(cFilDest) //Não Gera Nf para franquia

	// 	U_RFAT25_E(nSC5RECNO,"OK")//Grava Status no Pedido

	// 	If !IsBlind()
	// 		Aviso(OemToAnsi("Atenção"),OemToAnsi("Por se tratar de uma filial Franquia não será gerada Nota de entrada no Destino!"),{"Ok"})
	// 	Else
	// 		U_FLOGJG("Por se tratar de uma filial Franquia não será gerada Nota de entrada no Destino!")
	// 	EndIf

	// 	NFS_QRY->( dbCloseArea() )
	// 	RestArea(aAreaSD1)
	// 	RestArea(aArea)
	// 	Return()

	// EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³            Monta o Array com o Cabecalho da Nota Fiscal de Entrada             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	aCabec :=   {	{"F1_TIPO",		"N",			        Nil },;
                    {"F1_FORMUL",	"N",					Nil },;
                    {"F1_DOC",		(cAliasNF)->D2_DOC,		Nil },;
                    {"F1_SERIE",	(cAliasNF)->D2_SERIE,	Nil },;
                    {"F1_COND",		(cAliasNF)->C5_CONDPAG,	Nil },;
                    {"F1_EMISSAO",	(cAliasNF)->D2_EMISSAO,	Nil },;
                    {"F1_FORNECE",	cCodFor,				Nil },;
                    {"F1_LOJA",		cLojFOr,				Nil },;
                    {"F1_FIMP",		"T",					Nil },;
                    {"F1_CHVNFE",	(cAliasNF)->F2_CHVNFE,	Nil },;
                    {"F1_ESPECIE",	"SPED",					Nil };
                }

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Armazena todos os itens da Nota de Saida no Array              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	(cAliasNF)->(DbGotop())
	Do While (cAliasNF)->( !Eof() ) ;
        .And. (cAliasNF)->D2_DOC     == cDocumento ;
        .And. (cAliasNF)->D2_SERIE   == cSerie     ;
        .And. (cAliasNF)->D2_CLIENTE == cCliente   ;
        .And. (cAliasNF)->D2_LOJA    == cLoja

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³                Monta o array com os Itens da Nota de Saida                 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		_nItem++
		If lJGGERNFE

			cTes := ""
			//Muda a filial so para pegar a tes
			// cFilAnt := cFilDest
			U_JGRT11_F(cFilDest) //Ajuste cFilAnt <> M0_CODFIL
			cTes := MaTesInt(1,_TPOPERTRANSF,cCodFor,cLojFOr,"F",(cAliasNF)->D2_COD)
			// cFilAnt := cFilOrig
			U_JGRT11_F(cFilOrig) //Ajuste cFilAnt <> M0_CODFIL

			If Empty(cTes)
				If !IsBlind()
					FWAlertWarning(OemToAnsi("Não foi localizada TES de entrada para o Produto: "+(cAliasNF)->D2_COD + CRLF +"A Nota fiscal de entrada não sera gerada na filial de destino!"), OemToAnsi("Atenção"))
				Else
					U_FLOGJG("Não foi localizada TES de entrada para o Produto: "+(cAliasNF)->D2_COD + CRLF +"A Nota fiscal de entrada não sera gerada na filial de destino!")
				EndIf
				(cAliasNF)->( dbCloseArea() )
				RestArea(aAreaSD1)
				RestArea(aArea)
				Return()
			EndIf

			//aLinha := {	{"D1_ITEM",		PADL((cAliasNF)->D2_ITEM,4,"0"), 	Nil },;

			aLinha :=   {	{"D1_ITEM",		StrZero(_nItem,4), 	    Nil },;
                            {"D1_COD",		(cAliasNF)->D2_COD, 	Nil },;
                            {"D1_UM",		(cAliasNF)->D2_UM, 		Nil },;
                            {"D1_LOCAL",	(cAliasNF)->LOCAL_DEST,	Nil },;
                            {"D1_QUANT",	(cAliasNF)->D2_QUANT,   Nil },;
                            {"D1_VUNIT",	(cAliasNF)->D2_PRCVEN,	Nil },;
                            {"D1_TOTAL",	(cAliasNF)->D2_TOTAL,	Nil },;
                            {"D1_CC",		cCCusto,				Nil },;
                            {"D1_TES",		cTes,					Nil },;
                            {"D1_EMISSAO",	(cAliasNF)->D2_EMISSAO,	Nil },;
                            {"D1_LOTECTL",	(cAliasNF)->D2_LOTECTL,	Nil },;
                            {"D1_NUMLOTE",	(cAliasNF)->D2_NUMLOTE,	Nil },;
                            {"D1_DTVALID",	(cAliasNF)->D2_DTVALID,	Nil };
                        }
		Else
			aLinha :=   {	{"D1_ITEM",		PADL((cAliasNF)->D2_ITEM,4,"0"),	Nil },;
                            {"D1_COD",		(cAliasNF)->D2_COD, 		    	Nil },;
                            {"D1_UM",		(cAliasNF)->D2_UM, 		        	Nil },;
                            {"D1_LOCAL",	(cAliasNF)->LOCAL_DEST,	        	Nil },;
                            {"D1_QUANT",	(cAliasNF)->D2_QUANT, 	        	Nil },;
                            {"D1_VUNIT",	(cAliasNF)->D2_PRCVEN,	        	Nil },;
                            {"D1_TOTAL",	(cAliasNF)->D2_TOTAL,	        	Nil },;
                            {"D1_CC",		cCCusto,	                    	Nil },;
                            {"D1_EMISSAO",	(cAliasNF)->D2_EMISSAO,	            Nil },;
                            {"D1_LOTECTL",	(cAliasNF)->D2_LOTECTL,	            Nil },;
                            {"D1_NUMLOTE",	(cAliasNF)->D2_NUMLOTE,	            Nil },;
                            {"D1_DTVALID",	(cAliasNF)->D2_DTVALID,	            Nil };
                        }
		EndIf

		Aadd( aCriaSB2, { (cAliasNF)->LOCAL_DEST , (cAliasNF)->D2_COD } )

		// If !lLocVirt
		// 	If (cAliasNF)->LOCAL_DEST $ GETMV("MV_LOCVIRT",,"XX")
		// 		lLocVirt := .t.
		// 		Aadd(aCabec,{"F1_TDOCSD3",	".",					Nil })
		// 	EndIf
		// EndIf

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³                Monta o array com os produtos  - Para Pre-Nota  				³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJGGERNFE
			AADD( aProd,    {   Alltrim(cFilDest),;
                                Alltrim((cAliasNF)->D2_DOC),;
                                Alltrim((cAliasNF)->D2_SERIE),;
                                Alltrim(cCodFor),;
                                Alltrim(cLojFOr),;
                                (cAliasNF)->D2_COD,;
                                PADL((cAliasNF)->D2_ITEM,4,"0"),;
                                "";
                            };
                ) //Tes
		EndIf

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³             Adiciona no Array com todos os Itens da Nota                   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		Aadd ( aItens, aLinha )

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³             Processa o Proximo Item da Nota Fiscal de Saida                ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		(cAliasNF)->(DbSkip())
	EndDo

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Chama a Rotina que Gera a Pre Nota de Entrada                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	If lJGGERNFE
		Eval(_MSG, "Gerando Nota de entrada "+cNota+" na Filial: "+cFilDest)
		PrcNotaEnt( cInfEmp, cFilDest, cFilOrig, aCabec, aItens, cNota, aCriaSB2 )
	ElseIf !lJGGERNFE
		Eval(_MSG, "Gerando Pre Nota de Entrada na Filial: "+cFilDest)
		PrcPreNota( cInfEmp, cFilDest, cFilOrig, aCabec, aItens, cNota, aProd)
	EndIf

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	(cAliasNF)->( DbCloseArea() )

	RestArea(aAreaSD1)
	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a Geração da Pre Nota Fiscal de Entrada com base    º±±
±±º          ³ na Nota Fiscal de Saida.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrcPreNota( cEmp, cFilDes, cFilOrigem, aCab, aIte, cNota, aProd )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                 Declara as Variaveis Utilizadas na Rotina                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	Local   aArea				:= GetArea()
	// Local   cFile				:= ""
	Local _aCab 	:= 	aCab
	Local _aIte 	:= 	aIte
	// Local nModulo         := 99
	// Local nOpc            :=  3
	// Local lRefresh        := .T.
	Local lMsErroAuto		:= .F.
	// Local lMsHelpAuto		:= .T.
	// Local lAutoErrNoFile	:= .F.
	// Local __cInterNet     := Nil
	// Local cTxtErro        := ""
	Local cKeySD1		:= ""
	Local Nx

	Default aProd       := {}

	MakeDir("C:\")

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre a Empresa Destino Onde a Pre Nota Sera Gerada             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cFilAnt := cFilDes //Entra na filial onde sera gerada Pre Nota de Entrada
	U_JGRT11_F() 

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³           Verifica se existem Itens para Geracao da Pre Nota de Entrada        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Len ( _aCab ) > 0 .And. Len ( _aIte ) > 0

		//MsAguarde({|| MSExecAuto({ | x , y , z | MATA140( x , y , z )} , aCab , aIte , 3 ) } , "Gerando Pre-Nota de Entrada")
		MsAguarde({|| MATA140( _aCab, _aIte, 3 ) } , "Gerando Pre-Nota de Entrada")

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³                   Chama a Rotina que exibe as Mensagens de Erro                ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lMsErroAuto

			MSGINFO( "*** Pré Nota de Entrada Incluida com Sucesso !! *** "+ CRLF + " *** Filial: "+cFilAnt+" Pré Nota: "+cNota+" ***")

			// U_RFAT25_E(nSC5RECNO,"EP")//Grava Status no Pedido

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³             Grava a TES de entrada no campo   D1_TESACLA		              ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If Len(aProd) > 0
				For Nx:=1 To Len(aProd)

					SD1->(DbSetOrder(1)) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
					cKeySD1 := aProd[Nx][01]+aProd[Nx][02]+aProd[Nx][03]+aProd[Nx][04]+aProd[Nx][05]+aProd[Nx][06]+aProd[Nx][07]
					//Begin Transaction
					If SD1->(DbSeek(cKeySD1,.F.))
						RecLock("SD1",.F.)
						SD1->D1_TESACLA := MaTesInt(1,_TPOPERTRANSF,SD1->D1_FORNECE,SD1->D1_LOJA,"F",SD1->D1_COD)
						MsUnLock()
					EndIf
					//End Transaction

				Next Nx
			EndIf


		Else

			//MostraErro()

		EndIf

	Endif


	cFilAnt := cFilOrigem //Retorna para filial de origem da nota fiscal de transferencia
	U_JGRT11_F() 

	RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a Geração da Nota Fiscal de Entrada com base    º±±
±±º          ³ na Nota Fiscal de Saida.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrcNotaEnt( cEmp, cFilDes, cFilOrigem, aCab, aIte, cNota, aCriaSB2 )

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³                 Declara as Variaveis Utilizadas na Rotina                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	Local aArea	    := GetArea()
	// Local   cFile				:= ""
	Local _aCab 	:= 	aCab
	Local _aIte 	:= 	aIte
	// Local nModulo         := 99
	// Local nOpc            :=  3
	// Local lRefresh        := .T.
	// Local __cInterNet     := Nil
	Local cTxtErro  := ""
	Local aFalha	:= {}		
	Local cTimeI	:= Time()
	Local A,nX

	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.

	Default aCriaSB2 := {}

	//MostraErro em casos de falhas
	If !IsBlind()
		lAutoErrNoFile	:= .F.
	EndIf

	If IsBlind()
		U_FLOGJG("***JGRT013->PrcNotaEnt-> Filial:"+cFilDes+" Nota:"+cNota+" Iniciado - "+cTimeI)
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre a Empresa Destino Onde a Pre Nota Sera Gerada             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	// cFilAnt := cFilDes //Entra na filial onde sera gerada Pre Nota de Entrada
	U_JGRT11_F(cFilDes) //Ajuste cFilAnt <> M0_CODFIL

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³           Verifica se existem Itens para Geracao da Pre Nota de Entrada        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Len ( _aCab ) > 0 .And. Len ( _aIte ) > 0

		For A:=1 To Len(aCriaSB2)

			//aCriaSB2[A][1] ARMAZEM
			//aCriaSB2[A][2] COD. PRODUTO

			SB2->(dbSetOrder(1))
			If !SB2->(dbSeek(xFilial("SB2")+ aCriaSB2[A][2] + aCriaSB2[A][1] ))
				U_FLOGJG("CriaSB2 - Criando Local de estoque "+aCriaSB2[A][1]+" para o Produto "+aCriaSB2[A][2])
				CriaSB2( aCriaSB2[A][2] , aCriaSB2[A][1] )
				U_FLOGJG("CriaSB2 executada")
				If SB2->(dbSeek(xFilial("SB2")+ aCriaSB2[A][2] + aCriaSB2[A][1] ))
					U_FLOGJG("CriaSB2 - CRIADO -  Local de estoque "+aCriaSB2[A][1]+" para o Produto "+aCriaSB2[A][2])
				Else
					U_FLOGJG("CriaSB2 - FALHA -  Local de estoque "+aCriaSB2[A][1]+" para o Produto "+aCriaSB2[A][2])
				EndIf
			EndIf

		Next A

		Begin Transaction

			/*If IsBlind()
			varinfo("VarInfo --> aCab:",aClone(_aCab))
			varinfo("VarInfo --> aIte:",aClone(_aIte))
			U_FLOGJG("------------------------------------------")
			varinfo("VarInfo --> aCab:", _aCab)
			varinfo("VarInfo --> aIte:", _aIte)
			EndIf*/
			If IsBlind()
				U_FLOGJG("***JGRT013->PrcNotaEnt->MSExecAuto->MATA103 - Filial:"+cFilDes+" Nota:"+cNota+" Iniciado - "+Time())
			EndIf
			MSExecAuto({|x,y,z| MATA103(x,y,z)}, _aCab , _aIte , 3 )
			aFalha := GetAutoGRLog()
			If IsBlind()
				U_FLOGJG("***JGRT013->PrcNotaEnt->MSExecAuto->MATA103 - Filial:"+cFilDes+" Nota:"+cNota+" Finalizado - "+Time())
			EndIf

			/*cTxtErro := ""
			For nX := 1 To Len(aFalha)
				cTxtErro += aFalha[nX] + Chr(13)+Chr(10)
			Next nX
			If !Empty(cTxtErro)
			U_FLOGJG("Erro ao gerar Nota de entrada - Erro: "+Chr(13)+Chr(10)+cTxtErro)
			EndIf*/
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³                   Chama a Rotina que exibe as Mensagens de Erro                ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !lMsErroAuto .And. Empty(cTxtErro)

				If IsBlind()
					U_FLOGJG("***JGRT013->Grava Status no Pedido -> JGRT11_F SC5 RECNO -> "+cValToChar(nSC5RECNO))
				EndIf
                // U_JGRT11_E( nSC5RECNO, JGTrPVOK, JGTrOrOK ) 
				// If lLocVirt
				// 	U_RFAT25_E(nSC5RECNO,"OK")//Grava Status no Pedido
				// Else
				// 	U_RFAT25_E(nSC5RECNO,"EP")//Grava Status no Pedido
				// EndIf

				If !IsBlind()
					MSGINFO( "*** Nota Fiscal de Entrada Incluida com Sucesso !! *** "+ CRLF + " *** Filial: "+cFilAnt+" Nota Entrada: "+cNota+" ***")
				Else
					U_FLOGJG("*** Nota Fiscal de Entrada Incluida com Sucesso !! *** "+ CRLF + " *** Filial: "+cFilAnt+" Nota Entrada: "+cNota+" ***")
				EndIf

			Else

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³                 Se der problema desfaz tudo				                  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

				RollBackSX8()
				DisarmTransaction()

				cTxtErro := ""
				For nX := 1 To Len(aFalha)
					cTxtErro += aFalha[nX] + CRLF
				Next nX

				If !IsBlind()
					MostraErro()
				Else
					U_FLOGJG("Erro ao gerar Nota de entrada - Erro: "+Chr(13)+Chr(10)+cTxtErro)
				EndIf

			EndIf
		End Transaction
	Endif


	// cFilAnt := cFilOrigem //Retorna para filial de origem da nota fiscal de transferencia
	U_JGRT11_F(cFilOrigem) //Ajuste cFilAnt <> M0_CODFIL

	RestArea(aArea)

	If IsBlind()
		U_FLOGJG("***JGRT013->PrcNotaEnt-> Filial:"+cFilDes+" Nota:"+cNota+" Inicio: "+cTimeI+" Fim:"+Time())
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filial do CNPJ													   º±±
±±º          ³                                  								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xRetFilial(_cCnpj)

	Local aArea    := FWGetArea()
    Local cFilAux  := cFilAnt
	Local aSM0     := {}
	Local cFilDest := ''
	Local cCnpj    := _cCnpj

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre as Filiais 											         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

    aSM0 := SearchSM0(cCnpj)
	If Len(aSM0) > 0
        cFilDest := aSM0[1][2]
    EndIf

	FWRestArea(aArea)

    U_JGRT11_F(cFilAux)

Return(cFilDest)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CNPJ DA Filial 													   º±±
±±º          ³                                  								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xRetCGCFil(_cFilial)

	Local aArea    := FWGetArea()
    Local cFilAux  := cFilAnt
	Local cCGCFil  := ""
	Local aSM0     := FWLoadSM0()
	Local cFil     := _cFilial

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre as Filiais 											         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aEval(aSM0, { |x| IIf(x[1] == cEmpAnt .And. x[2] == cFil, cCGCFil := x[18] , "") })

	FWRestArea(aArea)

    U_JGRT11_F(cFilAux)

Return(cCGCFil)
