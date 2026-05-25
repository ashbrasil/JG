#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*
###########################################################################################################################
# P.E.............: LJ7001
# DATA CRIACAO....: 16/01/2026
# AUTOR...........: JESUS DE LIMA RAMOS
# DESCRICAO.......: CHAMADO ANTES DO INÍCIO DA GRAVAÇÃO DO ORÇAMENTO. UTILIZADO PARA VALIDAÇÕES NO FINAL DA VENDA.
# RETORNO.........: TRUE (.T.) = PROSSEGUE COM A FINALIZAÇÃO DA VENDA FALSE(.F.) = ABORTA A FINALIZAÇÃO DA VENDA.
# PARAMETROS......: PARAMIXB
# 					[1]	Tipo da operação de acordo com as opções: 1 - Orçamento / 2 - Venda / 3 - Pedido
# 					[2]	Array com os dados da devolução de acordo com a estrutura: 
# 					[2][1] - Série da NF de devolução / 
# 					[2][2] - Número da NF de devolução / 
# 					[2][3] - Código do cliente da devolução / 
# 					[2][4] - Loja do cliente da devolução / 
# 					[2][5] - Tipo de operação (1=Troca; 2=Devolução) 
# 					OBS: Esse array é preenchido pela rotina LOJA720 quando se realiza uma operação de troca/devolução.
# 					[3]	Tipo de documento impresso pela venda de acordo com as opções: 1 - Cupom fiscal / 2 - Nota fiscal
###########################################################################################################################
# DATA ALTERACAO..:
# AUTOR...........:
# MOTIVO..........:
###########################################################################################################################
*/

User Function LJ7001()
	Local aArea       As Array
	Local aAreaSB1    As Array
	Local aAreaSF4    As Array
	Local nTipo       As Numeric
	Local lRet 	      As Logical
	Local lEhCaixa    As Logical
	Local nPosProduto As Numeric
	Local nPosLocal   As Numeric
	Local nPosQuant   As Numeric
	Local nPosLote    As Numeric
	Local nPosTES     As Numeric
	Local nPosDel     As Numeric
	Local cProduto    As String
	Local cLocal      As String
	Local nQuant      As Numeric
	Local cLoteCtl    As String
	Local cTES        As String
	Local nSaldo      As Numeric
	Local cMsgSaldo   As String
	Local cMsgLote    As String
	Local nX

	aArea	  := FWGetArea()
	aAreaSB1  := SB1->(FWGetArea())
	aAreaSF4  := SF4->(FWGetArea())
	lRet      := .T.
	nTipo     := Paramixb[1] // 1 - Orçamento / 2 - Venda / 3 - Pedido
	lEhCaixa  := U_xDfPerCx(3) // Verifica se o usuário é caixa

	If nTipo == 2 .And. !lEhCaixa // Operação 2 (Venda) e o operador não tem permissão para finalizar (Caixa)
		lRet := .F.
		FWAlertInfo( "Atenção! Usuário sem permissão para finalizar venda.", "Permissão Negada" )

	ElseIf lRet

		nPosProduto := GDFieldPos("LR_PRODUTO", aHeader)
		nPosQuant   := GDFieldPos("LR_QUANT",   aHeader)
		nPosLote    := GDFieldPos("LR_LOTECTL", aHeaderDet)
		nPosLocal   := GDFieldPos("LR_LOCAL",   aHeaderDet)
		nPosTES     := GDFieldPos("LR_TES",     aHeaderDet)
		nPosDel     := IIf(Len(aCols)>0,Len(aCols[1]),0)
		nSaldo      := 0
		cMsgSaldo   := ""
		cMsgLote    := ""

		If nPosProduto > 0 .And. nPosLocal > 0 .And. nPosQuant > 0 .And. nPosLote > 0 .And. nPosTES > 0 .And. nPosDel > 0

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))

			For nX:=1 To Len(aCols)
				If !aCols[nX][nPosDel]
					cProduto := aCols[nX][nPosProduto]
					nQuant   := aCols[nX][nPosQuant]
					cLoteCtl := aColsDet[nX][nPosLote]
					cLocal   := aColsDet[nX][nPosLocal]
					cTES     := aColsDet[nX][nPosTES]
					nSaldo   := fEstoque(cProduto, cLocal)

					If nQuant > nSaldo
						cMsgSaldo += IIf(Empty(cMsgSaldo),"",", ")+cProduto
					EndIf

					If SB1->(DbSeek(FWxFilial("SB1")+PadR(cProduto,TamSX3("B1_COD")[1])))
						If SB1->B1_RASTRO == "L"
							If SF4->(DbSeek(FWxFilial("SF4")+PadR(cTES,TamSX3("F4_CODIGO")[1])))
								If SF4->F4_ESTOQUE == "S"
									If Empty(cLoteCtl)
										cMsgLote += IIf(Empty(cMsgLote),"",", ")+cProduto
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

				EndIf
			Next nX
		EndIf

		If !Empty(cMsgSaldo) .Or. !Empty(cMsgLote)
			If !Empty(cMsgSaldo)
				cMsgSaldo := "Não há saldo disponível para o(s) produto(s) abaixo:"+CRLF+CRLF+cMsgSaldo
			EndIf
			If !Empty(cMsgLote)
				cMsgLote := "Produto(s) com controle de rastreio, mas sem lote informado:"+CRLF+CRLF+cMsgLote
			EndIf
			FWAlertWarning(OemToAnsi(cMsgSaldo+IIf(Empty(cMsgSaldo),"",CRLF+CRLF)+cMsgLote), OemToAnsi("Inconsistências - Saldo Insuficiente ou Ausência de Lote(s)"))
			lRet := .F.
		EndIf

	EndIf

	FWRestArea(aArea)
	FWRestArea(aAreaSB1)
	FWRestArea(aAreaSF4)
	FWFreeArray(aArea)
	FWFreeArray(aAreaSB1)
	FWFreeArray(aAreaSF4)

