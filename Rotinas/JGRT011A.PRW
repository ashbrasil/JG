#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  JGRT011A  ºAutor  ³Lorran Gomes        	º Data ³ 08/03/2026 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para apontamento manual, ou via arquivo, do pedido	º±±
±±º          ³ de venda para a Transferência entre filiais					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
³ V.1.00 - Versão inicial, sem ajuste nos códigos de armazéns.
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function JGRT011A()
	Local _aArea 		:= FWGetArea()
	Local aButtons 		:= {}
	Local oButton1
	Local oFont1 		:= TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oFilO
	Local oDFilO
	Local cDFilO 		:= Space(50)
	Local oFilD
	Local oDFilD
	Local cDFilD 		:= Space(50)
	Local oARMO
	Local cARMO 		:= Space(TamSx3("C6_LOCAL")[1])
	Local oARMD
	Local cARMD 		:= Space(TamSx3("C6_LOCAL")[1])
	Local oARMF
	Local cARMF			:= Space(TamSx3("C6_LOCAL")[1])
	Local oCliente
	Local oFornec
	Local oSolicit
	Local cSolicit 		:= Space(30)
	Local oObser
	Local cObser
	Local oQuant
	Local nQuant 		:= 0
	Local oProduto
	Local cProduto 		:= Space(TamSx3("B1_COD")[1])
	Local oDescProd
	Local cDescProd		:= Space(TamSx3("B1_DESC")[1])
	// Local oGroup1
	Local oGroup2
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay6
	Local oSay7
	Local oSay8,oSay9
	Local bOk
	Local bSair
	Local lSai := .t.
	//Local oPanel1
	//Local oPanel
	Local nPosSay := 0
	Local nPosGet := 0
	Private _oSay10
	Private _oSay11
	Private _lDFilO := .F., _lDFilD := .T., _lARMO := .F., _lARMD := .F.
	Private _oVlTotal,_oQtItens
	Private _nVlTotal	:= 0
	Private _nQtItens	:= 0
	Private _cFilO 		:= cFilAnt //Space(04)
	Private _cFilD		:= Space(TamSX3("C5_FILIAL")[1])
	Private _cCliente 	:= Space(TamSx3("C5_CLIENTE")[1] + TamSx3("C5_LOJACLI")[1] + 1)
	Private _cFornec	:= Space(TamSx3("F1_FORNECE")[1] + TamSx3("F1_LOJA")[1] + 1)
	Private _oMSGetTrf
	Static oDlg

	// Definir os valores iniciais de filial e armazém
	// _cFilO := "0101"
	cARMO  := GetNewPar("JG_LOCORIT","") // Local de origem das transferências.
	cARMD  := GetNewPar("JG_LOCDEST","") // Local de destino temporário das transferências.
	cARMF  := GetNewPar("JG_LOCFINT","") // Local de final das transferências, após liberação do estoque.

	ValidFil(@_cFilO, _cFilD, @cDFilO, @cARMO, "O")
	fCliFor("F", _cFilO, @_cFornec)
	// Iif(!Empty(_cFilO), oFilD:SetFocus(), oFilO:SetFocus())
	// Fim da definição

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	DEFINE MSDIALOG oDlg TITLE "Transferência entre filiais - V.1.00" FROM C(000), C(000)  TO C(000), C(000) COLORS 0, 16777215 PIXEL

	oDlg:lMaximized := .T.

	oPanel:= tPanel():New(C(025),C(001),"",oDlg,,,,,16777215,C(510),C(060),.T.,.F.)

	nPosSay := 004
	nPosGet := 004

	@ C(nPosSay), C(004) SAY oSay1 PROMPT "Filial Origem" SIZE C(049), C(007) OF oPanel FONT oFont1 COLORS 0, 14342874 PIXEL
	@ C(nPosGet), C(047) MSGET oFilO VAR _cFilO SIZE C(021), C(007) OF oPanel COLORS 0, 16777215 FONT oFont1 VALID( IIf(ValidFil(@_cFilO, _cFilD, @cDFilO, @cARMO, "O"), fCliFor("F", _cFilO, @_cFornec), oFilO:SetFocus()) ) F3 "SM0" PIXEL When _lDFilO
	@ C(nPosGet), C(082) MSGET oDFilO VAR cDFilO SIZE C(106), C(007) OF oPanel COLORS 0, 16777215  PIXEL When .f.

	@ C(nPosSay), C(190) SAY oSay3 PROMPT "Armaz.Origem" SIZE C(067), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet), C(230) MSGET oARMO VAR cARMO SIZE C(010), C(007) OF oPanel COLORS 0, 16777215 PIXEL When _lARMO
	oBtn3 := TBtnBmp2():New( C(nPosGet),C(480),26,26,"AVGARMAZEM.PNG",,,,,oPanel,"Armazém de Origem",,,)

	@ C(nPosSay), C(255) SAY oSay9 PROMPT "Fornec./Loja" SIZE C(067), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet), C(293) MSGET oFornec VAR _cFornec SIZE C(040), C(007) OF oPanel COLORS 0, 16777215 PIXEL When .f.

	@ C(nPosGet-3),   C(391) GROUP oGroup2 TO C(050), C(510) PROMPT "Observação - Nota Fiscal" OF oPanel COLOR 0, 16777215 PIXEL
	@ C(nPosGet+5),   C(395) GET oObser VAR cObser MEMO SIZE C(101), C(036) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL

	@ C(nPosSay+=10) , C(004) SAY oSay2 PROMPT "Filial Destino" SIZE C(049), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet+=10) , C(047) MSGET oFilD VAR _cFilD SIZE C(021), C(007) OF oPanel COLORS 0, 16777215 FONT oFont1 VALID( IIf(ValidFil(@_cFilD, _cFilO, @cDFilD, @cARMD, "D", @cARMF), fCliFor("C", _cFilD, @_cCliente), oFilD:SetFocus()) ) F3 "SM0" PIXEL When _lDFilD
	@ C(nPosGet)		, C(082) MSGET oDFilD VAR cDFilD SIZE C(106), C(007) OF oPanel COLORS 0, 16777215 PIXEL When .f.

	@ C(nPosSay), C(190) SAY oSay4 PROMPT "Armaz.Destino" SIZE C(067), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet), C(230) MSGET oARMD VAR cARMD SIZE C(010), C(007) OF oPanel COLORS 0, 16777215 PIXEL When _lARMD
	oBtn4 := TBtnBmp2():New( C(nPosGet+10),C(480),26,26,"AVGBOX1_MDI.PNG",,,,,oPanel,"Armazém de Destino",,,)

	@ C(nPosSay), C(255) SAY oSay8 PROMPT "Cliente/Loja" SIZE C(067), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet), C(293) MSGET oCliente VAR _cCliente SIZE C(040), C(007) OF oPanel COLORS 0, 16777215 PIXEL When .f.

	@ C(nPosSay+=10), C(004) SAY oSay7 PROMPT "Solicitante" SIZE C(049), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet+=10), C(047) MSGET oSolicit VAR cSolicit SIZE C(141), C(007) OF oPanel COLORS 0, 16777215 FONT oFont1 PIXEL PICTURE "@!"

	//Lorran Ferreira - 13/08/2019
	@ C(nPosSay), C(190) SAY oSay4 PROMPT "Armaz.Final" SIZE C(067), C(007) OF oPanel FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(nPosGet), C(230) MSGET oARMF VAR cARMF SIZE C(010), C(007) OF oPanel COLORS 0, 16777215 PIXEL When _lARMD
	// oBtn4 := TBtnBmp2():New( C(nPosGet+20),C(480),26,26,"ESTOMOVI.PNG",,,,{|| MsgStop("Armazém destino após a Liberação da transferência!!") } ,oPanel,"Armazem de Destino",,,)
	oBtn4 := TBtnBmp2():New( C(nPosGet+20),C(480),26,26,"ESTOMOVI.PNG",,,,,oPanel,"Armazém de Destino",,,)

	***************************************************************************************
	//@ C(062), C(000) MSPANEL oPanel SIZE C(520), C(035) OF oDlg COLORS 0,16777215 CENTERED

	//oPanel1 := tPanel():Create(oDlg,C(062),C(000),"",,,,,16777215,C(520),C(035),.T.,.T.)
	oPnlP2 := tPanel():New(C(062),C(001),"",oDlg,,,,,16777215,C(510),C(015),.T.,.F.)

	@ C(004), C(003) SAY "Quant.:" SIZE C(035), C(007) OF oPnlP2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(004), C(025) MSGET oQuant VAR nQuant SIZE C(035), C(007) OF oPnlP2 COLORS 0, 16777215 FONT oFont1 PIXEL HASBUTTON PICTURE "@E 999,999"//PesqPict("SC6","C6_QTDVEN",14,2)
	@ C(004), C(065) SAY oSay6 PROMPT "Produto:" SIZE C(034), C(007) OF oPnlP2 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(004), C(090) MSGET oProduto VAR cProduto SIZE C(070), C(007) OF oPnlP2 COLORS 0, 16777215 FONT oFont1 F3 "XSB1C6" PIXEL VALID(fProduto(@cProduto, @cDescProd))
	@ C(004), C(162) MSGET oDescProd VAR cDescProd SIZE C(190), C(007) OF oPnlP2 COLORS 0, 16777215 FONT oFont1 PIXEL When .f.

	@ C(004), C(363) BUTTON oButton1 PROMPT "Incluir" SIZE C(044), C(008) OF oPnlP2 PIXEL ACTION(AddItem(@nQuant, @cProduto, @cDescProd, "", cARMO, cARMD), oQuant:SetFocus())
	oBtn2 := TBtnBmp2():New( C(004),C(830),28,28,"MDIEXCEL_OCEAN.PNG",,,,{|| FWMsgRun(, {|oSay| fImpCSV( @oSay, @nQuant, @cProduto, @cDescProd, "", cARMO, cARMD) }, "Processando - Imp.Arquivo CSV", "Aguarde, processando a rotina" ) }, oPnlP2,"(F2) Importar Arquivo CSV(Excel)",,,)
	fMSNewGe1()
	***************************************************************************************
	oPnlP3 := tPanel():New(C(190),C(001),"",oDlg,,,,,16777215,C(510),C(025),.T.,.F.)
	@ C(005), C(270) SAY "Valor Total:" SIZE C(067), C(009) OF oPnlP3 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(005), C(310) SAY _oVlTotal /* _oSay10 */ PROMPT Transform(_nVlTotal,PesqPict("SL1", "L1_VLRTOT" ,,1)) SIZE C(040), C(009) OF oPnlP3 COLOR CLR_HRED PIXEL  FONT oFont1

	@ C(005), C(380) SAY "Quant.Itens:" SIZE C(067), C(009) OF oPnlP3 FONT oFont1 COLORS 0, 16777215 PIXEL
	@ C(005), C(420) SAY _oQtItens /* _oSay11 */ PROMPT Transform(_nQtItens, "@E 999,999.99") SIZE C(040), C(009) OF oPnlP3 COLOR CLR_HRED PIXEL  FONT oFont1

	bOk 	:= {|| lSai := fGera(_cCliente, cARMO, cARMD, cARMF, cObser, cSolicit, _oMSGetTrf:aHeader, _oMSGetTrf:aCols), If(lSai, oDlg:End(), .T.)}
	bSair	:= {|| oDlg:End() }

	//AADD(aButtons, {"", {|| FWMsgRun(, {|oSay| fImpCSV() }, "Processando - Imp.Arquivo CSV", "Aguarde, processando a rotina" ) }, "(F2) Imp.Aquivo CSV"})

	SetKey( VK_F2,    {|| FWMsgRun(, {|oSay| fImpCSV(@oSay, @nQuant, @cProduto, @cDescProd, "", cARMO, cARMD) }, "Processando - Imp.Arquivo CSV", "Aguarde, processando a rotina" )} ) //Importar Arquivo CSV
	SetKey( K_CTRL_L, {|| U_JGRT007()} ) //Atalho para seleção do lote/sublote/validade

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bSair, , aButtons)

	SetKey( VK_F2, Nil )
	SetKey( K_CTRL_L, Nil )

	FWRestArea(_aArea)

