#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "COLORS.CH"

//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
#Define COR_VERMELHO RGB(255, 000, 000)
#Define COR_PRETO2  RGB(100, 100, 100)

User Function ImpOrcPed()
    Local oPrinter
    Local lAdjustToLegacy   := .F.
    Local lDisableSetup     := .T.
    Local cLocal            := "\spool"	
	Local _cTime      		:= Time()
    Local oBrowse           := GetmBrowse()
    Local cNum              := ''
    
    Private cChaveCli      	:= ''
    Private cAliasImp   	:= oBrowse:alias()
	Private lImagem			:= MsgYesNo("Imprimir imagem do produto?") // Imprimir imagem do produto
	Private _nLimPaCol		:= 585 // N˙mero Limite da p·gina em coluna
	Private _nFinalPage		:= 800 // N˙mero Final da p·gina
	Private _nColIniPag		:= 10  // N˙mero da coluna inicial
	Private _nColInicio		:= 12  // N˙mero da coluna inicial
	Private _nProxLin		:= 12  // PrÛxima linha a ser impressa
	Private _nSegundaCol	:= 390 // N˙mero da segunda coluna
	Private _nMaxLin		:= 740// N˙mero m·ximo de linhas por p·gina
	Private _nTamMaxPr		:= 30  // Tamanho m·ximo do nome do produto
	Private _nTamMaxObs		:= 160 // Tamanho m·ximo da observaÁ„o    
    Private cTipoPed        := ''

    If (cAliasImp == "SC5")
        cChaveCli   := &("xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI")
        cNum        := SC5->C5_NUM
    Elseif (cAliasImp == "SCJ")
        cChaveCli   := &("xFilial('SA1') + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA")
        cNum        := SCJ->CJ_NUM
    ElseIf (cAliasImp == "SL1")
        cChaveCli := &("xFilial('SA1') + SL1->L1_CLIENTE + SL1->L1_LOJA")
        cNum        := SL1->L1_NUM
    Else
        MsgInfo("Este relatÛrio deve ser executado a partir do pedido de orcamento.","AtenÁ„o")
        Return        
    EndIf
        
	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(cChaveCli))

	_cTime		:= Alltrim(StrTran(_cTime,":",""))
    
    cTipoPed    := GetTipoPedido(cAliasImp)    

	oPrinter 	:= FWMSPrinter():New(StrTokArr(SA1->A1_NOME,' ')[1]+ cNum, IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
	
    

    
    // Definir fontes
	Private oFont11    := TFontEx():New(oPrinter,"Arial",10,10,.F.,.T.,.F.)// 11
	Private oFont11N   := TFontEx():New(oPrinter,"Arial",10,10,.T.,.T.,.F.)// 11
	Private oFont12N   := TFontEx():New(oPrinter,"Arial",11,11,.T.,.T.,.F.)// 12
	Private oFont14N   := TFontEx():New(oPrinter,"Arial",14,14,.T.,.T.,.F.)// 14
	Private oFont20N   := TFontEx():New(oPrinter,"Arial",20,20,.T.,.T.,.F.)// 20
	Private oFont28N   := TFontEx():New(oPrinter,"Arial",28,28,.T.,.T.,.T.)// 28

	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9) // A4
	oPrinter:SetMargin(0,0,0,0)

	oPrinter:Setup()		
	if oPrinter:nModalResult == PD_OK
		RptStatus({|lEnd| ImpOrcPed(@oPrinter)}, "Imprimindo Oramento, aguarde...")
		oPrinter:Preview()	
	EndIf
	
	FreeObj(oPrinter)
Return

Static Function ImpOrcPed(oPrinter)
    Local nLin              := 09
	Local nPag              := 1

	oPrinter:StartPage()
	ImpLogo(oPrinter, @nLin, @nPag)
	ImpCabCli(oPrinter, @nLin, @nPag)
	ImpCabProd(oPrinter, @nLin, @nPag)
	ImpProdutos(oPrinter, @nLin, @nPag)
    ImpObs(oPrinter, @nLin)
    ImpRod(oPrinter, nPag)
	oPrinter:EndPage()
