#Include "Totvs.ch"

/*/{Protheus.doc} JGRT007
description
	Essa função tem como finalidade validar o cadastro do cliente conforme o cenário de venda na tela de atendimento do Venda Assistida.
@type function
@version 1.0
@author  Jesus Ramos
@since   25/01/2026
@return  variant, return_description
/*/
User Function JGRT007(lShowMsg, cCodCli, cLojaCli)
	Local aAreaSA1		As Array
	Local lCliValido	As Logical
	Local _cChave		As String
	Local _cUFFil 		As String
	// Local lMata410		As Logical
	// Local lLoja701		As Logical
	Local cMsg			As String

	Default lShowMsg := .F.
	Default cCodCli  := ""
	Default cLojaCli := ""

	lCliValido  := .F.

	lMata410    := FWIsInCallStack("MATA410")
	lLoja701    := FWIsInCallStack("LOJA701")

	aAreaSA1	:= SA1->(FWGetArea())
	_cUFFil		:= FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_ESTCOB"})[1][2]
	_cChave		:= ""

	If !Empty(cCodCli) .And. !Empty(cLojaCli)
		_cChave   := cCodCli + cLojaCli
	Else
		If lMata410
			_cChave   := M->C5_CLIENTE + M->C5_LOJACLI
		ElseIf lLoja701
			If INCLUI //Inclusão
				_cChave   := M->LQ_CLIENTE + M->LQ_LOJA
			Else      //Alteração
				_cChave   := SL1->L1_CLIENTE + SL1->L1_LOJA
			EndIf
		EndIf
	EndIf

	cMsg := ""

	If Empty(_cChave)
		lCliValido := .F.	//Chave do cliente não informada
		If !Empty(cCodCli) .Or. !Empty(cLojaCli)
			cMsg := "Cliente informado nos parâmetros não encontrado."
		Else
			cMsg := "Cliente ainda não informado ou módulo/rotina não configurada para validação automática (Venda Assistida / Pedido de Venda)."
		EndIf
	Else
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + _cChave))

			cCPFCNPJ := AllTrim(SA1->A1_CGC)

			If lMata410 .And. (cCPFCNPJ == "00000000000" .Or. cCPFCNPJ == "00000000000000")	//Valida se o CPF/CNPJ está preenchido apenas com zeros.
				lCliValido := .F.
				cMsg := "CPF/CNPJ inválido para emissão de nota fiscal em pedido de venda (Apenas zeros)."
			ElseIf AllTrim(SA1->A1_PESSOA) == "J"															//Cliente PJ - NFe
				If !(lCliValido := (cCPFCNPJ <> "00000000000" .And. cCPFCNPJ <> "00000000000000" .And. CGC(cCPFCNPJ)	//Valida o CNPJ do cliente
					cMsg := "CNPJ Inválido para emissão de nota fiscal."
				EndIf
			ElseIf AllTrim(SA1->A1_PESSOA) == "F" .And. SA1->A1_EST <> _cUFFil							//Cliente PF fora do estado - NFe
				If !(lCliValido := ChkCPF(SA1->A1_CGC))	//Valida o CPF do cliente
					cMsg := "CPF Inválido para emissão de nota fiscal."
				EndIf
			Else
				lCliValido := .T.
			EndIf
		Else
			lCliValido := .F.	//Cliente não encontrado
			cMsg := "Cliente não encontrado."
		EndIf
	EndIf

	FWRestArea(aAreaSA1)

	If lShowMsg .And. !lCliValido
		FWAlertInfo(cMsg, "Validação de Cliente")
	EndIf

Return(lCliValido) 
