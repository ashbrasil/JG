#include "rwmake.ch" 

/*/{Protheus.doc} MT410ACE
Ponto de entrada 'MT410ACE' criado para verificar o acesso dos usuários nas rotinas: Excluir, Visualizar, Resíduo, Copiar e Alterar do Pedido de Venda.
@type    function
@version Protheus 12
@author  Jesus Ramos
@since   13/02/2026
@sintax	 MT410ACE( nOpc ) --> lContinua
@return  lContinua - Tipo: Lógico, .T. - Continuar a rotina / .F. - Cancelar a rotina
nOpc => 1 - Excluir, 2 - Visualizar e Resíduo, 3 - Copiar e 4 - Alterar.
/*/
User Function MT410ACE()
	Local aArea       := GetArea()
	Local aAreaSC5    := SC5->(FWGetArea())
	Local aAreaSC6    := SC6->(FWGetArea())
	Local nOpc 	      := ParamIxb[1]
	Local lRetorno    := .T.
	Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cCodGerOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SC5->C5_VEND1,"A3_GEREN")
	Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SC5->C5_VEND1,"A3_NOME")

	// If ALTERA // Melhorar a validação, separando caixa de vendedor
	If !FwIsAdmin()
		If Empty(SC5->C5_VEND1) .Or. Empty(cCodVndLog) .Or. !(cCodVndLog $ cJGGERLOJ+SC5->C5_VEND1+";"+cCodGerOrc+";") // Vendedor+Gerente Loja+Superiores
			FwAlertError("Este pedido de venda pertentece ao(à) vendedor(a) "+SC5->C5_VEND1+"-"+AllTrim(cNomVndOrc)+"."+CRLF+;
							"Somente ele(ela) e seu gerente poderão editá-lo.", "ATENÇÃO - Vendedor")
			lRetorno := .F.
		EndIf
	EndIf

	If lRetorno 
		If nOpc == 2 // Visualização
			If ProcName(2) <> "A410VISUAL" // Eliminar Residuo
				MsgInfo("Rotina de eliminar residuos desabilitada!","Use rotina de exclusão")
				lRetorno := .F.
			EndIf
		ElseIf !Empty(SC5->C5_NOTA)
			If nOpc == 4 //Alteração
				FwAlertError("O pedido já está faturado.","ATENÇÃO - Alteração")
			ElseIf nOpc == 1 //Exclusão
				FwAlertError("O pedido já está faturado.","ATENÇÃO - Exclusão")
			ElseIf nOpc == 3 //Cópia
				FwAlertError("O pedido já está faturado.","ATENÇÃO - Cópia")
			EndIf
			lRetorno := .F.
		EndIf
	EndIf
		// // If ALTERA // Melhorar a validação, separando caixa de vendedor
		// If !FwIsAdmin()
		// 	If Empty(SC5->C5_VEND1) .Or. Empty(cCodVndLog) .Or. ( SC5->C5_VEND1 <> cCodVndLog .And. cCodVndLog <> cCodGerOrc .And. !(cCodVndLog $ cJGGERLOJ) ) // Vendedor referente ao gerente da loja - Melhorar a validação
		// 		FwAlertError("Este pedido de venda pertentece ao(à) vendedor(a) "+SC5->C5_VEND1+"-"+AllTrim(cNomVndOrc)+"."+CRLF+;
		// 						"Somente ele(ela) e seu gerente (Rodrigo) poderão editá-lo.", "ATENÇÃO - Vendedor")
		// 		lRetorno := .F.
		// 	EndIf
		// EndIf

	FWRestArea(aAreaSC5)
	FWRestArea(aAreaSC6)
	RestArea(aArea)

Return(lRetorno)
