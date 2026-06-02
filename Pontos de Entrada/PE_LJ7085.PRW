#Include "Totvs.ch"

/*/{Protheus.doc} LJ7085

	Ponto de Entrada para inclusão de mensagens adicionais no rodapé da NFCe.

@type function
@version  
@author Jesus Ramos
@since 27/05/2026
@return variant, return_description
/*/
User Function LJ7085()

	Local aRet := {}

	Aadd( aRet, Array(2) ) 
	aRet[1][1] := NiL 
	aRet[1][2] := U_FRODCUP() 

Return (aRet) 
