#include "Totvs.ch" 

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
	Local nOpc 	      := ParamIxb[1]
	Local lRetorno    := .T.
	Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cCodGerOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SC5->C5_VEND1,"A3_GEREN")
	Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SC5->C5_VEND1,"A3_NOME")

	If !FwIsAdmin()
		If Empty(SC5->C5_VEND1) .Or. Empty(cCodVndLog) .Or. !(cCodVndLog $ cJGGERLOJ+SC5->C5_VEND1+";"+cCodGerOrc+";") // Vendedor+Gerente Loja+Superiores
			FwAlertError("Este pedido de venda pertentece ao(à) vendedor(a):"+CRLF+"<b>"+SC5->C5_VEND1+"-"+AllTrim(cNomVndOrc)+"</b>."+CRLF+CRLF+;
							"Somente ele/ela e seu gerente poderão acessá-lo para edição ou visualização.", "ATENÇÃO - Vendedor")
			lRetorno := .F.
		EndIf
	EndIf

	If lRetorno 
		If nOpc == 2 // Visualização
			If !FwIsAdmin() .And. ProcName(2) <> "A410VISUAL" // Eliminar Residuo
				MsgInfo("A rotina de eliminar residuos encontra-se desabilitada!","Use a rotina de exclusão")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	FWRestArea(aAreaSC5)
	RestArea(aArea)

Return(lRetorno)
