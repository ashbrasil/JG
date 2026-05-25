#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} LJ7032
description
	Essa função tem como finalidade validar a permissão de edição de orçamentos na tela de atendimento do Venda Assistida.
@type function
@version 1.0
@author  Jesus Ramos
@since   20/01/2026
@return  variant, return_description
/*/
/****************************** Parametros *****************************************************************
PARAMIXB[1] <=> NROTINA:
2 - Visualizar
3 - Atendimento
4 - Finaliza Venda
************************************************************************************************************/
User Function LJ7032()
	Local nTipo		  := Paramixb[1]

	Local area        := GetArea()
	Local areaSL1     := SL1->(GetArea())
	Local areaSL2     := SL2->(GetArea())
	Local lLjEmitNFCe := LjEmitNFCe()	//Verifica se NFC-e Habilitado na estação 
	Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local lRetorno    := .T.
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SL1->L1_VEND,"A3_NOME")
	Local lEhCaixa    := U_xDfPerCx(3) // Verifica se o usuário é caixa

	If nTipo == 4
		If !FwIsAdmin() .And. (!lLjEmitNFCe .Or. !lEhCaixa) // Melhorar a validação, separando caixa de vendedor
			If SL1->L1_VEND <> cCodVndLog .And. !(cCodVndLog $ cJGGERLOJ) // Vendedor referente ao gerente da loja - Melhorar a validação
				FwAlertError("Este orçamento pertentece ao(à) vendedor(a) "+SL1->L1_VEND+"-"+AllTrim(cNomVndOrc)+"."+CRLF+CRLF+;
								"Somente ele(ela) e seu gerente (Messias) poderão editá-lo.", "Edição do orçamento")
				lRetorno := .F.
			EndIf
		EndIf

		If lRetorno
			If !SL1->L1_XMOVTRF $ JGTrOrNSA+"/"+JGTrOrEAb+"/"+JGTrOrOK+"/"+JGTrOrExD+"/"+JGTrOrExO
					// Não entra na regra, pois não se trata de um orçamento com transferência de estoque
				FwAlertError("A transferência para este orçamento encontra-se em andamento."+CRLF+CRLF+;
								"Por isso, o mesmo não pode ser editado."+CRLF+CRLF+;
								"Aguarde a finalização do processo de transferência para que o caixa possa finalizá-lo."+CRLF+CRLF+;
								"<b>"+U_fDsStTrf("O",SL1->L1_XMOVTRF)+"</b>", "Edição do orçamento")
				lRetorno := .F.
			ElseIf SL1->L1_XMOVTRF == JGTrOrExD
				FwAlertError("A nota fiscal de transferência referente a este orçamento foi excluída."+CRLF+;
								"Por isso, o mesmo não poderá ser editado até que se resolva a situação da transferência de estoque."+CRLF+CRLF+;
								"Verifique o motivo com os responsáveis por este fluxo.", "Edição do orçamento")
				lRetorno := .F.
			ElseIf SL1->L1_XMOVTRF == JGTrOrOK .And. !lEhCaixa
				FwAlertError("A transferência para este orçamento foi concluída e somente o caixa poderá finalizá-lo.", "Edição do orçamento")
				lRetorno := .F.
			ElseIf SL1->L1_XMOVTRF == JGTrOrEAb .And. lEhCaixa
				FwAlertError("Você é um(a) Operador(a) de Caixa, e este orçamento exige transferência e ainda está em manutenção pelo solicitante/vendedor."+CRLF+CRLF+;
								"Aguarde a conclusão da negociação e a efetivação da transferência de estoque para que possa finalizá-lo.", "Edição do orçamento")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If lRetorno
		If Type("__bkKCtrlL") == "U"
			Public __bkKCtrlL
		EndIf
		__bkKCtrlL := SetKey( K_CTRL_L ) //Guarda a configuração atual da tecla CTRL+L
		SetKey( K_CTRL_L, {|| U_JGRT007()} ) //Atalho para seleção do lote/sublote/validade
	EndIf

	RestArea(areaSL1)
	RestArea(areaSL2)
	RestArea(area)

Return(lRetorno)
