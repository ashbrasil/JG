#include "TOTVS.CH"

/*--------------------------------------------------------------------------------------------------
Função: JGRT009
Tipo: Função usuario
Descrição: Rotina para custo após entrada por compra
Uso: JG
Parâmetros:	
Retorno: 
----------------------------------------------------------------------------------------------------
Autor: Lorran Ferreira
Data : 28/03/2019
----------------------------------------------------------------------------------------------------
Atualizações: 
30/01/2026 - Jesus Ramos - Ajustes para implantação na JG
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------*/
User Function JGRT009(cTpCliFor, cCodCliFor, cLojCliFor)

	Local aAreaSA1   := SA1->(FWGetArea())
	Local aAreaSA2   := SA2->(FWGetArea())
	Local cNomCliFor := ""

	Default cTpCliFor  := ""
	Default cCodCliFor := ""
	Default cLojCliFor := ""
	
	If !(Empty(cTpCliFor) .Or. Empty(cCodCliFor) .Or. Empty(cLojCliFor))
		If cTpCliFor == "C"
			DbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(FWxFilial("SA1")+PadR(Alltrim(cCodCliFor),TamSx3("A1_COD")[1])+PadR(Alltrim(cLojCliFor),TamSx3("A1_LOJA")[1])))
				cNomCliFor := SA1->A1_NOME
			EndIf
		ElseIf cTpCliFor == "F"
			DbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(FWxFilial("SA2")+PadR(Alltrim(cCodCliFor),TamSx3("A2_COD")[1])+PadR(Alltrim(cLojCliFor),TamSx3("A2_LOJA")[1])))
				cNomCliFor := SA2->A2_NOME
			EndIf
		EndIf
	EndIf

	FWRestArea(aAreaSA1)
	FWRestArea(aAreaSA2)

Return cNomCliFor
