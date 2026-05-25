#Include "Totvs.ch"

/*/{Protheus.doc} JGRT009
Função para retornar o nome do cliente ou fornecedor conforme os parâmetros informados, buscando nas tabelas SA1 (clientes) ou SA2 (fornecedores).
@type function
@version  
@author Samsung
@since 28/04/2026
@param cTpCliFor, character, param_description
@param cCodCliFor, character, param_description
@param cLojCliFor, character, param_description
@return variant, return_description
/*/
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
