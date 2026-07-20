#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JGTRANSF.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  JGRT011   ∫Autor  ≥Lorran Gomes        ∫ Data ≥  09/11/15    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Browse de pedidos de transferencia (saidas).				 	 ∫±±
±±∫          ≥ TransferÍncia entre filiais								    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso      ≥ AP                                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function JGRT011()

	Local oBrowse
	Private aRotina   := MenuDef()

	// Instanciamento da Classe de Browse

	oBrowse := FWMBrowse():New()

	// DefiniÁ„o da tabela do Browse

	oBrowse:SetAlias('SC5')

	// DefiniÁ„o da legenda
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVPSp)	, "BR_BRANCO"	, U_fDsStTrf( "P", JGTrPVPSp )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVPFt)	, "BR_AMARELO"	, U_fDsStTrf( "P", JGTrPVPFt )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVNPA)	, "BR_LARANJA"	, U_fDsStTrf( "P", JGTrPVNPA )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVNPE)	, "BR_AZUL"		, U_fDsStTrf( "P", JGTrPVNPE )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVOK ) 	, "CHECKOK"		, U_fDsStTrf( "P", JGTrPVOK  )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVEPL ) 	, "BR_VIOLETA"	, U_fDsStTrf( "P", JGTrPVEPL )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVExD) 	, "BR_MARROM"	, U_fDsStTrf( "P", JGTrPVExD )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVExO) 	, "BR_VERMELHO"	, U_fDsStTrf( "P", JGTrPVExO )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVOS ) 	, "CLIPS"		, U_fDsStTrf( "P", JGTrPVOS  )    )
	oBrowse:AddLegend( "ALLTRIM(C5_XMOVTRF) == "+ValToSql(JGTrPVCan) 	, "BR_CANCEL"	, U_fDsStTrf( "P", JGTrPVCan )    )
	oBrowse:AddLegend( "ALLTRIM(C5_NOTA) == 'XXXXXX'" 					, "BR_PRETO"	, "PV de TransferÍncia Cancelado" )

	// DefiniÁ„o de filtro
	oBrowse:SetFilterDefault( " !Empty(C5_XMOVTRF) " )

	// Titulo da Browse
	oBrowse:SetDescription('TransferÍncia entre filiais')

	//Bot„o
	//ADD BUTTON oButton TITLE "Bot„o 1" ACTION { || MsgAlert(oBrowse:At()) } OF oBrowse

	// Opcionalmente pode ser desligado a exibiÁ„o dos detalhes
	//oBrowse:DisableDetails()

	// AtivaÁ„o da Classe
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction: MenuDef
>>Cria o menu do browse

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//-------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 					ACTION 'a410Visual'		OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
	ADD OPTION aRotina TITLE 'Incluir'    					ACTION 'U_JGRT011A()' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Gerar/Imprimir Danfe'			ACTION 'U_JGRT11_A()' 	OPERATION 7                      ACCESS 0 //OPERATION 7
	ADD OPTION aRotina TITLE 'Gerar Entrada Destino' 		ACTION 'U_JGRT11_B()' 	OPERATION 7                      ACCESS 0 //OPERATION 7
	ADD OPTION aRotina TITLE 'Liberar SeparaÁ„o do Pedido'	ACTION 'U_JGRT11_C()' 	OPERATION 7                      ACCESS 0 //OPERATION 7
	ADD OPTION aRotina TITLE 'Cancelar a TransferÍncia'		ACTION 'U_JGRT11_G()' 	OPERATION 7                      ACCESS 0 //OPERATION 7
	If FWIsAdmin()
	ADD OPTION aRotina TITLE 'Executa Job Manualmente' 		ACTION 'U_JGRT11_J()' 	OPERATION 7                      ACCESS 0 //OPERATION 7
	EndIf

Return aRotina

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera Danfe														   ∫±±
±±∫          ≥                                  								   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function JGRT11_A()
	Local lRet := .T.
	
	Private AFILBRW := {"SF2",""} //Para n„o dar erro apÛs impress„o
	
	//cFilAnt := SC5->C5_FILIAL
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Faz a chamada da rotina padr„o de impress„o do danfe   				 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	SPEDDANFE()

Return(lRet)

/*/{Protheus.doc} JGRT11_B

	Rotina para gerar a nota de entrada no destino, quando a nota de saÌda j· tiver sido lanÁada e excluÌda anteriormente.

@type function
@version 1.0
@author  Jesus Ramos
@since   22/05/2026
@return  Logical, .T. para sucesso na geraÁ„o da nota de entrada, .F. para falha na geraÁ„o da nota de entrada.
/*/
User Function JGRT11_B()

	Local _aArea := FWGetArea()
	Local cIdMov := ""
	Local lRet   := .T.

	cIdMov := "["+SC5->C5_FILIAL +"-"+ SC5->C5_NUM +"]"
	U_FLOGJG(cIdMov+" "+ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )

	If Alltrim(SC5->C5_NOTA) = "XXXXXX"
		FWAlertWarning(OemToAnsi("O Pedido est· cancelado/residuado!"), OemToAnsi("AtenÁ„o"))

	ElseIf !(SC5->C5_XMOVTRF == JGTrPVExD)
		FWAlertWarning(OemToAnsi("Esta opÁ„o destina-se, unicamente, a um novo registro da entrada da nota fiscal de transferÍncia na filial de destino, "+CRLF+;
									"quando esta foi lanÁada anteriormente e excluÌda."+CRLF+CRLF+;
									"Esta operaÁ„o de transferÍncia encontra-se com o status <b>"+U_fDsStTrf("P",SC5->C5_XMOVTRF)+"</b>"+;
									", portanto, n„o pode ser processada por esta opÁ„o."), OemToAnsi("AtenÁ„o"))

	ElseIf FWAlertYesNo("Confirma a re-inclus„o da Nota de Entrada na filial de Destino?"+CRLF+CRLF+"Filial: "+SC5->C5_FILIAL+" Doc./SÈrie: "+SC5->C5_NOTA+"/"+SC5->C5_SERIE, "AtenÁ„o")

		U_FLOGJG(cIdMov+" Antes U_JGRT11_B - Gera nota de entrada na filial de destino"+" Time:"+TIME())
		FWMsgRun(, { |oSay| lRet := U_JGRT13A(@oSay,SC5->C5_FILIAL,SC5->C5_NOTA,SC5->C5_SERIE) }, "Processando - Nota de Entrada no Destino", "Aguarde, processando a rotina" )
		U_FLOGJG(cIdMov+" Nota de entrada gerada na filial de destino? "+IIf(lRet,"Sim","N„o")+" Time:"+TIME())

		If lRet
			U_JGRT11_E(SC5->(Recno()), JGTrPVOK, JGTrOrOK)//Grava Status no Pedido e no OrÁamento
		EndIf
		U_FLOGJG(cIdMov+" Depois U_JGRT11_B - Gera nota de entrada na filial de destino"+" Time:"+TIME())

	EndIf

	FWRestArea(_aArea)

