#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M410ALOK
Ponto de Entrada executado antes de iniciar a alteração, exclusão ou cópia de um Pedido de Venda.
@type function
@version Protheus 12
@author  Jesus Ramos
@since   12/02/2026
/*/
User Function M410ALOK

	Local aAreaSC5    := SC5->(GetArea())
	Local aArea       := GetArea()
	Local lRetorno    := .T.

	If !Empty(SC5->C5_NOTA)
		If ALTERA //Alteração
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Alteração")
			lRetorno := .F.
		ElseIf !INCLUI .And. !ALTERA //Exclusão
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Exclusão")
			lRetorno := .F.

		// ElseIf INCLUI .And. FWIsInCallStack("A410COPIA") //Cópia
		// 	If FwIsAdmin()
		// 		lRetorno := .T.
		// 	Else
		// 		FwAlertError("O pedido já está faturado.","ATENÇÃO - Cópia")
		// 	EndIf

		EndIf

	EndIf

	RestArea(aAreaSC5)
	RestArea(aArea)

	If lRetorno
		If Type("__bkKCtrlL") == "U"
			Public __bkKCtrlL
		EndIf
		__bkKCtrlL := SetKey( K_CTRL_L ) //Guarda a configuração atual da tecla CTRL+L
		SetKey( K_CTRL_L, {|| U_JGRT007()} ) //Atalho para seleção do lote/sublote/validade
	EndIf

Return(lRetorno)
