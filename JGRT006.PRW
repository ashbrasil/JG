#INCLUDE "TOTVS.CH"

// #DEFINE P_MARCA     1
// #DEFINE P_PRODUTO   2
// #DEFINE P_DESCRICAO 3
// #DEFINE P_VALOR     4

/*/{Protheus.doc} User Function JGRT006
    Rotina Histórico de vendas do produto para cliente
    @type  Function
    @author Lorran Ferreira
    @since 13/10/2023
    /*/
User Function JGRT006(_ItemPos)

Local aArea		  := GetArea()
Local cPosITEM    := ""
Local nSav		  := N
Local lPedidoVen  := FwIsInCallStack("MATA410")
Local lVendaAssi  := FwIsInCallStack("LOJA701")
Local cCliCodigo  := ""
Local cCliLoja    := ""

Static cCliCodigo := ""
Static cCliLoja   := ""
Static nPosItem   := 0
Static nPosProd   := 0
Static cPosITEM   := ""
Static cProCodigo := ""

Default _ItemPos := ""

If lPedidoVen
    cCliCodigo := M->C5_CLIENTE
    cCliLoja   := M->C5_LOJACLI
    nPosItem   := GdFieldPos("C6_ITEM")
    nPosProd   := GdFieldPos("C6_PRODUTO")
    cPosITEM   := aCols[N,nPosItem]
    cProCodigo := aCols[N,nPosProd]
ElseIf lVendaAssi
    cCliCodigo := M->LQ_CLIENTE
    cCliLoja   := M->LQ_LOJA
    nPosItem   := GdFieldPos("LR_ITEM")
    nPosProd   := GdFieldPos("LR_PRODUTO")
    cPosITEM   := aCols[N,nPosItem]
    cProCodigo := aCols[N,nPosProd]
Else
    Return(.T.)
EndIf

If Empty( _ItemPos )
    _ItemPos := cPosITEM
EndIf

// If !(Alltrim(cCliCodigo) == Alltrim(SA1->A1_COD) .And. Alltrim(cCliLoja) == Alltrim(SA1->A1_LOJA))
// 	SA1->(DbSetOrder( 1 ))
// 	SA1->(DbSeek( FWxFilial("SA1")+cCliCodigo+cCliLoja ))
// EndIf

//Excetua o cliente padrão - Incluir os clientes referentes às filiais
If !(Alltrim(cCliCodigo) == Alltrim(SUPERGETMV("MV_CLIPAD",.F.,"XYZXYZ")))
    fHistorico(cProCodigo, cCliCodigo, cCliLoja)
EndIf

N := nSav

RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} fHistorico
    Histórico de vendas do produto para cliente.
    @type   Static Function
    @author Jesus Ramos
    @since 21/01/2026
    /*/
Static Function fHistorico(cProCodigo, cCliCodigo, cCliLoja)
    
Local cQry 		:= ""
Local aLista	:= {}

cQry += "   SELECT " + CRLF
cQry += "   	F2_EMISSAO AS EMISSAO, F2_FILIAL AS FILIAL, F2_SERIE AS SERIE, F2_DOC AS DOC, D2_ITEM AS ITEM " + CRLF
cQry += "   	, D2_QUANT AS QTDE, D2_PRCVEN AS VALOR, D2_TOTAL AS TOTAL, F2.R_E_C_N_O_ AS F2_RECNO " + CRLF
cQry += "   FROM " + CRLF
cQry += "   	" + RetSqlName("SD2") + " D2 " + CRLF
cQry += "   	INNER JOIN " + RetSqlName("SF2") + " F2 ON F2.D_E_L_E_T_ = ' ' " + CRLF
cQry += "   		AND F2_FILIAL = D2_FILIAL AND F2_SERIE = D2_SERIE AND F2_DOC = D2_DOC " + CRLF
cQry += "   		AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA " + CRLF
cQry += "   WHERE " + CRLF
cQry += "   	D2.D_E_L_E_T_ = ' ' AND D2_COD = " + ValToSql(cProCodigo) + CRLF
cQry += "   	    AND D2_CLIENTE = " + ValToSql(cCliCodigo) + " AND D2_LOJA = " + ValToSql(cCliLoja) + CRLF
cQry += "   	    AND ( D2_CF BETWEEN '5100' AND '5123' OR D2_CF BETWEEN '6100' AND '6123' ) " + CRLF
cQry += "   ORDER BY " + CRLF
cQry += "       F2.R_E_C_N_O_ DESC " + CRLF
cQry += "   FETCH FIRST 3 ROW ONLY " + CRLF

cAliasTemp := MpSysOpenQuery(cQry)

While (cAliasTemp)->(!EoF())

		AAdd(aLista, { .F.,;
						StoD((cAliasTemp)->EMISSAO), ;
						(cAliasTemp)->FILIAL, ;
						Alltrim((cAliasTemp)->SERIE), ;
						Alltrim((cAliasTemp)->DOC), ;
						Alltrim((cAliasTemp)->ITEM), ;
						(cAliasTemp)->QTDE, ;
						(cAliasTemp)->VALOR, ;
						(cAliasTemp)->TOTAL })

	(cAliasTemp)->(DBSkip())
	
EnddO

(cAliasTemp)->(DBCloseArea())

If Len(aLista) > 0
    fViewHistorico(aLista)
EndIf

Return()

/*/{Protheus.doc} fViewHistorico
    Tela para visualizar o histórico de vendas do produto para cliente.
    @type  Static Function
    @author Jesus Ramos
    @since 26/01/2026
