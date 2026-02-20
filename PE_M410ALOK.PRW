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
		lRetorno := .F.
		If ALTERA //Alteração
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Alteração")
		ElseIf !INCLUI .And. !ALTERA //Exclusão
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Exclusão")
		ElseIf INCLUI .And. FWIsInCallStack("A410COPIA") //Cópia
			If FwIsAdmin()
				lRetorno := .T.
			Else
				FwAlertError("O pedido já está faturado.","ATENÇÃO - Cópia")
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC5)
	RestArea(aArea)

Return(lRetorno)
