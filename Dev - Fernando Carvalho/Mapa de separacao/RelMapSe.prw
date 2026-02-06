#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

User Function RelMapSe()
	
	Local oPrinter
    Local lAdjustToLegacy   := .F.
    Local lDisableSetup     := .T.
    Local cLocal            := "\spool"
	Local _cTime      		:= Time()

	Private lPedido			:= .F.
	Private _nLimPaCol		:= 585 // Número Limite da página em coluna
	Private _nFinalPage		:= 800 // Número Final da página
	Private _nColIniPag		:= 10  // Número da coluna inicial
	Private _nColInicio		:= 12  // Número da coluna inicial
	Private _nProxLin		:= 12  // Próxima linha a ser impressa
	Private _nSegundaCol	:= 390 // Número da segunda coluna
	Private _nMaxLin		:= 740// Número máximo de linhas por página
	Private _nTamMaxPr		:= 35 // Tamanho máximo do nome do produto
	Private _nTamMaxObs		:= 160 // Tamanho máximo da observação

	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + CB7->CB7_CLIENT + CB7->CB7_LOJA))

	
	dbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If !SC5->(DbSeek(xFilial("SC5") + CB7->CB7_PEDIDO))
		MSGINFO("Pedido não localizado na tabela de pedidos de venda (SC5).","Mapa de Separação")
		Return
	EndIf
	_cTime		:= Alltrim(StrTran(_cTime,":",""))

	oPrinter 	:= FWMSPrinter():New("MAPA_SEPARACAO"+_cTime, IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
	
	Private oFont11    := TFontEx():New(oPrinter,"Arial",10,10,.F.,.T.,.F.)// 11
	Private oFont11N   := TFontEx():New(oPrinter,"Arial",10,10,.T.,.T.,.F.)// 11
	Private oFont12N   := TFontEx():New(oPrinter,"Arial",11,11,.T.,.T.,.F.)// 12
	Private oFont28N   := TFontEx():New(oPrinter,"Arial",28,28,.T.,.T.,.F.)// 18

	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9) // A4
	oPrinter:SetMargin(10,10,10,10)
	//oPrinter:SetFont(oFont1,.T.)

	// Definir área de impressão 
	//oPrinter:box(nLin,09,_nFinalPage,_nLimPaCol)

	oPrinter:Setup()		
	if oPrinter:nModalResult == PD_OK
		RptStatus({|lEnd| RelMapSe(@oPrinter)}, "Imprimindo Mapa de separação, aguarde...")
		oPrinter:Preview()	
	EndIf
	
	FreeObj(oPrinter)
Return

/*/{Protheus.doc} RelMapSe (Static)
Imprime o mapa de separação com logo, dados da empresa/cliente e produtos.
@type static function
@author
@since 02/02/2026
/*/
Static Function RelMapSe(oPrinter)
	Local nLin              := 09
	Local nPag              := 1

	SetRegua(20)
	oPrinter:StartPage()
	ImpLogo(oPrinter, @nLin, @nPag)
	ImpCab(oPrinter, @nLin, @nPag)
	ImpCabProd(oPrinter, @nLin)
	ImpProd(oPrinter, @nLin, @nPag, _nMaxLin)
	ImpObs(oPrinter, @nLin)
	ImpRod(oPrinter, @nPag)
    oPrinter:EndPage()
Return

/*/{Protheus.doc} GetLogo
Retorna o caminho do arquivo de logo conforme empresa.
@type static function
@author
@since 02/02/2026
@return cLogo, character, Caminho do arquivo de imagem
/*/
Static Function GetLogo()

	Local _cLogo      := ""
	Local _cNome      := "logo"
	Local _cExt       := ".jpg"
	Local _cStartPath := GetSrvProfString("Startpath","")

	_cStartPath := _cStartPath + "imagens/"

	If File(_cStartPath + _cNome + Alltrim(cEmpAnt) + _cExt)
		_cLogo := (_cStartPath + _cNome + Alltrim(cEmpAnt) + _cExt)

	ElseIf File(_cStartPath + _cNome + _cExt)
		_cLogo := (_cStartPath + _cNome + _cExt)

	Endif

Return _cLogo