/*/
Static Function fViewHistorico(aLista)
    
    Local oDialog       as object
    Local oDlgTela      as object
    Local aCoors        as array
    Local oFwLayer      as object
    Local oPainelA      as object
    Local aButtons      := {}   as array
	Local oBrwTela      as object
	Local aBrwTela	    := {}   as array
    // Local oTimer        as object
    // Local nTempo        := 3000 as numeric // 3 segundos
    // Local nVezes        := 0    as numeric
    // Local oOk           := LoadBitmap(GetResources(), "LBOK") as object
    // Local oNo           := LoadBitmap(GetResources(), "LBNO") as object   
 
    Private oTimer      as object
    Private nTempo      := 3000 as numeric // 3 segundos
    Private nVezes      := 0    as numeric

    //Obter os dados de tamanho da tela atual
	aCoors := FwGetDialogSize()
    aCoors[3] := 200 //aCoors[3]*0.45 //% da tela atual
    aCoors[4] := 750 //aCoors[4]*0.38 //% da tela atual

    // Método responsável por criar a janela e montar os paineis.
    oDialog := FWDialogModal():New()

    // Métodos para configurar o uso da classe.
    oDialog:SetBackground( .F. ) 
    // oDialog:SetTitle( 'Histórico de vendas do produto para o cliente')
    oDialog:SetSize( aCoors[3]/2, aCoors[4]/2 )
    oDialog:EnableFormBar( .T. )
    oDialog:SetCloseButton( .F. )
    oDialog:SetEscClose( .T. )
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    // oDialog:addCloseButton({|| AddProduto(@aBrwTela) , oDialog:DeActivate()}, "Fechar") //{|| SELF:OOWNER:END()}

    //AADD(aButtons,  { Nil,"Confirmar"   , {|| AddProduto(@aBrwTela) , oDialog:DeActivate()}   ,""		, 0 , .T. , .F. } )
    // AADD(aButtons,  { Nil,"Detalhes"    , {|| FDETALHE(aBrwTela[oBrwTela:nAt,02]) }   ,""		, 0 , .T. , .F. } )
    AADD(aButtons,  { Nil,"Fechar"      , {|| oDialog:DeActivate()}   ,""		, 0 , .T. , .F. } )

    oDialog:addButtons( aButtons )    

    // Capturar o objeto do FwDialogModal para alocar outros objetos se necessário.
    oDlgTela := oDialog:GetPanelMain()

    //Criando a camada
    oFwLayer := FwLayer():New()
    oFwLayer:init(oDlgTela,.F.)

    //Adicionando linhas
    oFWLayer:addLine("LIN01" , 100  , .F.)

    //Adicionando as colunas das linhas
    oFWLayer:addCollumn("COL01LIN01",   100  , .F., "LIN01")

    //criar janelas nas colunas
    oFWLayer:addWindow('COL01LIN01', 'WC01LIN01' ,'Histórico de vendas do produto '+AllTrim(cProCodigo)+' para o cliente',100,.F.,.F.,,'LIN01',)

    //Criando os paineis
    oPainelA  := oFWLayer:getWinPanel('COL01LIN01','WC01LIN01','LIN01')

	//Monta o Browse
	oBrwTela := TWBrowse():New(01, 01, 200,200,,,, oPainelA,,,,,,,,,,,, .F.,, .T.,, .F.,,,)
	//Ajusta o tamanho do browse conforme o painel, ficando com tamanho dinamico
	oBrwTela:nWidth  := oPainelA:nclientwidth
	oBrwTela:nHeight := oPainelA:nclientheight

	aBrwTela  := aLista
	oBrwTela:setArray(aBrwTela)

	// oBrwTela:addColumn( TCColumn():New("",              {||If(aBrwTela[oBrwTela:nAt,01],oOk,oNo)},   /*cPicture*/ ,,, "CENTER", 10, .T., .F.,,,,,) )
	// oBrwTela:addColumn( TCColumn():New("Produto",       {||aBrwTela[oBrwTela:nAt,02]},             /*cPicture*/ ,,, "LEFT" , 30 , .F., .F.,,,,,) )
	// oBrwTela:addColumn( TCColumn():New("Descricao",     {||aBrwTela[oBrwTela:nAt,03]},             /*cPicture*/ ,,, "LEFT" , 60 , .F., .F.,,,,,) )
    // oBrwTela:addColumn( TCColumn():New("Valor",         {||aBrwTela[oBrwTela:nAt,04]},             "@E 99,999,999.99",,, "RIGHT" , 35 , .F., .F.,,,,,) )

	// oBrwTela:addColumn( TCColumn():New("",              {||IIf(aBrwTela[oBrwTela:nAt,01],oOk,oNo)}, /*cPicture*/ ,,, "CENTER", 10, .T., .F.,,,,,) )
	oBrwTela:addColumn( TCColumn():New("Emissão",       {||aBrwTela[oBrwTela:nAt,02]},              /*cPicture*/ ,,, "LEFT" , 35 , .F., .F.,,,,,) )
	oBrwTela:addColumn( TCColumn():New("Filial",        {||aBrwTela[oBrwTela:nAt,03]},              /*cPicture*/ ,,, "LEFT" , 25 , .F., .F.,,,,,) )
	oBrwTela:addColumn( TCColumn():New("Serie",         {||aBrwTela[oBrwTela:nAt,04]},              /*cPicture*/ ,,, "LEFT" , 25 , .F., .F.,,,,,) )
	oBrwTela:addColumn( TCColumn():New("Doc",           {||aBrwTela[oBrwTela:nAt,05]},              /*cPicture*/ ,,, "LEFT" , 35 , .F., .F.,,,,,) )
	oBrwTela:addColumn( TCColumn():New("Item",          {||aBrwTela[oBrwTela:nAt,06]},              /*cPicture*/ ,,, "LEFT" , 25 , .F., .F.,,,,,) )
    oBrwTela:addColumn( TCColumn():New("Qtde",          {||aBrwTela[oBrwTela:nAt,07]},              "@E 99,999,999.99",,, "RIGHT" , 40 , .F., .F.,,,,,) )
    oBrwTela:addColumn( TCColumn():New("Valor",         {||aBrwTela[oBrwTela:nAt,08]},              "@E 99,999,999.99",,, "RIGHT" , 60 , .F., .F.,,,,,) )
    oBrwTela:addColumn( TCColumn():New("Total",         {||aBrwTela[oBrwTela:nAt,09]},              "@E 99,999,999.99",,, "RIGHT" , 60 , .F., .F.,,,,,) )

	//oBrwTela:bWhen := { || Len(aBrwTela) > 0 }  

    // DoubleClick event
	// oBrwTela:bLDblClick := {|| aBrwTela[oBrwTela:nAt,1] := !aBrwTela[oBrwTela:nAt,1] , FMUDA(@aBrwTela,oBrwTela:nAt,aBrwTela[oBrwTela:nAt,1]) ,;
	// oBrwTela:DrawSelect()}

    oBrwTela:SetFocus()

    // // Define o Objeto Timer para atualizar o status do pagamento
    // oTimer := TTimer():New(nTempo, {|| nVezes++, Sleep(1000), IIf(nVezes > 2, oDialog:End(),NIL) }, oDialog )
    // oTimer:Activate()

    oDialog:Activate()