Return(lRet)

/*/{Protheus.doc} JGRT11_C

	Rotina para liberar a transferÍncia de estoque sem realizar a separaÁ„o dos itens.

@type function
@version  
@author Samsung
@since 22/05/2026
@return Logical, .T. para sucesso no cancelamento, .F. para falhoa no cancelamento.
/*/
User Function JGRT11_C()

	Local _aArea       := FWGetArea()
	Local cIdMov       := ""
	Local lRet         := .F.
	Local lLiberar     := .F.
	Local nItensPed    := 0
	Local nSemOrdSep   := 0
	Local nOrdNaoFin   := 0
	Local nLoteComErro := 0
	Local nRecnoPed	   := SC5->(Recno())

	cIdMov := "["+SC5->C5_FILIAL +"-"+ SC5->C5_NUM +"]"
	U_FLOGJG(cIdMov+" "+ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )

	If Alltrim(SC5->C5_NOTA) = "XXXXXX"
		FWAlertWarning(OemToAnsi("O Pedido est· cancelado/residuado!"), OemToAnsi("AtenÁ„o"))
	ElseIf !Empty(SC5->C5_NOTA)
		FWAlertWarning(OemToAnsi("O Pedido j· foi faturado!"), OemToAnsi("AtenÁ„o"))
	ElseIf !(SC5->C5_XMOVTRF == JGTrPVPSp)
		FWAlertWarning(OemToAnsi("Esta opÁ„o destina-se, unicamente, a liberar um pedido de transferÍncia que esteja com status <b>Pendente de SeparaÁ„o</b>"+;
									" e que n„o possua ordem(s) de separaÁ„o gerada(s) ou, se existirem, j· estejam finalizadas."+CRLF+CRLF+;
									"Esta operaÁ„o de transferÍncia encontra-se com o status <b>"+U_fDsStTrf("P",SC5->C5_XMOVTRF)+"</b>"+;
									", portanto, n„o pode ser processada por esta opÁ„o."), OemToAnsi("AtenÁ„o"))

	Else

	    nItensPed    := fItensPed(SC5->C5_FILIAL, SC5->C5_NUM)
	    nSemOrdSep   := fSemOrdSep(SC5->C5_FILIAL, SC5->C5_NUM)
	    nOrdNaoFin   := fOrdNaoFin(SC5->C5_FILIAL, SC5->C5_NUM)
		nLoteComErro := fLoteComErro(SC5->C5_FILIAL, SC5->C5_NUM)

	    If nItensPed = 0
			FWAlertWarning(OemToAnsi("N„o foram localizados itens para o pedido."+CRLF+;
										"Verifique se o pedido ainda existe lanÁado no sistema."), OemToAnsi("AtenÁ„o"))
	    ElseIf nLoteComErro > 0
			FWAlertWarning(OemToAnsi("Algum(ns) item(ns) que exige(m) lote/serial n„o teve(tiveram) o apontamento do lote/serial, "+;
									"ou o lote/serial apontado n„o existe ou est· inconsistente?"+CRLF+CRLF+;
									"Provavelmente, a melhor soluÁ„o ser· realizar a separaÁ„o para preencher os lotes/seriais faltantes."+CRLF+CRLF+;
									"Revise os lanÁamentos para poder prosseguir."), OemToAnsi("AtenÁ„o"))
	    ElseIf nOrdNaoFin > 0
			FWAlertWarning(OemToAnsi("Existem ordens de separaÁ„o n„o finalizadas."+CRLF+CRLF+;
										"Finalize a separaÁ„o para as ordens ainda em aberto/andamento "+;
										"ou estorne as ordens de separaÁ„o para conseguir liberar a transferÍncia sem separaÁ„o."), OemToAnsi("AtenÁ„o"))

		Else

			If nSemOrdSep > 0 .And. nSemOrdSep <> nItensPed
				lLiberar := FWAlertYesNo(OemToAnsi("N„o foram geradas ordens de separaÁ„o para todos os itens do pedido."+CRLF+;
													"PorÈm, as ordens de separaÁ„o geradas foram todas finalizadas."+CRLF+CRLF+;
													"Deseja liberar a transferÍncia sem separar os demais produtos?"), OemToAnsi("Libera?"))
			Else
				lLiberar := FWAlertYesNo("Confirma a liberaÁ„o do pedido sem realizar a separaÁ„o?", "LiberaÁ„o")
			EndIf

			If lLiberar

				SC5->(DbGoTo(nRecnoPed))

				If !SC5->(Deleted())

					If SoftLock("SC5") //Evitar que 2 usu·rios acessem o mesmo registro simultaneamente

						If SC5->C5_XMOVTRF == JGTrPVPSp

							U_FLOGJG(cIdMov+" Antes U_JGRT11_C - Libera pedido sem SeparaÁ„o"+" Time:"+TIME())
							U_JGRT11_E(SC5->(Recno()), JGTrPVPFt, JGTrOrPPF)//Grava Status no Pedido e no OrÁamento
							U_JGRT11_D("P", SC5->(Recno()), "SeparaÁ„o liberada.")//Grava Status no Pedido e no OrÁamento

							If SC5->C5_XMOVTRF == JGTrPVPFt
								lRet := .T.
								FWAlertInfo(OemToAnsi("LiberaÁ„o efetuada com sucesso."), OemToAnsi("Sucesso"))
							Else
								FWAlertInfo(OemToAnsi("A liberaÁ„o n„o foi efetuada como esperado."+CRLF+CRLF+;
														"Reavalie a situaÁ„o do pedido."), OemToAnsi("AtenÁ„o"))
							EndIf
							U_FLOGJG(cIdMov+" TransferÍncia liberada sem separaÁ„o? "+IIf(lRet,"Sim","N„o")+" Time:"+TIME())
							U_FLOGJG(cIdMov+" Depois U_JGRT11_C - Libera pedido sem SeparaÁ„o"+" Time:"+TIME())

						Else
							FWAlertInfo(OemToAnsi("O pedido mudou de situaÁ„o durante a confirmaÁ„o da rotina."+CRLF+CRLF+;
													"Reavalie a necessidade de execuÁ„o."), OemToAnsi("Status"))
						EndIf

						If IsLocked("SC5", SC5->(Recno()))
							SC5->(MsrUnlock()) //Libera o SoftLock
						EndIf

					Else
						FWAlertInfo(OemToAnsi("N„o foi possÌvel reservar o pedido para efetuarmos a liberaÁ„o da separaÁ„o do pedido."+CRLF+;
												"Algum outro processo est· bloqueando este pedido."+CRLF+CRLF+;
												"Saia e tente novamente."), OemToAnsi("Bloqueado"))

					EndIf

				Else
					FWAlertError(OemToAnsi("O pedido foi excluÌdo enquanto prepar·vamos para iniciar."+CRLF+CRLF+;
											"O cancelamento/resÌduo n„o poder· prosseguir. Saia e verifique a situaÁ„o real do pedido."), OemToAnsi("AtenÁ„o"))

				EndIf

			Else
				FWAlertInfo(OemToAnsi("A liberaÁ„o da separaÁ„o do pedido foi abortada pelo usu·rio."), OemToAnsi("AtenÁ„o"))

			EndIf
		EndIf

	EndIf

	FWRestArea(_aArea)