Return(.T.)

//------------------------------------------------
Static Function fMSNewGe1()
	//------------------------------------------------
	Local nX
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {}//{"C6_ITEM","C6_PRODUTO","C6_QTDVEN","C6_PRUNIT","C6_TES"}
	Local aAlterFields := {"C6QTDVEN", "C6LOTECTL"}
	Local aSX3         := {}

	Aadd(aFields,{"C6_ITEM"		, "C6ITEM" 		,""				, ""	})
	Aadd(aFields,{"C6_PRODUTO"	, "C6PRODUTO" 	,""				, ""    })
	Aadd(aFields,{"B1_DESC"		, "C6DESCRI"  	,""				, ""	})
	Aadd(aFields,{"C6_QTDVEN"	, "C6QTDVEN" 	,""				, ""	})
	Aadd(aFields,{"C6_PRCVEN"	, "C6PRCVEN" 	,"Vl.Unit"		, ""	})
	Aadd(aFields,{"C6_LOCAL"	, "C6LOCAL" 	,""				, ""	})
	Aadd(aFields,{"C6_TES"		, "C6TES" 		,""				, ""	})
	Aadd(aFields,{"C6_LOTECTL"	, "C6LOTECTL" 	,""				, ""	})

	// Define field properties
	For nX := 1 to Len(aFields)
		aSX3 := u_fLoadSX3("S"+SubStr(aFields[nX][1],1,2), {aFields[nX][1]}, ;
							{"X3_TITULO","X3_PICTURE","X3_TAMANHO","X3_DECIMAL","X3_USADO","X3_TIPO","X3_F3","X3_CONTEXT","X3_CBOX","X3_RELACAO"})
		Aadd(aHeaderEx, {Iif(Empty(aFields[nX,3]),aSX3[1][1],aFields[nX,3]),aFields[nX,2],aSX3[1][2],aSX3[1][3],aSX3[1][4],aFields[nX,4],;
							aSX3[1][5],aSX3[1][6],aSX3[1][7],aSX3[1][8],aSX3[1][9],aSX3[1][10]})
		Aadd(aFieldFill, CriaVar(aFields[nX][1]))
	Next nX

	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	_oMSGetTrf := MsNewGetDados():New( C(078), C(002), C(190), C(510), GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields, , 999, "AllwaysTrue", "AllwaysTrue","AllwaysTrue" , oDlg, aHeaderEx, aColsEx)

	_oMSGetTrf:oBrowse:bChange    := {|| fAtuTotais()} //Atualizar totais ao mudar de linha
	_oMSGetTrf:oBrowse:bLostFocus := {|| fAtuTotais()} //Atualizar totais ao sair da linha

	_oMSGetTrf:cFieldOk := "U_JGRT11A1()"
	_oMSGetTrf:bDelOk	:= {|x| FDELLN(_oMSGetTrf:nAt) }