Return

/*/{Protheus.doc} FMUDA
    Muda a Marca
    @type  Static Function
    @author Lorran Ferreira
    @since 13/10/2023
/*/
// Static Function FMUDA(aLista,nLinha,lMarca)
    
//     Local _P := 0

//     For _P:=1 To Len(aLista)
//         If _P != nLinha
//           aLista[_p][1] := !lMarca
//         EndIf
//     Next _P

// Return

/*/{Protheus.doc} FDETALHE
    Mostra o detalha do plano selecionado
    @type  Static Function
    @author Lorran Ferreira
    @since 27/01/2024
/*/
// Static Function FDETALHE(cCodPlano)
    
// 	Local oDlg      as object
//     Local oFwLayer_ as object
//     Local oPanel01  as object	
//     Local oPanel02  as object	
//     Local aCoors    as array
// 	Local oBrwDet   as object
// 	Local aBrwDet	:= {}   as array    
//     Local aLista    := {} as array
//     Local oMemo     as object
//     Local cMemo     := "" as character
//     Local cQry      := "" as character
//     Local cAliasTemp  := "" as character

//     DEFAULT cCodPlano := ""

//     If EMPTY(cCodPlano)
//         Return()
//     EndIf

//     cQry := "SELECT DISTINCT ZZQ_CODSER,ZZQ_QUANT,ZAF_CODIGO,ZAF_DESCRI,ZAF_DETALH "
//     cQry += "FROM "+RetSqlName("ZZQ")+" ZZQ "
//     cQry += "INNER JOIN "+RetSqlName("ZAF")+" ZAF ON ZAF.D_E_L_E_T_='' AND ZAF_FILIAL='"+FwxFilial("ZAF")+"' AND ZAF_CODIGO=ZZQ_CODSER "
//     cQry += "WHERE ZZQ.D_E_L_E_T_='' "
//     cQry += "AND ZZQ_FILIAL = '"+FwxFilial("ZZQ")+"' "
//     cQry += "AND ZZQ_PLANO = '"+Alltrim(cCodPlano)+"' "
//     cQry += "AND ZZQ_MSBLQL<>'1' "

