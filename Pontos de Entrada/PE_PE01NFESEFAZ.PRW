#include "totvs.ch"

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada da geração de NFe SEFAZ. Ajusta a descrição dos itens
do array de parâmetros incluindo a série do documento.
@type user function
@author Fernando Carvalho
@since 02/02/2026
@version 1.0
@param aParam, array, Parâmetros recebidos em PARAMIXB (clonado).
@return aParam, array, Parâmetros com a coluna 4 concatenada com a série.
@example
// retorno esperado (coluna 4 recebe " - Série: <serie>")
// aParam[1,n,4] := "Item" + " - Série: 001"
@see
/*/
#DEFINE _CRLF_NFE	Chr(13)+Chr(10)	//PARAMIXB[5]  POS DOS ITENS/PRODUTOS
#DEFINE _PAR_IT		01				//PARAMIXB[5]  POS DOS ITENS/PRODUTOS
#DEFINE _PAR_MS		02				//PARAMIXB[5]  POS DA MENSAGEM
#DEFINE _PAR_NF		05				//PARAMIXB[5]  POS DOS DADOS DA NOTA FISCAL
#DEFINE _PAR_DP		16				//PARAMIXB[16] POS DETALHAMENTO DOS PAGAMENTOS
#DEFINE _PAR_IT_DS	04				//PARAMIXB[5]  POS DESCRIÇÃO DO PRODUTO NOS DADOS DOS ITENS DA NOTA FISCAL
#DEFINE _PAR_IT_LT	19				//PARAMIXB[5]  POS LOTECTL DO ITEM NOS TIPO NOS DADOS DOS ITENS NOTA FISCAL
#DEFINE _PAR_NF_TP	04				//PARAMIXB[5]  POS TIPO NOS DADOS DA NOTA FISCAL - Tipo de Nota: 1 – Saída, 2 – Entrada
#DEFINE _PAR_NF_HR	06				//PARAMIXB[5]  POS HORA DE SAIDA NOS DADOS DA NOTA FISCAL
#DEFINE _PAR_NF_DS	09				//PARAMIXB[5]  POS DATA DE SAIDA NOS DADOS DA NOTA FISCAL
#DEFINE _PAR_NF_CL	07				//PARAMIXB[5]  POS CLIENTE NOS DADOS DA NOTA FISCAL
#DEFINE _PAR_NF_LJ	08				//PARAMIXB[5]  POS LOJA NOS DADOS DA NOTA FISCAL

User Function PE01NFESEFAZ()
	Local aArea         := FwGetArea()
	Local aAreaSD2      := SD2->(FwGetArea())
	Local aAreaSC5      := SC5->(FwGetArea())
	Local aProd         := AClone(PARAMIXB[_PAR_IT])
	Local cMensCli      := PARAMIXB[_PAR_MS]
	Local aNota         := AClone(PARAMIXB[_PAR_NF])
	Local aRetorno		:= AClone(PARAMIXB)
	Local nLoop			:= 1

	// Complementa a descrição com o número de série, localizado na posição 20, referente ao número do lote (Padrão JG)
	For nLoop := 1 To Len(aProd)
		If !Empty(AllTrim(aProd[nLoop,_PAR_IT_LT])) // Verifica se a posição do lote está preenchida para evitar concatenação desnecessária
			aProd[nLoop,_PAR_IT_DS] := AllTrim(aProd[nLoop,_PAR_IT_DS]) + ' - Série: ' + AllTrim(aProd[nLoop,_PAR_IT_LT])
		EndIf
	Next nLoop

	//Informação adicional
	cMensCli += "Codigo Cliente: " +  aNota[_PAR_NF_CL]+ " - " + aNota[_PAR_NF_LJ]
	cMensCli += " / "
	cMensCli += "Vendedor: " +  SF2->F2_VEND1 + " - " + AllTrim(POSICIONE("SA3",1,xFilial("SA3") + SF2->F2_VEND1, "A3_NOME"))
	cMensCli += " / "
	cMensCli += "Forma de pagamento: " +  SF2->F2_COND + " - " + AllTrim(POSICIONE("SE4",1,xFilial("SE4") + SF2->F2_COND, "E4_DESCRI"))

	DbSelectArea("SD2")
	SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))) ;
		.And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) = SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

		DbSelectArea("SC5")
		If SC5->(DbSeek(FWxFilial("SC5")+SD2->D2_PEDIDO))
			If SC5->(FieldPos("C5_XMSNOTA")) > 0 .And. Len(AllTrim(SC5->C5_XMSNOTA)) > 0 ;
				.And. !Empty(SC5->C5_XMSNOTA) .And. !AllTrim(SC5->C5_XMSNOTA) $ cMensCli

				If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
					cMensCli += " / "
				EndIf
				cMensCli += "Obs.: "+AllTrim(SC5->C5_XMSNOTA)+" "

			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaSD2)
	restArea(aArea)

	aRetorno[1] := aClone(aProd)
	aRetorno[2] := cMensCli

Return aRetorno
