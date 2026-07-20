#INCLUDE "Totvs.ch"

/*/{Protheus.doc} MT103FIM
description: Tratativas adicionais após a finalização da gravação da nota fiscal de entrada.
@type function
@version  
@author Jesus Ramos
@since 30/01/2026
@return variant, return_description

@Obs: A variável cTipo é global e indica o tipo da nota fiscal que está sendo processada.
/*/

User Function MT103FIM()

Local nOpcao     := PARAMIXB[1]  // Opção Escolhida pelo usuario no aRotina
Local nConfirma  := PARAMIXB[2]  // Se o usuario confirmou a operação de gravação da NFE

// Verifica se é um estorno da devolução
If nOpcao == 5 .AND. nConfirma == 1 .AND. cTipo == "D" 
	// Reverter os efeitos da devolução a partir do estorno/exclusão
	// Rotina()...
// Verifica se é uma devolução
ElseIf nConfirma == 1 .AND. cTipo == "D" .AND. ( nOpcao == 3 .OR. nOpcao == 4 ) 
	// Tratar os efeitos adicionais da devolução
	// Rotina()...
// Verifica se é entrada normal
ElseIf nConfirma == 1 .AND. cTipo == "N" .AND. ( nOpcao == 3 .OR. nOpcao == 4 ) 
	//Tratamento do custo(ZZ4) na entrada por compra
	If ExistBlock("JGRT008")
		If (!IsBlind()) // COM INTERFACE GRÁFICA
			Processa( {|| U_JGRT008() }, "Aguarde...", "Finalizando a gravação total da NF...",.F.)
		Else
			U_JGRT008()
		EndIf
	EndIf
EndIf

Return .T.