Return(lRet)


/*/{Protheus.doc} JGRT11_D

	Grava o log de ocorrÍncias no pedido de transferÍncia e orÁamento, quando necess·rio.

@type function
@version  1.0
@author Jesus Ramos
@since 06/05/2026
@param cIdentOrig, numeric, Tipo que identifica se o conte˙do de nRecno È referente ao orÁamento ou pedido, onde: O - OrÁamento, P - Pedido.
@param nRecno, numeric, N˙mero do registro (recno) do orÁamento/pedido.
@param cTextoLog, character, Texto do log a ser gravado no campo de observaÁıes do orÁamento/pedido.
@return Logical, Indica se a gravaÁ„o do log foi realizada com sucesso (.T.) ou n„o (.F.).
/*/
User Function JGRT11_D(cIdentOrig, nRecno, cTextoLog)

	Local lRet       := .F.
	Local _cAliasAnt := Alias()
	Local _aArea     := FWGetArea()
	Local _aAreaSC5  := SC5->(FWGetArea())
	Local _aAreaSL1  := SL1->(FWGetArea())
	Local cLinhaLog  := DToC(Date())+" - "+Time()+" - Usu·rio: "+__cUserId+"-"+cUserName+" - "+ProcName(1)+" > "+ProcName(0)+CRLF+CRLF+cTextoLog

	U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )

	Default cIdentOrig := ""
	Default nRecno     := 0
	Default cTextoLog  := ""

	//Begin Transaction

	If !Empty(nRecno) .And. !Empty(cTextoLog)
		If cIdentOrig == "O"
			SL1->(DbGoTo(nRecno))
			If SL1->(Recno()) = nRecno
				If RecLock("SL1", .F.)
					SL1->L1_XLOGTRF := cLinhaLog
					SL1->(MsUnlock())
					lRet := .T.
				EndIf
			EndIf
		ElseIf cIdentOrig == "P"
			SC5->(DbGoTo(nRecno))
			If SC5->(Recno()) = nRecno
				If RecLock("SC5", .F.)
					SC5->C5_XLOGTRF := cLinhaLog
					SC5->(MsUnlock())
					lRet := .T.
				EndIf
			EndIf
			If !Empty(SC5->C5_XFILTRF) .And. !Empty(SC5->C5_XORCTRF)
				If SL1->(DbSeek(SC5->C5_XFILTRF+SC5->C5_XORCTRF)) .And. SL1->(L1_FILIAL+L1_NUM) == SC5->(C5_XFILTRF+C5_XORCTRF) .And. Empty(SL1->L1_DOC)
					If RecLock("SL1", .F.)
						SL1->L1_XLOGTRF := cLinhaLog
						SL1->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//End Transaction

	FWRestArea(_aAreaSL1)
	FWRestArea(_aAreaSC5)
	FWRestArea(_aArea)
	DbSelectArea(_cAliasAnt)

Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava Status no Pedido de venda								∫±±
±±∫          ≥                                  							∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function JGRT11_E(nSC5RECNO, cPedStatus, cOrcStatus)

	Local lRet       := .F.
	Local _cAliasAnt := Alias()
	Local _aArea     := FWGetArea()
	Local _aAreaSC5  := SC5->(FWGetArea())
	Local _aAreaSL1  := SL1->(FWGetArea())

	U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " SM0:"+SM0->M0_CODFIL+" cFilAnt: "+cFilAnt )

	Default nSC5RECNO := 0
	Default cPedStatus := ""
	Default cOrcStatus := ""

	//Begin Transaction

	If 	nSC5RECNO > 0 .And. !Empty(cPedStatus)
		SC5->(DbGoTo(nSC5RECNO))
		If SC5->(RECNO()) = nSC5RECNO
			If RecLock("SC5", .F.)
				SC5->C5_XMOVTRF := cPedStatus
				SC5->(MsUnlock())
				lRet := .T.
			EndIf
		EndIf
		If !Empty(cOrcStatus) .And. !Empty(SC5->C5_XFILTRF) .And. !Empty(SC5->C5_XORCTRF)
			If SL1->(DbSeek(SC5->C5_XFILTRF+SC5->C5_XORCTRF)) .And. SL1->(L1_FILIAL+L1_NUM) == SC5->(C5_XFILTRF+C5_XORCTRF) .And. Empty(SL1->L1_DOC)
				If RecLock("SL1", .F.)
					If SL1->L1_XMOVTRF == JGTrOrCan .And. cOrcStatus == JGTrOrEAb
						SL1->L1_XPEDTRF := ""
					EndIf
					SL1->L1_XMOVTRF := cOrcStatus
					SL1->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	//End Transaction

	FWRestArea(_aAreaSL1)
	FWRestArea(_aAreaSC5)
	FWRestArea(_aArea)
	DbSelectArea(_cAliasAnt)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Verifica o cFilAnt x SM0										   ∫±±