/*/{Protheus.doc} ImpLogo
Imprime logo e código de barras da ordem de separação.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpLogo(oPrinter, nLin, nPag)
	Local nColTex := 150
	Local nColBar := 450
	nLin += 5
	//LOGO
	oPrinter:SayBitmap(nLin,_nColInicio, GetLogo(),80,60) 
	
	//CODIGO DE BARRAS
	oPrinter:Code128(nLin +10 ,nColBar, CB7->CB7_ORDSEP,1,30)

	//MAPA DE SEPARAÇÃO
	nLin += 35
	oPrinter:Say(nLin,nColTex,"MAPA DE SEPARAÇÃO",oFont28N:oFont)	

	nLin += 20
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	
Return

/*/{Protheus.doc} ImpCab
Imprime cabeçalho com dados da empresa, cliente e pedido.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpCab(oPrinter, nLin, nPag)

	Local cCliCod  := SA1->A1_COD
	Local cCliLoja := SA1->A1_LOJA

	// =========================
	// DADOS DA EMPRESA (SM0)
	// =========================
	SM0->(DbSetOrder(1))
	If !SM0->(DbSeek(cEmpAnt + cFilAnt))
		ConOut("Não posicionou na SM0")
	EndIf

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Empresa de Faturamento:", SM0->M0_NOMECOM )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "CNPJ:", Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, "Vendedor:", SC5->C5_VEND1 + " - " + Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NOME") ) 
		

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Endereço:", SM0->M0_ENDCOB )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, "Bairro:", SM0->M0_BAIRCOB )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Cidade:", SM0->M0_CIDCOB )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, "CEP:", Transform(SM0->M0_CEPCOB, "@R 99999-999") )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Número Único:", "ORDEM:" + CB7->CB7_ORDSEP +"/ PEDIDO:"+SC5->C5_NUM )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, "Data da Negociação:", DtOC(SC5->C5_EMISSAO) + " " + SC5->C5_XHORA )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Local de Entrega:", GetEndEnt() )

	/*nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "CIF/FOB:", Iif(SC5->C5_TPFRETE=="C","CIF","FOB") )
	*/
	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, "Tipo do Frete:", GetFreightType(SC5->C5_TPFRETE) )
	

	nLin += _nProxLin - 5
	oPrinter:Line(nLin, _nColIniPag, nLin, _nLimPaCol)

	// =========================
	// DADOS DO CLIENTE (SA1)
	// =========================
	SA1->(DbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1") + cCliCod + cCliLoja))
		ConOut("Não posicionou na SA1")
	EndIf

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, ;
		"Cliente:", SA1->A1_COD +'-'+SA1->A1_LOJA +'-'+SA1->A1_NOME )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, ;
		"CNPJ/CPF:", Transform(SA1->A1_CGC, "@R 99.999.999/9999-99") )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, ;
		"Inscrição Estadual:", SA1->A1_INSCR )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, ;
		"Endereço:", SA1->A1_END )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, ;
		"Bairro:", SA1->A1_BAIRRO )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, _nColInicio, ;
		"Cidade:", SA1->A1_MUN )

	SayLabelValue( oPrinter, nLin, _nSegundaCol, ;
		"CEP:", SA1->A1_CEP )

	nLin += _nProxLin + 5
	oPrinter:Line(nLin, _nColIniPag, nLin, _nLimPaCol)

Return


