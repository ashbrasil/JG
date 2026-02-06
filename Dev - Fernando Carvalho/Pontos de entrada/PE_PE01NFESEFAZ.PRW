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
	
	
	For nLoop := 1 To Len(aParam[1,1])
		aParam[1,nLoop,4] := AllTrim(aParam[1,nLoop,4]) + ' - Série: ' + AllTrim(aParam[1,nLoop,19])
	Next nLoop

	RestArea(aAreaSD2)
	restArea(aArea)
Return aParam
