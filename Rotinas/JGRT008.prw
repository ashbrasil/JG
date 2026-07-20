#INCLUDE "TOPCONN.CH"
#INCLUDE "Ap5Mail.ch"
#include "TOTVS.CH"

/*/{Protheus.doc} JGRT008

	Rotina para definição do custo e precificação dos produtos a partir da entrada de NF de compra, com base nos parâmetros definidos no sistema.

@type function
@version  
@author Jesus Ramos
@since  23/06/2026
@param lGrvCust, logical, Indica se o custo calculado deverá ser gravado na tabela ZZ4. Padrão: .T.
@return variant, return_description
/*/
User Function JGRT008()

	Local aAreaSF1 := SF1->(GetArea())
	Local aAreaSD1 := SD1->(GetArea())
	// Local aPonteiro := Nil
	Local cCFOPCusto := SuperGetMv("JG_CFOPCCP",.F.,"102;403" /*"102;403;926;121;923"*/ ) //CFOP que indicam operação de compra
	Local aRet	:= {}
	Local aUpdZZ4 := {}
	Local cB1DESCR := ""
	Local lCustoMed := .T.
	// Local lMA103OPC	:= FWIsInCallStack("FWMBROWSE") .And. !FWIsInCallStack("U_MT103FIM")
	// Local cD1XCCUSTO := "*"
	Local x
	// Local _CustoAdd	:= 0
	Local nPICM		 := 0
	Local nD1BASEICM := 0
	Local nD1VALICM	 := 0

	Default lGrvCust  := .T.

	If !SuperGetMv("JG_ACUSENT",.F.,.F.) //Atualiza o custo pela entrada de NF de compra
		Return()
	EndIf

    ChkFile("ZZ4", .F.)

	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(FWxFilial("SA2")+PadR(Alltrim(SF1->F1_FORNECE),TamSx3("A2_COD")[1])+PadR(Alltrim(SF1->F1_LOJA),TamSx3("A2_LOJA")[1])))
		If !Empty(SA2->A2_FILTRF) //Quando for CNPJ de filial não entra na regra de custo
			Return()
		EndIf
	EndIf
	
	//Não considerar serie interna de serviço para o custo.
	If AllTrim(SF1->F1_SERIE)=="U"
		Return()
	EndIf

	// If lMA103OPC .And. !IsBlind()

	// 	If !pergunte("JGRT008",.t.) //Chama a tela de parametros
	// 		Return()
	// 	Else
	// 		lCustoMed 	:= MV_PAR01==1
	// 		cD1XCCUSTO  := Iif( MV_PAR02==1 , "S" , "*" )
	// 	EndIf

	// EndIf

	SD1->( dbSetOrder(3) ) //D1_FILIAL, D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, R_E_C_N_O_, D_E_L_E_T_
	If SD1->( DbSeek( SF1->F1_FILIAL + DTOS(SF1->F1_EMISSAO) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
		While !SD1->( Eof() ) .And. (SD1->D1_FILIAL + DTOS(SD1->D1_EMISSAO) + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA) == (SF1->F1_FILIAL + DTOS(SF1->F1_EMISSAO) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)

			If SUBSTR(SD1->D1_CF,2,3) $ cCFOPCusto //.And. Alltrim(SD1->D1_XCCUSTO) <> cD1XCCUSTO

				// aPonteiro := SD1->(GetArea())
				// _CustoAdd := POSICIONE("SD1",, SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM , "D1_TOTAL" , "XITEMREF")
				// RestArea(aPonteiro)

				nPICM 		:= SD1->D1_PICM
				nD1BASEICM 	:= SD1->D1_BASEICM
				nD1VALICM	:= SD1->D1_VALICM

				// //Se tem NF de operação triangular vinculada, pega o Valor do ICMS para montar o CUSTO
				// If !Empty(SF1->F1_XNFTRIA) .And. !Empty(SF1->F1_XSETRIA) .And. !Empty(SF1->F1_XFORTRI) .And. !Empty(SF1->F1_XLOJTRI)
				// 	NFTRIANGULAR(@nPICM,@nD1BASEICM,@nD1VALICM)
				// EndIf 

				aProdutos := {}
				aProd := {}
				Aadd( aProd , { "_FILIAL"		, cFilAnt })
				Aadd( aProd , { "_D1PROD" 		, SD1->D1_COD } )
				Aadd( aProd , { "_D1VUNIT" 		, SD1->D1_VUNIT } )
				Aadd( aProd , { "_D1TES" 		, SD1->D1_TES} )
				Aadd( aProd , { "_D1QUANT" 		, SD1->D1_QUANT } )
				Aadd( aProd , { "_D1CUSTO" 		, Round(SD1->D1_CUSTO/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_PICM" 		, nPICM} )
				Aadd( aProd , { "_D1CF" 		, SD1->D1_CF } )
				Aadd( aProd , { "_D1VALDESC" 	, Round(SD1->D1_VALDESC/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1VALFRE" 	, Round(SD1->D1_VALFRE/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1DESPESA" 	, Round(SD1->D1_DESPESA/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1SEGURO" 	, Round(SD1->D1_SEGURO/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1COFINS" 	, Round(SD1->D1_VALIMP5/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1PIS" 		, Round(SD1->D1_VALIMP6/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1VALIPI" 	, Round(SD1->D1_VALIPI/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1VALICM" 	, Round(nD1VALICM/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1BASEICM" 	, Round(nD1BASEICM/SD1->D1_QUANT,3) } )
				Aadd( aProd , { "_D1ICMSRET" 	, Round(SD1->D1_ICMSRET/SD1->D1_QUANT,2) } )
				Aadd( aProd , { "_D1FORNECE" 	, SD1->D1_FORNECE } )
				Aadd( aProd , { "_D1LOJA" 		, SD1->D1_LOJA } )
				Aadd( aProd , { "_ONLINE" 		, .T. } )

				Aadd( aProd , { "_A2GRPTRIB" 	, SA2->A2_GRPTRIB } )

				cB1DESCR := ""	
				SB1->(dbSetOrder(1))
				If SB1->( MsSeek( xFilial("SB1") + SD1->D1_COD ) )
					Aadd( aProd , { "_B1NCM" 		, SB1->B1_POSIPI } )
					Aadd( aProd , { "_B1GRTRIB" 	, SB1->B1_GRTRIB } )
					Aadd( aProd , { "_B1ORIGEM" 	, SB1->B1_ORIGEM } )
					cB1DESCR := SB1->B1_DESC
				EndIf

				Aadd( aProdutos , aClone( aProd ) )

				aRet := U_fCalcCus(aProdutos,lGrvCust,SD1->D1_ITEM,lCustoMed)

				// If aRet[1]

				// 	If RecLock("SD1",.F.)
				// 		SD1->D1_XCCUSTO := "S"
				// 	EndIf
				// 	SD1->(MsUnLock())

				// EndIf

				For x:=1 To Len(aRet[2])

					Aadd( aRet[2][x] , { "ITEM" 	 , SD1->D1_ITEM		} )
					Aadd( aRet[2][x] , { "PRODUTO" 	 , cB1DESCR	} )

					Aadd( aUpdZZ4 , aClone( aRet[2][x] ) )

				Next x

			EndIf

			SD1->( DbSkip() )

		Enddo
	EndIf

	If Len(aUpdZZ4) > 0
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+PadR(Alltrim(SF1->F1_FORNECE),TamSx3("A2_COD")[1])+PadR(Alltrim(SF1->F1_LOJA),TamSx3("A2_LOJA")[1])))
		fWorkflow( aUpdZZ4 )
	EndIf

	RestArea(aAreaSF1)
	RestArea(aAreaSD1)

Return()

Static Function fWorkflow( aUpdZZ4 )

	Local cAssunto	:= "WorkFlow - Atualização de custo - Filial: "+SF1->F1_FILIAL+" Nota: "+SF1->F1_DOC +"/"+ SF1->F1_SERIE
	Local cMsg		:= ""
	Local cAnexo	:= ""
	Local cPara		:= "jesus.ramos@ashbrasil.com" //fPegaEmail()
	Local aEstrutura := {}
	Local _nPos		:= 0
	Local  _cCC 	:= ""
	Local x,y,nx

	Default aUpdZZ4 := {}

	//Aadd( aEstrutura , { "GRAVADO" 	 , "Gravado?" 				} )
	Aadd( aEstrutura , { "UF"	  	 , "UF"	 , "%%"				} )
	Aadd( aEstrutura , { "CODIGO"  	 , "Cod.Prod" , "%%"				} )
	Aadd( aEstrutura , { "PRODUTO"   , "Produto" , "%%"				} )
	Aadd( aEstrutura , { "ITEM" 	 , "Item NF" , "%%"				} )

	Aadd( aEstrutura , { "MRGUF_A"    , "Custo Mrg.UF"	, "TRANSFORM(%%, '@E 999,999,999.9999')"		} )
	Aadd( aEstrutura , { "MRGUF_N"    , "Novo Custo Mrg.UF"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGUF_VP"   , "%Variação C.Mrg.UF"	, "TRANSFORM(%%, '@E 999,999,999.99')+'%'"	} )

	Aadd( aEstrutura , { "MRGSST_A"   , "Custo Mrg.Sem ST"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGSST_N"   , "Novo Custo Mrg.Sem ST"	 , "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGSST_VP"  , "%Variação C.Mrg.Sem ST"	 , "TRANSFORM(%%, '@E 999,999,999.99')+'%'"	} )

	Aadd( aEstrutura , { "MRGCST_A"   , "Custo Mrg.Com ST"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGCST_N"   , "Novo Custo Mrg.Com ST"	 , "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGCST_VP"  , "%Variação C.Mrg.Com ST"	 , "TRANSFORM(%%, '@E 999,999,999.99')+'%'"	} )

	Aadd( aEstrutura , { "MRGIPI_A"   , "Custo Mrg.CD IPI"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGIPI_N"   , "Novo Custo Mrg.CD IPI"	 , "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGIPI_VP"  , "%Variação C.Mrg.CD IPI"	 , "TRANSFORM(%%, '@E 999,999,999.99')+'%'"	} )

	Aadd( aEstrutura , { "MRGCDESP_A" , "Custo Mrg.Despesa"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGCDESP_N" , "Novo Custo Mrg.Despesa" , "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	Aadd( aEstrutura , { "MRGCDESP_VP" , "%Variação C.Mrg.Despesa" , "TRANSFORM(%%, '@E 999,999,999.99')+'%'"	} )

	//Aadd( aEstrutura , { "MRGTRA_A"   , "Custo Transferencia"	, "TRANSFORM(%%, '@E 999,999,999.9999')"	} )
	//Aadd( aEstrutura , { "MRGTRA_N"   , "Novo Custo Transferencia" , "TRANSFORM(%%, '@E 999,999,999.9999')"	} )


	/**		Monta o script HTML para ser enviado por email 	**/
	cMsg+= "<p><b></font><font color='Red' size='2' face='Verdana'>Atenção: e-mail de notificação, não responder!</font></b><br>"
	cMsg+= "<div>"
	cMsg+= "<table style='border-color: black; width: 999px; float: left;' border='0'>"
	cMsg+= "<tbody>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='text-align: center; background-color: #0070c0; width: 983px;' colspan='2'><span style='color: #ffffff;'><strong> Nota Fiscal de Entrada do Custo </strong></span></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Data:</strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+DTOC(DATE())+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Data Sistema:</strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+DTOC(dDataBase)+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Hora:</strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+Time()+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Filial: </strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+cFilAnt+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Nota: </strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+SF1->F1_DOC+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Serie: </strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+SF1->F1_SERIE+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='width: 200px; background-color: #d0cece;'><strong>&nbsp;Fornecedor: </strong></td>"
	cMsg+= "<td style='background-color: #d0cece; width: 783px;'><strong>&nbsp;"+SF1->F1_FORNECE +"/"+ SF1->F1_LOJA+"-"+Alltrim(SA2->A2_NOME)+"</strong></td>"
	cMsg+= "</tr>"
	cMsg+= "<tr style='height: 30px;'>"
	cMsg+= "<td style='text-align: center; background-color: #0070c0; width: 983px;' colspan='2'><span style='color: #ffffff;'><strong> Detalhes do Processamento </strong></span></td>"
	cMsg+= "</tr>"
	cMsg+= "</tbody>"
	cMsg+= "</table>"
	cMsg+= "</div>"
	//cMsg+= "<div>&nbsp;</div>"
	cMsg+= "<div>"
	cMsg+= "<table style='width: 999px; height: 112px;'>"
	cMsg+= "<tbody>"


	cMsg+= "<tr style='height: 30px;'>"
	For x:=1 To Len(aEstrutura)
		cMsg+= "<td style='text-align: center; background-color: #0070c0; width: 86px;'><span style='color: #ffffff;'><strong>&nbsp;"+aEstrutura[x][2]+"&nbsp;</strong></span></td>"
	Next x
	cMsg+= "</tr>"


	For nx:=1 To Len(aUpdZZ4)

		cMsg+= "<tr style='height: 30px;'>"

		For y:=1 To Len(aEstrutura)

			If (_nPos := aScan(aUpdZZ4[nx],{|x| x[1] == aEstrutura[y][1] })) > 0

				xConteudo := aUpdZZ4[nx][_nPos][2]

				cMsg+= "<td style='text-align: justify; background-color: #d0cece; width: 86px;'>&nbsp;"+ &( StrTran( aEstrutura[y][3] ,'%%','xConteudo' )) +"</td>"

			EndIF

		Next y

		cMsg+= "</tr>"

	Next nx

	cMsg+= "</tbody>"
	cMsg+= "</table>"
	cMsg+= "</div>"
	cMsg+= "<div>&nbsp;</div>"
	cMsg+= "<div> <p style='text-align: center;'><strong>Suporte a Sistemas <em>By ASH</em></strong></p> </div> "

	_ret := EnvMail(cAssunto, cMsg, cPara, _cCC, cAnexo)

Return

Static Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo)

	Local _cMailS		:= "stmp.gmail.com:587"       //GetMv("MV_RELSERV")
	Local _cAccount		:= "jesuslimaramos@gmail.com" //GetMV("MV_RELACNT")
	Local _cPass		:= "Eu%jlr_#2026@google"      //GetMV("MV_RELFROM")
	Local _cSenha2		:= "Eu%jlr_#2026@google"      //GetMV("MV_RELPSW")
	Local _cUsuario2	:= "jesuslimaramos@gmail.com" //GetMV("MV_RELACNT")
	Local lAuth			:= .T. //GetMv("MV_RELAUTH",,.F.)
	Local _xx			:= 0

	Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

	If lAuth		// Autenticacao da conta de e-mail
		lResult := MailAuth(_cUsuario2, _cSenha2)
		If !lResult
			MsgAlert("Não foi possivel autenticar a conta - " + _cUsuario2)
			Return()
		EndIf
	EndIf

	_xx := 0

	lResult := .F.

	do while !lResult

		If !Empty(_cAnexo)
			Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
		Else
			Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
		Endif

		_xx++
		if _xx > 5
			Exit
		Else
			Get Mail Error cErrorMsg
			If !("successfully" $ cErrorMsg)
				MsgAlert(cErrorMsg)
			EndIf
		EndIf
	EndDo

Return lResult

Static Function fPegaEmail()

	Local cRet := "" //teste
	Local cRetPar := ""

	Local _ESWFFISC := "JG_WFATUC"
	Local cQtdPar := 9
	Local x

	For x:=1 To cQtdPar

		cRetPar := Alltrim(GetMv(_ESWFFISC+Alltrim(cValToChar(x)) , .f. , ""))

		If !Empty(cRetPar)

			If Empty(cRet)
				cRet += cRetPar
			Else
				If Substr(cRet,Len(cRet),1) == ";"
					cRet += cRetPar
				Else
					cRet += ";"+cRetPar
				EndIf
			EndIf

		EndIf

	Next x

Return(cRet)

/*/{Protheus.doc} NFTRIANGULAR
	Coleta os valores necessário da NF triangular para custo
	@type Function
	@author user
	@since 13/10/2022
	@version 1.0
/*/
Static Function NFTRIANGULAR(nPICM,nD1BASEICM,nD1VALICM)
	
	Local cQry    	 := ""
	Local cAliasTemp := ""
	Local cCFOPTRI	 := SuperGetMv("ES_CFOPTRI",.F.,"2923") //CFOP de operação Triangular
	Local cCFOPIn	 := ""

	If !Empty(cCFOPTRI)
		cCFOPIn := FormatIn(cCFOPTRI,";") //CFOP de operação Triangular
	EndIf

	cQry := " SELECT D1_PICM,D1_VALICM,D1_BASEICM"
	cQry += " ,D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD"
	cQry += " FROM SD1010 SD1 "
	cQry += " WHERE SD1.D_E_L_E_T_='' "
	cQry += " AND D1_FILIAL = '"+SD1->D1_FILIAL+"' "
	cQry += " AND D1_DOC = '"+SF1->F1_XNFTRIA+"' "
	cQry += " AND D1_SERIE = '"+SF1->F1_XSETRIA+"' "
	cQry += " AND D1_FORNECE = '"+SF1->F1_XFORTRI+"' "
	cQry += " AND D1_LOJA = '"+SF1->F1_XLOJTRI+"'"
	cQry += " AND D1_ITEM = '"+SD1->D1_ITEM+"' AND D1_COD = '"+Alltrim(SD1->D1_COD)+"' AND D1_QUANT = "+cValToChar(SD1->D1_QUANT)+" AND D1_CF IN "+cCFOPIn+" AND D1_VUNIT = "+cValToChar(SD1->D1_VUNIT)

    cAliasTemp  := MpSysOpenQuery( cQry )

    While (cAliasTemp)->(!EOF())
		If !Empty((cAliasTemp)->D1_DOC)
			If (cAliasTemp)->D1_VALICM > 0
				nPICM 		:= (cAliasTemp)->D1_PICM
				nD1BASEICM 	:= (cAliasTemp)->D1_BASEICM
				nD1VALICM	:= (cAliasTemp)->D1_VALICM
			EndIf
		EndIf
        (cAliasTemp)->(DBSKIP())
    EndDo

    (cAliasTemp)->(DBCLOSEAREA( ))

Return

/*/{Protheus.doc} User Function RCOMA036
	Executa o reprocessamento de custo para os produtos marcados.
	@type  Function
	@author Lorran Ferreira
	@since 19/01/2024
	/*/
User Function RCOMA036()

	Private _MSG	 := {| cStr | oSay:cCaption := (cStr) , ProcessMessages() }	

	If MsgYesNo( "Deseja continuar?" , "Reprocessamento de custo!" )
		FWMsgRun(, {|oSay| xRCOMA036(@oSay) }, "Reprocessamento de custo" , "Aguarde, processando a rotina" )
	EndIf

Return

Static Function xRCOMA036(oSay)

	Local aAreaSF1 := SF1->(GetArea())
	Local aAreaSD1 := SD1->(GetArea())
	
	Local _CustoAdd	:= 0
	Local aPonteiro := Nil
	Local cCFOPCusto := SuperGetMv("ES_CFOPCCP",.F.,"102;403" /*";926;121;923"*/) //CFOP 
	Local aRet	:= {}
	Local aUpdZZ4 := {}
	Local cB1DESCR := ""
	Local lCustoMed := .T.
	Local x
	Local nPICM		 := 0
	Local nD1BASEICM := 0
	Local nD1VALICM	 := 0
	Local lGrvCust  := .T.
	Local cQry := ""
	Local cAliasTemp := ""
	Local aCalCustoM := {}
	Local lCalCustoM := .F.
	Local cD1XCCUSTO := "R"
	Local nTotReg := 0
	Local nCont	  := 0	

	If !pergunte("RCOMA036",.t.) //Chama a tela de parametros
		Return()
	Else
		lCustoMed 	:= MV_PAR03==1
	EndIf

	Eval(_MSG,"Coletando dados SQL...")
	cQry := "SELECT DISTINCT D1_DTDIGIT,D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_TIPO "
	cQry += "FROM "+RetSqlName("SD1")+" SD1 "
	cQry += "WHERE SD1.D_E_L_E_T_='' "
	cQry += "AND SUBSTRING(SD1.D1_FILIAL,1,2) = '"+FWCodEmp("SD1")+"' "
	cQry += "AND D1_DTDIGIT BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
	cQry += "AND D1_XCCUSTO = '"+cD1XCCUSTO+"' "
	//cQry += "AND D1_DOC = '000064337' AND D1_SERIE = '002' "
	cQry += "ORDER BY D1_DTDIGIT "

	cAliasTemp := MpSysOpenQuery( cQry )

	nTotReg := Contar(cAliasTemp,"!Eof()")
	nCont	:= 0
	(cAliasTemp)->(DbGoTop())

	If nTotReg==0
		MsgInfo("Não foram encontrados registros para processamento.","Sem registros")
	EndIf

	while (cAliasTemp)->(!EOF())

		nCont++
		Eval(_MSG, "Registros:#"+cValToChar(nCont)+"/"+cValToChar(nTotReg)+"#"+ " Nota Fiscal:"+(cAliasTemp)->D1_DOC+"/"+(cAliasTemp)->D1_SERIE )

		aUpdZZ4 := {}

		SF1->(DbSetOrder(1)) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		If !SF1->( DbSeek( (cAliasTemp)->D1_FILIAL + (cAliasTemp)->D1_DOC + (cAliasTemp)->D1_SERIE + (cAliasTemp)->D1_FORNECE + (cAliasTemp)->D1_LOJA + (cAliasTemp)->D1_TIPO ) )
			(cAliasTemp)->(DBSKIP())
			Loop
		EndIf

		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+PadR(Alltrim(SF1->F1_FORNECE),TamSx3("A2_COD")[1])+PadR(Alltrim(SF1->F1_LOJA),TamSx3("A2_LOJA")[1])))
			If SubStr(SA2->A2_CGC,1,8) == SubStr( FWArrFilAtu(cEmpAnt, cFilAnt)[18] ,1,8)//"07851862" //Quando for CNPJ de filial não entra na regra de custo
				(cAliasTemp)->(DBSKIP())
				Loop
			EndIf
		Else
			(cAliasTemp)->(DBSKIP())
			Loop
		EndIf		

		SD1->( dbSetOrder(3) ) //D1_FILIAL, D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SD1->( DbSeek( SF1->F1_FILIAL + DTOS(SF1->F1_EMISSAO) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
			While !SD1->( Eof() ) .and. (SD1->D1_FILIAL + DTOS(SD1->D1_EMISSAO) + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA) == (SF1->F1_FILIAL + DTOS(SF1->F1_EMISSAO) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)

				If Alltrim(SD1->D1_XCCUSTO) == cD1XCCUSTO .And. SUBSTR(SD1->D1_CF,2,3) $ cCFOPCusto

					aPonteiro := SD1->(GetArea())
					_CustoAdd := POSICIONE("SD1",, SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM , "D1_TOTAL" , "XITEMREF")
					RestArea(aPonteiro)

					nPICM 		:= SD1->D1_PICM
					nD1BASEICM 	:= SD1->D1_BASEICM
					nD1VALICM	:= SD1->D1_VALICM

					// //Se tem NF de operação triangular vinculada, pega o Valor do ICMS para montar o CUSTO
					// If !Empty(SF1->F1_XNFTRIA) .And. !Empty(SF1->F1_XSETRIA) .And. !Empty(SF1->F1_XFORTRI) .And. !Empty(SF1->F1_XLOJTRI)
					// 	NFTRIANGULAR(@nPICM,@nD1BASEICM,@nD1VALICM)
					// EndIf 

					aProdutos := {}
					aProd := {}
					Aadd( aProd , { "_FILIAL"		, cFilAnt })
					Aadd( aProd , { "_D1PROD" 		, SD1->D1_COD } )
					Aadd( aProd , { "_D1VUNIT" 		, SD1->D1_VUNIT } )
					Aadd( aProd , { "_D1TES" 		, SD1->D1_TES} )
					Aadd( aProd , { "_D1QUANT" 		, SD1->D1_QUANT } )
					Aadd( aProd , { "_D1CUSTO" 		, Round(SD1->D1_CUSTO/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_PICM" 		, nPICM} )
					Aadd( aProd , { "_D1CF" 		, SD1->D1_CF } )
					Aadd( aProd , { "_D1VALDESC" 	, Round(SD1->D1_VALDESC/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1VALFRE" 	, Round(SD1->D1_VALFRE/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1DESPESA" 	, Round(SD1->D1_DESPESA/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1SEGURO" 	, Round(SD1->D1_SEGURO/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1COFINS" 	, Round(SD1->D1_VALIMP5/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1PIS" 		, Round(SD1->D1_VALIMP6/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1VALIPI" 	, Round(SD1->D1_VALIPI/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1VALICM" 	, Round(nD1VALICM/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1BASEICM" 	, Round(nD1BASEICM/SD1->D1_QUANT,3) } ) //Lorran Ferreira - 27/02/2020
					Aadd( aProd , { "_D1ICMSRET" 	, Round(SD1->D1_ICMSRET/SD1->D1_QUANT,2) } )
					Aadd( aProd , { "_D1FORNECE" 	, SD1->D1_FORNECE } )
					Aadd( aProd , { "_D1LOJA" 		, SD1->D1_LOJA } )
					Aadd( aProd , { "_ONLINE" 		, .T. } )
					Aadd( aProd , { "_A2GRPTRIB" 	, SA2->A2_GRPTRIB } )

					cB1DESCR := ""	
					SB1->(dbSetOrder(1))
					If SB1->( MsSeek( xFilial("SB1") + SD1->D1_COD ) )
						Aadd( aProd , { "_B1NCM" 		, SB1->B1_POSIPI } )
						Aadd( aProd , { "_B1GRTRIB" 	, SB1->B1_GRTRIB } )
						Aadd( aProd , { "_B1ORIGEM" 	, SB1->B1_ORIGEM } )
						cB1DESCR := SB1->B1_DESC
					EndIf

					Aadd( aProd , { "_VSERVSUP" 	, Round(_CustoAdd/SD1->D1_QUANT,2) } ) //Valor do custo de serviço agregados ao produto Ex.: Suporte DELL
					Aadd( aProdutos , aClone( aProd ) )

					lCalCustoM := .F.
					If lCustoMed
						lCalCustoM := aScan(aCalCustoM,{|x| x=SD1->D1_COD})>0
					EndIf

					aRet := U_fCalcCus(aProdutos,lGrvCust,SD1->D1_ITEM,lCalCustoM)
					If aRet[1]

						If lCustoMed .And. !lCalCustoM
							Aadd( aCalCustoM , SD1->D1_COD )
						EndIf					

						If RecLock("SD1",.F.)
							SD1->D1_XCCUSTO := "S"
						EndIf
						SD1->(MsUnLock())

					EndIf

					For x:=1 To Len(aRet[2])

						Aadd( aRet[2][x] , { "ITEM" 	 , SD1->D1_ITEM		} )
						Aadd( aRet[2][x] , { "PRODUTO" 	 , cB1DESCR	} )

						Aadd( aUpdZZ4 , aClone( aRet[2][x] ) )

					Next x

				EndIf

				SD1->( DbSkip() )

			Enddo
		EndIf

		If MV_PAR04==1 .And. Len(aUpdZZ4) > 0
			fWorkflow( aUpdZZ4 )
		EndIf

		(cAliasTemp)->(DBSKIP())
	enddo

	(cAliasTemp)->(DbClosearea())


	RestArea(aAreaSF1)
	RestArea(aAreaSD1)

Return