±±∫          ≥                                  								   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function JGRT11_F(cNewFilial)
	Local cFilOld := cFilAnt

	Default cNewFilial  := ""

	If cNewFilial <> cFilAnt
		cFilAnt := IIf(Empty(cNewFilial), cFilAnt, cNewFilial)
	EndIf
	FWSM0Util():setSM0PositionBycFilant()
	U_FLOGJG(ProcName(1) +">"+ ProcName(0) + " - SM0 POSICIONADA CONFORME CFILANT >>> SM0:"+cFilAnt +" -->SM0_OLD: "+cFilOld)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera Danfe														   ∫±±
±±∫          ≥                                  								   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function JGRT11_J()
	Local lRet       := .T.
	Local nIntervalo := 0

	//MsgInfo("Executa Job Manualmente")

	FWMsgRun(, {|oSay| U_JGRT012(cEmpAnt, cFilAnt, nIntervalo) }, "Processando o Job de TransferÍncias...", "Aguarde, processando a rotina" )

	// Processa({|| U_JGRT012(cEmpAnt, cFilAnt, nIntervalo) }, "Processando o Job de TransferÍncias...")

Return(lRet)


/*⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥                Verifica o documento no destino			                   ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ*/
Static Function xNfDest(_cFil, _cNota, __cSerieNf, _cCNPJ)
	
	Local lRet      := .F.
	Local cQuery    := ""
	Local cCodFor   := " "
	Local cLojaFor  := " "
	Local cAliasMov
	
	SA2->(dbsetOrder(3))
	If SA2->(dbSeek(xFilial("SA2")+_cCNPJ))
		cCodFor  := SA2->A2_COD
		cLojaFor := SA2->A2_LOJA
	EndIf
	
	cQuery := " SELECT DISTINCT " + CRLF
	cQuery := "     1 " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + CRLFRetSqlName("SF1") + " SF1 "
	cQuery += " WHERE " + CRLF
	cQuery += "     F1_FILIAL      = " + ValToSql(_cFil) + " " + CRLF
	cQuery += "     AND F1_DOC     = " + ValToSql(_cNota) + " " + CRLF
	cQuery += "     AND F1_SERIE   = " + ValToSql(__cSerieNf) + " " + CRLF
	cQuery += "     AND F1_FORNECE = " + ValToSql(cCodFor) + " " + CRLF
	cQuery += "     AND F1_LOJA    = " + ValToSql(cLojaFor) + " " + CRLF
	cQuery += "     AND D_E_L_E_T_ <> '*' " + CRLF

	cAliasMov := MPSysOpenQuery( cQuery )
	
	If (cAliasMov)->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	
	(cAliasMov)->( dbCloseArea() )
	
Return(lRet)

/*/{Protheus.doc} fRvStTrPV
description
	Reverte o status da transferÍncia do Pedido de Venda recebido para o status imediatamente anterior.
@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@param cStTrfPV, character, param_description
@return variant, return_description
/*/
User Function fRvStTrPV(cStTrfPV)
	Local cNewStPV := ""

	Do Case
        Case cStTrfPV == JGTrPVOK 
            cNewStPV := JGTrPVNPE
        Case cStTrfPV == JGTrPVNPE
            cStTrfPV := JGTrPVNPA
        Case cStTrfPV == JGTrPVNPA
            cNewStPV := JGTrPVPFt
        Case cStTrfPV == JGTrPVPFt
            cNewStPV := JGTrPVPSp
        Case cStTrfPV == JGTrPVExD
            cNewStPV := JGTrOrOK
        Otherwise
            cNewStPV := " "
    EndCase

Return cNewStPV

/*/{Protheus.doc} fRvStTrOr
description
	Reverte o status da transferÍncia do OrÁamento recebido para o status imediatamente anterior.
@type user function
@version  
@author Jesus Ramos
@since 12/03/2026
@param cStTrfPV, character, param_description
@return variant, return_description
/*/
User Function fRvStTrOr(cStTrfOrc)
	Local cNewStOrc := ""

	Do Case
        Case cStTrfOrc == JGTrOrIni 
            cNewStOrc := JGTrOrEAb
        Case cStTrfOrc == JGTrOrPPS
            cNewStOrc := JGTrOrIni
        Case cStTrfOrc == JGTrOrPPF
            cNewStOrc := JGTrOrPPS
        Case cStTrfOrc == JGTrOrNPA
            cNewStOrc := JGTrOrPPF
        Case cStTrfOrc == JGTrOrNPE
            cNewStOrc := JGTrOrNPA
        Case cStTrfOrc == JGTrOrOK
            cNewStOrc := JGTrOrNPE
        Otherwise
            cNewStOrc := " "
    EndCase

Return cNewStOrc


