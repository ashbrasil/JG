#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103VLEX  º Autor ³ Lorran Ferreira    º Data ³  01/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado antes de qualquer atualizacao na exclusao e deve   º±±
±±º          ³ ser utilizado para validar se a exclusao deve ser          º±±
±±º          ³ ou nao                                    					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function A103VLEX()
	
	Local cAliasAnt := Alias()
	Local aArea     := FWGetArea()
	Local aAreaSC5  := SC5->(FWGetArea())
	Local aAreaSL1  := SL1->(FWGetArea())
	Local cFilTrf   := ""
	Local aCliFil   := {}
	Local cMsg      := ""
	Local lRet	    := .T.

	cFilTrf := U_xfFilFor(SF1->F1_FORNECE, SF1->F1_LOJA)
	If !Empty(cFilTrf)
		aCliFil := U_xfCliFil(SF1->F1_FILIAL)
		If Len(aCliFil) >= 2
			DbSelectArea("SC5")
			SC5->(DbOrderNickName("XNFSERCLLJ")) //C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI
			If SC5->(DbSeek(cFilTrf+SF1->F1_DOC+SF1->F1_SERIE+aCliFil[1]+aCliFil[2])) .And. ;
					SC5->C5_FILIAL == cFilTrf .And. SC5->C5_NOTA == SF1->F1_DOC .And. SC5->C5_SERIE == SF1->F1_SERIE .And. SC5->C5_CLIENTE == aCliFil[1] .And. SC5->C5_LOJACLI == aCliFil[2]
				If !Empty(SC5->C5_XMOVTRF) .And. !Empty(SC5->C5_XFILTRF)
					If !Empty(SC5->C5_XORCTRF)
						DbSelectArea("SL1")
						SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
						If SL1->(DbSeek(SC5->(C5_XFILTRF+C5_XORCTRF))) .And. SL1->L1_FILIAL == SC5->C5_XFILTRF .And. SL1->L1_NUM == SC5->C5_XORCTRF
							If !Empty(SL1->L1_DOC)
								cMsg += "Situação do orçamento na transferência imediata:"+CRLF
								cMsg += "O orçamento <b>"+SL1->L1_NUM+"</b>, vinculado a esta transferência, já foi finalizado."+CRLF
								cMsg += "Portanto, para excluir a transferência será necessário cancelar a venda para liberação do estoque."
							EndIf
						EndIf
					EndIf
					If Empty(cMsg)
						U_JGRT11_E(SC5->(Recno()), JGTrPVExD, JGTrOrExD)//Grava Status no Pedido
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

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSL1)
	FWRestArea(aArea)
	DbSelectArea(cAliasAnt)

	FWFreeArray(aAreaSC5)
	FWFreeArray(aAreaSL1)
	FWFreeArray(aArea)

Return(lRet)