/*/{Protheus.doc} ImpCabProd
Imprime cabeçalho da tabela de produtos com colunas.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpCabProd(oPrinter, nLin)
	Local nProxCol	:= 0

	nLin +=_nProxLin 
	oPrinter:Say(nLin,280	,"PRODUTOS",oFont12N:oFont)
	nLin += 5
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	//CABEÇALHO DOS PRODUTOS
	nLin +=_nProxLin
	oPrinter:Say(nLin,_nColInicio				,"Cód"				,oFont11N:oFont)
	nProxCol += 90
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Produto"			,oFont11N:oFont)
	nProxCol += 120
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Und."				,oFont11N:oFont)
	nProxCol += 40
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Quantidade"		,oFont11N:oFont)
	nProxCol += 60
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Marca"			,oFont11N:oFont)
	nProxCol += 50
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Controle"			,oFont11N:oFont)
	nProxCol += 50
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Ref.Fornecedor"	,oFont11N:oFont)
	nProxCol += 65
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Localização"		,oFont11N:oFont)
	nProxCol += 65
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Lote"				,oFont11N:oFont)
	nLin += 5
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	
Return

/*/{Protheus.doc} ImpProd
Imprime os produtos/itens da ordem de separação com quantidade, marca e localização.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpProd(oPrinter, nLin, nPag, _nMaxLin)

	Local nProxCol := 0
	Local aLinhas  := {}
	
	// Posiciona CB8 e SB1
	DbSelectArea("CB8")
	CB8->(DbSetOrder(1)) // Filial + ordem de separação
	If !CB8->(DbSeek(xFilial("CB8") + CB7->CB7_ORDSEP))
		Return
	EndIf
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // Filial + codigo do produto
	

	nLin += _nProxLin

	While !CB8->(Eof()) .And. ;
		  CB8->CB8_FILIAL == CB7->CB7_FILIAL .And. ;
		  CB8->CB8_ORDSEP == CB7->CB7_ORDSEP

		IncRegua()

		SB1->(DbSeek(xFilial("SB1") + CB8->CB8_PROD))
		

		// Quebra de página
		If nLin >= _nMaxLin
			ImpRod(oPrinter, nPag)
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPag++
			nLin := _nProxLin
			oPrinter:Line(nLin, _nColIniPag, nLin, _nLimPaCol)
			ImpCabProd(oPrinter, @nLin)
			nLin += _nProxLin
		EndIf

		// Código		
		oPrinter:Say(nLin, _nColInicio, CB8->CB8_PROD, oFont11:oFont)
		

		nProxCol += 45
		// Quebra descrição sem cortar palavra
		aLinhas := QuebraTexto(SB1->B1_DESC, _nTamMaxPr)
		// Produto (linha 1)
		oPrinter:Say(nLin, _nColInicio + nProxCol, aLinhas[1], oFont11:oFont)

		// Produto (linha 2)
		If Len(aLinhas) > 1
			oPrinter:Say(nLin + _nProxLin, ;
				_nColInicio + nProxCol, ;
				aLinhas[2], ;
				oFont11:oFont)
		EndIf

		nProxCol += 170

		// Unidade
		oPrinter:Say(nLin, _nColInicio + nProxCol, SB1->B1_UM, oFont11:oFont)

		nProxCol += 40

		// Quantidade
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			Transform(CB8->CB8_QTDORI, "@E 999.999"), ;
			oFont11:oFont)

		nProxCol += 55

		// Marca (SB1)
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			PadR(SB1->B1_FABRIC, 10), ;
			oFont11:oFont)

		nProxCol += 50

		// Controle
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			SB1->B1_SERIE, ;
			oFont11:oFont)

		nProxCol += 50

		// Referência do fornecedor
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			PadR(Posicione("SA5",2,xFilial('SA5')+CB8->CB8_PROD,'A5_CODPRF'), 18), ;
			oFont11:oFont)

		nProxCol += 65

		// Localização (SB1)
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			PadR(CB8->CB8_LCALIZ, 18), ;
			oFont11:oFont)

		nProxCol += 65

		// Lote
		oPrinter:Say(nLin, ;
			_nColInicio + nProxCol, ;
			PadR(CB8->CB8_LOTECT, 18), ;
			oFont11:oFont)

		// Avança linha
		nLin += _nProxLin
		If Len(aLinhas) > 1
			nLin += _nProxLin
		EndIf

		nProxCol := 0

		CB8->(DbSkip())
	EndDo

Return