Return

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

	EndIf

Return _cLogo
Static Function ImpLogo(oPrinter, nLin, nPag)
	Local nColPos	:= _nColInicio
	//LOGO
	oPrinter:SayBitmap(nLin, _nLimPaCol - 100, GetLogo(),100,100) 
	
	//EMPRESA
	nLin += 10
	oPrinter:SayAlign(nLin,nColPos, SM0->M0_NOMECOM, oFont28N:oFont, 240, 20, COR_VERMELHO)
	
	nLin += 40
	SayLabelValue( oPrinter, nLin, nColPos + 05, "CNPJ:", Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, nColPos + 05, "EndereÁo:", SM0->M0_ENDCOB )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, nColPos + 05, "Bairro:", SM0->M0_BAIRCOB )

	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, nColPos + 05, "Cidade:", SM0->M0_CIDCOB )
	
	nLin += _nProxLin
	SayLabelValue( oPrinter, nLin, nColPos + 05, "CEP:", Transform(SM0->M0_CEPCOB, "@R 99999-999") )

	nLin += 05
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	
Return



Static Function ImpCabCli(oPrinter, nLin, nPag)

    Local nColEsq   := _nColInicio
    Local nColDir   := _nSegundaCol
	Local oBrush1   := TBrush():New( , COR_CINZA)
    Local cVendedor := ""
    Local cCondPag  := ""
    Local cTpFrete  := ""
    Local cPedido   := ""
    

    If (cAliasImp == "SC5")
        cPedido   := &("SC5->C5_NUM")
        cVendedor := &("SC5->C5_VEND1")
        cCondPag  := &("SC5->C5_CONDPAG")
        cTpFrete  := &("SC5->C5_TPFRETE")
    Elseif (cAliasImp == "SCJ")
        cPedido   := &("SCJ->CJ_NUM")
        cVendedor := ''
        cCondPag  := &("SCJ->CJ_CONDPAG")
        cTpFrete  := &("SCJ->CJ_TPFRETE")
    ElseIf (cAliasImp == "SL1")
        cPedido   := &("SL1->L1_NUM")
        cVendedor := &("SL1->L1_VEND")
        cCondPag  := &("SL1->L1_CONDPG")     
        cTpFrete  := &("SL1->L1_TPFRET")
    EndIf
    // Fundo do tÌtulo
    oPrinter:FillRect( {nLin, _nColIniPag, nLin + 18, _nLimPaCol}, oBrush1,'-2')
    oPrinter:SayAlign( ;
        nLin , ;
        _nColIniPag +230, ;
        cTipoPed +" N∫: "+ AllTrim(cPedido), ;
        oFont14N:oFont, ;
        _nLimPaCol - _nColIniPag, ;
        18, ;
        COR_PRETO )

    nLin += 30

    SayLabelValue( oPrinter, nLin, nColEsq, "Cliente:"  , AllTrim(SA1->A1_COD) + " - " + Alltrim(SA1->A1_LOJA)+ " - " + AllTrim(SA1->A1_NOME) )

    SayLabelValue( oPrinter, nLin, nColDir, "CNPJ:"     , Transform(SA1->A1_CGC, "@R 99.999.999/9999-99") )

    nLin += _nProxLin
    SayLabelValue( oPrinter, nLin, nColEsq, "I.E.:"     , SA1->A1_INSCR )
    SayLabelValue( oPrinter, nLin, nColDir, "Email:"    , SA1->A1_EMAIL )
    
    nLin += _nProxLin
    SayLabelValue( oPrinter, nLin, nColEsq, "Contato:"  , SA1->A1_CONTATO )
    SayLabelValue( oPrinter, nLin, nColDir, "Vendedor:" ,AllTrim(cVendedor) + " - " + Posicione("SA3", 1, xFilial("SA3") + cVendedor, "A3_NOME") )

    nLin += _nProxLin
    SayLabelValue( oPrinter, nLin, nColEsq, "EndereÁo:" , AllTrim(SA1->A1_END) + ", " + ;
                                                          AllTrim(SA1->A1_BAIRRO) + ", " + ;
                                                          AllTrim(SA1->A1_MUN) + "-" + ;
                                                          AllTrim(SA1->A1_EST) + ", " + ;
                                                          Transform(SA1->A1_CEP, "@R 99999-999") )

     nLin += _nProxLin
    SayLabelValue( oPrinter, nLin, nColEsq, "CondiÁ„o Pgto:", cCondPag + " - " + Posicione("SE4", 1, xFilial("SE4") + cCondPag, "E4_DESCRI"))
    SayLabelValue( oPrinter, nLin, nColDir, "Frete:"    ,  GetFreightType(cTpFrete) )
    
    nLin += 05
	oPrinter:Line( nLin, _nColIniPag, nLin, _nLimPaCol )

   

