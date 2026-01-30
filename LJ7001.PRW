#INCLUDE "TOTVS.CH"

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

	Local nTipo     As Numeric
	Local lRet 	    As Logical
	Local lEhCaixa  As Logical

	nTipo     := Paramixb[1] // 1 - Orçamento / 2 - Venda / 3 - Pedido
	lRet      := .T.
	lEhCaixa  := U_xDfPerCx(3) // Verifica se o usuário é caixa

	If nTipo == 2 .And. !lEhCaixa // Operação 2 (Venda) e o operador não tem permissão para finalizar (Caixa)
		lRet := .F.
		FWAlertInfo( "Atenção! Usuário sem permissão para finalizar venda.", "Permissão Negada" )
	EndIf

Return(lRet)

/*/{Protheus.doc} xDfPerCx
description
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
