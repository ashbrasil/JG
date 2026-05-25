#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ JGRT011B ºAutor  ³Lorran Gomes        º Data ³  08/03/2026 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera pedido e NF no faturamento 			 					º±±
±±º          ³ Transferência entre filiais									º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function JGRT011B(_nRecnoPed, _cCliente, _cArmOrig, _cArmDest, _cObs, aSC5, aSC6)
	Local _aArea := FWGetArea()
	Local aDoc

	Private _MSG := {| cStr | Iif(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), U_FLOGJG(cStr)) }

	// Default aSC5      := {} //Array com campos extras parar adicionar no ExecAuto.
	// Default aSC6      := {} //Array com campos extras parar adicionar no ExecAuto.

	// U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )
	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	If IsBlind() .Or. FWIsInCallStack("JGRT011") //Chama direto a geração sem mostrar o progresso para não travar a tela do pedido.
		aDoc := fGera(_nRecnoPed, _cCliente, _cArmOrig, _cArmDest, _cObs, aSC5, aSC6)
	Else
		FWMsgRun(, {|oSay| aDoc := fGera(_nRecnoPed, _cCliente, _cArmOrig, _cArmDest, _cObs, aSC5, aSC6, @oSay) }, ;
							"Processando - "+IIf(_nRecnoPed>0,"Nota Fiscal", "Pedido de Venda"), "Aguarde, processando a rotina" )
	EndIf

	FWRestArea(_aArea)

Return( aDoc )

