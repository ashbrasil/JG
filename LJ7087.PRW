#Include "Totvs.ch"

/*/{Protheus.doc} LJ7087
description
	Essa função tem como finalidade validar o tipo de emissão (CF, NFC-e ou NFe) na tela de atendimento do Venda Assistida.
@type function
@version 1.0
@author  Jesus Ramos
@since   20/01/2026
@return  variant, return_description
/*/
User Function LJ7087()
	Local aAreaSA1		As Array
	Local lLjEmitNFCe 	As Logical
	Local _nRet			As Numeric
	Local _cChave		As String
	Local _cUFFil 		As String
	Local lJGLJ7087     As Logical
	Local cCliPad		As String
	Local cLojaPad		As String

	_nRet     := 0
	lJGLJ7087 := SuperGetMV("JG_LJ7087",.F.,.F.) // Ativa ou desativa a customização

	If lJGLJ7087

		cCliPad  := SuperGetMV("MV_CLIPAD", .F., "XYZXYZ") // Código do cliente padrão para validação
		cLojaPad := SuperGetMV("MV_LOJAPAD", .F., "XYZX")  // Código loja do cliente padrão para validação

		lLjEmitNFCe := LjEmitNFCe()	//Verifica se NFC-e Habilitado na estação 
		_cUFFil		:= FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_ESTCOB"})[1][2]
		_cChave		:= ""

		If INCLUI //Inclusão
			_cChave   := M->LQ_CLIENTE + M->LQ_LOJA
		Else      //Alteração
			_cChave   := SL1->L1_CLIENTE + SL1->L1_LOJA
		EndIf

		aAreaSA1 := SA1->(FWGetArea())

		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + _cChave))

			If !lLjEmitNFCe
				_nRet := 1	//1 = Força NFCe quando não for usuário-caixa
			ElseIf SA1->(A1_COD+A1_LOJA) == cCliPad + cLojaPad
				_nRet := 1	//1 = Emissão de NFCe para cliente padrão
			ElseIf AllTrim(SA1->A1_PESSOA) == "J"								//Venda cliente PJ - NFe
				_nRet := 2	//2 = Emissao de NFe
			ElseIf AllTrim(SA1->A1_PESSOA) == "F" .And. SA1->A1_EST <> _cUFFil	//Venda cliente PF fora do estado - NFe
				_nRet := 2	//2 = Emissao de NFe
			Else //Demais cenários
				_nRet := 1	//1 = Emissão de CF ou NFC-e
			EndIf

		EndIf

		FWRestArea(aAreaSA1)

	EndIf

Return(_nRet) 