Return(lRet)

/*/{Protheus.doc} xDfPerCx

	Essa função tem como finalidade verificar se o usuário possui permissão de caixa.

@type function
@version 1.0
@author  Jesus Ramos
@since   20/01/2026
@param   nPermissao, numeric, param_description
@return  variant, return_description
/*/
User Function xDfPerCx(nPermissao)

	Local lPermissao As Logical
	Local aAcesso    As Array
	Local cAcessUser As String
	Local nPosCx

	Default nPermissao := 0

	lEhCaixa := .F.

	If nPermissao > 0
		aAcesso    := {}
		cAcessUser := SLF->LF_ACESSO
		aAcesso    := Lj120Acesso(aAcesso, cAcessUser, .F.)

		If (nPosCx := AScan(aAcesso, {|x| x[4] == nPermissao})) > 0 // 4 - Posição do indicador da permissão (numérico)
			lPermissao := aAcesso[nPosCx][1] == "S" // 1 - Posição do indicador se tem permissão (S/N)
		EndIf
	EndIf

Return lPermissao

/*/{Protheus.doc} fEstoque

    Função para apuração do saldo em estoque do produto informado

@type    function
@version 1.0
@author  Jesus Ramos
@since   20/05/2026
@param cProduto, character, param_description
@param cLocal, character, param_description
@return Numeric, Saldo do produto no estoque.
/*/
Static Function fEstoque(cProduto, cLocal)
    Local aArea       As Array
	Local cJGFILSUBE  As String  // Parâmetro que, se existir, informa a filial substituta para o estoque da filial corrente.
	Local nStok       As Numeric
	Local cFilEstoque As String	 // Inicialmente, recebe a filial logada, que será ajustada para a filial do parâmetro JG_FILSUBE, caso exista e seu conteúdo difira da filial logada.
    Local cFilBkp     As String

	aArea := FWGetArea()
    cFilBkp := cFilAnt
    nStok := 0

	cJGFILSUBE := GetNewPar("JG_FILSUBE", cFilAnt)

	If NROTINA == 4 .And. SL1->L1_XMOVTRF $ JGTrOrOK+";"+JGTrOrNSA+";" // Se for finalização de venda e a transferência já estiver concluída
		cFilEstoque := cFilAnt
	ElseIf !Empty(cJGFILSUBE) .And. !(cFilAnt == cJGFILSUBE)
		cFilEstoque := cJGFILSUBE
	Else
		cFilEstoque := cFilAnt
	EndIf

    If !(cFilEstoque == cFilAnt)
        cFilAnt := cFilEstoque
        FWSM0Util():setSM0PositionBycFilant()
    EndIf

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If SB2->(DbSeek(PadR(cFilEstoque,TamSX3("B2_FILIAL")[1])+PadR(cProduto,TamSX3("B2_COD")[1])+cLocal))
		nStok := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMP)
	EndIf

    If !(cFilBkp == cFilAnt)
        cFilAnt := cFilBkp
        FWSM0Util():setSM0PositionBycFilant()
    EndIf

	FWRestArea(aArea)

Return(nStok)