Return

Static Function ImpCabProd(oPrinter, nLin, nPag)
	Local nProxCol	:= 0

	//TITULO DOS PRODUTOS
    nLin += 15
	oPrinter:Say(nLin,270	,"PRODUTOS",oFont12N:oFont)
	nLin += 05
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	//CABE«ALHO DOS PRODUTOS
	nLin +=_nProxLin
	If lImagem
		nProxCol	:= 10
		oPrinter:Say(nLin,_nColInicio + nProxCol,"Foto"				,oFont11N:oFont)
        nProxCol += 40
	EndIf	
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Codigo"			,oFont11N:oFont)
	nProxCol += 60
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Produto"			,oFont11N:oFont)
	nProxCol += 130
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Und."				,oFont11N:oFont)
	nProxCol += 40
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Quantidade"		,oFont11N:oFont)
	nProxCol += 60
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"NCM"			,oFont11N:oFont)
	
    If !(cAliasImp == "SL1")
        nProxCol += 30
        oPrinter:Say(nLin,_nColInicio + nProxCol	,"ALIQ. ICMS"		,oFont11N:oFont)
	EndIf

    nProxCol += 50
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"ICMS-ST"			,oFont11N:oFont)
	nProxCol += 40
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Valor"	,oFont11N:oFont)
	If (cAliasImp == "SL1")
        nProxCol += 60
        oPrinter:Say(nLin,_nColInicio + nProxCol	,"Desconto"		,oFont11N:oFont)
	EndIf
    nProxCol += 60
	oPrinter:Say(nLin,_nColInicio + nProxCol	,"Total"		,oFont11N:oFont)
	nLin += 05
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)

Return

