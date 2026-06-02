#Include "Totvs.ch"

/*/{Protheus.doc} FIMPCUP

	Rotina para complementação de informações adicionais da NFCe, para formação do XML e, conseguentemente, impressão.

@type function
@version  
@author Jesus Ramos
@since 27/05/2026
@return _cMsg, Texto para complementação das informações adicionais da NFCe, no XML, para posterior impressão.
/*/
User Function FRODCUP()

	Local cMVCLIPAD  := GetNewPar("MV_CLIPAD", "")
	Local cMVLOJAPAD := GetNewPar("MV_LOJAPAD", "")
	Local cMVLJFISMS := GetNewPar("MV_LJFISMS", "")
	Local _cMsg      := ""

	_cMsg += "Orçamento: "+SL1->L1_NUM + CRLF
	_cMsg += "Cliente: "+SA1->A1_COD+"-"+SA1->A1_LOJA + CRLF
	_cMsg += "Nome: "+AllTrim(SA1->A1_NOME) + CRLF
	If !(cMVCLIPAD+cMVLOJAPAD = SL1->(L1_CLIENTE+L1_LOJA))
		_cMsg += "CPF/CNPJ: "+ Transform(SA1->A1_CGC, IIf(SA1->A1_PESSOA=="J", "@R 99.999.999/9999-99","@R 999.999.999-99") ) + CRLF
	EndIf
	_cMsg += "Operador: "+__cUserID+"-"+Upper(cUserName) + CRLF
	_cMsg += "Vendedor: "+SA3->A3_COD+"-"+SubStr(AllTrim(SA3->A3_NOME),1,25)

	If !Empty(cMVLJFISMS)
		_cMsg += CRLF + CRLF + cMVLJFISMS
	EndIf

Return (_cMsg)