/*/{Protheus.doc} ImpObs
Imprime observações do pedido quebradas em múltiplas linhas.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpObs(oPrinter, nLin)
	Local nX
	Local aLinhas := QuebraTexto(AllTrim(SC5->C5_MENNOTA), _nTamMaxObs)
	//OBSERVAÇÃO
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	nLin +=_nProxLin 
	oPrinter:Say(nLin,280	,"OBSERVAÇÃO",oFont12N:oFont)
	nLin += 5
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	For nX := 1 To Len(aLinhas)
		nLin +=_nProxLin 
		oPrinter:Say(nLin,_nColInicio,aLinhas[nX],oFont11:oFont)
	Next
	nLin +=_nProxLin
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
Return


/*/{Protheus.doc} ImpRod
Imprime rodapé com número da página.
@type static function
@author
@since 02/02/2026
/*/
Static Function ImpRod(oPrinter, nPag)

	//RODAPE
	oPrinter:Line(768,_nColIniPag,768,_nLimPaCol)
	oPrinter:Say(780,280,"Página " + StrZero(nPag,2))    
Return



// Retorna um array com as linhas já quebradas
/*/{Protheus.doc} QuebraTexto
Quebra texto em múltiplas linhas conforme tamanho máximo.
@type static function
@author
@since 02/02/2026
@param cTexto, character, Texto a quebrar
@param nTamMax, numeric, Tamanho máximo por linha
@return aLinhas, array, Array com linhas quebradas
/*/
Static Function QuebraTexto(cTexto, nTamMax)
	Local aLinhas := {}
	Local cLinha  := ""
	Local aPal    := {}
	Local nI

	cTexto := AllTrim(cTexto)
	aPal   := StrTokArr(cTexto, " ")

	For nI := 1 To Len(aPal)
		// Testa se cabe a próxima palavra
		If Len(cLinha + " " + aPal[nI]) <= nTamMax
			cLinha += IIf(Empty(cLinha), "", " ") + aPal[nI]
		Else
			AAdd(aLinhas, cLinha)
			cLinha := aPal[nI]
		EndIf
	Next

	If !Empty(cLinha)
		AAdd(aLinhas, cLinha)
	EndIf

Return aLinhas

/*/{Protheus.doc} SayLabelValue
Imprime um rótulo seguido de seu valor.
@type static function
@author
@since 02/02/2026
/*/
Static Function SayLabelValue(oPrinter, nLin, nCol, cLabel, cValue)
	Local nLabelLen := oPrinter:GetTextWidth(cLabel, oFont11N:oFont,2) - Len(cLabel)
	oPrinter:Say(nLin, nCol, cLabel, oFont11N:oFont)
	oPrinter:Say( ;
		nLin, ;
		nCol + nLabelLen , ;
		AllTrim(cValue), ;
		oFont11:oFont )
Return

/*/{Protheus.doc} GetFreightType
Retorna a descrição do tipo de frete.
@type static function
@author
@since 02/02/2026
@param cType, character, Código do tipo de frete (C, F, T, R, D, S)
@return cDesc, character, Descrição do tipo de frete
/*/
Static Function GetFreightType(cType)
	Local cDesc := ""
	Do Case
		Case cType == "C"
			cDesc := "CIF"
		Case cType == "F"
			cDesc := "FOB"
		Case cType == "T"
			cDesc := "Por conta de terceiros"
		Case cType == "R"
			cDesc := "Por conta remetente"
		Case cType == "D"
			cDesc := "Por conta destinatário"
		Case cType == "S"
			cDesc := "Sem frete"
		Otherwise
			cDesc := "Desconhecido"
	EndCase
Return cDesc

/*/{Protheus.doc} GetEndEnt
Retorna o endereço de entrega baseado nos dados do cliente.
@type static function
@author
@since 02/02/2026
@return cEndEnt, character, Endereço de entrega completo
/*/
Static Function GetEndEnt()
	Local cEndEnt 	:= ""
	Local aArea 	:= GetArea()
	Local cTipo 	:= ''

	If (SC5->(C5_CLIENT + C5_LOJAENT) == SC5->(C5_CLIENTE + C5_LOJACLI))
		cEndEnt := AllTrim(SA1->A1_END) + ", "  + AllTrim(SA1->A1_BAIRRO) + " - CEP: " + Transform(SA1->A1_CEP, "@R 99999-999") + " - " + AllTrim(SA1->A1_MUN) + " - " + SA1->A1_EST 
	Else
		cTipo := Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENT + SC5->C5_LOJAENT, "A1_XTIPO")
		If cTipo == "U" // Unidade
			cEndEnt := SA1->A1_NOME
		Else // Outro
			cEndEnt := AllTrim(SA1->A1_END) + ", "  + AllTrim(SA1->A1_BAIRRO) + " - CEP: " + Transform(SA1->A1_CEP, "@R 99999-999") + " - " + AllTrim(SA1->A1_MUN) + " - " + SA1->A1_EST 
		EndIf
	EndIf

	RestArea(aArea)
Return cEndEnt