Static Function ImpProdutos(oPrinter, nLin, nPag)
    Local nCol      := 0
    Local cProduto  := 0
    Local nQuant    := 0
    Local nCST      := 0
    Local nAliqIcm  := 0
    Local nICMS     := 0
    Local nItem     := 0
    Local nPreco    := 0
    Local nDesc     := 0
    Local nTotal    := 0
    Local nTotalG   := 0
    Local nTotalI   := 0
    Local cTes      := ""
    Local aLinhas   := {}
    Local cTpFrete  := ""
    Local cPedido   := ""
    Local cChavePed := ""
    Local cAliasPro := ""
    Local cFilPed   := ""

    If (cAliasImp == "SC5")
        cAliasPro   := "SC6"
        cPedido     := &("SC5->C5_NUM")
        cChavePed   := "SC6->(C6_FILIAL+C6_NUM) ==  SC5->(C5_FILIAL+C5_NUM)"
        cTpFrete    := &("SC5->C5_TPFRETE")
        cFilPed     := SC5->C5_FILIAL

    Elseif (cAliasImp == "SCJ")
        cAliasPro   := "SCK"
        cPedido     := &("SCJ->CJ_NUM")
        cChavePed   := "SCK->(CK_FILIAL+CK_NUM) ==  SCJ->(CJ_FILIAL+CJ_NUM)"
        cTpFrete    := &("SCJ->CJ_TPFRETE")
        cFilPed     := SCJ->CJ_FILIAL

    ElseIf (cAliasImp == "SL1")        
        cAliasPro   := "SL2"
        cPedido     := &("SL1->L1_NUM")
        cChavePed   := "SL2->(L2_FILIAL+L2_NUM) ==  SL1->(L1_FILIAL+L1_NUM)"
        cTpFrete    := &("SL1->L1_TPFRET")
        cFilPed     := SL1->L1_FILIAL
    
    EndIf
    

    dbSelectArea(cAliasPro)
    (cAliasPro)->(DbSetOrder(1)) // Ajuste se o seu Ìndice for outro
    (cAliasPro)->(DbSeek(cFilPed + cPedido))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // Filial + codigo do produto
	
    xImposto( SA1->A1_COD, SA1->A1_LOJA, SA1->A1_TIPO, cTpFrete )

    While !(cAliasPro)->(Eof()) .And. &(cChavePed)
        If (cAliasImp == "SC5")
            nPreco   := &("SC6->C6_PRCVEN")
            nDesc    := &("SC6->C6_VALDESC")
            nTotal   := &("SC6->C6_VALOR")
            cProduto := &("SC6->C6_PRODUTO")
            nQuant   := &("SC6->C6_QTDVEN")
            nItem    := Val(&("SC6->C6_ITEM"))
            cTes     := &("SC6->C6_TES")
        Elseif (cAliasImp == "SCJ")
            nPreco   := &("SCK->CK_PRCVEN")
            nDesc    := &("SCK->CK_VALDESC")
            nTotal   := &("SCK->CK_VALOR")
            cProduto := &("SCK->CK_PRODUTO")
            nQuant   := &("SCK->CK_QTDVEN")
            nItem    := Val(&("SCK->CK_ITEM"))
            cTes     := &("SCK->CK_TES")

        ElseIf (cAliasImp == "SL1")
            nPreco   := &("SL2->L2_VRUNIT")
            nDesc    := &("SL2->L2_VALDESC")
            nTotal   := &("SL2->L2_VLRITEM")
            cProduto := &("SL2->L2_PRODUTO")
            nQuant   := &("SL2->L2_QUANT")
            nItem    := Val(&("SL2->L2_ITEM"))
            cTes     := &("SL2->L2_TES")
        EndIf
        MaFisAdd(;
				cProduto            ,;// 1-Codigo do Produto ( Obrigatorio )
                cTes          ,;// 2-Codigo do TES ( Opcional )
                nQuant       ,;// 3-Quantidade ( Obrigatorio )
                nPreco              ,;// 4-Preco Unitario ( Obrigatorio )
                nDesc               ,;// 5-Valor do Desconto ( Opcional )
                ""                  ,;// 6-Numero da NF Original ( Devolucao/Benef )
                ""                  ,;// 7-Serie da NF Original ( Devolucao/Benef )
                0                   ,;// 8-RecNo da NF Original no arq SD1/SD2
                0                   ,;// 9-Valor do Frete do Item ( Opcional )
                0                   ,;// 10-Valor da Despesa do item ( Opcional )
                0                   ,;// 11-Valor do Seguro do item ( Opcional )
                0                   ,;// 12-Valor do Frete Autonomo ( Opcional )
                nTotal            ,;// 13-Valor da Mercadoria ( Obrigatorio )
                0                   ,;// 14-Valor da Embalagem ( Opiconal )
                , , , , , , , , , , , , ,;
                ) // 28-Classificacao fiscal)

        nCST     := MaFisRet(nItem,"IT_VALSOL")
        nICMS    := MaFisRet(nItem,"IT_VALICM")
        nAliqIcm := MaFisRet(nItem,"IT_ALIQICM")

        //Posiciona na tabela de produtos
		SB1->(DbSeek(xFilial("SB1") + cProduto))

        // ===== CONTROLE DE P¡GINA =====
        If nLin > _nMaxLin
            oPrinter:EndPage()
            nPag++
            oPrinter:StartPage()
            nLin := 20
            ImpCabProd(oPrinter, @nLin, @nPag)
        EndIf

        nCol := _nColInicio

        // ===== FOTO DO PRODUTO =====
        If lImagem
            nLin += 5
            oPrinter:SayBitmap(nLin, nCol , GetFoto(), 40, 40)
            nLin += 20
            nCol += 50
        Else
            nLin += _nProxLin   
        EndIf
        
       
        oPrinter:Say(nLin, nCol, cProduto, oFont11:oFont)

        nCol += 50
        aLinhas := QuebraTexto(SB1->B1_DESC, _nTamMaxPr)
		// Produto (linha 1)
		oPrinter:Say(nLin,nCol, aLinhas[1], oFont11:oFont)

		// Produto (linha 2)
		If Len(aLinhas) > 1
			oPrinter:Say(nLin + _nProxLin, nCol, aLinhas[2], oFont11:oFont)
		EndIf

        nCol += 140
        oPrinter:Say(nLin, nCol, SB1->B1_UM, oFont11:oFont)

        nCol += 40
        oPrinter:Say(nLin, nCol, Transform(nQuant, X3Picture("C6_QTDVEN")), oFont11:oFont)

        nCol += 50
        oPrinter:Say( nLin, nCol, SB1->B1_POSIPI, oFont11:oFont )

        If !(cAliasImp == "SL1")
            nCol += 40
            oPrinter:Say( nLin, nCol, Transform(nAliqIcm,  "@E 999,999.99"), oFont11:oFont)
        EndIf

        nCol += 40
        oPrinter:Say( nLin, nCol, Transform(nICMS,  "@E 999,999.99"), oFont11:oFont)

        nCol += 40
        oPrinter:Say( nLin, nCol, Transform(nPreco, "@E 999,999.99"), oFont11:oFont)
        If (cAliasImp == "SL1")            
            nCol += 60
            oPrinter:Say( nLin, nCol, Transform(nDesc, "@E 999,999.99"), oFont11:oFont)
        EndIf        
        nCol += 60
        oPrinter:Say( nLin, nCol, Transform(nTotal, "@E 999,999.99"), oFont11:oFont)

        nLin += _nProxLin
        If Len(aLinhas) > 1
			nLin += _nProxLin
		EndIf
        nTotalG += nTotal
        nTotalI += nTotal + nCST + nICMS
        (cAliasPro)->(DbSkip())

    EndDo
    nLin += 05
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
    
    nLIn += _nProxLin
    oPrinter:Say( nLin, _nSegundaCol,"TOTAL SEM IMPOSTO: R$ " + Transform(nTotalG, "@E 999,999.99"), oFont11:oFont)
    nLIn += _nProxLin
    oPrinter:Say( nLin, _nSegundaCol,"TOTAL COM IMPOSTO: R$ " + Transform(nTotalI, "@E 999,999.99"), oFont11:oFont)
    nLin += 05
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
Return

