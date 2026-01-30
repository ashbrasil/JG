#include "totvs.ch"

/*/{Protheus.doc} LJ7032
description
	Essa função tem como finalidade validar a permissão de edição de orçamentos na tela de atendimento do Venda Assistida.
@type function
@version 1.0
@author  Jesus Ramos
@since   20/01/2026
@return  variant, return_description
/*/
/****************************** Parametros *****************************************************************
4 - Finaliza Venda
************************************************************************************************************/
User Function LJ7032()
	Local nTipo		  := Paramixb[1]

	Local area        := GetArea()
	Local areaSL1     := SL1->(GetArea())
	Local areaSL2     := SL2->(GetArea())
	Local lLjEmitNFCe := LjEmitNFCe()	//Verifica se NFC-e Habilitado na estação 
	Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local lRetorno    := .T.
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SL1->L1_VEND,"A3_NOME")
	Local lEhCaixa    := U_xDfPerCx(3) // Verifica se o usuário é caixa

	If nTipo = 4 .And. (!lLjEmitNFCe .Or. !lEhCaixa) // Melhorar a validação, separando caixa de vendedor
		If SL1->L1_VEND <> cCodVndLog .And. !(cCodVndLog $ cJGGERLOJ) // Vendedor referente ao gerente da loja - Melhorar a validação
			FwAlertError("Este orçamento pertentece ao(à) vendedor(a) "+SL1->L1_VEND+"-"+AllTrim(cNomVndOrc)+"."+CRLF+;
							"Somente ele(ela) e seu gerente (Messias) poderão editá-lo.", "Edição do orçamento")
			lRetorno := .F.
		EndIf
	EndIf

	RestArea(areaSL1)
	RestArea(areaSL2)
	RestArea(area)

Return(lRetorno)