Return

/*/{Protheus.doc} JGRT11A1
Função para validar os campos ao editar o grid de pedidos.
Aqui, utilizada para atualizar os totais ao modificar a coluna de valor ou mudar de linha.
@type function
@version  
@author Jesus Ramos
@since 08/03/2026
@return variant, return_description
/*/
User Function JGRT11A1()
	Local nPDel       As Numeric
	Local nLinha      As Numeric
    Local nPosProduto As Numeric
    Local nPosQuant   As Numeric
    Local cProduto    As String
    Local nQuant      As Numeric
	Local lB1Rastro   As Logical
    Local lRet        As Logical

	lRet := .T.

	If ReadVar() == "M->C6QTDVEN"
		nPosProduto := GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)
		nPosQuant   := GdFieldPos("C6QTDVEN" , _oMSGetTrf:aHeader)
		nLinha      := _oMSGetTrf:nAt

		If nPosProduto > 0 .And. nPosQuant > 0 .And. nLinha > 0
			nPDel := Len(_oMSGetTrf:aCols[nLinha])
			If !_oMSGetTrf:aCols[nLinha][nPDel]
				cProduto  := aCols[nLinha][nPosProduto]
				nQuant    := aCols[nLinha][nPosQuant]
				lB1Rastro := (Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_RASTRO") == "L")
				If lB1Rastro .And. M->C6QTDVEN > 1
					FWAlertWarning(OemToAnsi("Para produto com controle de lote/serial, a quantidade deve ser unitária!"), OemToAnsi("Atenção"))
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		_oMSGetTrf:oBrowse:bEDITCOL := {|| fAtuTotais()} //Atualizar totais ao modificar a quantidade
	EndIf

Return(lRet)

/*/{Protheus.doc} AddItem
description
	Função controlar a chamada da função que adiciona os itens no pedido de transferência.
@type function
@version  
@author Samsung
@since 09/03/2026
@param nQuant, numeric, param_description
@param cProduto, character, param_description
@param cDescProd, character, param_description
@param cARMO, character, param_description
@param cARMD, character, param_description
@param _MsgAlert, variant, param_description
@return variant, return_description
/*/
Static Function AddItem( nQuant, cProduto, cDescProd, cLoteCtl, cARMO, cARMD, _MsgAlert )

	fIncluir( nQuant, cProduto, cDescProd, cLoteCtl, cARMO, cARMD, _MsgAlert )

	nQuant		:= 0
	cProduto 	:= Space(TamSx3("B1_COD")[1])
	cDescProd	:= Space(TamSx3("B1_DESC")[1])

Return()

/*/{Protheus.doc} fIncluir
description
	Função para incluir os itens no pedido de transferência.
	Realiza as validações necessárias antes de adicionar o item ao grid.
@type function
@version  
@author Samsung
@since 09/03/2026
@param nQuant, numeric, param_description
@param cProduto, character, param_description
@param cDescProd, character, param_description
@param cARMO, character, param_description
@param cARMD, character, param_description
@param cCodEstr, character, param_description
@param _MsgAlert, variant, param_description
@return variant, return_description
/*/
Static Function fIncluir(nQuant, cProduto, cDescProd, cLoteCtl, cARMO, cARMD, _MsgAlert)

	Local lLinha1   := .F.
	Local nPos      := 0
	Local nCusto    := 0
	Local cTes	    := ""
	Local nProdDupl := 0
	Local lB1Rastro := .F.
	Local _cItem    := PadR('0',TamSX3("C6_ITEM")[1],'0')
	Local lRet      := .T.
	Local x

	Default _MsgAlert := .T.
	Default cCodEstr  := ""

	_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .T. //Libera para adicionar nova linha na aCols

	lLinha1 := Iif( Len(_oMSGetTrf:aCols) = 1 .And. Empty(_oMSGetTrf:aCols[1][1]) , .T. , .F. )

	If Empty(cProduto) .Or. Empty(_cFilO)
		Return(.T.)
	EndIf

	lB1Rastro := (Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_RASTRO") == "L")

	If lB1Rastro .And. nQuant > 1
		FWAlertWarning(OemToAnsi("Para produto com controle de lote/serial, a quantidade deve ser unitária!"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	nProdDupl := 0

	//Verifica se o produto ja foi adicionado
	//aEval(_oMSGetTrf:aCols,{|x| IIf( x[GdFieldPos("C6PRODUTO",_oMSGetTrf:aHeader)]==cProduto , nProdDupl:=x ,"" ) })
	For x:=1 To Len(_oMSGetTrf:aCols)
		If !_oMSGetTrf:aCols[x][Len(_oMSGetTrf:aCols[x])] .And. Alltrim(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO",_oMSGetTrf:aHeader)]) == Alltrim(cProduto)
			If !lB1Rastro .Or. Alltrim(_oMSGetTrf:aCols[x][GdFieldPos("C6LOTECTL",_oMSGetTrf:aHeader)]) == Alltrim(cLoteCtl)
				nProdDupl := x
				Exit
			EndIf
		EndIf
	Next x

	If nProdDupl > 0
		If !lB1Rastro
			FWAlertWarning(OemToAnsi("O produto "+AllTrim(cProduto)+" já foi adicionado à lista."+CRLF+CRLF+;
										"Você deve alterar a quantidade do item já existente!"), OemToAnsi("Atenção"))
		Else
			FWAlertWarning(OemToAnsi("O produto "+AllTrim(cProduto)+" já foi adicionado à lista com o lote "+cLoteCtl+"."+CRLF+CRLF), OemToAnsi("Atenção"))
		EndIf
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	// If cFilAnt <> _cFilO
	// 	cFilAnt := _cFilO
	// EndIf

	U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL

	If Empty(cARMO)
		FWAlertWarning(OemToAnsi("Informe o armazém de Origem!"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	If Empty(cARMD)
		FWAlertWarning(OemToAnsi("Informe o armazém de Destino!"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	If nQuant = 0
		FWAlertWarning(OemToAnsi("Informe a quantidade para o produto <b>"+cProduto+"</b>"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	If Empty(_cCliente)
		FWAlertWarning(OemToAnsi("O Cliente(Filial de destino) não foi localizado!"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	// Determinação do valor do custo unitário para a transferência:
	nCusto := ROUND(Posicione("SB2", 1, FWxFilial("SB2") + cProduto + cARMO, "B2_CM1"), 2)

	If nCusto = 0
		nCusto := ROUND(Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_CUSTD"), 2)
	EndIf
	If nCusto = 0
		nCusto := ROUND(Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_UPRC"), 2)
	EndIf
	If nCusto = 0
		nCusto := ROUND(Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_PRV1"), 2)
	EndIf

	If nCusto = 0
		FWAlertWarning(OemToAnsi("Não foi localizado preço de custo para saída do produto <b>"+cProduto+"</b>"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	// Determinação da quantidade disponível para a transferência.
	// Caso o estoque esteja zerado, o item não será adicionado ao grid.
	// Caso o saldo em estoque seja menor que a quantidade solicitada, o operador será questionado sobre prosseguir com o ajuste ou ignorar o item.
	nQuant := fEstoque(cProduto, cARMO, nQuant, _MsgAlert)

	If nQuant = 0
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Desativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	If !Empty(cLoteCtl)
		DbSelectArea("SB8")
		SB8->(DbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		If !(SB8->(DbSeek(FWxFilial("SB8") + cProduto + cARMO + cLoteCtl)) .And.;
				SB8->B8_FILIAL == FWxFilial("SB8") .And. SB8->B8_PRODUTO == cProduto .And. SB8->B8_LOCAL == cARMO .And. SB8->B8_LOTECTL == cLoteCtl .And. SB8->B8_SALDO > 0)
			FWAlertWarning(OemToAnsi("Não foi localizado o lote de controle informado para o produto <b>"+cProduto+"</b> ou o lote não tem saldo em estoque."), OemToAnsi("Atenção"))
			_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
			Return(.F.)
		EndIf
	EndIf

	// Determinação do TES
	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	cTes := MaTesInt(	2, ;
						'04', ;
						Substr(_cCliente,1,8), ;
						Substr(_cCliente,9,4), ;
						"C", ;
						cProduto ;
					)

	If Empty(cTes)
		FWAlertWarning(OemToAnsi("Não foi localizado TES de saída para produto!"), OemToAnsi("Atenção"))
		_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .F. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.
		Return(.F.)
	EndIf

	If !lLinha1
		If !_oMSGetTrf:AddLine()
			FWAlertError(OemToAnsi("Uma nova linha Não Foi criada!"), OemToAnsi("Erro"))
		EndIf
	EndIf

	nPos := Len(_oMSGetTrf:aCols)

	If nPos > 0
		_lDFilO := .F.
		_lDFilD := .F.
		_lARMO 	:= .F.
		_lARMD 	:= .F.
	EndIf

	//_cItem := PadR('0',TamSX3("C6_ITEM")[1],'0')
	//_cItem := Soma1(_cItem,TamSX3("C6_ITEM")[1])

	If nPos = 1
		_cItem := Soma1(_cItem,TamSX3("C6_ITEM")[1])
	Else
		_cItem := Soma1( _oMSGetTrf:aCols[nPos-1][GdFieldPos("C6ITEM",_oMSGetTrf:aHeader)] , TamSX3("C6_ITEM")[1] )
	EndIf

	_oMSGetTrf:aCols[nPos][GdFieldPos("C6ITEM",		_oMSGetTrf:aHeader)]	:= _cItem
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6PRODUTO",	_oMSGetTrf:aHeader)]	:= Pad(cProduto, TamSX3("C6_PRODUTO")[1])
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6DESCRI",	_oMSGetTrf:aHeader)]	:= Pad(cDescProd, TamSX3("C6_DESCRI")[1])
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6QTDVEN",	_oMSGetTrf:aHeader)]	:= nQuant
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6PRCVEN",	_oMSGetTrf:aHeader)]	:= nCusto
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6LOCAL",	_oMSGetTrf:aHeader)]	:= Pad(cARMO, TamSX3("C6_LOCAL")[1])
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6TES",		_oMSGetTrf:aHeader)]	:= Pad(cTes, TamSX3("C6_TES")[1])
	_oMSGetTrf:aCols[nPos][GdFieldPos("C6LOTECTL",	_oMSGetTrf:aHeader)]	:= Pad(cLoteCtl, TamSX3("C6_LOTECTL")[1])

	_oMSGetTrf:ForceRefresh()

	_nVlTotal := 0
	_nQtItens := 0

	For x:=1 To Len(_oMSGetTrf:aCols)

		If !_oMSGetTrf:aCols[x,len(_oMSGetTrf:acols[x])]

			_nVlTotal += _oMSGetTrf:aCols[x][GdFieldPos("C6PRCVEN", _oMSGetTrf:aHeader)] * _oMSGetTrf:aCols[x][GdFieldPos("C6QTDVEN", _oMSGetTrf:aHeader)]

			_nQtItens++

		EndIf

	Next x

	nQuant		:= 0
	cProduto 	:= Space(TamSx3("B1_COD")[1])
	cDescProd	:= Space(TamSx3("B1_DESC")[1])

	_oMSGetTrf:oBrowse:OMOTHER:OBROWSE:OMOTHER:LINSERT := .f. //Dasativa criação de nova linha na aCols, para o usuario nao adicionar nova linha com seta para baixo.

Return(lRet)

Static Function fEstoque(cProduto, cARMO, nQuant, _MsgAlert)

	Local nStok := 0

	Default _MsgAlert := .T.

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If SB2->(DbSeek(xFilial("SB2")+PADR(cProduto,LEN(SB2->B2_COD))+cARMO))
		nStok := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMP)
	EndIf

	If nQuant > nStok

		If _MsgAlert
			FWAlertWarning(OemToAnsi("Não há saldo disponível para o produto <b>"+cProduto+"</b>"), OemToAnsi("Saldo Insuficiente"))
		EndIf
		If nStok > 0
			If FWAlertNoYes("A Quantidade informada não é suficiente, deseja utilizar a quantidade disponível?"+CRLF+CRLF+;
							"Quant.Solicitada: "+cValToChar(nQuant)+CRLF+"Quant.Disponível: "+cValToChar(nStok)+CRLF+CRLF+;
							"Saldo Em Estoque - Produto: "+cProduto+"-"+Posicione("SB1",1,FWxFilial("SB1")+Pad(cProduto,TamSx3("B1_COD")[1]),"B1_DESC"))
				nQuant := nStok
			Else
				Return(0)
			EndIf
		Else
			Return(0)
		EndIf

	EndIf

Return(nQuant)

Static Function fAtuTotais()

	Local nQuant := 0
	Local nPDel	 := Len(_oMSGetTrf:acols[1])
	Local x

	_nVlTotal := 0
	_nQtItens := 0

	For x:=1 To Len(_oMSGetTrf:aCols)

		nQuant := 0

		If !_oMSGetTrf:aCols[x,nPDel] .And. Alltrim(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)]) <> "******"

			If !Empty(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)])
				nQuant := fEstoque(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)],_oMSGetTrf:aCols[x][GdFieldPos("C6LOCAL", _oMSGetTrf:aHeader)],_oMSGetTrf:aCols[x][GdFieldPos("C6QTDVEN", _oMSGetTrf:aHeader)])
			EndIf

			If nQuant = 0 .And. !Empty(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)])

				_oMSGetTrf:aCols[x,nPDel] := .T.

				FWAlertWarning(OemToAnsi("Não há saldo disponível. Por isso, a linha será excluída!"+CRLF+CRLF+;
											"Produto: "+aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)]), OemToAnsi("Saldo Insuficiente"))

				_oMSGetTrf:aCols[x][GdFieldPos("C6QTDVEN", _oMSGetTrf:aHeader)] := nQuant

				_oMSGetTrf:ForceRefresh()

			Else

				_oMSGetTrf:aCols[x][GdFieldPos("C6QTDVEN", _oMSGetTrf:aHeader)] := nQuant

				_nVlTotal += _oMSGetTrf:aCols[x][GdFieldPos("C6PRCVEN", _oMSGetTrf:aHeader)] * _oMSGetTrf:aCols[x][GdFieldPos("C6QTDVEN", _oMSGetTrf:aHeader)]

				_nQtItens++

			EndIf
		ElseIf "**" $ Alltrim(_oMSGetTrf:aCols[x][GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)])
			_oMSGetTrf:aCols[x,nPDel] := .T.
		EndIf

	Next x

	_oVlTotal:Refresh()
	_oQtItens:Refresh()
	// _oSay10:Refresh()
	// _oSay11:Refresh()
	oDlg:Refresh()

Return(.T.)

//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction:
>>Faz a busca do produto por codigo ou por codigo de barras.

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//--------------------------------------------------------------
Static Function fCliFor(cTp,cFil,cCliFor)

	Local aSM0    := FWLoadSM0()
	// Local bSM0		:= {|x| MsgInfo(x) }
	Local _cCNPJ := ""

	If Empty(cFil)
		Return()
	EndIf

	aEval(aSM0,{|x| IIf(x[1]==cEmpAnt .And. x[2]==cFil ,_cCNPJ:=x[18],"") })

	If Empty(_cCNPJ)
		FWAlertWarning("O CNPJ da filial é inválido (vazio)!", "Atenção")
		Return(.F.)
	EndIf

	If cTp == "C"

		// If cFilAnt <> _cFilO
		// 	cFilAnt := _cFilO
		// EndIf

		U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL

		SA1->(dbsetOrder(3))
		If SA1->(dbSeek(xFilial("SA1")+_cCNPJ))
			cCliFor := SA1->A1_COD+SA1->A1_LOJA
		EndIf

	ElseIf cTp == "F"

		U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

		SA2->(dbsetOrder(3))
		If SA2->(dbSeek(xFilial("SA2")+_cCNPJ))
			cCliFor := SA2->A2_COD+SA2->A2_LOJA
		EndIf

	EndIf

Return

//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction:
>>Faz a busca do produto por codigo ou por codigo de barras.

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//--------------------------------------------------------------
Static Function fProduto(cCod,cDescProd)

	Local cProduto := Alltrim(cCod)

	If Len(cProduto) == 6
		cDescProd := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
	ElseIf Len(cProduto) > 6
		cDescProd := Posicione("SB1",5,xFilial("SB1")+cProduto,"B1_DESC")
	Else
		cCod 		:= Space(TamSx3("B1_COD")[1])
		cDescProd	:= Space(TamSx3("B1_DESC")[1])
	EndIf

	Return()

//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction: ValidFil
>>Verifica se a filial selecionada é validada

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//------------------------------------------------------------------
Static Function ValidFil(cFilPos, cFilValid, cDescFil, _cARMZ, _cTp, _cARMF)
	Local lRet := .T.

	// _cARMZ := Space(02)

	If !FWFilExist(cEmpAnt,cFilPos)
		FWAlertWarning(OemToAnsi("A filial de "+IIf(_cTp == "O","origem","destino")+" ("+cFilPos+") informada não existe!"), OemToAnsi("Atenção"))
		cFilPos := Space(4)
		cDescFil := Space(60)
		Return(.f.)
	EndIf

	If !FWFilExist(cEmpAnt,cFilValid)
		FWAlertWarning(OemToAnsi("A filial de "+IIf(_cTp == "O","destino","origem")+" ("+cFilValid+") não existe!"), OemToAnsi("Atenção"))
		cFilPos := Space(4)
		cDescFil := Space(60)
		Return(.f.)
	EndIf

	If cFilPos == cFilValid
		FWAlertWarning(OemToAnsi("As filiais de origem e destino não podem ser iguais!"), OemToAnsi("Atenção"))
		cFilPos := Space(4)
		cDescFil := Space(60)
		Return(.f.)
	EndIf

	If _cTp == "O"
		If !(cFilPos $ "0101;0103;0104;")
			FWAlertWarning(OemToAnsi("A filial de origem deve ser 0101, 0103 ou 0104!"), OemToAnsi("Atenção"))
			cFilPos := Space(4)
			cDescFil := Space(60)
			Return(.f.)
		EndIf
		 _cARMO := GetNewPar("JG_LOCORIT","",cFilPos)

	ElseIf _cTp == "D"

		If !(cFilPos $ "0101;0103;0104;")
			FWAlertWarning(OemToAnsi("A filial de destino deve ser 0101, 0103 ou 0104!"), OemToAnsi("Atenção"))
			cFilPos := Space(4)
			cDescFil := Space(60)
			Return(.f.)
		EndIf
		_cARMZ := GetNewPar("JG_LOCDEST","",cFilPos)
		_cARMF := GetNewPar("JG_LOCFINT","",cFilPos)
	EndIf

	cDescFil := FWFilialName(cEmpAnt,cFilPos,1)
	// _cARMZ := "01" // Por enquanto, o armazém de trabalho será fixo.

Return(lRet)


Static Function fImpCSV( oSay, nQuant, cProduto, cDescProd, cLoteCtl, cARMO, cARMD )

	Local oError := ErrorBlock({|e| _cErro := ("Mensagem de Erro: " +chr(10)+ e:Description)})
	Local _cErro := ""
	Local _cTipoArq := ""
	Local _cLinha := ""
	Local _aLin	:= {}
	Local _cKey := ";"
	Local _MSG	 := {| cStr | oSay:cCaption := (cStr) , ProcessMessages() }
	Local cType := OemToAnsi("Arquivos CSV") + "(*.csv) |*.csv|"
	Local _MsgAlert := .T.
	Local nCont := 0

	If !FWAlertNoYes(OemToAnsi("Considerar produtos com saldo ZERO na importação?"+CRLF+CRLF+"NÃO > A mensagem do produto com saldo ZERO não será apresentada na tela!"), OemToAnsi("Atenção"))
		_MsgAlert := .F.
	EndIf

	If Empty(cARMO)
		FWAlertWarning(OemToAnsi("Informe o armazém de Origem!"), OemToAnsi("Atenção"))
		Return()
	EndIf

	If Empty(cARMD)
		FWAlertWarning(OemToAnsi("Informe o armazém de Destino!"), OemToAnsi("Atenção"))
		Return()
	EndIf

	If Empty(_cFilO) .Or. Empty(_cFilD)
		Return()
	EndIf

	Eval(_MSG,"Localizando arquivo...")
	_cTipoArq := 	cGetFile ( cType , 'Importar Arquivo CSV(Excel)', 1, 'C:\TEMP', .T., GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.,.T.)

	If Empty(_cTipoArq)
		Return()
	EndiF

	Begin Sequence
		nHandle := FT_FUse(_cTipoArq)
	End Sequence
	ErrorBlock(oError)

	If nHandle = -1
		FWAlertError("Erro ao abrir o arquivo "+_cTipoArq+": "+_cErro, "Erro")
	Else
		*************************
		Eval(_MSG,"Lendo Arquivo...")
		//Monta o cabecalho do arquivo
		FT_FGoTop()
		_cLinha  := FT_FReadLn()
		_aLin := aClone(Separa(_cLinha,_cKey,.T.))
		*************************
		If Len(_aLin) = 2
			_aLin := {}
			FT_FSKIP()
			While !FT_FEOF()

				nCont++
				Eval(_MSG,"Importando Linha - "+cValToChar(nCont))

				_cErro := ""
				_cLinha  := FT_FReadLn()

				_aLin := aClone(Separa(_cLinha,_cKey,.T.))

				If Len(_aLin) >= 2

					_aLin[1]	:= Alltrim(_aLin[1])
					cProduto 	:= Substr( StrTran(_aLin[1],'"',"") ,1,6)
					cDescProd := Posicione("SB1",1,xFilial("SB1")+Pad(cProduto,TamSx3("B1_COD")[1]),"B1_DESC")
					nQuant 	:= Val(_aLin[2])
					If Len(_aLin) >= 3
						cLoteCtl := Alltrim(_aLin[3])
					Else
						cLoteCtl := ""
					EndIf

					If nQuant > 0
						AddItem(@nQuant, @cProduto, @cDescProd, cLoteCtl, cARMO, cARMD, _MsgAlert)
					EndIf
				Else
					FWAlertWarning(OemToAnsi("Problema na linha "+cValToChar(FT_FRecno())+" do arquivo selecionado, esse registo não sera importado"), OemToAnsi("Atenção"))
				EndIf

				ErrorBlock(oError)
				FT_FSKIP()
			EndDo

		Else

			FWAlertWarning(OemToAnsi("Arquivo selecionado fora do Layout!"), OemToAnsi("Atenção"))

		EndIf
		FT_FUSE()
	EndIf

	FWAlertSuccess(OemToAnsi("Importação Finalizada!"),OemToAnsi("Sucesso"))

Return


Static Function fGera(_cCliente, cARMO, cARMD, cARMF, cObser, cSolicit, aHeader, aCols)

	Local lGera			:= .T.
	Local aColsAx		:= {}
	Local cMsg			:= ""
	Local cMsgLote      := ""
	Local nQuant		:= 0
	Local aDoc
	Local nPDel			:= len(aCols[1])
	Local aSC5			:= {}
	Local aSC6			:= {}
	Local x
	Local cProduto		:= ""
	Local cLoteCtl		:= ""
	Local cLocalEst		:= ""
	Local cNumLote		:= ""
	Local cDtValid		:= SToD(Space(8))
	// Local nItensAptos	:= 0

	If cFilAnt <> _cFilO
		// cFilAnt := _cFilO
		U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL
	EndIf

	If !FWAlertYesNo(OemToAnsi("Confirma a Transferência para a filial "+_cFilD+"?"), OemToAnsi("Atenção"))
		Return(.F.)
	EndIf

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

	DbSelectArea("SB8")
	SB8->(DbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)

	If Len(aCols) > 0

		For x:=1 To Len(aCols)

			If (Empty(aCols[x][GdFieldPos("C6PRODUTO", aHeader)]) .Or. "**" $ aCols[x][GdFieldPos("C6PRODUTO", aHeader)]) .And. !aCols[x,nPDel]
				aCols[x,nPDel] := .T.
			Else
				cLoteCtl  := Pad(aCols[x][GdFieldPos("C6LOTECTL", aHeader)],TamSx3("B8_LOTECTL")[1])
				cProduto  := Pad(aCols[x][GdFieldPos("C6PRODUTO", aHeader)],TamSx3("B1_COD"    )[1])
				cLocalEst := Pad(aCols[x][GdFieldPos("C6LOCAL"  , aHeader)],TamSx3("B8_LOCAL"  )[1])
				If !SB1->(DbSeek(FWxFilial("SB1")+cProduto)) .Or. SB1->B1_FILIAL <> FWxFilial("SB1") .Or. SB1->B1_COD <> cProduto
					aCols[x,nPDel] := .T.
					cMsg += "Item: "+cValToChar(x)+" - Produto <b>"+cProduto+"</b>: Não localizado."+CRLF
				EndIf
			EndIf

			cNumLote := ""
			cDtValid := SToD(Space(8))

			//Verifica saldo em estoque
			If !aCols[x,nPDel]
				nQuant := fEstoque(cProduto, cLocalEst, aCols[x][GdFieldPos("C6QTDVEN", aHeader)])
				If nQuant = 0
					// aCols[x,nPDel] := .T.
					cMsg += "Item: "+cValToChar(x)+" - Produto <b>"+cProduto+"</b>: Sem saldo disponível no estoque."+CRLF
				ElseIf SB1->B1_RASTRO == "L"
					If Empty(cLoteCtl)
						cMsgLote += "Item: "+cValToChar(x)+" - Produto <b>"+cProduto+"</b>: Sem lote informado."+CRLF
					Else
						If !(SB8->(DbSeek(FWxFilial("SB8") + cProduto + cLocalEst + cLoteCtl)) .And.;
								SB8->B8_FILIAL == FWxFilial("SB8") .And. SB8->B8_PRODUTO == cProduto .And. SB8->B8_LOCAL == cLocalEst .And. SB8->B8_LOTECTL == cLoteCtl .And. SB8->B8_SALDO > 0)
							lGera := .F.
							cMsg += "Item: "+cValToChar(x)+" - Produto <b>"+cProduto+"</b>: Lote informado <b>"+cLoteCtl+"</b> não existe ou não tem saldo."+CRLF
						Else
							cNumLote := SB8->B8_NUMLOTE
							cDtValid := SB8->B8_DTVALID
						EndIf
					EndIf
				EndIf
			EndIf

			If !aCols[x,nPDel]

				// nItensAptos++

				Aadd(aColsAx, {aClone(aCols[x]), cNumLote, cDtValid})

			EndIf

		Next x

		// If Len(aColsAx) > 0
		// 	aCols := aColsAx
		// Else
		// 	aColsAx := aCols
		// 	aCols := {}
		// EndIf
	EndIf

	If Empty(_cFilO)
		lGera := .F.
		cMsg += ">>O Cliente da filial de origem não foi informado!"+CRLF
	EndIf
	If Empty(_cCliente)
		lGera := .F.
		cMsg += ">>O Cliente da filial de origem não foi informado!"+CRLF
	EndIf
	If Empty(cARMO)
		lGera := .F.
		cMsg += ">>O Armazém de origem não foi informado!"+CRLF
	EndIf
	If Empty(cARMD)
		lGera := .F.
		cMsg += ">>O Armazém de destino não foi informado!"+CRLF
	EndIf
	If Empty(cARMF)
		lGera := .F.
		cMsg += ">>O Armazém FINAL para liberação não foi informado!"+CRLF
	EndIf
	If Empty(cSolicit)
		lGera := .F.
		cMsg += ">>Informe o Solicitante da Transferência!"+CRLF
	EndIf
	If Len(aHeader) = 0
		lGera := .F.
	EndIf
	// If Len(aCols) = 0
	// 	lGera := .F.
	// 	aCols := aColsAx
	// 	cMsg += ">>Não há itens para gerar a Transferência!"+CRLF
	// EndIf
	// If nItensAptos = 0
	If Len(aColsAx) = 0
		lGera := .F.
		// aCols := aColsAx
		cMsg += ">>Não há itens aptos para a geração da Transferência!"+CRLF
	EndIf

	If lGera

		If Empty(cMsgLote) .Or. ;
			FWAlertYesNo(OemToAnsi("Algum(ns) item(ns) que exige(m) lote/serial não teve(tiveram) o apontamento do lote/serial."+CRLF+;
									"Você confirma a geração do pedido para apontar estas informações durante a separação do pedido?"+CRLF+CRLF+cMsgLote), OemToAnsi("Atenção"))

			cObser += CRLF+"Solicitante: "+cSolicit
			cObser += CRLF+"Usuario: "+Upper(cUSERNAME)

			//Montagem do Array contendo os campos e valores do cabeçalho (SC5) para ExecAuto MATA410
			aSC5 := {}

			AAdd(aSC5, {"C5_TIPO"			, "N"					, Nil} )
			AAdd(aSC5, {"C5_CLIENTE"		, Substr(_cCliente,1,6)	, Nil} )
			AAdd(aSC5, {"C5_LOJACLI"		, Substr(_cCliente,7,4)	, Nil} )
			AAdd(aSC5, {"C5_CONDPAG"		, "001"					, Nil} )
			AAdd(aSC5, {"C5_XFILTRF"        , _cFilD                , Nil} )
			AAdd(aSC5, {"C5_XLOCDES"        , cARMD                 , Nil} )
			AAdd(aSC5, {"C5_XLOCFIN"        , cARMF                 , Nil} )

			//Montagem do Array contendo os campos e valores dos itens (SC6) para ExecAuto MATA410
			aSC6 := {}

			For x:=1 To Len(aColsAx)

				// If !aColsAx[x,nPDel]

					aLinha := {}

					//Carga da linha de um item

					aAdd(aLinha, {"C6_ITEM"   , aColsAx[x][1][GdFieldPos("C6ITEM"   , aHeader)], Nil} )
					aAdd(aLinha, {"C6_PRODUTO", aColsAx[x][1][GdFieldPos("C6PRODUTO", aHeader)], Nil} )
					aAdd(aLinha, {"C6_QTDVEN" , aColsAx[x][1][GdFieldPos("C6QTDVEN" , aHeader)], Nil} )
					aAdd(aLinha, {"C6_QTDLIB" , aColsAx[x][1][GdFieldPos("C6QTDVEN" , aHeader)], Nil} )
					aAdd(aLinha, {"C6_PRCVEN" , aColsAx[x][1][GdFieldPos("C6PRCVEN" , aHeader)], Nil} )
					aAdd(aLinha, {"C6_PRUNIT" , 0                                              , Nil} )
					aAdd(aLinha, {"C6_LOCAL"  , aColsAx[x][1][GdFieldPos("C6LOCAL"  , aHeader)], Nil} )
					aAdd(aLinha, {"C6_LOTECTL", aColsAx[x][1][GdFieldPos("C6LOTECTL", aHeader)], Nil} )
					aAdd(aLinha, {"C6_NUMLOTE", aColsAx[x][2]                                  , Nil} )
					aAdd(aLinha, {"C6_DTVALID", aColsAx[x][3]                                  , Nil} )

					Aadd(aSC6, aLinha)

				// EndIf

			Next x

			// aAdd(aSC5,{ "C5_XLOCFIM"		, cARMF })
			// aAdd(aSC5,{ "C5_XMOVTRF"	, JGTrPVPFt })
			
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³                 		Gera Pedido e Nota fiscal de saida					  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			aDoc := U_JGRT011B( 0, _cCliente, cARMO, cARMD, cObser, aSC5, aSC6 )
			MsUnLockAll()
			If cFilAnt <> _cFilO
				// cFilAnt := _cFilO
				U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL
			EndIf

			If Len(aDoc) >= 5 .And. !Empty(aDoc[5])
				U_JGRT11_E(aDoc[5], JGTrPVPSp)//Grava Status no Pedido
			EndIf

			// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ³                 		Envia e valida nfe no sefaz				              ³
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			// FWMsgRun(, {|oSay| lGeraNfe := U_RFATA25D(@oSay,aDoc[1],aDoc[2],"1") }, "Processando - Nota de Saida NFESEFAZ", "Aguarde, processando a rotina" )
			// MsUnLockAll()
			// U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

			// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ³                 Gera Nota Fiscal de entrada na filial de destino			     ³
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			// If !Empty(aDoc[1]) .And. lGeraNfe
			// 	U_RFATA25C(aDoc[1],aDoc[2],DtoS(dDataBase))
			// EndIf
			FWFreeArray(aSC5)
			FWFreeArray(aSC6)
			FWFreeArray(aLinha)

		Else

			lGera := .F.

		EndIf

	Else

		FWAlertWarning(OemToAnsi(cMsg), OemToAnsi("Atenção"))

	EndIf

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

Return lGera
/*
Static Function fListArmz(_cTp,_cFilO,_cFilD,_cARMZ)//fArmOrg

	Local _aArmz := {}
	Local oDlgAmz
	Local oQual,cVarQ
	Local cTpArmz := ""

	Default _cARMZ := ""

	If Empty(_cFilO) .Or. Empty(_cFilD)
		Aviso(OemToAnsi("Atenção"),OemToAnsi("A filial de origem ou destino não foi informada!"),{"Retornar"})
		Return()
	EndIf

	If _cTp == "O"
		_aArmz := U_RFATA26("RFATA25A",_cFilO,_cFilD,"1O")
		cTpArmz := "Origem"
	ElseIf _cTp == "D"
		_aArmz := U_RFATA26("RFATA25A",_cFilO,_cFilD,"1D")
		cTpArmz := "Destino"
	EndIf

	If Len(_aArmz) > 0
		DEFINE MSDIALOG oDlgAmz TITLE OemToAnsi("Seleção de Armazem liberado") STYLE DS_MODALFRAME From 145,0 To 342,260 COLORS 0, 16777215 OF oMainWnd PIXEL
		//oDlgAmz:lEscClose := .F.
		@ 02,02 TO 080,129 LABEL OemToAnsi("Selecione o armazem - "+cTpArmz) OF oDlgAmz  PIXEL
		@ 10,06 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi("Codigo     "),OemToAnsi("Nome") FIELDSIZES 15,30 SIZE 120,065 ON DBLCLICK (_cARMZ:=_aArmz[oQual:nAt,1],oDlgAmz:End()) NoScroll OF oDlgAmz PIXEL
		oQual:SetArray(_aArmz)
		oQual:bLine := { || { _aArmz[oQual:nAt,1],_aArmz[oQual:nAt,2] }}
		DEFINE SBUTTON FROM 083,100 TYPE 2 ACTION oDlgAmz:End() ENABLE OF oDlgAmz
		ACTIVATE MSDIALOG oDlgAmz CENTERED
	Else

		If _cTp == "O"
			Aviso(OemToAnsi("Atenção"),OemToAnsi("Não a armazém de origem liberado saindo da filial "+_cFilO+" para filial "+_cFilD+"! "),{"Retornar"})
		Else
			Aviso(OemToAnsi("Atenção"),OemToAnsi("Não a armazém de destino liberado saindo da filial "+_cFilO+" para filial "+_cFilD+"! "),{"Retornar"})
		EndIf

		_cARMZ := Space(02)

		Return()
	EndIf

Return()
*/
/*
Static Function SetArmazF(cArmzO,cArmzD)

	Local cDeParaArmz := GETMV("ES_LOCDEPA",,"")//"13;01;13%14;01;14"
	Local cLOCVIRT	  := GETMV("MV_LOCVIRT",,"XX")
	Local cLOCLIBPD	  := GETMV("ES_LOCPDLB",,"")
	Local aArray1 := {}
	Local aArray2 := {}
	Local x

	aArray1 := StrTokArr2( Alltrim(cDeParaArmz), "%" )

	For x:=1 To Len(aArray1)

		Aadd( aArray2 , Aclone(StrTokArr2( Alltrim(aArray1[x]), ";" )) ) 

	Next x

	cARMF := cLOCLIBPD

	If !Empty(cArmzO) .And. !Empty(cArmzD)

		If cArmzD $ cLOCVIRT
			cARMF := cArmzD
		EndIf

		For x:=1 To Len(aArray2)

			If aArray2[x][1]==cArmzO .And. aArray2[x][2]==cArmzD
				cARMF := aArray2[x][3]
				Exit
			EndIf

		Next x

	Else
		cARMF := Space(02)
	EndIf

Return()
*/

/*
Função: FDELLN
Tipo: Estática
Finalidade: Se tiver kit delata ou recupera os componentes
Parâmetro(s):
- nLinha: Linha atual do Acols.
*/
Static Function FDELLN(nLinha)
	Local nPosProd	 := GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)
	Local nPDel		 := Len(_oMSGetTrf:aCols[nLinha])

	If !Empty(_oMSGetTrf:aCols[nLinha][nPosProd]) .And. !("**" $ Alltrim(_oMSGetTrf:aCols[nLinha][nPosProd]))

		_oMSGetTrf:aCols[nLinha][nPDel] := !_oMSGetTrf:aCols[nLinha][nPDel]

	EndIf

	fAtuTotais()

	_oMSGetTrf:ForceRefresh()

Return(.F.)
