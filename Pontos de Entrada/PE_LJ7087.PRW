#Include "Totvs.ch"

/*/{Protheus.doc} LJ7087
description
	Essa função tem como finalidade validar o tipo de emissão (CF, NFC-e ou NFe) na tela de atendimento do Venda Assistida.
@type function
@version 1.0
@author  Jesus Ramos
@since   20/01/2026
@update  21/04/2026 - Jesus Ramos
@return  numeric, 0 = Verifica emissao (padrão) / 1 = Emissão de CF ou NFC-e / 2 = Emissao de nota
/*/
User Function LJ7087()
	Local aAreaSA1		As Array
	// Local lLjEmitNFCe	As Logical
	// Local lEhCaixa		As Logical
	Local _nRet			As Numeric
	Local _cChave		As String
	Local _cUFFil		As String
	Local lJGLJ7087		As Logical
	Local nJGLJ7087R	As Numeric
	Local cCliPad		As String
	Local cLojaPad		As String

	lJGLJ7087  := SuperGetMV("JG_LJ7087",.F.,.F.) // Ativa ou desativa a customização
	nJGLJ7087R := SuperGetMV("JG_LJ7087R",.F.,0) // Retorno padrão para o P.E. LJ7087

	If ValType(nJGLJ7087R) == "N" .And. cValToChar(nJGLJ7087R) $ "0/1/2/"
		_nRet := nJGLJ7087R
	Else
		_nRet := 0
	EndIf

	If lJGLJ7087

		cCliPad  := SuperGetMV("MV_CLIPAD", .F., "XYZXYZ") // Código do cliente padrão para validação
		cLojaPad := SuperGetMV("MV_LOJAPAD", .F., "XYZX")  // Código loja do cliente padrão para validação

		// lLjEmitNFCe	:= LjEmitNFCe()	//Verifica se NFC-e Habilitado na estação
		// lEhCaixa	:= U_xDfPerCx(3) // Verifica se o usuário é caixa
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

			If SA1->(A1_COD+A1_LOJA) == cCliPad + cLojaPad
				_nRet := 1	//1 = Emissão de NFCe para cliente padrão
			ElseIf AllTrim(SA1->A1_PESSOA) == "J"								//Venda cliente PJ - NFe
				_nRet := 2	//2 = Emissao de NFe
			// ElseIf !lLjEmitNFCe
			// 	_nRet := 1	//1 = Força NFCe quando não for usuário-caixa para forçar uma falha
			// ElseIf AllTrim(SA1->A1_PESSOA) == "F" .And. SA1->A1_EST <> _cUFFil	//Venda cliente PF fora do estado - NFe //Reavaliar esta regra
			// 	_nRet := 2	//2 = Emissao de NFe
			// Else //Demais cenários
			// 	_nRet := 0	//0 = Retorna para o padrão, com base no parâmetro MV_
			EndIf

		EndIf

		FWRestArea(aAreaSA1)

	EndIf

Return(_nRet)