Static Function fGera(_nRecnoPed, _cCliente, _cArmOrig, _cArmDest, _cObs, aSC5, aSC6, oSay)

    Local cAliasAnt    	:= Alias()
    Local aArea         := FwGetArea()
    Local aAreaSC5      := SC5->(FwGetArea())
    Local aAreaSC6      := SC6->(FwGetArea())
    Local aAreaSC9      := SC9->(FwGetArea())
    Local aAreaSB2      := SB2->(FwGetArea())
    Local aAreaSA1      := SA1->(FwGetArea())
    Local aAreaSB1      := SB1->(FwGetArea())
    Local aAreaSE4      := SE4->(FwGetArea())
    Local aAreaSA3      := SA3->(FwGetArea())

	Local _aCab			:= {}
	Local _aItens		:= {}
	// Local aLinha		:= {}
	// Local aMapSC6		:= {}
	Local cErrorBlock	:= ""
	Local aErro
	Local _cMsgErro		:= ""
	Local _cBloqEst		:= ""
	Local _cBloqCred	:= ""
	Local _aPvlNfs		:= {}
	Local _cPedido		:= ""
	Local nRecnoPed     := 0
	Local nRecnoNf      := 0
	Local cNota 		:= ""
	Local cSerie		:= ""
	// Local C
	Local x, y, nX

	Default oSay := Nil
	Default aSC5 := {} //Array com campos extras parar adicionar no ExecAuto.
	Default aSC6 := {} //Array com campos extras parar adicionar no ExecAuto.

	DBSelectArea("SC5")
	DBSelectArea("SC6")
	DBSelectArea("SC9")
	DBSelectArea("SA1")
	DBSelectArea("SB1")
	DBSelectArea("SB2")
	DBSelectArea("SE4")
	DBSelectArea("SA3")

	If _nRecnoPed = 0

		//Array contendo os campos do cabeçalho (SC5) para ExecAuto MATA410
		_aCab   := AClone(aSC5)
		If !Empty(_cObs) .And. (AScan(_aCab, {|x| x[1] == "C5_XMSNOTA"}) == 0)
		    AAdd(_aCab, {"C5_XMSNOTA", _cObs, Nil} )
		EndIf

		_aItens := AClone(aSC6)
		
		If Len(_aCab) > 0 .And. Len(_aItens) > 0

			Eval(_MSG,cFilAnt+"-Gerando Pedido de Transferência...")
			lMsErroAuto := .F.
			lAutoErrNoFile := .T.

			Begin Transaction
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³                 Gera Pedido de venda no faturamento - MATA410			     ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				U_FLOGJG("JGRT011B - Gerando Pedido - Filial: "+cFilAnt)
				SC5->(dbSetOrder(1))
				MsExecAuto({|x,y,z| MATA410(x,y,z) }, _aCab, _aItens, 3)
				aErro := GetAutoGRLog()

				If !lMsErroAuto

					If !IsBlind()
						FWAlertSuccess("Foi gerado pedido no faturamento - Número: "+SC5->C5_NUM, "Pedido Gerado")
					Else
						U_FLOGJG("Foi gerado pedido no faturamento - Número: "+SC5->C5_NUM)
					EndIf

					_cPedido  := SC5->C5_NUM
					nRecnoPed := SC5->(RECNO())

					// U_JGRT11_E(SC5->(RECNO()), JGTrPVPSp)//Grava Status no Pedido

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³                 Prepara os dados para gerar Nota fiscal de saida			   ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL
					// Eval(_MSG,cFilAnt+"-Preparando Nota de Saída Transferência...")
					// _aAreaAt := FWGetArea()
					// fPrepNfs(@_aPvlNfs, @_cBloqEst, @_cBloqCred, _cPedido)
					// FWRestArea(_aAreaAt)

				Else

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³                 Se der problema desfaz tudo				                  ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

					RollBackSX8()
					DisarmTransaction()

					cErrorBlock := ""
					For nX := 1 To Len(aErro)
						cErrorBlock += aErro[nX] + CRLF
					Next nX

					cErrorBlock := "Erro ao gerar Pedido de Transferência: "+CRLF+cErrorBlock
					If !IsBlind()
						FWAlertError(cErrorBlock, "Erro")
					Else
						U_FLOGJG(cErrorBlock)
					EndIf

				EndIf
			End Transaction

		EndIf

	Else

		nRecnoPed := _nRecnoPed
		SC5->(DbGoTo(nRecnoPed))
		Eval(_MSG, cFilAnt+"-Preparando Nota de Saída Transferência...")
		_cPedido := SC5->C5_NUM

		_aAreaAt := FWGetArea()
		fPrepNfs(@_aPvlNfs, @_cMsgErro, @_cBloqEst, @_cBloqCred, _cPedido)
		FWRestArea(_aAreaAt)

		If Len(_aPvlNfs) > 0 .And. Empty(_cBloqEst) .And. Empty(_cBloqCred) .And. Empty(_cMsgErro)
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³                 Gera a Nota fiscal de saida					                  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Eval(_MSG,cFilAnt+"-Gerando Nota de Saída Transferência...")
			U_FLOGJG("JGRT011B - Gerando Nota de Saída - Filial: "+cFilAnt)
			U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL
			_aAreaAt := FWGetArea()
			
			cSerie := fDefSerie() // Jesus Ramos - 02/09/2020 - Definição da série pelo MV_ESPECIE
			
			SX5->(dbSetOrder(1))
			SX5->(DbSeek(cFilAnt+"01"+Pad(cSerie,6)))

			Pergunte("MT460A",.F.)
			mv_par17 := 2 //Gera Titulo              ?  Sim/Nao  
			mv_par18 := 2 //Gera guia recolhimento   ?  Sim/Nao
			mv_par19 := 2 //Gera Titulo ICMS Próprio ?  Sim/Nao
			mv_par20 := 2 //Gera Guia ICMS Próprio   ?  Sim/Nao 

			cNota := MaPvlNfs(_aPvlNfs,cSerie,.F.,.F.,.F.,.T.,.F.,0,0,.T.,.F.,Nil)
			nRecnoNf := SF2->(RECNO())

			FWRestArea(_aAreaAt)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Destrava os registro do SX5                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//SX5->(MsRUnLock())
			MSUnlockAll()

			If Alltrim(_cPedido) <> Alltrim(SC5->C5_NUM)
				cErrorBlock := "JGRT011B - Erro ao gerar o pedido de venda."+CRLF+;
								"Número do pedido diferente do pedido processado, ao final do processo de preparação do documento de saída."+CRLF+;
								"Verifique se o documento de saída (NF) foi gerado corretamente para o pedido: "+_cPedido+" (Pedido posicionado: "+SC5->C5_NUM+")."
				If !IsBlind()
					FWAlertError(cErrorBlock, "Erro")
				Else
					U_FLOGJG(cErrorBlock)
				EndIf
			EndIf

			If Empty(cNota)
				cErrorBlock := "A nota fiscal de saída não foi gerada devido a algum problema momentâneo, tente gerar a nota novamente."
				If !IsBlind()
					FWAlertError(cErrorBlock, "Nota Fiscal Não Gerada")
				Else
					U_FLOGJG(cErrorBlock)
				EndIf
			Else
				If !IsBlind()
					FWAlertSuccess("A nota fiscal de saída foi gerada com sucesso! "+ CRLF +" Numero: "+cNota+" - Série: "+cSerie, "Nota Fiscal Saída Gerada")
				Else
					U_FLOGJG("A nota fiscal de saída foi gerada com sucesso! "+ CRLF +" Numero: "+cNota+" - Série: "+cSerie)
				EndIf
			EndIf
		Else
			If !Empty(_cMsgErro)
				cErrorBlock += _cMsgErro
				If !IsBlind() 
					FWAlertWarning(_cMsgErro, "ERRO")
				Else
					U_FLOGJG(_cMsgErro)
				EndIf
			EndIf
			If !Empty(_cBloqCred)
				cErrorBlock += _cBloqCred
				If !IsBlind() 
					FWAlertWarning(_cBloqCred, "BLOQUEIO POR CREDITO")
				Else
					U_FLOGJG(_cBloqCred)
				EndIf
			EndIf
			If !Empty(_cBloqEst)
				cErrorBlock += _cBloqEst
				If !IsBlind()
					FWAlertWarning(_cBloqEst, "BLOQUEIO POR ESTOQUE")
				Else
					U_FLOGJG(_cBloqEst)
				EndIf
			EndIf
		EndIf

    EndIf

    //Restaura a entrada da rotina                                    
    FwRestArea(aAreaSA3)
    FwRestArea(aAreaSE4)
    FwRestArea(aAreaSB1)
    FwRestArea(aAreaSA1)
    FwRestArea(aAreaSB2)
    FwRestArea(aAreaSC9)
    FwRestArea(aAreaSC6)
    FwRestArea(aAreaSC5)
    FwRestArea(aArea)
    DbSelectArea(cAliasAnt)