/*/{Protheus.doc} JGRT11_G

	Rotina de acionamento e controle da operaÁ„o de resÌduo (cancelamento) do pedido de transferÍncia.

@type    function
@version 1.0
@author  Jesus Ramos
@since   22/05/2026
@return  Nil
/*/
User Function JGRT11_G(p_Ms520Del)
	Local cRet       As String
	Local cIdMov     As String
	Local nRecnoPed  As Numeric
	Local nItensPed  As Numeric
	Local nSemOrdSep As Numeric
	Local nOrdNaoFin As Numeric
	Local cMsgRes    As String

	Default p_Ms520Del := .F.

	nRecnoPed  := SC5->(Recno())
	cRet       := ""
	nItensPed  := 0
	nSemOrdSep := 0
	nOrdNaoFin := 0
	cMsgRes    := ""

	cIdMov := "["+SC5->C5_FILIAL +"-"+ SC5->C5_XFILTRF +"-"+ SC5->C5_NUM +"]"
	U_FLOGJG(cIdMov+" -Antes U_JGRT11G1 - Cancela TransferÍncia (Residua)"+" Time:"+TIME())

	// Valida os campos necess·rios para autorizar o resÌduo do pedido de transferÍncia
	If !(SC5->C5_XMOVTRF $ JGTrPVPSp+"/"+JGTrPVPFt+"/"+JGTrPVExO+"/"+JGTrPVOS) // O pedido precisa estar com status Pendente de SeparaÁ„o ou Pendente de Faturamento.

		cMsgRes := "O pedido precisa estar com os seguintes status:"+CRLF+CRLF+;
					"  -> Pendente de SeparaÁ„o"+CRLF+;
					"  -> Pendente de Faturamento"
		If IsBlind() .Or. p_Ms520Del
			U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
		Else
			FWAlertWarning(OemToAnsi(cMsgRes), OemToAnsi("Cancelamento da TransferÍncia"))
		EndIf

	ElseIf "X" $ SC5->C5_NOTA // Pedido j· residuado n„o entra na Rotina

		cMsgRes := "O pedido j· se encontra residuado."
		If IsBlind() .Or. p_Ms520Del
			U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
		Else
			FWAlertWarning(OemToAnsi(cMsgRes), OemToAnsi("Cancelamento da TransferÍncia"))
		EndIf

	ElseIf !Empty(SC5->C5_NOTA) // Pedido j· faturado n„o entra na Rotina

		cMsgRes := "O pedido j· se encontra faturado, n„o sendo possÌvel efetuar seu cancelamento/resÌduo."
		If IsBlind() .Or. p_Ms520Del
			U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
		Else
			FWAlertWarning(OemToAnsi(cMsgRes), OemToAnsi("Cancelamento da TransferÍncia"))
		EndIf

	Else

	    nItensPed    := fItensPed(SC5->C5_FILIAL, SC5->C5_NUM)
	    nSemOrdSep   := fSemOrdSep(SC5->C5_FILIAL, SC5->C5_NUM)
	    nOrdNaoFin   := fOrdNaoFin(SC5->C5_FILIAL, SC5->C5_NUM)

	    If nItensPed = 0

			cMsgRes := "N„o foram localizados itens para o pedido."
			If IsBlind() .Or. p_Ms520Del
				U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
			Else
				FWAlertWarning(OemToAnsi(cMsgRes), OemToAnsi("AtenÁ„o"))
			EndIf

	    ElseIf nSemOrdSep < nItensPed .Or. nOrdNaoFin > 0

			cMsgRes := "Existem ordens de separaÁ„o vinculadas a este pedido."+CRLF+CRLF+;
						"Para que seja possÌvel o cancelamento deste pedido, faz-se necess·rio cancelar/excluir/estornar "+;
						"as ordens de separaÁ„o."

			If p_Ms520Del .Or. SoftLock("SC5") //Evitar que 2 usu·rios acessem o mesmo registro simultaneamente
				If SC5->C5_XMOVTRF $ JGTrPVPSp+"/"+JGTrPVPFt+"/"+JGTrPVExO+"/"+JGTrPVOS
					U_JGRT11_E(SC5->(Recno()), JGTrPVOS, JGTrOrOS)//Grava Status no Pedido
					U_JGRT11_D("P", SC5->(Recno()), cMsgRes)//Grava Status no Pedido e no OrÁamento
				EndIf
				If !p_Ms520Del .And. IsLocked("SC5", SC5->(Recno()))
					SC5->(MsrUnlock()) //Libera o SoftLock
				EndIf
			EndIf

			If IsBlind() .Or. p_Ms520Del
				U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
			Else
				FWAlertWarning(OemToAnsi(cMsgRes), OemToAnsi("AtenÁ„o"))
			EndIf

		Else

			If IsBlind() .Or. FWAlertYesNo(OemToAnsi("Confirma o cancelamento desta transferÍncia?"), OemToAnsi("Cancelamento da TransferÍncia"))

				SC5->(DbGoTo(nRecnoPed))

				If !SC5->(Deleted())

					// cIdMov := ""

					If p_Ms520Del .Or. SoftLock("SC5") //Evitar que 2 usu·rios acessem o mesmo registro simultaneamente

						If SC5->C5_XMOVTRF $ JGTrPVPSp+"/"+JGTrPVPFt+"/"+JGTrPVExO

							// cIdMov := "["+SC5->C5_FILIAL +"-"+ SC5->C5_XFILTRF +"-"+ SC5->C5_NUM +"]"
							U_FLOGJG(cIdMov+" Antes U_JGRT11G1 - Cancela TransferÍncia (Residua)"+" Time:"+TIME())

							cRet := ""
							If IsBlind() .Or. p_Ms520Del
								cRet := U_JGRT11G1()
							Else
								FWMsgRun(, {|oSay| cRet := U_JGRT11G1() }, "Processando o cancelamento da transferÍncia selecionada...", "Aguarde, processando a rotina" )
							EndIf

							U_FLOGJG(cIdMov+" Retorno: "+IIf(Empty(cRet),"Sucesso",cRet)+" Time:"+TIME())
							U_FLOGJG(cIdMov+" Depois U_JGRT11G1 - Cancela TransferÍncia (Residua)"+" Time:"+TIME())

							If Empty(cRet)
								cMsgRes := "O cancelamento da transferÍncia foi processado com sucesso."
								If IsBlind() .Or. p_Ms520Del
									U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
								Else
									FWAlertSuccess(OemToAnsi(cMsgRes), OemToAnsi("TransferÍncia cancelada"))
								EndIf
								U_JGRT11_D("P", SC5->(Recno()), "Transferencia cancelada.")//Grava Status no Pedido e no OrÁamento
							Else
								If IsBlind() .Or. p_Ms520Del
									U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cRet)
								Else
									FWAlertError(OemToAnsi(cRet), OemToAnsi("Falha no cancelamento"))
								EndIf
								U_JGRT11_D("P", SC5->(Recno()), cRet)//Grava Status no Pedido e no OrÁamento
							EndIf

						Else

							cMsgRes := "O pedido mudou de situaÁ„o durante a confirmaÁ„o da rotina."+CRLF+CRLF+;
										"Reavalie a necessidade de execuÁ„o."
							If IsBlind() .Or. p_Ms520Del
								U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
							Else
								FWAlertInfo(OemToAnsi(cMsgRes), OemToAnsi("Status"))
							EndIf

						EndIf

						If !p_Ms520Del .And. IsLocked("SC5", SC5->(Recno()))
							SC5->(MsrUnlock()) //Libera o SoftLock
						EndIf

					Else

						cMsgRes := "N„o foi possÌvel reservar o pedido para efetuarmos o cancelamento/resÌduo."+CRLF+;
									"Algum outro processo est· bloqueando este pedido."+CRLF+CRLF+;
									"Saia e tente novamente."
						If IsBlind() .Or. p_Ms520Del
							U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
						Else
							FWAlertInfo(OemToAnsi(cMsgRes), OemToAnsi("Bloqueado"))
						EndIf

					EndIf

				Else

					cMsgRes := "O pedido foi excluÌdo enquanto prepar·vamos para iniciar."+CRLF+CRLF+;
								"O cancelamento/resÌduo n„o poder· prosseguir. Saia e verifique a situaÁ„o real do pedido."
					If IsBlind() .Or. p_Ms520Del
						U_FLOGJG(cIdMov + " - Time:"+TIME() + " - "+cMsgRes)
					Else
						FWAlertError(OemToAnsi(cMsgRes), OemToAnsi("AtenÁ„o"))
					EndIf

				EndIf

			Else

				FWAlertInfo(OemToAnsi("O cancelamento da transferÍncia foi abortado pelo usu·rio."), OemToAnsi("Cancelamento da TransferÍncia"))

			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} JGRT11G1

	Rotina para resÌduo (cancelamento) do pedido de transferÍncia, cancelando o processo de transferÍncia em andamento.
	Somente aceito para pedidos de transferÍncia com status:
		- JGTrPVPSp - PV Pendente Separar;
		- JGTrPVPFt - PV Pendente Faturar.
	Caso seja transferÍncia para o Varejo (Venda Assistida), atualiza, tambÈm, o status do orÁamento, retornando-o para:
		- JGTrOrEAb - OrÁamento em Aberto.

