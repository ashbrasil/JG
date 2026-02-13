#include "totvs.ch"

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada da geração de NFe SEFAZ. Ajusta a descrição dos itens
do array de parâmetros incluindo a série do documento.
@type user function
@author Fernando Carvalho
@since 02/02/2026
@version 1.0
@param aParam, array, Parâmetros recebidos em PARAMIXB (clonado).
@return aParam, array, Parâmetros com a coluna 4 concatenada com a série.
@example
// retorno esperado (coluna 4 recebe " - Série: <serie>")
// aParam[1,n,4] := "Item" + " - Série: 001"
@see
PE01NFESEFAZ
/*/

User Function PE01NFESEFAZ()
	Local aArea         := FwGetArea()
	Local aAreaSD2      := SD2->(FwGetArea())
	Local aParam		:= aClone(PARAMIXB)
	Local nLoop			:= 1
	
	
	For nLoop := 1 To Len(aParam[1])
		aParam[1,nLoop,4] := AllTrim(aParam[1,nLoop,4]) + ' - Série: ' + AllTrim(aParam[1,nLoop,20])
		
	Next nLoop

	//Informação adicional
	aParam[2] += "Codigo Cliente: " +  aParam[5,7]+ " - " + aParam[5,8]
	aParam[2] += " / "
	aParam[2] += "Vendedor: " +  SF2->F2_VEND1 + " - " + AllTrim(POSICIONE("SA3",1,xFilial("SA3") + SF2->F2_VEND1, "A3_NOME"))
	aParam[2] += " / "
	aParam[2] += "Forma de pagamento: " +  SF2->F2_COND + " - " + AllTrim(POSICIONE("SE4",1,xFilial("SE4") + SF2->F2_COND, "E4_DESCRI"))

	RestArea(aAreaSD2)
	restArea(aArea)
Return aParam
