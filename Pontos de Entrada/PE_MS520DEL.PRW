#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} MS520DEL
Ponto de Entrada localizado na função MaDelNfs da rotina MATA521 (Exclusão de Documentos de Saída).
Executado antes da exclusão do registro da tabela SF2.

@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@return variant, return_description
/*/

User Function MS520DEL()
    Local cAliasAnt        := Alias()
    Local aArea            := FWGetArea()
    Local aAreaSC5         := SC5->(FWGetArea())
    Local aAreaSF2         := SF2->(FWGetArea())
    Local aAreaSD2         := SD2->(FWGetArea())
    Local nSC5RECNO        := 0

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	If SC5->(DbSeek(SD2->(D2_FILIAL+D2_PEDIDO))) .And. SD2->(D2_FILIAL+D2_PEDIDO) == SC5->(C5_FILIAL+C5_NUM)

		If !Empty(SC5->C5_XMOVTRF)
	    	nSC5RECNO := SC5->(RecNo())
			U_JGRT11_E(nSC5RECNO, JGTrPVExO, JGTrOrExO) //Grava Status no Pedido e no Orçamento
			U_JGRT11_D("P", nSC5RECNO, "Nota fiscal de saída por transferência ("+SF2->(F2_FILIAL+"-"+F2_DOC+"-"+F2_SERIE)+") excluída pelo usuário: "+__cUserId+"-"+cUserName+" em "+DToC(Date())+" às "+Time())//Grava Status no Pedido e no Orçamento
			// Chamada à função de resíduo do pedido
			U_JGRT11_G(.T.)
		EndIf

	EndIf

    // Avaliar novas regras a serem aplicadas nesse ponto de entrada, caso necessário.
    // Residuar o pedido de transferência; eliminar as ordens de separação; liberar os estoques; eliminar o pedido de venda.

    FWRestArea(aAreaSD2)
    FWRestArea(aAreaSF2)
    FWRestArea(aAreaSC5)
    FWRestArea(aArea)
    DbSelectArea(cAliasAnt)

	FWFreeArray(aAreaSD2)
	FWFreeArray(aAreaSF2)
	FWFreeArray(aAreaSC5)
	FWFreeArray(aArea)

/*
if lResiduaPed

		dbselectarea("SC9")
		SC9->(dbsetorder(1))
		if SC9->(dbseek(xFilial("SC9")+cNumPed))

			While !Eof() .and. C9_FILIAL+C9_PEDIDO = xFilial("SC9")+cNumPed
				SC9->(a460estorna())
				SC9->(dbskip())
			EndDo

		Endif

		// Residuar
		DbSelectArea("SC5")
		SC5->(dbsetorder(1))
		if SC5->(dbseek(xFilial("SC5")+cNumPed))
			
			RecLock("SC5",.F.)
				SC5->C5_NOTA := "XXXXXX"
				SC5->C5_SERIE:= "XXX"
			MsUnlock()
		
		ENDIF         
		
		DbSelectArea("SC6")
		SC6->(dbsetorder(1))
		if SC6->(dbseek(xFilial("SC6")+cNumPed))

   			While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+cNumPed
    			
   				RecLock("SC6",.f.)
				SC6->C6_NOTA  := "XXXXXX"
				SC6->C6_SERIE := "XXX"
				SC6->C6_QTDENT := SC6->C6_QTDVEN
				SC6->C6_BLQ   := "R"
				SC6->(MsUnLock())
				SC6->(dbskip())
			EndDo

		Endif
	
Endif
*/

Return
