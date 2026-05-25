#Include "Totvs.ch"

/*/{Protheus.doc} A100DEL

Ponto de entrada para validar a exclusão do documento de entrada.
Validações realizadas:
- Se o produto possui controle de estoque e se há saldo disponível para exclusão do documento de entrada.
- Se a nota é de transferência imediata vinculada a um orçamento do SIGALOJA e se o orçamento não está finalizado.

@type    function
@version 1.0
@author  Jesus Ramos
@since   01/05/2026
@return  variant, return_description
/*/
User Function A100DEL()

	Local cAliasAnt := Alias()
	Local aArea     := FWGetArea()
	Local aAreaSD1  := SD1->(FWGetArea())
	Local aAreaSF4  := SF4->(FWGetArea())
	Local aAreaSB2  := SB2->(FWGetArea())
	Local aAreaSC5  := SC5->(FWGetArea())
	Local aAreaSL1  := SL1->(FWGetArea())
	Local cFilTrf   := ""
	Local aCliFil   := {}
	Local cMsg      := ""
	Local lMVESTNEG := (GetMv("MV_ESTNEG",.F.,"N") <> 'S') 
	Local lRet	    := .T.

	DBSELECTAREA("SF4")
	SF4->(DBSETORDER(1))

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	If DbSeek(FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

		DBSELECTAREA("SB2")
		SB2->(DBSETORDER(1))

		While SD1->(!EOF()) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And.;
				SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA

			If SF4->(DbSeeK(FWxFilial("SF4")+SD1->D1_TES))
				If SF4->F4_ESTOQUE == "S"
					If DbSeeK(FWxFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
						If (SB2->B2_QATU - IIf( SB2->B2_RESERVA > 0, SB2->B2_RESERVA, 0 )) < SD1->D1_QUANT
							If lMVESTNEG 
								If Empty(cMsg)
									cMsg += "<b>Item(ns)/Produto(s) sem saldo disponível:</b>"+CRLF+CRLF
									cMsg += AllTrim(SD1->D1_ITEM)+"/"+AllTrim(SD1->D1_COD)
								Else
									cMsg += ", "+AllTrim(SD1->D1_ITEM)+"/"+AllTrim(SD1->D1_COD)
								EndIf
							EndIf
						Endif
					Endif
				Endif
			Endif
			SD1->(DbSkip())

		EndDo

	Endif

	cFilTrf := U_xfFilFor(SF1->F1_FORNECE, SF1->F1_LOJA)
	If !Empty(cFilTrf)
		aCliFil := U_xfCliFil(SF1->F1_FILIAL)
		If Len(aCliFil) >= 2
			DbSelectArea("SC5")
			SC5->(DbOrderNickName("XNFSERCLLJ")) //C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI
			If SC5->(DbSeek(cFilTrf+SF1->F1_DOC+SF1->F1_SERIE+aCliFil[1]+aCliFil[2])) .And. ;
					SC5->C5_FILIAL == cFilTrf .And. SC5->C5_NOTA == SF1->F1_DOC .And. SC5->C5_SERIE == SF1->F1_SERIE .And. SC5->C5_CLIENTE == aCliFil[1] .And. SC5->C5_LOJACLI == aCliFil[2]
				If !Empty(SC5->C5_XMOVTRF) .And. !Empty(SC5->C5_XFILTRF) .And. !Empty(SC5->C5_XORCTRF)
					DbSelectArea("SL1")
					SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
					If SL1->(DbSeek(SC5->(C5_XFILTRF+C5_XORCTRF))) .And. SL1->L1_FILIAL == SC5->C5_XFILTRF .And. SL1->L1_NUM == SC5->C5_XORCTRF
						If !Empty(SL1->L1_DOC)
							cMsg += IIf(!Empty(cMsg),CRLF+CRLF,"")+"<b>Situação do orçamento na transferência imediata:</b>"+CRLF+CRLF
							cMsg += "O orçamento <b>"+SL1->L1_NUM+"</b>, vinculado a esta transferência, já foi finalizado."+CRLF+CRLF
							cMsg += "Não é possível excluir a nota fiscal de entrada vinculada a um orçamento já finalizado."+CRLF
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cMsg)
		lRet := .F.
		If !IsBlind()
			FWAlertError(cMsg, "Exclusão não permitida")
		EndIf
	EndIf

	FWRestArea(aAreaSD1)
	FWRestArea(aAreaSF4)
	FWRestArea(aAreaSB2)
	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSL1)
	FWRestArea(aArea)
    DbSelectArea(cAliasAnt)

	FWFreeArray(aAreaSD1)
	FWFreeArray(aAreaSF4)
	FWFreeArray(aAreaSB2)
	FWFreeArray(aAreaSC5)
	FWFreeArray(aAreaSL1)
	FWFreeArray(aArea)

Return(lRet)