//     cAliasTemp  := MpSysOpenQuery( cQry )
//     while (cAliasTemp)->(!EOF())

//             AADD( aLista, {     (cAliasTemp)->ZZQ_CODSER,;
//                                 (cAliasTemp)->ZAF_DESCRI,;
//                                 (cAliasTemp)->ZZQ_QUANT,;
//                                 (cAliasTemp)->ZAF_DETALH;
//                                 } )

//         (cAliasTemp)->(DbSkip())
//     enddo
//     (cAliasTemp)->(DbCloseArea())    

//     //Obter os dados de tamanho da tela atual
// 	aCoors := FwGetDialogSize()
//     aCoors[3] := aCoors[3]*0.50 //% da tela atual - Altura
//     aCoors[4] := aCoors[4]*0.60 //% da tela atual - Largura

// 	DEFINE MSDIALOG oDlg TITLE "Detalhe do plano "+ Alltrim(cCodPlano) FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] COLORS 0, 16777215 PIXEL //STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) 

//     //Criando a camada
//     oFwLayer_ := FwLayer():New()
//     oFwLayer_:init(oDlg,.F.)

//     //Adicionando linhas
//     oFwLayer_:addLine("LIN1" , 100  , .F.)

//     //Adicionando as colunas das linhas
//     oFwLayer_:addCollumn("COL1",   60, .F., "LIN1")
//     oFwLayer_:addCollumn("COL2",   40, .F., "LIN1")

//     //criar janelas nas colunas
//     oFwLayer_:addWindow('COL1', 'WCOL101' ,'Serviços' ,100,.F.,.F.,,'LIN1',)
//     oFwLayer_:addWindow('COL2', 'WCOL201' ,'Detalhe do serviço' ,100,.F.,.F.,,'LIN1',)