@type    function
@version 1.0
@author  Jesus Ramos
@since   21/05/2026
@return  Nil
/*/
User Function JGRT11G1()

    Local aAreaSC5 As Array
    Local aAreaSC6 As Array
    Local aAreaSC9 As Array
    Local lSC6OK   As Logical
	Local cStatus  As String
	Local bBlock

    Private __cErr 	 //ErrorBlock
    Private __cStack //ErrorBlock

    aAreaSC5 := SC5->(FWGetArea())
    aAreaSC6 := SC6->(FWGetArea())
    aAreaSC9 := SC9->(FWGetArea())
    lSC6OK   := .F.
	cStatus  := ""
	__cErr   := ""
	__cStack := ""

    bBlock := ErrorBlock() 

    BEGIN SEQUENCE

		ErrorBlock( { |oError| __cErr:=oError:Description , __cStack:=oError:ErrorStack , Break(oError) } )

		Begin Transaction

			U_JGRT11_E(SC5->(Recno()), JGTrPVCan, JGTrOrCan)//Grava Status no Pedido

			SC6->(dbsetorder(1))
			If SC6->( dbseek( SC5->C5_FILIAL+SC5->C5_NUM ))

				While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

					RecLock("SC6", .F.)
						SC6->C6_QTDEMP := 0
						SC6->C6_QTDLIB := 0
					SC6->(MsUnLock())

					lSC6OK := .T.

					SC6->(dbskip())
				EndDo

			EndIf

			If lSC6OK

				SC9->(dbsetorder(1))
				If SC9->(dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

					While !Eof() .and. SC9->C9_FILIAL+SC9->C9_PEDIDO == SC5->C5_FILIAL+SC5->C5_NUM
						SC9->(a460estorna())
						SC9->(dbskip())
					EndDo

				EndIf

				If RecLock("SC5", .F.)
					SC5->C5_NOTA  := "XXXXXX"
					SC5->C5_SERIE := "XXX"
					SC5->(MsUnlock()) 
				EndIf   

				SC6->(dbsetorder(1))
				If SC6->(dbseek( SC5->C5_FILIAL+SC5->C5_NUM ))

					While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

						If RecLock("SC6",.f.)
							SC6->C6_NOTA   := "XXXXXX"
							SC6->C6_SERIE  := "XXX"
							SC6->C6_QTDENT := SC6->C6_QTDVEN
							SC6->C6_BLQ    := "R"
							SC6->(MsUnLock())
						EndIf

						SC6->(dbskip())

					EndDo

				EndIf

			EndIf

			U_JGRT11_E(SC5->(Recno()), JGTrPVCan, JGTrOrEAb)//Grava Status no Pedido

		End Transaction

    RECOVER
        //RECOVER - Define um ponto de recuperaÁ„o, dentro do bloco de sequÍncia, para o qual o 
        //fluxo de execuÁ„o ser· desviado apÛs a execuÁ„o de um comando BREAK.

		If InTransact()
			DisarmTransaction()
		EndIf

        cStatus := __cErr

        U_FLOGJG('O seguinte erro ocorreu: ' + __cErr+CRLF+__cStack)

    END SEQUENCE

    ErrorBlock(bBlock)

    FWRestArea(aAreaSC5)
    FWRestArea(aAreaSC6)
    FWRestArea(aAreaSC9)

    FWFreeArray(aAreaSC5)
    FWFreeArray(aAreaSC6)
    FWFreeArray(aAreaSC9)

Return cStatus

/*/{Protheus.doc} fItensPed
description
    Verifica a quantidade de itens existentes no pedido.
