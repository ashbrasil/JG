#include "totvs.ch"
#Include "TopConn.Ch"
#Include "tbiconn.ch"

#Define nPEmpresa 3
#Define nPFilial  2

/*/{Protheus.doc} JGRT007

	Rotina para consulta de lote/serial, a partir do atalho CTRL+L, a partir de um orçamento do Venda Assistida ou um Pedido de Venda ou um apontamento do Facilitador de Transferências.
	Caso selecionado algum lote, suas informações são utilizadas para preencher as variáveis das respectivas rotinas de origem.

@type    function
@version 1.0
@author  Jesus Ramos
@since   09/05/2026
@param Nil
@return Nil
/*/
User Function JGRT007()
	Local cAliasAnt		:= Alias()
	Local aArea    		:= FWGetArea()
	Local lEhVndAss		:= FWIsInCallStack("LOJA701")       // Verifica se a chamada é proveniente do Venda Assistida, para ajustar as informações exibidas na consulta de lote/serial conforme o caso.
	Local lEhPedVen		:= FWIsInCallStack("MATA410")       // Verifica se a chamada é proveniente do Pedido de Venda, para ajustar as informações exibidas na consulta de lote/serial conforme o caso.
	Local lEhFacTrf		:= FWIsInCallStack("U_JGRT011A")    // Verifica se a chamada é proveniente do Facilitador de transferências, para ajustar as informações exibidas na consulta de lote/serial conforme o caso.
	Local cJGFILSUBE	:= GetNewPar("JG_FILSUBE", cFilAnt) // Parâmetro que, se existir, informa a filial substituta para o estoque da filial corrente.
	Local nLinha   		:= 0
	Local aLoteRet 		:= {}
	Local lOk      		:= .T.

	Private cFilEstoque := cFilAnt 							// Inicialmente, recebe a filial logada, que será ajustada para a filial do parâmetro JG_FILSUBE, caso exista e seu conteúdo difira da filial logada.
	Private cCodProduto := Space(TamSX3("LR_PRODUTO")[1]) 	// Coletará o código do produto da linha do item do atendimento.
	Private cLocEstoque := Space(TamSX3("LR_LOCAL")[1])   	// Coletará o código do armazém (local de estoque) na linha do item do atendimento.
	Private nPosProduto := 0 								// Variável para identificar a posição do código do produto no array de detalhes do atendimento.
	Private nPosLocal   := 0 								// Variável para identificar a posição do local de estoque no array de detalhes do atendimento.
	Private nPosLoteCtl := 0 								// Variável para identificar a posição do número do lote no array de detalhes do atendimento.
	Private nPosNumLote := 0 								// Variável para identificar a posição do número do sublote no array de detalhes do atendimento.
	Private nPosDtValid := 0 								// Variável para identificar a posição da data de validade do lote no array de detalhes do atendimento.
	Private nPosQuant   := 0 								// Variável para identificar a posição da quantidade no array de detalhes do atendimento.
	Private aLotesNoPed := {} 								// Variável para montar um array com os lotes já informados no pedido para serem desconsiderados na consulta de lotes.

	If !lEhVndAss .And. !lEhPedVen .And. !lEhFacTrf
		FWAlertError("Esta rotina deve ser executada somente a partir de um atendimento do Venda Assistida, um Pedido de Venda ou do Facilitador de Transferências.", "CTRL+L - Chamada inválida")
		lOk := .F.
	EndIf

	If lOk

		If lEhVndAss
			nPosProduto := GdFieldPos("LR_PRODUTO", aHeader   ) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_PRODUTO" })
			nPosLocal   := GdFieldPos("LR_LOCAL"  , aHeaderDet) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_LOCAL"   })
			nPosLoteCtl := GdFieldPos("LR_LOTECTL", aHeaderDet) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_LOTECTL" })
			nPosNumLote := GdFieldPos("LR_NLOTE"  , aHeaderDet) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_NLOTE"   })
			nPosDtValid := GdFieldPos("LR_DTVALID", aHeaderDet) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_DTVALID" })
			nPosQuant   := GdFieldPos("LR_QUANT"  , aHeader   ) // AScan(aHeaderDet, { |x| AllTrim(x[2]) == "LR_QUANT"   })
			nLinha := N
		ElseIf lEhPedVen
			nPosProduto := GdFieldPos("C6_PRODUTO", aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRODUTO" })
			nPosLocal   := GdFieldPos("C6_LOCAL"  , aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_LOCAL"   })
			nPosLoteCtl := GdFieldPos("C6_LOTECTL", aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_LOTECTL" })
			nPosNumLote := GdFieldPos("C6_NUMLOTE", aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_NUMLOTE" })
			nPosDtValid := GdFieldPos("C6_DTVALID", aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_DTVALID" })
			nPosQuant   := GdFieldPos("C6_QTDVEN" , aHeader) // AScan(aHeader, { |x| AllTrim(x[2]) == "C6_QTDVEN"  })
			nLinha := N
		ElseIf lEhFacTrf
			nPosProduto := GdFieldPos("C6PRODUTO", _oMSGetTrf:aHeader)
			nPosLocal   := GdFieldPos("C6LOCAL"  , _oMSGetTrf:aHeader)
			nPosLoteCtl := GdFieldPos("C6LOTECTL", _oMSGetTrf:aHeader)
			nPosQuant   := GdFieldPos("C6QTDVEN" , _oMSGetTrf:aHeader)
			nLinha := _oMSGetTrf:nAt
		EndIf

		If nPosProduto == 0 .Or. nPosLocal == 0 .Or. nPosLoteCtl == 0 .Or. ((lEhVndAss .Or. lEhPedVen) .And. (nPosNumLote == 0 .Or. nPosDtValid == 0))
			FWAlertError("A estrutura de detalhes do atendimento está inconsistente."+CRLF+CRLF+;
							"Para que a consulta de lotes seja realizada é necessário que os campos de código do produto, local de estoque, controle de lote, número do lote e data de validade "+;
							"estejam devidamente configurados na estrutura de itens do atendimento.", "Estrutura inconsistente")
			lOk := .F.
		Else

			If lEhVndAss
				cCodProduto := aCols[nLinha][nPosProduto]
				cLocEstoque := aColsDet[nLinha][nPosLocal]
				nQuant      := aCols[nLinha][nPosQuant]
				For nX:=1 To Len(aColsDet)
					If nX <> nLinha .And. aCols[nX][nPosProduto] == cCodProduto .And. aColsDet[nX][nPosLocal] == cLocEstoque
						AAdd(aLotesNoPed, aColsDet[nX][nPosLoteCtl]) // Monta um array com os lotes já informados no pedido para serem desconsiderados na consulta de lotes.
					EndIf
				Next nX
			ElseIf lEhPedVen
				cCodProduto := aCols[nLinha][nPosProduto]
				cLocEstoque := aCols[nLinha][nPosLocal]
				nQuant      := aCols[nLinha][nPosQuant]
				For nX:=1 To Len(aCols)
					If nX <> nLinha .And. aCols[nX][nPosProduto] == cCodProduto .And. aCols[nX][nPosLocal] == cLocEstoque
						AAdd(aLotesNoPed, aCols[nX][nPosLoteCtl]) // Monta um array com os lotes já informados no pedido para serem desconsiderados na consulta de lotes.
					EndIf
				Next nX
			Else
				cCodProduto := _oMSGetTrf:aCols[nLinha][nPosProduto]
				cLocEstoque := _oMSGetTrf:aCols[nLinha][nPosLocal]
				nQuant      := _oMSGetTrf:aCols[nLinha][nPosQuant]
				For nX:=1 To Len(_oMSGetTrf:aCols)
					If nX <> nLinha .And. _oMSGetTrf:aCols[nX][nPosProduto] == cCodProduto .And. _oMSGetTrf:aCols[nX][nPosLocal] == cLocEstoque
						AAdd(aLotesNoPed, _oMSGetTrf:aCols[nX][nPosLoteCtl]) // Monta um array com os lotes já informados no pedido para serem desconsiderados na consulta de lotes.
					EndIf
				Next nX
			EndIf

		EndIf

	EndIf

	If lOk

		If Empty(cCodProduto)
			FWAlertError("Para que a consulta de lotes seja realizada é necessário estar posicionado na linha do item para o qual se deseja selecionar um lote e o código do produto nessa linha esteja preenchido.", "Sem produto")
			lOk := .F.
		Else
			If !(Posicione("SB1", 1, FWxFilial("SB1") + cCodProduto, "B1_RASTRO") == "L")
				FWAlertError("O produto atual não tem controle de lote/serial. Portanto, a consulta não será realizada.", "Produto sem controle de rastreio")
				lOk := .F.
			EndIf
		EndIf

		If lOk .And. Empty(cLocEstoque)
			FWAlertError("Para que a consulta de lotes seja realizada é necessário que o local de estoque esteja preenchido na linha do item.", "Sem local")
			lOk := .F.
		EndIf

	EndIf

	If lOk

		If lEhVndAss .And. !Empty(cJGFILSUBE) .And. !(cFilAnt == cJGFILSUBE)
			cFilEstoque := cJGFILSUBE
		Else
			cFilEstoque := cFilAnt
		EndIf

		aLoteRet := fSelLote()

		If Len(aLoteRet) >= 3
			If lEhVndAss
				aColsDet[nLinha][nPosLoteCtl] := aLoteRet[1]
				aColsDet[nLinha][nPosNumLote] := aLoteRet[2]
				aColsDet[nLinha][nPosDtValid] := aLoteRet[3]
			ElseIf lEhPedVen
				aCols[nLinha][nPosLoteCtl] := aLoteRet[1]
				aCols[nLinha][nPosNumLote] := aLoteRet[2]
				aCols[nLinha][nPosDtValid] := aLoteRet[3]
			Else
				_oMSGetTrf:aCols[nLinha][nPosLoteCtl] := aLoteRet[1]
				_oMSGetTrf:ForceRefresh()
			EndIf
		EndIf

	EndIf

	FWRestArea(aArea)
	DbSelectArea(cAliasAnt)

Return

Static Function fSelLote()
	Local _aArea          := FWGetArea()
	Local _aTitulos       := {}
	Local _aRet           := ""
	Local cDescProduto    := Posicione("SB1",1,FWxFilial("SB1")+cCodProduto,"B1_DESC") //Busca a descrição do produto para exibir na tela de consulta de lote/serial

	Private _oListBox
	Private _oFonte1
	Private _cTitulo      := "Consulta de lotes/seriais JG"
	Private _aLegenda     := {}
	Private _aLote        := {}
	Private _oCodProduto
	Private _oDescProduto
	Private aBUTTONS

	Static _oDlg //Antes era private, esta ficando fora do foco do objeto, Esta focando no BROWSE

	// Cria a fonte para ser usada na montagenm da tela
	_oFonte1  := TFont():New( "Arial",,14,,.T.)

	// Adiciona as opcoes de legenda do programa
	AAdd( _aLegenda, {"BR_VERDE"   ,"Válido" } )
	AAdd( _aLegenda, {"BR_AMARELO" ,"Vencido"} )

	aBUTTONS := {}

	// Cria a tela principal
	DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 0,0 TO 390,600 OF oMainWnd PIXEL //Modificado GetWndDefault() para oMainWnd, estava abrindo na browse

	@ 014+25,002 Say "Código:" Size 030,008 COLOR CLR_BLACK PIXEL OF _oDlg FONT _oFonte1
	@ 013+25,025 MSGET _oCodProduto VAR cCodProduto SIZE 30,9 OF _oDlg FONT _oFonte1 PIXEL When .F.

	@ 014+25,081 Say "Descrição:" Size 040,008 COLOR CLR_BLACK PIXEL OF _oDlg FONT _oFonte1
	@ 013+25,111 MSGET _oDescProduto VAR cDescProduto SIZE 185,9 OF _oDlg FONT _oFonte1 PIXEL When .F.

	// Cria listbox com os dados dos produtos conforme a tabela temporaria criada
	AAdd(_aLote   , { "", ""    , ""       , ""           , ""     })
	AAdd(_aTitulos, { "", "Lote", "SubLote", "Dt.Validade", "Saldo"})
	AAdd(_aTitulos, { 06, 50    , 50       , 20           , 20     })

	_oListBox := TWBrowse():New(040+25,001,300,120,,_aTitulos[1],_aTitulos[2],_oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	// _oListBox:blDblClick := {|| _aRet := fRetLote( _aLote[_oListBox:nAT][02], _aLote[_oListBox:nAT][03], _aLote[_oListBox:nAT][04] ), _oDlg:End() }
	_oListBox:blDblClick := {|| _aRet := fRetLote(), _oDlg:End() }
	_oListBox:SetArray(_aLote)

	_oListBox:bLine := { || {	LoadBitmap(GetResources()  ,;
								_aLote[_oListBox:nAT][01]),;
								_aLote[_oListBox:nAT][02] ,;
								_aLote[_oListBox:nAT][03] ,;
								_aLote[_oListBox:nAT][04] ,;
								_aLote[_oListBox:nAT][05]  ;
							};
						}

	Processa( { || _oPesqSB8() }, "Pesquisando Lotes/Seriais..." )

	ACTIVATE MsDIALOG _oDlg ON INIT ENCHOICEBAR( _oDlg, {|| _aRet := fRetLote(),_oDlg:END()}, {|| _oDlg:END()}, , aBUTTONS) CENTERED

	FWRestArea(_aArea)

Return (_aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RESTC001  ºAutor  ³Microsiga           º Data ³  12/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PESQUISA DO PRODUTO POR DESCRIÇÃO, GRUPO, SUB-GRUPO, CLASSE,º±±
±±º          ³FABRICANTE                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _oPesqSB8()
	Local _cQuery   := ""
	Local _cLegenda
	Local cAlias      := ""

	// Zera o array com os dados dos produtos
	_aLote := {}

	// Cria tabela temporaria com os dados dos produtos 
	_cQuery := " SELECT DISTINCT " + CRLF
	_cQuery += "     B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, B8_SALDO " + CRLF
	_cQuery += " FROM " + CRLF
	_cQuery += "     "+RetSqlName("SB8")+" SB8 " + CRLF
	_cQuery += " WHERE " + CRLF
	_cQuery += "     SB8.D_E_L_E_T_ <> '*' " + CRLF
	_cQuery += "     AND B8_FILIAL  = "+ValToSql(cFilEstoque)+" " + CRLF
	_cQuery += "     AND B8_PRODUTO = "+ValToSql(cCodProduto)+" " + CRLF
	_cQuery += "     AND B8_LOCAL   = "+ValToSql(cLocEstoque)+" " + CRLF
	_cQuery += "     AND B8_SALDO > 0 " + CRLF
	_cQuery += " ORDER BY " + CRLF
	_cQuery += "     B8_DTVALID, B8_LOTECTL, B8_NUMLOTE " + CRLF

	cAlias := MPSysOpenQuery(_cQuery)
	TcSetField(cAlias, "B8_DTVALID", "D", 08, 0)
	TcSetField(cAlias, "B8_SALDO"  , "N", 10, 2)

	While (cAlias)->(!Eof())

		If AScan(aLotesNoPed, {|x| x == (cAlias)->B8_LOTECTL}) = 0 //Lote ainda não informado no pedido
			If (cAlias)->B8_DTVALID > Date() //Lote vencido
				_cLegenda := "BR_VERDE"
			Else
				_cLegenda := "BR_AMARELO"
			EndIf

			AAdd(_aLote,  { _cLegenda, (cAlias)->B8_LOTECTL, (cAlias)->B8_NUMLOTE, (cAlias)->B8_DTVALID, (cAlias)->B8_SALDO } )
		EndIf
		(cAlias)->( dbSkip() )

	EndDo
	(cAlias)->( dbCloseArea() )

	_oListBox:nAT := 1 //teste

	If !(Len(_aLote) > 0)
		_aLote := {} 
		AAdd(_aLote, {"","","","",""} )
	EndIf

	_oListBox:SetArray(_aLote)

	_oListBox:bLine := { || {	LoadBitmap(GetResources() ,;
								_aLote[_oListBox:nAT][01]),;
								_aLote[_oListBox:nAT][02] ,;
								_aLote[_oListBox:nAT][03] ,;
								_aLote[_oListBox:nAT][04] ,;
								_aLote[_oListBox:nAT][05] } }

	_oListBox:Refresh()

Return(.T.)


/*/{Protheus.doc} fRetLote

	Essa função tem como finalidade retornar as informações do lote selecionado na consulta de lote/serial.

@type    function
@version 1.0
@author  Jesus Ramos
@since   19/05/2026
@return  Array, Vetor contendo as informações do lote selecionado, sendo: [1] - Controle de lote, [2] - Número do lote e [3] - Data de validade do lote.
/*/
Static Function fRetLote()
	Local cAliasAnt    := Alias()
	Local _aRet        := {}
	// Local _pLoteCtl    := _aLote[_oListBox:nAT][02]
	// Local _pNumLote    := _aLote[_oListBox:nAT][03]
	// Local _pDtValidade := _aLote[_oListBox:nAT][04]

	DbSelectArea("SB8")
	SB8->( DbSetOrder(3) ) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->( DbSeek( cFilEstoque + cCodProduto + cLocEstoque + _aLote[_oListBox:nAT][02] + _aLote[_oListBox:nAT][03] + DToS(_aLote[_oListBox:nAT][04]) ) ) ;
	   .And. cFilEstoque + cCodProduto + cLocEstoque + _aLote[_oListBox:nAT][02] + _aLote[_oListBox:nAT][03] + DToS(_aLote[_oListBox:nAT][04]) == SB8->( B8_FILIAL + B8_PRODUTO + B8_LOCAL + B8_LOTECTL + B8_NUMLOTE + DToS(B8_DTVALID) )

		_aRet := { SB8->B8_LOTECTL, SB8->B8_NUMLOTE, SB8->B8_DTVALID } //Concatena as informações do lote para retorno

	EndIf

	DbSelectArea(cAliasAnt)

Return _aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)