Static Function ImpImposto()

Return

Static Function ImpObs(oPrinter, nLin)
	Local nX
	Local aLinhas := QuebraTexto(AllTrim(SC5->C5_MENNOTA), _nTamMaxObs)
	//OBSERVA«√O
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	nLin +=_nProxLin 
	oPrinter:Say(nLin,280	,"OBSERVA«√O",oFont12N:oFont)
	nLin += 5
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
	For nX := 1 To Len(aLinhas)
		nLin +=_nProxLin 
		oPrinter:Say(nLin,_nColInicio,aLinhas[nX],oFont11:oFont)
	Next
	nLin +=_nProxLin
	oPrinter:Line(nLin,_nColIniPag,nLin,_nLimPaCol)
Return

Static Function ImpRod(oPrinter, nPag)

	//RODAPE
	oPrinter:Line(768,_nColIniPag,768,_nLimPaCol)
	oPrinter:Say(780,280,"P·gina " + StrZero(nPag,2))    
Return
Static Function SayLabelValue(oPrinter, nLin, nCol, cLabel, cValue)
	Local nLabelLen := oPrinter:GetTextWidth(cLabel, oFont12N:oFont,2) - Len(cLabel)
	oPrinter:Say(nLin, nCol, cLabel, oFont12N:oFont)
	oPrinter:Say( ;
		nLin, ;
		nCol + nLabelLen , ;
		AllTrim(cValue), ;
		oFont11:oFont )