//     //Criando os paineis
//     oPanel01  := oFwLayer_:getWinPanel('COL1','WCOL101','LIN1')
//     oPanel02  := oFwLayer_:getWinPanel('COL2','WCOL201','LIN1')

// 	//Monta o Browse
// 	oBrwDet := TWBrowse():New(01, 01, 321,234,,,, oPanel01,,,,,,,,,,,, .F.,, .T.,, .F.,,,)
// 	//Ajusta o tamanho do browse conforme o painel, ficando com tamanho dinamico
// 	oBrwDet:nWidth  := oPanel01:nclientwidth
// 	oBrwDet:nHeight := oPanel01:nclientheight

//     oBrwDet:bChange    := {|| cMemo := aBrwDet[oBrwDet:nAt,04] , oMemo:Refresh() }    

//     aBrwDet := {{"","", 0,""}} //Valor padrão para browse sem dados.
//     If Len(aLista)>0
// 	aBrwDet  := aLista
//     EndIf
// 	oBrwDet:setArray(aBrwDet)

// 	oBrwDet:addColumn( TCColumn():New("Codigo",       {||aBrwDet[oBrwDet:nAt,01]},             /*cPicture*/ ,,, "LEFT" , 30 , .F., .F.,,,,,) )
// 	oBrwDet:addColumn( TCColumn():New("Descricao",    {||aBrwDet[oBrwDet:nAt,02]},             /*cPicture*/ ,,, "LEFT" , 80 , .F., .F.,,,,,) )
//     oBrwDet:addColumn( TCColumn():New("Quantidade",   {||aBrwDet[oBrwDet:nAt,03]},             "@E 99,999,999.99",,, "RIGHT" , 30 , .F., .F.,,,,,) )

//     oScr1 := TScrollBox():New(oPanel02,01,01,(oPanel02:nclientheight-2)/2,(oPanel02:nclientwidth-2)/2,.T.,.T.,.T.)
// 	//Ajusta o tamanho do browse conforme o painel, ficando com tamanho dinamico
// 	// oScr1:nWidth  := oPanel01:nclientwidth-2
// 	// oScr1:nHeight := oPanel01:nclientheight-2    
//     cMemo := aBrwDet[oBrwDet:nAt,04]
//     @ 002, 001 GET oMemo VAR cMemo MEMO SIZE (oScr1:nWidth-2)/2, (oScr1:nHeight-2)/2 OF oScr1 COLORS 0, 16777215 PIXEL
//     oMemo:lReadOnly := .T.

//     ACTIVATE MSDIALOG oDlg CENTERED


// Return

/*/{Protheus.doc} AddProduto
    (Adiciona o produto na aCols do CallCenter)
    @type  Static Function
    @author Lorran Ferreira
    @since 13/10/2023
    /*/
