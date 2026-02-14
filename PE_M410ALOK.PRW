#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M410ALOK
Ponto de entrada que permite inserir novas opções no menu do Cadastro de Produtos (MATA010) 
através da variável do tipo array aRotina.
@type function
@version Protheus 12
@author Diego Lélis
@since 21/05/2021
/*/
User Function M410ALOK

	Local aAreaSC5    := SC5->(GetArea())
	Local aAreaSC6    := SC6->(GetArea())
	Local aArea       := GetArea()
	Local lRetorno    := .T.
	// Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	// Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	// Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SC5->C5_VEND1,"A3_NOME")

	If !Empty(SC5->C5_NOTA)
		If ALTERA //Alteração
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Alteração")
		ElseIf !INCLUI .And. !ALTERA //Exclusão
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Exclusão")
		ElseIf INCLUI .And. FWIsInCallStack("A410COPIA")  //Cópia
			FwAlertError("O pedido já está faturado.","ATENÇÃO - Cópia")
		EndIf
		lRetorno := .F.
	// Else
	// 	If ALTERA // Melhorar a validação, separando caixa de vendedor
	// 		If SC5->C5_VEND1 <> cCodVndLog .And. !(cCodVndLog $ cJGGERLOJ) // Vendedor referente ao gerente da loja - Melhorar a validação
	// 			FwAlertError("Este pedido de venda pertentece ao(à) vendedor(a) "+SL1->L1_VEND+"-"+AllTrim(cNomVndOrc)+"."+CRLF+;
	// 							"Somente ele(ela) e seu gerente (Rodrigo) poderão editá-lo.", "ATENÇÃO - Vendedor")
	// 			lRetorno := .F.
	// 		EndIf
	// 	EndIf
	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)

Return(lRetorno)
