#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} LJVLDEST

    Este ponto de entrada permite decidir, se deverá realizar a validação do estoque ou não para um determinado produto da venda.
    Este ponto de entrada é apenas uma validação complementar à configuração padrão do sistema para validação de estoque.
    Desta forma, o sistema primeiro verifica a configuração do parâmetro MV_ESTNEG se não permite vender com estoque negativo, para que depois seja executado este ponto de entrada.

@type function
@version 1.0
@author Jesus Ramos
@since 15/05/2026
@return Logical, .T. - Código do produto é válido, .F. - Código do produto é inválido.
/*/
User Function LJVLDEST()
    Local aArea       As Array
    Local cProduto    As String
    Local cLocal      As String
    Local nQuant      As Numeric
    Local cCodTES     As String
    Local nSaldo      As Numeric
    Local cJGFILSUBE  As String
    Local cFilEst     As String
    Local lRet        As Logical

	aArea      := FWGetArea()
	cJGFILSUBE := GetNewPar("JG_FILSUBE", cFilAnt)
    lRet       := .T.

        If NROTINA == 4 .And. SL1->L1_XMOVTRF $ JGTrOrOK+";"+JGTrOrNSA+";" // Se for finalização de venda e a transferência já estiver concluída
            cFilEst := cFilAnt
        ElseIf !Empty(cJGFILSUBE) .And. !(cFilAnt == cJGFILSUBE)
            cFilEst := cJGFILSUBE
        Else
            cFilEst := cFilAnt
        EndIf

        cProduto := PARAMIXB[01] //Código do produto
        cLocal   := PARAMIXB[02] //Local de Estoque (Código do Armazém)
        nQuant   := PARAMIXB[03] //Quantidade vendida do produto
        cCodTES  := PARAMIXB[04] //Código do TES

        If (lRet := (Posicione("SF4", 1, FWxFilial("SF4")+PadR(cCodTES,TamSX3("F4_CODIGO")[1]), "F4_ESTOQUE") == "S")) //Se o TES movimenta estoque

            nSaldo := fEstoque( cFilEst, cProduto, cLocal )

            If nQuant > nSaldo
                FWAlertWarning(OemToAnsi("Não há saldo disponível para o produto <b>"+cProduto+"</b>"), OemToAnsi("Saldo Insuficiente"))
            EndIf

            lRet := .F. // Desativa a validação de estoque padrão

        EndIf

    // EndIf

    FWRestArea(aArea)
    FWFreeArray(aArea)

Return lRet

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
Static Function fEstoque(cFilEstoque, cProduto, cLocal)
    Local aArea   As Array
	Local nStok   As Numeric
    Local cFilBkp As String

    cFilBkp := cFilAnt

    If !(cFilEstoque == cFilAnt)
        cFilAnt := cFilEstoque
        FWSM0Util():setSM0PositionBycFilant()
    EndIf

	aArea := FWGetArea()
    nStok := 0

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If SB2->(DbSeek(cFilAnt+PadR(cProduto,TamSX3("B2_COD")[1])+PadR(cLocal,TamSX3("B2_LOCAL")[1])))
		nStok := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMP)
	EndIf

    If !(cFilBkp == cFilAnt)
        cFilAnt := cFilBkp
        FWSM0Util():setSM0PositionBycFilant()
    EndIf

	FWRestArea(aArea)

Return(nStok)