@type function
@version  
@author Samsung
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fItensPed(cFilPed, cNumPed)
    Local cQuery As String
    Local nCount As Numeric

	nCount := 0
    cQuery := ""

    cQuery += " SELECT " + CRLF
    cQuery += "     COUNT(*) AS NCOUNT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     "+RetSqlDel("SC6") + CRLF
	cQuery += "		AND C6_FILIAL = "+ValToSql(cFilPed) + CRLF
    cQuery += "     AND C6_NUM = "+ValToSql(cNumPed) + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount

/*/{Protheus.doc} fSemOrdSep
description
    Verifica a quantidade de itens do pedido que n„o possuem ordem de separaÁ„o gerada.
@type function
@version  
@author Samsung
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fSemOrdSep(cFilPed, cNumPed)

    Local cQuery As String
    Local nCount As Numeric

    // Legendas da CB7 - Ordens de SeparaÁ„o - ACDA100:
    // aCores := {	{ "CB7->CB7_DIVERG == '1'", "DISABLE"  },;
    //             { "CB7->CB7_STATPA == '1'", "BR_CINZA" },;
    //             { "CB7->CB7_STATUS == '9'", "ENABLE"   },;
    //             { "CB7->CB7_STATUS $ '12345678'","BR_AMARELO" },;
    //             { "CB7->CB7_STATUS == '0'", "BR_AZUL"  } }

	nCount := 0
    cQuery := ""

    cQuery += " SELECT " + CRLF
    cQuery += "     COUNT(*) AS NCOUNT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     SC6.D_E_L_E_T_ <> '*' AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" " + CRLF
    cQuery += "     AND NOT EXISTS(" + CRLF
    cQuery += "         SELECT " + CRLF
    cQuery += "             1 " + CRLF
    cQuery += "         FROM " + CRLF
    cQuery += "             "+RetSqlName("CB8")+" CB8 " + CRLF
    cQuery += "             INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "                 AND CB7.CB7_FILIAL = CB8.CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7.CB7_PEDIDO = CB8.CB8_PEDIDO " + CRLF
    cQuery += "         WHERE " + CRLF
    cQuery += "             CB8.D_E_L_E_T_ <> '*' " + CRLF
    cQuery += "             AND CB8.CB8_FILIAL = SC6.C6_FILIAL AND CB8.CB8_PEDIDO = SC6.C6_NUM AND CB8.CB8_ITEM = SC6.C6_ITEM " + CRLF
    cQuery += "     ) " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount

/*/{Protheus.doc} fOrdNaoFin
description
    Verifica a quantidade de itens do pedido que possuem ordem de separaÁ„o gerada mas n„o finalizada.