Return

Static Function GetFoto()
    Local aExtensao     := {".JPG",".JPEG",".BMP",".PNG"}
    Local cExtensao     := ""
    Local cPathPict     := GetSrvProfString("Startpath","")
    Local cBmpPict      := ""            
    Local cPathImage    := ""    
    Local nX            := 1


    cBmpPict := Upper( AllTrim( SB1->B1_BITMAP ) )
    For nX := 1 To Len(aExtensao)
        cExtensao := aExtensao[nX]
        If File(cPathPict+cBmpPict+cExtensao)
            cPathImage := cPathPict+cBmpPict+cExtensao
            Exit
        EndIf
    Next nX
Return cPathImage

Static Function xImposto(cCliCodigo, cCliLoja, cCliTipo, cCliTpFrete)
//+------------------------------------------------------------------------------+
		// Inicializa a funùùo fiscal                                                    |
		//+------------------------------------------------------------------------------+
		MaFisSave()
		MaFisEnd()
		MaFisIni(cCliCodigo      ,;// 1-Codigo Cliente/Fornecedor
		cCliLoja                 ,;// 2-Loja do Cliente/Fornecedor
		"C"                      ,;// 3-C:Cliente , F:Fornecedor
		"N"                      ,;// 4-Tipo da NF
		cCliTipo                 ,;// 5-Tipo do Cliente/Fornecedor
		Nil                      ,;// 6-
		Nil                      ,;// 7-
		Nil                      ,;// 8-
		Nil                      ,;// 9-
		"MATA461"                ,;// 10-Nome da rotina que esta utilizando a funcao
		Nil                      ,;// 11-
		Nil                      ,;// 12-
		Nil                      ,;// 13-
		Nil                      ,;// 14-
		Nil                      ,;// 15-
		Nil                      ,;// 16-
		Nil                      ,;// 17-
		Nil                      ,;// 18-
		Nil                      ,;// 19-
		Nil                      ,;// 20-
		Nil                      ,;// 21-
		Nil                      ,;// 22-
		Nil                      ,;// 23-
		Nil                      ,;// 24-
		Nil                      ,;// 25-
		cCliTpFrete              ;// 26-
		)
Return        

// Retorna um array com as linhas j· quebradas
Static Function QuebraTexto(cTexto, nTamMax)
	Local aLinhas := {}
	Local cLinha  := ""
	Local aPal    := {}
	Local nI

	cTexto := AllTrim(cTexto)
	aPal   := StrTokArr(cTexto, " ")

	For nI := 1 To Len(aPal)
		// Testa se cabe a prÛxima palavra
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
			cDesc := "Por conta destinat·rio"
		Case cType == "S"
			cDesc := "Sem frete"
		Otherwise
			cDesc := "Desconhecido"
	EndCase
Return cDesc


Static Function GetTipoPedido(cAliasImp)
    Local cTipo     := ""
    
    If (cAliasImp == "SC5")
            cTipo := "Pedido"
    ElseIf cAliasImp == "SCJ"
            cTipo := "Orcamento"
    Else
         If (Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_RESERVA) .AND. dDataBase<=SL1->L1_DTLIM .AND. SL1->L1_STATUS <> "D" .AND. IIf(SL1->(FieldPos("L1_STORC")) >0, SL1->L1_STORC <> "C", .T.) .And. Empty(SL1->L1_NUMFRT) .AND. (FieldPos("L1_STATUES") = 0 .Or. Empty(SL1->L1_STATUES)))
            cTipo := "Orcamento"
        Elseif Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D"
            cTipo := "Orcamento"
        Else    
            cTipo := "Pedido"
        EndIf            
    EndIf
Return cTipo    
