#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M410INIC
Ponto de Entrada executado Antes da abertura da Tela de Inclusão.
@type function
@version Protheus 12
@author  Jesus Ramos
@since   14/05/2026
/*/
User Function M410INIC()

	Local aAreaSC5    := SC5->(GetArea())
	Local aArea       := GetArea()
	Local lRetorno    := .T.

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