Return( { cNota, cSerie, nRecnoNF, _cPedido, nRecnoPed, cErrorBlock } )

/*/{Protheus.doc} fPrepNfs

	Retorna a avaliação das liberações do pedido.

@type function
@version  
@author Jesus Ramos
@since 06/05/2026
@param _aPvlNfs, variant, matriz de 
@param _cBloqEst, variant, param_description
@param _cBloqCred, variant, param_description
@param _cPedido, variant, param_description
@return variant, return_description
/*/
Static Function fPrepNfs( _aPvlNfs, _cMsgErro, _cBloqEst, _cBloqCred, _cPedido )

    Local cAliasAnt := Alias()
    Local aArea     := FwGetArea()
    Local aAreaSC5  := SC5->(FwGetArea())
    Local aAreaSC6  := SC6->(FwGetArea())
    Local aAreaSC9  := SC9->(FwGetArea())
    Local aAreaSB2  := SB2->(FwGetArea())
    Local aAreaSA1  := SA1->(FwGetArea())
    Local aAreaSB1  := SB1->(FwGetArea())
    Local aAreaSE4  := SE4->(FwGetArea())
    Local aAreaSA3  := SA3->(FwGetArea())

	_cMsgErro   := ""
	_cBloqEst 	:= ""
	_cBloqCred	:= ""

	If Alltrim(SC5->C5_NUM) <> Alltrim(_cPedido)

		SC5->(dbSetOrder(1))
		If !SC5->(DbSeek(cFilAnt+_cPedido))
			_cMsgErro := "Erro ao posicionar no pedido de venda: "+_cPedido+"."
			Return()
		EndIf

	EndIf

	SC9->(dbSetOrder(1))
	If SC9->(DbSeek(SC5->C5_FILIAL + SC5->C5_NUM))
		_aPvlNfs := {}
		While !SC9->(EOF()) .AND. SC9->C9_FILIAL == SC5->C5_FILIAL .AND. SC9->C9_PEDIDO = SC5->C5_NUM

			// a450Grava - Parametros nOpc:	1 - Libera
			//                  			2 - Rejeita
			//            					lAtuCred : Indica se Libera Credito
			//            					lAtuEst  : Indica se Libera Estoque
			//a450Grava(1,lAtuCred,lAtuEst)

			SC6->(dbSetOrder(1))
			SC5->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SB2->(dbSetOrder(1))
			SF4->(dbSetOrder(1))
			SE4->(dbSetOrder(1))

			If !Empty(SC9->C9_BLEST) .AND. SC9->C9_BLEST <> "10"
				If Empty( _cBloqEst )
					_cBloqEst := "["+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"] Contém itens com bloqueio de estoque: " + CRLF
				EndIf
				_cBloqEst += "Item: "+Alltrim(SC9->C9_ITEM)+" Produto: "+SC9->C9_PRODUTO + CRLF
			EndIf

			If !Empty(SC9->C9_BLCRED) .AND. SC9->C9_BLCRED <> "10"
				_cBloqCred := "["+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"] Pedido Bloqueado por Crédito."
			EndIf

			If Len(AllTrim(SC9->C9_BLEST)) <= 0 .And. Len(AllTrim(SC9->C9_BLCRED)) <= 0
				SC6->(DbSeek(FWxFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM)))
				SB1->(DbSeek(FWxFilial("SB1")+SC9->C9_PRODUTO))
				SB2->(DbSeek(FWxFilial("SB2")+SC9->(C9_PRODUTO+C9_LOCAL)))
				SF4->(DbSeek(FWxFilial("SF4")+SC6->C6_TES))
				SE4->(DbSeek(FWxFilial("SE4")+SC5->C5_CONDPAG))
				aAdd(_aPvlNfs,{ SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			EndIf
			SC9->(dbSkip())
		EndDo

	EndIf

    //Restaura a entrada da rotina                                    
    FwRestArea(aAreaSA3)
    FwRestArea(aAreaSE4)
    FwRestArea(aAreaSB1)
    FwRestArea(aAreaSB2)
    FwRestArea(aAreaSA1)
    FwRestArea(aAreaSC9)
    FwRestArea(aAreaSC6)
    FwRestArea(aAreaSC5)
    FwRestArea(aArea)
    DbSelectArea(cAliasAnt)

Return


Static Function fDefSerie()

Local aEspecie		:= StrTokArr2( SuperGetMv("MV_ESPECIE",.F.,""), ";" ) // 002=SPED;U=RPS
Local aSerie
Local nX
Local cSerieSped	:= ""

For nX := 1 To Len(aEspecie)
	aSerie := StrTokArr2( aEspecie[nX], "=" )
	If Len(aSerie) > 1 .And. AllTrim(aSerie[2]) == "SPED"
		cSerieSped := aSerie[1]
		Exit
	EndIf
Next nX

Return(cSerieSped)
