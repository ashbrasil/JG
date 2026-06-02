#Include "Totvs.ch"
#include "TbiConn.ch"
#Include "TopConn.ch"
#Include "jgtransf.ch"

/*/{Protheus.doc} JGRT011C

	Rotina responsável por realizar a liberação do estoque referente à transferência recebida.
	O processo consiste da realização de transferência de estoque do armazém de recepção da mercadoria 
	para o armazém definitivo, geralmente o armazém de venda.

@type function
@version  
@author Jesus Ramos
@since 28/05/2026
@return Nil
/*/
	// 1 - Filial do Fornecedor, 2 - Cliente/Loja da Filial do Fornecedor, 3 - Recno da SC5, 4 - Recno da SF2, 5 - Armazém final da transferência

Static P_FILIAL  := 1
Static P_CLIENTE := 2
Static P_PEDIDO  := 3
Static P_NOTA    := 4
Static P_LOCAL   := 5

User Function JGRT011C()

	Local aArea  	:= FWGetArea()
	Local aAreaSC5 	:= SC5->(FWGetArea())
	Local aAreaSA2 	:= SA2->(FWGetArea())
	Local lGera	  	:= .T.
	Local aNfOrig   := {}
	Local cMsgAviso := ""
	Local cLocalNew := GETMV("JG_LOCPDLB",,"01")//"01"
	Local cTitAviso := OemToAnsi("Lib. Estoque Transferência - JGRT011C")

	U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )

	cMsgAviso += "Filial: "+SF1->F1_FILIAL+CRLF+;
					"Doc./Serie: "+SF1->(F1_DOC+F1_SERIE)+CRLF+;
					"Fornecedor: "+SF1->(F1_FORNECE+"-"+F1_LOJA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verifica se a NF ja foi Liberada                      		  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SF1->F1_XDOCSD3)

		FWAlertInfo(OemToAnsi("A NF selecionada já foi Liberada!"+CRLF+"Documento de liberação: "+SF1->F1_XDOCSD3), cTitAviso)

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Verifica se o fornecedor da transferencia é uma filial 	  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA2->(dbsetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
			cMsgAviso += " - "+SA2->A2_NOME+CRLF+CRLF
		Else
			cMsgAviso += CRLF+CRLF
			cMsgAviso += "O Fornecedor desta nota fiscal não foi localizado!"+CRLF+CRLF
			lGera := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Verifica a Nf na origem                               		 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aNfOrig := U_xfNfOrig(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_EMISSAO)

		If Empty(aNfOrig[P_FILIAL])
			cMsgAviso += "O Fornecedor desta nota fiscal não é uma filial!"+CRLF+CRLF
			lGera := .F.
		ElseIf aNfOrig[P_FILIAL] == SF1->F1_FILIAL
			cMsgAviso += "Filial de saída igual à filial de entrada não constitui operação de transferência!"+CRLF+CRLF
			lGera := .F.
		ElseIf Empty(aNfOrig[P_CLIENTE])
			cMsgAviso += "O cliente referente à filial não foi identificado!"+CRLF+CRLF
			lGera := .F.
		ElseIf Empty(aNfOrig[P_PEDIDO])
			cMsgAviso += "O pedido de venda referente à transferência não foi localizado na filial de origem <b>"+aNfOrig[P_FILIAL]+"</b>!"+CRLF+CRLF
			lGera := .F.
		ElseIf Empty(aNfOrig[P_NOTA])
			cMsgAviso += "A nota fiscal <b>"+SF1->F1_DOC+"</b> não foi localizada na filial de origem <b>"+aNfOrig[P_FILIAL]+"</b>!"+CRLF+CRLF
			lGera := .F.
		ElseIf Empty(aNfOrig[P_LOCAL])
			cMsgAviso += "O local de destino da liberação de estoque não foi informado no pedido de venda!"+CRLF+CRLF
			lGera := .F.
		EndIf

		If lGera
			cMsgAviso := OemToAnsi("Confirma a Liberação de Estoque da Transferência?"+CRLF+CRLF+cMsgAviso)
			If FWAlertYesNo(cMsgAviso, "Confirmação")
				FWMsgRun(, {|oSay| _fmata261(@oSay, cLocalNew, aNfOrig[P_PEDIDO]) }, "Processando - Libera Estoque Transferência", "Aguarde, processando a rotina" )
			EndIf
		Else
			cMsgAviso := OemToAnsi("A liberação não foi realizada devido às seguintes ocorrências:"+CRLF+CRLF+cMsgAviso)
			FWAlertInfo(cMsgAviso, cTitAviso)
		EndIf

	EndIf

	FWRestArea(aAreaSA2)
	FWRestArea(aAreaSC5)
	FWRestArea(aArea)

Return

/*/{Protheus.doc} _fmata261

	Rotina responsável por realizar a transferência de estoque do armazém de recepção da mercadoria 
	para o armazém definitivo.

@type function
@version  
@author Jesus Ramos
@since 28/05/2026
@param oSay, object, Objeto visual para exibição do processamento da rotina.
@param cLocalNew, String, Local de destino para a transferência
@return Nil
/*/
Static Function _fmata261(oSay, cLocalNew, nSC5Recno)

	Local lOk		 := .T.
	Local cAlias	 := ""
	// Local aAreaSD3   := SD3->(FWGetArea())
	Local aItem	     := {}
	Local cNumDoc	 := ""
	Local cErroBlock := ""
	Local aErro
	Local _MSG	     := {| cStr | Iif(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), U_FLOGPRIME(cStr)) }
	Local cTitAviso  := OemToAnsi("Lib. Estoque Transferência - JGRT011C")
	Local Nx
	Local cObsLib    := AllTrim("JGRT011C "+AllTrim(UsrRetName(RetCodUsr())))

	PRIVATE lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	Default cLocalNew := "01"

	Eval(_MSG,"Coletando os itens do documento...")

	cQry := " SELECT " + CRLF
	cQry += "     D1_ITEM, D1_FILIAL, D1_COD, B1_DESC, D1_UM, D1_LOCAL, D1_QUANT, D1_LOTECTL, D1_NUMLOTE, D1_DTVALID " + CRLF
	cQry += " FROM " + CRLF
	cQry += "     " + RetSqlName("SD1") + " SD1 " + CRLF
	cQry += "     INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + RetSqlDel("SB1") + " " + CRLF
	cQry += "         AND B1_FILIAL = " + ValToSql(FWxFilial("SB1")) + " AND B1_COD = D1_COD " + CRLF
	cQry += " WHERE " + CRLF
	cQry += "     " + RetSqlDel("SD1") + CRLF
	cQry += "     AND D1_FILIAL  = " + ValToSql(SF1->F1_FILIAL) + CRLF
	cQry += "     AND D1_DOC     = " + ValToSql(SF1->F1_DOC) + CRLF
	cQry += "     AND D1_SERIE   = " + ValToSql(SF1->F1_SERIE) + CRLF
	cQry += "     AND D1_FORNECE = " + ValToSql(SF1->F1_FORNECE) + CRLF
	cQry += "     AND D1_LOJA    = " + ValToSql(SF1->F1_LOJA) + CRLF
	cQry += " ORDER BY " + CRLF
	cQry += "     D1_ITEM " + CRLF

	cAlias := MpSysOpenQuery(cQry)
	TcSetField(cAlias, "D1_DTVALID", "D", 08, 0)

	If Contar(cAlias, "!Eof()") > 0
		lOk := .T.
	Else
		lOk := .F.
	EndIf

	(cAlias)->(DbGoTop())

	If lOk

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Inclusao                                            		  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Begin Transaction

		Eval(_MSG,"Preparando os itens do documento...")
		//Cabecalho a Incluir
		//cNumDoc	:= GetSxENum("SD3","D3_DOC",1)
		cNumDoc	:= NextNumero("SD3",2,"D3_DOC",.T.)
		cNumDoc	:= A261RetINV(cNumDoc)
		aAuto := {}
		aadd(aAuto,{cNumDoc, dDataBase})

		If Len(cObsLib) > TamSX3("D3_OBSERVA")[1]
			cObsLib := Substr(cObsLib,1,TamSX3("D3_OBSERVA")[1])
		Else
			cObsLib := PadR(cObsLib,TamSX3("D3_OBSERVA")[1])
		EndIf

		DbSelectArea("SB2")

		While (cAlias)->( !EOF() )
			//Itens a Incluir
			aItem := {}

			SB2->(dbSetOrder(1))
			If !SB2->(dbSeek(FWxFilial("SB2")+(cAlias)->D1_COD+cLocalNew))
				Eval(_MSG,"Produto: "+Alltrim((cAlias)->D1_COD)+" Criando Armazém "+cLocalNew)
				CriaSB2((cAlias)->D1_COD,cLocalNew)
				Eval(_MSG,"Preparando os itens do documento...")
			EndIf
			
			//Campo      Tipo Tamanho Decimal
			aadd(aItem,(cAlias)->D1_COD)  		//D3_COD      C        15       0
			aadd(aItem,(cAlias)->B1_DESC) 		//D3_DESCRI   C        30       0
			aadd(aItem,(cAlias)->D1_UM)  		//D3_UM       C         2       0
			aadd(aItem,(cAlias)->D1_LOCAL) 		//D3_LOCAL    C         2       0
			aadd(aItem,"")						//D3_LOCALIZ  C        15       0
			aadd(aItem,(cAlias)->D1_COD)  		//D3_COD      C        15       0
			aadd(aItem,(cAlias)->B1_DESC)  		//D3_DESCRI   C        30       0
			aadd(aItem,(cAlias)->D1_UM)  		//D3_UM       C         2       0
			aadd(aItem,cLocalNew)    			//D3_LOCAL    C         2       0
			aadd(aItem,"")						//D3_LOCALIZ  C        15       0
			aadd(aItem,"")       				//D3_NUMSERI  C        20       0
			aadd(aItem,(cAlias)->D1_LOTECTL)	//D3_LOTECTL  C        10       0
			aadd(aItem,(cAlias)->D1_NUMLOTE)	//D3_NUMLOTE  C         6       0
			If !Empty((cAlias)->D1_LOTECTL)
				aadd(aItem,(cAlias)->D1_DTVALID)	//D3_DTVALID  D         8       0
			Else
				aadd(aItem,Date())					//D3_DTVALID  D         8       0
			EndIf
			aadd(aItem,0)						//D3_POTENCI  N         6       2
			aadd(aItem,(cAlias)->D1_QUANT) 		//D3_QUANT    N        12       2
			aadd(aItem,0)						//D3_QTSEGUM  N        12       2
			aadd(aItem,"")   					//D3_ESTORNO  C         1       0
			aadd(aItem,"")      				//D3_NUMSEQ   C         6       0
			aadd(aItem,(cAlias)->D1_LOTECTL)	//D3_LOTECTL  C        10       0
			If !Empty((cAlias)->D1_LOTECTL)
				aadd(aItem,(cAlias)->D1_DTVALID)	//D3_DTVALID  D         8       0
			Else
				aadd(aItem,Date())					//D3_DTVALID  D         8       0
			EndIf
			aadd(aItem,"")						//D3_ITEMGRD  C         3       0
			If Getmv("JG_D3IDDCF",,.F.)
				aadd(aItem,"")						//D3_IDDCF    C         6       0
			EndIf
			aadd(aItem,cObsLib)					//D3_OBSERVA  C        30       0
			aadd(aAuto,aItem)

			(cAlias)->(DbSkip())
		EndDo

		Eval(_MSG,"Gerando a Transferência do estoque para o Armazém: "+cLocalNew)
		If Len(aAuto) > 0
			MSExecAuto({|x,y| mata261(x,y)},aAuto,3)
			aErro := GetAutoGRLog()
		EndIf

		If !lMsErroAuto
			Eval(_MSG,"Atualizando STATUS da Transferência")

			// aAreaSD3 := SD3->(FWGetArea())
			// SD3->(DbSetOrder(2))
			// If SD3->(DbSeek(xFilial("SD3")+cNumDoc))
			// 	RecLock("SD3",.F.)
			// 		SD3->D3_XOBS := "MSExecAuto - Lib.Estoque Transf. - JGRT011C - Usuario: "+ALLTRIM(USRRETNAME(RETCODUSR()))
			// 	SD3->(MsUnlock())
			// EndIf
			// FWRestArea(aAreaSD3)

			RecLock("SF1",.F.)
				SF1->F1_XDOCSD3 := cNumDoc
			SF1->(MsUnlock())

			U_JGRT11_E(nSC5Recno, JGTrPVOK, JGTrOrOK)//Grava Status no Pedido

			FWAlertInfo(OemToAnsi("Estoque de Transferência Liberado com sucesso!"+CRLF+CRLF+;
									"Documento de transferência: "+cNumDoc), cTitAviso)

		Else
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³                 Se der problema desfaz tudo				                  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/


			//DisarmTransaction()

			cErroBlock := ""
			For nX := 1 To Len(aErro)
				cErroBlock += aErro[nX] + CRLF
			Next nX

			FWAlertError(OemToAnsi("Erro ao Liberar Estoque da Transferência: "+CRLF+CRLF+cErroBlock), cTitAviso)

			Mostraerro()

		EndIf

		//End Transaction

	EndIf

	(cAlias)->(DbCloseArea())

Return Nil
