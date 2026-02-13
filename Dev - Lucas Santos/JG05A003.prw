#Include 'Protheus.ch'
#Include 'FWPrintSetup.ch'
#Include 'RPTDef.ch'
#Include 'TopConn.ch'

User Function JG05A003(cOpcao)
	Local aArea  := GetArea()
	Local cPedido  := SC5->C5_NUM
	Local cClient  := SC5->C5_CLIENTE
	Local cloja    := SC5->C5_LOJACLI 
	Local cNota    := ""
	Local cSerie   := ""
	Local cAliasSD2 := GetNextAlias()
	Local cPasta   := ""
	Local cArquivo := ""

	cQuery := " SELECT D2_DOC, D2_SERIE FROM " + RetSqlName("SD2") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND D2_PEDIDO = '" + cPedido + "'"
	cQuery += " AND D2_FILIAL = '" + xFilial("SD2") + "'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasSD2)
	(cAliasSD2)->(dbGoTop())

	If !(cAliasSD2)->(EOF())
		cNota  := (cAliasSD2)->D2_DOC
		cSerie := (cAliasSD2)->D2_SERIE

		// Imprimir Nota Promissória
		If cOpcao == "1"

			If AllTrim(cNota) <> ""

				Processa({|| U_JG05A001(cNota, cSerie) }, "Processando Nota Promissória...")

			Else
				Alert("Pedido não possui Nota Fiscal vinculada.")
			EndIf

			// Imprimir Boleto
		ElseIf cOpcao == "2"

			If File(Lower("\spool\boleto_bancario_"+cNota+".pdf"))

				cPasta   := "C:\Temp\"
				cArquivo := Lower("boleto_bancario_"+cNota+".pdf")

				lCopiou := CpyS2T( Lower("\spool\boleto_bancario_"+cNota+".pdf"), cPasta )

				If lCopiou

					ShellExecute("OPEN", cArquivo, "", cPasta, 1)

				Else

					alert("Boleto bancário não pode ser copiado.")
				EndIF

			Else

				u_JG05A002(cNota, cSerie, cClient, cLoja)
				if File(Lower("\spool\boleto_bancario_"+cNota+".pdf"))
					lRet := .t.
					cPasta   := "C:\Temp\"
					cArquivo := Lower("boleto_bancario_"+cNota+".pdf")

					lCopiou := CpyS2T( Lower("\spool\boleto_bancario_"+cNota+".pdf"), cPasta )

					If lCopiou

						//ShellExecute("OPEN", cArquivo, "", cPasta, 1)

					Else

						alert("Boleto bancário não pode ser copiado.")
					EndIF
				else

					cMsgErro:= "Boleto bancário não encontrado."
					alert(cMsgErro)
				endIf



			EndIf

		EndIf
	else
        msgInfo("Pedido não possui Nota Fiscal vinculada.")
	endIf
	RestArea(aArea)

Return