/*
Static Function AddProduto(aLista)
    
	Local PL       := N
    Local nAtual   := 0
    Local cCodREF  := aCols[N,nPosProd]
    Local cIteREF  := aCols[N,nPosItem]
    Local cTipREF  := "SER"
    Local cTabela  := aCols[N,nPosTabPre]
    Local lTemMarca  := .F.

    If aScan(aLista, {|x| x[P_MARCA] }) > 0
        lTemMarca  := .T.
    EndIf
	
    If lTemMarca
    	// -> Adiciona os produtos no aCols
		For PL:=1 To Len(aLista)
			
            If !aLista[PL][P_MARCA]
                Loop
            EndIf

			oGetTlv:addLine(.t.)

			nAtual := N

			oGetTlv:oBrowse:Refresh(.T.)
			
			aCols[n, nUBALIWT ] 	:= "SUB"
			aCols[n, mUBRECWT ] 	:= 0
			aCols[n,Len(acols[n])]	:= .F.
			aCols[n, nPosQuant]		:= 1
            aCols[n, nPosPrc] 	    := aLista[PL][P_VALOR]

			// executo as validacoes
			__ReadVar			:= "M->UB_PRODUTO"
			M->UB_PRODUTO		:= aLista[PL][P_PRODUTO]
			SX3->(DbSetOrder(2), DbSeek("UB_PRODUTO"))
			&(SX3->X3_VALID)
			n := nAtual
			&(SX3->X3_VLDUSER)
			n := nAtual
		
			//Dispara os Gatilhos
		
			RunTrigger(2,N,Nil,,"UB_PRODUTO")
			n := nAtual//Retorna para a linha do produto, por conta do gatilho
		
            aCols[n, nPosXIDPROD]   := cCodREF 
            aCols[n, nPosCODREF]    := cCodREF 
            aCols[n, nPosITEREF]    := cIteREF
            aCols[n, nPosTIPREF]    := cTipREF
            aCols[n, nPosFILNF]     := cESFILPTKR //Filial da NF do Primetek Resolve
            aCols[n, nPosMOVFAT]    := cTipREF+"00" //Tipo de Produto
            aCols[n, nPosPrc] 	    := aLista[PL][P_VALOR]
			aCols[n, nPosPrcTab]    := aCols[n, nPosPrc]
			aCols[n, nPosTot]       := Round( aCols[n, nPosQuant] * aCols[n, nPosPrcTab] , 2 )
			aCols[n, nPosTotCTr]    := aCols[n][nPosTot]
			aCols[n, nPosTabPre]    := cTabela
            aCols[n, nPosDesc]      := 0
			aCols[n, nPosVDes]      := 0
			aCols[n, nPosAcres]     := 0
			aCols[n, nPosVAcres]    := 0            

			__ReadVar			:= "M->UB_PRODUTO"

			n := nAtual

            Tk273Calcula(,n)
			
			//Dispara o ponto de entrada para calcular as comissões
			U_TKEVALI()
			
		Next PL
    else
        If lTemMarca
            MsgStop("O número de série não foi informado o produto não será adicionado!")
        EndIf
    EndIf

Return 
*/
/*/{Protheus.doc} FPODEADD
    (Verifica se pode adicionar o plano, se tem plano vinculado, ou o produto foi modificado.)
    @type  Static Function
    @author Lorran Ferreira
    @since 13/10/2023
/*/
/*
Static Function FPODEADD()
    Local nRegRef := 0
    Local lRet       := .T.

    nRegRef := aScan(aCols, {|x| !aTail(x) .And. x[nPosITEREF] == aCols[N,nPosItem] } )

    If nRegRef > 0
        If aCols[nRegRef][nPosCODREF] == aCols[N][nPosProd]

            If !FwIsInCallStack("U_ESTRUTURA") // Não notificar a inclusão de estrutura de produtos.
                MsgAlert("Já existe(m) produtos(s) inserido(s) para este item/produto."+CRLF+;
                            "Não serão ofertados/inseridos novos lançamentos."+CRLF+;
                            "Para modificá-los, exclua-os e edite o item/produto.",;
                            "Primetek Resolve")
            Endif
            lRet := .F.

        Else 
            
            MsgAlert("Existem produtos vinculados ao item/produto anterior, e serão excluídos.", "Primetek Resolve")
            
            lRet := FDELJAADD()
            
            If !lRet
                MsgAlert("Os produtos vinculados ao produto anterior não foram excluídos devido a algum problema."+CRLF+;
                            "Refaça o orçamento."+CRLF+;
                            "Primetek Resolve")
            EndIf
            
        EndIf
        
    EndIf
Return lRet
*/
/*/{Protheus.doc} FDELJAADD
    Deleta registro Primetek Resolve
    @type  Static Function
    @author Lorran Ferreira
    @since 13/10/2023
/*/
/*
Static Function FDELJAADD()

Local lRet       := .F.
Local nLinBusca     := 0
Local lProcessar := .T.

While lProcessar

	nLinBusca := aScan(aCols, {|a| !aTail(a) .And. a[nPosITEREF] == aCols[N,nPosItem] }, nLinBusca+1)

	If nLinBusca > 0

		aCols[nLinBusca][Len(aCols[nLinBusca])] := .T.
		lRet := .T.
		
	Else

		lProcessar := .F.

	EndIf

End

If lRet

	oGetTlv:oBrowse:Refresh(.T.)

	aValores[1]	:= U_RTMKA02C()
	aValores[6]	:= U_RTMKA02C()
	aValores[8]	:= U_RTMKA02C()
	
	aObj[1]:Refresh()
	aObj[6]:Refresh()
	aObj[8]:Refresh()

EndIf

Return(lRet)
*/
