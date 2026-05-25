#include "Totvs.ch"

/*/{Protheus.doc} MS520VLD
Ponto de Entrada para validação de exclusão de nota fiscal de saída.
Valida a situação da transferência entre filiais, se for o caso, verificando se a nota ou pre-nota foi excluída na filial de destino.
Valida para não permitir retroagir data para cancelamento de NF-e autorizada.

@type function
@version 12.1.2410
@author Jesus Ramos
@since 12/03/2026
@return variant, return_description
/*/
User Function MS520VLD

	Local cAliasAnt  := Alias()
	Local aArea      := FWGetArea()
	Local aAreaSF2   := SF2->(FWGetArea())
	Local lRetorno   := .T.
	Local cFilCli    := ""

	//Validação se o usuário está retroagindo data para cancelar NF autorizada
	lRetorno := fVLDDATA()

	//Validação para notas de transferência entre filiais
	If U_xfNfDest(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, DToS(SF2->F2_EMISSAO))

		cFilCli := U_xfFilCli(SF2->F2_CLIENTE, SF2->F2_LOJA)

		If IsBlind()
			U_FLOGJG("Para notas fiscais de saída por transferência entre filiais, deve-se, primeiramente, excluir a mesma nota na entrada da filial de destino."+CRLF+CRLF+;
						"Constatamos que esta nota fiscal ainda não foi excluída da entrada da filial de destino (" + cFilCli + ")."+CRLF+CRLF+;
						"Efetue a exclusão desta nota na entrada da filial de destino (" + cFilCli + ") e retorne para proceder com a exclusão da nota de saída, novamente.")
		Else
			FWAlertWarning("Para notas fiscais de saída por transferência entre filiais, deve-se, primeiramente, excluir a mesma nota na entrada da filial de destino."+CRLF+CRLF+;
							"Constatamos que esta nota fiscal ainda não foi excluída da entrada da filial de destino (" + cFilCli + ")."+CRLF+CRLF+;
							"Efetue a exclusão desta nota na entrada da filial de destino (" + cFilCli + ") e retorne para proceder com a exclusão da nota de saída, novamente.",;
							"Atenção")
		EndIf
		lRetorno := .F.

	EndIf

	FWRestArea(aAreaSF2)
	FWRestArea(aArea)
	DbSelectArea(cAliasAnt)

	FwFreeArray(aAreaSF2)
	FwFreeArray(aArea)

Return lRetorno

/*--------------------------------------------------------------------------------------------------
Função: fVLDDATA
Tipo: Função Static
Descrição: Validação se o usuário está retroagindo data para cancelar NF autorizada                                           
Uso: Primetek
Parâmetros:
Retorno:
----------------------------------------------------------------------------------------------------
Autor: Lorran Ferreira
Data : 26/06/2018
----------------------------------------------------------------------------------------------------
Atualizações: 
--------------------------------------------------------------------------------------------------*/
Static Function fVLDDATA()

	Local lRet      := .T.
	Local aArea 	:= FWGetArea()
	Local dDtdigit  := dDataBase
	Local nSpedExc 	:= SuperGetMv("MV_SPEDEXC",,24)
	Local nHoras	:= 0
	
	If dDataBase <> Date()
	
		dDtdigit := IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
		nHoras := SubtHoras(IIF(!Empty(SF2->F2_DAUTNFE),SF2->F2_DAUTNFE,dDtdigit),IIF(!Empty(SF2->F2_HAUTNFE),SF2->F2_HAUTNFE,SF2->F2_HORA),Date()/*dDataBase*/, substr(Time(),1,2)+":"+substr(Time(),4,2) )
		
		If nHoras > nSpedExc .And. Alltrim(SF2->F2_ESPECIE) == 'SPED' .And. Alltrim(SF2->F2_FIMP) == 'S'
			If IsBlind()
				U_FLOGPRIME("Não é permitido excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e é de " + Alltrim(STR(nSpedExc)) + " horas")
			Else
				FWAlertWarning("Não é permitido excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e é de " + Alltrim(STR(nSpedExc)) +" horas" + CRLF + ;
								"Verifique o motivo da alteração da data base do sistema para esta operação. Data base: "+DtoC(dDataBase) + " - Data Atual: "+DtoC(Date()) + CRLF + ;
								"Em caso de dúvidas, favor entrar em contato com o Departamento Fiscal.", ;
								"Cancelamento NEGADO")
			EndIF
			
			lRet := .F.
				
		EndIf
	
	EndIf
	
	FWRestArea(aArea)
	
Return(lRet)