@type function
@version  
@author Samsung
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fOrdNaoFin(cFilPed, cNumPed)
    Local cQuery As String
    Local nCount As Numeric

	nCount := 0
    cQuery := ""

	cQuery += "	SELECT " + CRLF
	cQuery += "		SUM( CASE WHEN CB7_STATUS = '9' THEN 0 ELSE 1 END ) NCOUNT " + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		( " + CRLF
	cQuery += "			SELECT " + CRLF
	cQuery += "				C6_FILIAL, C6_NUM, C6_ITEM, MAX(CB7.R_E_C_N_O_) RECNO_CB7 " + CRLF
	cQuery += "			FROM " + CRLF
	cQuery += "				SC6010 SC6 " + CRLF
	cQuery += "			INNER JOIN CB8010 CB8 ON " + CRLF
	cQuery += "				"+RetSqlDel("CB8") + CRLF
	cQuery += "				AND CB8_FILIAL = C6_FILIAL " + CRLF
	cQuery += "				AND CB8_PEDIDO = C6_NUM " + CRLF
	cQuery += "				AND CB8_ITEM   = C6_ITEM " + CRLF
	cQuery += "			INNER JOIN CB7010 CB7 ON " + CRLF
	cQuery += "				"+RetSqlDel("CB7") + CRLF
	cQuery += "				AND CB7_FILIAL = CB8_FILIAL " + CRLF
	cQuery += "				AND CB7_ORDSEP = CB8_ORDSEP " + CRLF
	cQuery += "				AND CB7_PEDIDO = CB8_PEDIDO " + CRLF
	cQuery += "			WHERE " + CRLF
    cQuery += "				"+RetSqlDel("SC6") + CRLF
    cQuery += "				AND C6_FILIAL = "+ValToSql(cFilPed) + CRLF
    cQuery += "				AND C6_NUM    = "+ValToSql(cNumPed) + CRLF
	cQuery += "			GROUP BY " + CRLF
	cQuery += "				C6_FILIAL, C6_NUM, C6_ITEM " + CRLF
	cQuery += "		) OS " + CRLF
	cQuery += "		INNER JOIN CB7010 CB7 ON CB7.R_E_C_N_O_ = OS.RECNO_CB7 " + CRLF

    // cQuery += " SELECT " + CRLF
    // cQuery += "     SUM( " + CRLF
    // cQuery += "         COALESCE( " + CRLF
    // cQuery += "             SELECT TOP 1 " + CRLF
    // cQuery += "                 CASE WHEN CB7_STATUS = '9' THEN 0 ELSE 1 END " + CRLF
    // cQuery += "             FROM " + CRLF
    // cQuery += "                 "+RetSqlName("CB8")+" CB8 " + CRLF
    // cQuery += "                 INNER JOIN "+RetSqlName("CB7")+" CB7 ON " + CRLF
    // cQuery += "                 	"+RetSqlDel("CB7") + CRLF
    // cQuery += "                     AND CB7_FILIAL = CB8_FILIAL " + CRLF
    // cQuery += "                 	AND ORDSEP     = ORDSEP " + CRLF
    // cQuery += "                 	AND CB7_PEDIDO = CB8_PEDIDO " + CRLF
    // cQuery += "                 	AND CB7_STATUS = '9' " + CRLF
    // cQuery += "             WHERE " + CRLF
    // cQuery += "                 "+RetSqlDel("CB8") + CRLF
    // cQuery += "                 AND CB8_FILIAL = SC6.C6_FILIAL " + CRLF
    // cQuery += "                 AND CB8_PEDIDO = SC6.C6_NUM " + CRLF
    // cQuery += "                 AND CB8_ITEM = SC6.C6_ITEM " + CRLF
    // cQuery += "             ORDER BY " + CRLF
    // cQuery += "                 CB7.R_E_C_N_O_ DESC " + CRLF
    // cQuery += "         , 0) " + CRLF
    // cQuery += "         ) NCOUNT " + CRLF
    // cQuery += " FROM " + CRLF
    // cQuery += "     "+RetSqlName("SC6")+" SC6 " + CRLF
    // cQuery += " WHERE " + CRLF
    // cQuery += "     "+RetSqlDel("SC6") + CRLF
    // cQuery += "     AND C6_FILIAL = "+ValToSql(cFilPed) + CRLF
    // cQuery += "     AND C6_NUM = "+ValToSql(cNumPed) + CRLF
    // cQuery += "     AND NOT EXISTS(" + CRLF
    // cQuery += "         SELECT DISTINCT " + CRLF
    // cQuery += "             1 " + CRLF
    // cQuery += "         FROM " + CRLF
    // cQuery += "             "+RetSqlName("CB8")+" CB8 " + CRLF
    // cQuery += "             INNER JOIN "+RetSqlName("CB7")+" CB7 ON " + CRLF
    // cQuery += "             	"+RetSqlDel("CB7") + CRLF
    // cQuery += "                 AND CB7.CB7_FILIAL = CB8.CB8_FILIAL " + CRLF
    // cQuery += "             	AND CB7_ORDSEP = CB8_ORDSEP " + CRLF
    // cQuery += "             	AND CB7.CB7_PEDIDO = CB8.CB8_PEDIDO " + CRLF
    // cQuery += "             	AND CB7.CB7_STATUS = '9' " + CRLF
    // cQuery += "         WHERE " + CRLF
    // cQuery += "             "+RetSqlDel("CB8") + CRLF
    // cQuery += "             AND CB8.CB8_FILIAL = SC6.C6_FILIAL " + CRLF
    // cQuery += "             AND CB8.CB8_PEDIDO = SC6.C6_NUM " + CRLF
    // cQuery += "             AND CB8.CB8_ITEM = SC6.C6_ITEM " + CRLF
    // cQuery += "     ) " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount

/*/{Protheus.doc} fLoteComErro

	Verifica a quantidade de itens do pedido que possuem algum problema relacionado ao lote, como por exemplo:
	- produto com controle de lote, mas sem lote informado;
	- produtos com controle de lote, com lote informado, mas o lote n„o existe na SB8.

@type function
@version  
@author Samsung
@since 09/03/2026
@param cFilial, character, param_description
@param cNumPed, character, param_description
@return variant, return_description
/*/
Static Function fLoteComErro(cFilPed, cNumPed)
    Local cQuery As String
    Local nCount As Numeric

	nCount := 0
    cQuery := ""

    cQuery += " SELECT " + CRLF
	cQuery += "		COUNT(*) NCOUNT " + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		"+RetSqlName("SC6")+" SC6 " + CRLF
	cQuery += "		LEFT JOIN "+RetSqlName("SB1")+" SB1 ON "+RetSqlDel("SB1")+" AND B1_FILIAL = "+ValToSql(FWxFilial("SB1"))+" AND B1_COD = C6_PRODUTO " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "		"+RetSqlDel("SC6")+" AND C6_FILIAL = "+ValToSql(cFilPed)+" AND C6_NUM = "+ValToSql(cNumPed)+" " + CRLF
	cQuery += "		AND	(COALESCE(B1_COD, ' ') = ' ' " + CRLF
	cQuery += "				OR	B1_RASTRO = 'L' AND C6_LOTECTL = ' ' " + CRLF
	cQuery += "				OR	B1_RASTRO = 'L' " + CRLF
	cQuery += "					AND NOT EXISTS( " + CRLF
	cQuery += "						SELECT " + CRLF
	cQuery += "							DISTINCT 1 " + CRLF
	cQuery += "						FROM " + CRLF
	cQuery += "							" + RetSqlName("SB8")+" SB8 " + CRLF
	cQuery += "						WHERE " + CRLF
	cQuery += "							" + RetSqlDel("SB8") + CRLF
	cQuery += "							AND B8_FILIAL  = C6_FILIAL " + CRLF
	cQuery += "							AND B8_PRODUTO = C6_PRODUTO " + CRLF
	cQuery += "							AND B8_LOCAL   = C6_LOCAL " + CRLF
	cQuery += "							AND B8_LOTECTL = C6_LOTECTL " + CRLF
	cQuery += "							AND B8_NUMLOTE = C6_NUMLOTE " + CRLF
	cQuery += "							AND B8_DTVALID = C6_DTVALID " + CRLF
	cQuery += "						) " + CRLF
	cQuery += "			) " + CRLF

    nCount := MpSysExecScalar(cQuery, "NCOUNT")

Return nCount
