#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#Include 'TopConn.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#include "RPTDEF.CH"
#include "FWPRINTSETUP.CH"
/*/{Protheus.doc} fFluxoFin
Função que orquestra a geração do borderô e impressão.
Brunno Alves
/*/
User Function JG05A002(cNota, cSerie, cCliente, cLoja)
	Local lBordOK := .T.

	// 1. Gera o Borderô
	//lBordOK := fGeraBord(cNota, cSerie, cCliente, cLoja)

	// 2. Se gerou borderô com sucesso, imprime o boleto
	If lBordOK
		fImpBoleto(cNota, cSerie, cCliente, cLoja)
	Else
		MsgStop("Não foi possível gerar o borderô. O boleto não será impresso.", "Erro")
	EndIf

Return

/*/{Protheus.doc} fGeraBord
Gera o borderô via ExecAuto (FINA060)
/*/
Static Function fGeraBord(cNota, cSerie, cCliente, cLoja)
	Local aCab      := {}
	Local aItens    := {}
	Local cQuery    := ""
	Local cAliasSE1 := GetNextAlias()
	Local lRet      := .T.
	Local cBanco    := SuperGetMV("MV_XBANCO",, "341") // <--- ATENCAO: Definir logica para pegar o banco correto
	Local cAgencia  := SuperGetMV("MV_XAGENC",, "7780")
	Local cConta    := SuperGetMV("MV_XCONTA",, "99664")
	Local cSubconta := "001"
	Local cEspecie  := "02"
	Local aBanco    := { {"001","B"}, {"237","R"},{"033","S"},{"756","C"},{"341","I"} }
	Local cBordero  := ""
	//Local lFindSEA  := .F.
	//Local nPos      := 0

	// Variável de controle de erro do ExecAuto
	Private lMsErroAuto := .F.

	cBordero := aBanco[5,2] + StrZero( day( dDataBase ),2 ) + Upper(chr( 64+Month( dDataBase ) ) ) + Right( Str( Year( date() ),4 ), 2 )

	//DbSelectArea("SEA")
	//SEA->( dbSetOrder( 1 ) )

	//lFindSEA := SEA->( DbSeek( xFilial( "SEA" )+cBordero,.F. ) )



	// Busca os titulos gerados pela nota (SE1) que ainda não estão em borderô
	cQuery := "SELECT R_E_C_N_O_ AS RECSE1, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	cQuery += "FROM " + RetSqlName("SE1") + " "
	cQuery += "WHERE E1_FILIAL  = '" + xFilial("SE1") + "' "
	cQuery += "AND E1_CLIENTE   = '" + cCliente + "' "
	cQuery += "AND E1_LOJA      = '" + cLoja + "' "
	cQuery += "AND E1_NUM       = '" + cNota + "' "
	cQuery += "AND E1_PREFIXO   = '" + cSerie + "' "
	cQuery += "AND E1_SITUACA   = '0' " // Carteira simples (sem borderô)
	cQuery += "AND D_E_L_E_T_   = ' ' "

	TCQuery cQuery New Alias (cAliasSE1)

	If (cAliasSE1)->(EoF())
		MsgAlert("Nenhum título disponível encontrado para gerar borderô.")
		// (cAliasSE1)->(DbCloseArea())
		Return .F.
	EndIf

	cBordero := ""
	// Monta Cabecalho do Borderô
	// O sistema gera a numeração automática se o parametro MV_NUMBOR estiver configurado
	aAdd(aCab, {"AUTBANCO"   , PadR(cBanco    ,TamSX3("A6_COD")[1])     })
	aAdd(aCab, {"AUTAGENCIA" , PadR(cAgencia  ,TamSX3("A6_AGENCIA")[1]) })
	aAdd(aCab, {"AUTCONTA"   , PadR(cConta    ,TamSX3("A6_NUMCON")[1])  })
	aAdd(aCab, {"AUTSITUACA" , "1"                                      })
	aAdd(aCab, {"AUTNUMBOR"  , PadR(cBordero  ,TamSX3("E1_NUMBOR")[1])  })
	aadd(aCab, {"AUTSUBCONTA", PadR(cSubconta ,TamSX3("EA_SUBCTA")[1])  })
	aadd(aCab, {"AUTESPECIE" , PadR(cEspecie  ,TamSX3("EA_ESPECIE")[1]) })

	// Monta Itens (Titulos a serem adicionados)
	While !(cAliasSE1)->(EoF())
		aAdd(aItens, {;
			{"E1_FILIAL"  , (cAliasSE1)->E1_FILIAL , Nil},;
			{"E1_PREFIXO" , (cAliasSE1)->E1_PREFIXO, Nil},;
			{"E1_NUM"     , (cAliasSE1)->E1_NUM    , Nil},;
			{"E1_PARCELA" , (cAliasSE1)->E1_PARCELA, Nil},;
			{"E1_TIPO"    , (cAliasSE1)->E1_TIPO   , Nil};
			})
		(cAliasSE1)->(DbSkip())
	EndDo
	(cAliasSE1)->(DbCloseArea())

	// Executa a rotina automática FINA060 (Borderôs)
	// 2 = Transferência
	// 3 = Inclusão
	MSExecAuto({|a, b| FINA060(a, b)}, 3,{aCab,aItens})

	If lMsErroAuto
		lRet := .F.
		MostraErro() // Exibe o erro na tela para o usuario
	Else
		MsgInfo("Borderô gerado com sucesso!", "Sucesso")
		//ConfirmSX8() // Confirma numeração do borderô
	EndIf

Return lRet


/*/{Protheus.doc} fImpBoleto
Chama a impressão do boleto (Exemplo usando FINR985 ou Customizado)
/*/
Static Function fImpBoleto(cNota, cSerie, cCliente, cLoja)

	LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
	SM0->M0_ENDCOB                                     ,; //[2]Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
	"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+              ; //[6]
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
	Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

	LOCAL aDadosTit
	LOCAL aDadosBanco
	LOCAL aDatSacado
	LOCAL aBolText     := {SuperGetMv("MV_MENBOL1",,"  ")   ,;    // Primeiro texto para comentario
	SuperGetMv("MV_MENBOL2",,"  ")   ,;    // Segundo texto para comentario
	SuperGetMv("MV_MENBOL3",,"  ")   ,;
		" ",;
		" " }    // Terceiro texto para comentario

	LOCAL nI           := 1
	LOCAL aCB_RN_NN    := {}
	LOCAL nVlrAbat	   := 0
	LOCAL cNosso       := ""
	// LOCAL _aVlrNF	   := {}
	Local lAdjustToLegacy	:= .F. //Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter.
	// Local lM460FIM	  := FWIsInCallStack("U_M460FIM")
	Local lDisabeSetup := .F.
	Local _cPathPDF := ""
	//Local cPathPDF  := ""
	Local _cArqPDF	:= ""
	//Local cArqPDF	:= ""
	private CDIGNOSSO := ""
	Private _cConvenio := ""
	Private _cCarteira := ""

	Private cString  := "SE1"
	Private wnrel    := "BOLETO BANCARIO"
	//Private cPerg     :="BOLETOBB  "
	Private titulo   := "Impressao de Boleto com Codigo de Barras"
	Private cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	Private cDesc2   := ""
	Private cDesc3   := ""
	Private Tamanho  := "G"

	Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	Private nLastKey := 0

	// oPrint:= TMSPrinter():New( "Boleto Bancario Laser" )
	// oPrint:Setup()
	// oPrint:SetPortrait()

	If select("TSE1") <> 0
		TSE1->(DbcloseArea())
	Endif

	// Busca os titulos gerados pela nota (SE1) que ainda não estão em borderô
	cQuery := "SELECT R_E_C_N_O_ AS RECSE1, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_DESCFIN, E1_NUMBCO "
	cQuery += "FROM " + RetSqlName("SE1") + " "
	cQuery += "WHERE E1_FILIAL  = '" + xFilial("SE1") + "' "
	cQuery += "AND E1_CLIENTE   = '" + cCliente + "' "
	cQuery += "AND E1_LOJA      = '" + cLoja + "' "
	cQuery += "AND E1_NUM       = '" + cNota + "' "
	cQuery += "AND E1_PREFIXO   = '" + cSerie + "' "
	// cQuery += "AND E1_SITUACA   = '0' " // Carteira simples (sem borderô)
	cQuery += "AND D_E_L_E_T_   = ' ' "

	TCQuery cQuery New Alias "TSE1"

	If TSE1->(EoF())
		MsgAlert("Nenhum título disponível encontrado para gerar borderô.")
		// (cAliasSE1)->(DbCloseArea())
		Return .F.
	EndIf
	// _cPathPDF := "C:\Temp\"
	_cPathPDF := "\SPOOL\"
	//_cPathPDF := GetSrvProfString("ROOTPATH","") + "\SPOOL\"
	lDisabeSetup := .T.

	If ! ExistDir(_cPathPDF)
		FWMakeDir(_cPathPDF)
	EndIf

/*
    If lM460FIM 
        lDisabeSetup := .T.
        if Empty(_cPathPDF)
            _cPathPDF := GetTempPath()		 //Definindo o diretório como a temporária do S.O.
            If Empty(_cPathPDF)
                _cPathPDF := "C:\TEMP"
            EndIf	
            //Se o último caracter da pasta não for barra, será barra para integridade
            If SubStr(_cPathPDF, Len(_cPathPDF), 1) != "\"
                _cPathPDF += "\"
            EndIf 
        EndIf
    EndIf
*/
	If 0=1//_lPDFCustom //Lorran Ferreira - Boleto em PDF para enviar por email
		lDisabeSetup := .T.
		lJob := .T.
		If !FWMakeDir( _cPathPDF )
			Return
		EndIf
		oPrint := FWMsPrinter():New(_cArqPDF,IMP_PDF,lAdjustToLegacy,_cPathPDF,.T., /*lTReport*/,/*oPrintSetup*/, /*cPrinter*/,.T./*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.F./*lViewPDF*/)
		oPrint:cPathPDF := _cPathPDF
		oPrint:lViewPDF := .F.
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
	Else
		// oPrint := FWMsPrinter():New("Boleto_Bancario_"+cNota, IIF(lM460FIM,IMP_PDF,IMP_SPOOL) , lAdjustToLegacy,IIF(lM460FIM,_cPathPDF,Nil),lDisabeSetup)
		oPrint := FWMsPrinter():New("Boleto_Bancario_"+cNota, IMP_PDF , lAdjustToLegacy,_cPathPDF,lDisabeSetup)
		// oPrint 		:= FWMSPrinter():New("Boleto_Bancario_"+cNota		, IMP_PDF, lAdjustToLegacy	,_cPathPDF				, lDisableSetup	,	,	,	,	, ,	.f.	,.F.,)// Ordem obrigátoria de configuração do relatório

		oPrint:lserver:=.T.
		oPrint:linjob:=.T.

		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		// If lM460FIM
			//Força a impressão em PDF
			oPrint:nDevice  := 6
			oPrint:cPathPDF := _cPathPDF
			oPrint:lServer  := .T.
			oPrint:lViewPDF := .f.
		// EndIf
	EndIf

	if !lDisabeSetup .And. oPrint:nModalResult <> PD_OK //.And. !_lPDFCustom
		Return
	endif

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	TSE1->( dbGoTop() )

	while !TSE1->( Eof() )

		If .T. // TSE1->E1_OK = '  '

			SE1->( DbSetOrder(2), DbSeek( xFilial("SE1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
			cNroDoc    :=  ""

			if !NrBordero()
				Set Filter to
				Aviso("ATENÇÃO","O banco "+SEE->EE_CODIGO+" não esta configurado para Impressão Boleto Laser",{"OK"})
				Return
			endif

			//Posiciona na Tabela do bordero.
			SEA->( DBSetOrder(1) )
			if !SEA->( DBSeek( xFilial("SEA") + SE1->E1_NUMBOR + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
				Alert("Titulo nao localizado no bordero selecionado. Pref. "+Alltrim(TSE1->E1_PREFIXO)+" Tit. "+Alltrim(TSE1->E1_NUM))
				Return
			endif

			//Posiciona na Arq de Parametros CNAB
			SEE->( DbSetOrder(1) )
			if !SEE->( DbSeek(xFilial("SEE")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)+"001",.T.) )
				alert("Erro na leitura dos parametros do banco do bordero gerado (Sub-conta diferente de 001),")
				return
			EndIf

			//Posiciona o SA6 (Bancos)
			SA6->( DbSetOrder(1) )
			if !SA6->( DbSeek(xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON) ,.T.) )
				Alert("Banco do bordero ("+Alltrim(SEA->EA_PORTADO)+" - "+Alltrim(SEA->EA_AGEDEP)+" - "+Alltrim(SEA->EA_NUMCON)+") nao localizado no cadastro de Bancos.")
				Return
			endif

			if Empty(SEE->EE_CODEMP)
				alert("Informar o convenio do banco no cadastro de parametros do banco (EE_CODEMP) !")
				return nil
			endif

			if Empty(SEE->EE_TABELA)
				alert("Informar a tabela do banco no cadastro de parametros do banco (EE_TABELA) !")
				return nil
			endif

			_cConvenio := AllTrim(SEE->EE_CODEMP) // Tamanho de 7.
			_cCarteira := '109'//Alltrim(SEE->EE_XCART)

			//Posiciona o SA1 (Cliente)
			SA1->( DbSetOrder(1) )
			SA1->( DbSeek(xFilial("SA1")+TSE1->E1_CLIENTE+TSE1->E1_LOJA,.T.) )

			If SEE->EE_CODIGO == '001'  // Banco do Brasil
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"BANCO BRASIL"     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dígito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"9" ,; // [7] Digito do Banco
				"Pagável em qualquer banco." ,; //"ATÉ O VENCIMENTO, PREFERENCIALMENTE EM TODA REDE BANCÁRIA" ,; // [8] Local de Pagamento1
				"",; //"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO BANCO DO BRASIL",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,; 	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] Código Cedente fornecido pelo Banco

			ElseIf SEE->EE_CODIGO == '341'  // Itau
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"Banco Itaú S.A."     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dígito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"7" ,; // [7] Digito do Banco
				"Pagável em qualquer banco." ,; //"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ" ,; // [8] Local de Pagamento1
				"",; //"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO ITAÚ",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;//[10] Digito Verificador da agencia
				_cConvenio}	//[11] Código Cedente fornecido pelo Banco

			ElseIf SEE->EE_CODIGO == '237'  // Bradesco
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"Bradesco S.A."     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dígito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"2" ,; // [7] Digito do Banco
				"Pagável em qualquer banco." ,; //"ATÉ O VENCIMENTO, PREFERENCIALMENTE NAS AGÊNCIAS BRADESCO" ,; // [8] Local de Pagamento1
				"",; //"APÓS O VENCIMENTO, NAS AGÊNCIAS DO BRADESCO",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] Código Cedente fornecido pelo Banco

			ElseIf SEE->EE_CODIGO == '033'  				// Santander
				aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
				"SANTANDER S.A."     		,; // [2]Nome do Banco
				AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dígito da conta corrente ( e para ser vazio )
				_cCarteira ,; // [6]Codigo da Carteira
				"2" ,; // [7] Digito do Banco
				"Pagável em qualquer banco." ,; // "ATÉ O VENCIMENTO, PREFERENCIALMENTE NAS AGÊNCIAS SANTANDER" ,; // [8] Local de Pagamento1
				"",; //"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO SANTANDER",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] Código Cedente fornecido pelo Banco

			ElseIf SEE->EE_CODIGO == '756'  // Banco Sicoob
				aDadosBanco  := {SEE->EE_CODIGO          ,;		// [1]Numero do Banco
				"SICOOB"     ,; 				// [2]Nome do Banco
				AllTrim(SubStr(SEE->EE_AGENCIA,1,4)) ,;	// [3]Agência
				AllTrim(SEE->EE_CONTA),; 		// [4]Conta Corrente -2
				AllTrim(SEE->EE_DVCTA),; 		// [5]Dígito da conta corrente
				_cCarteira ,; 					// [6]Codigo da Carteira
				"0" ,; 						// [7] Digito do Banco
				"Pagável em qualquer banco." ,; // [8] Local de Pagamento1 // "Pagável em qualquer banco até a data de vencimento." ,; // [8] Local de Pagamento1
				"",; // [9] Local de Pagamento2
				"",; 	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] Código Cedente fornecido pelo Banco
			Endif

			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
				AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
				SA1->A1_EST                                      ,;     	// [5]Estado
				SA1->A1_CEP                                      ,;      	// [6]CEP
				SA1->A1_CGC										 ,;  		// [7]CGC
				SA1->A1_PESSOA									  }     	// [8]PESSOA
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
				AllTrim(SA1->A1_MUN )	                            ,;   	// [4]Cidade
				SA1->A1_ESTC	                                    ,;   	// [5]Estado
				SA1->A1_CEPC                                        ,;   	// [6]CEP
				SA1->A1_CGC											,;		// [7]CGC
				SA1->A1_PESSOA										 }		// [8]PESSOA
			Endif

			nVlrAbat   :=  SomaAbat(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,"R",1,,TSE1->E1_CLIENTE,TSE1->E1_LOJA)

			//
			// Incrementa sequencia do nosso numero no parametro banco
			//
			_cont:=0
			DbSelectArea("SE1")
			SE1->( DBSetOrder(1) )
			If SE1->( DBSeek(XFILIAL("SE1")+TSE1->E1_PREFIXO+TSE1->E1_NUM+TSE1->E1_PARCELA+TSE1->E1_TIPO) )

				If !Empty(SE1->E1_NUMBCO)
					cNroDoc 	:= Alltrim(SE1->E1_NUMBCO)
					//cDigNosso 	:= SE1->E1_XDVNNUM
					_cont:=1
				Endif

			EndIf

			If Empty(cNroDoc)
				If SEE->EE_CODIGO == '001'
					if Len( AllTrim(SEE->EE_CODEMP) ) < 7
						cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),5)
						cDigNosso := Dig11BB(AllTrim(SEE->EE_CODEMP)+cNroDoc )		//CALC_di9(SEE->EE_CODEMP+cNosso)
					elseif Len( AllTrim(SEE->EE_CODEMP) ) == 7
						cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
						cDigNosso := DigitoBB(cNosso)
					endif

				elseIf SEE->EE_CODIGO == '341'
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),8)
					cTexto    := Alltrim(aDadosBanco[3]) + Alltrim(aDadosBanco[4]) + Alltrim(aDadosBanco[6]) + cNroDoc
					cDigNosso := Modu10(cTexto)

				elseIf SEE->EE_CODIGO == '237'
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
					if !aDadosBanco[6] == "02"
						cDigNosso := Modu11(Alltrim(aDadosBanco[6]) + cNroDoc , 7 )
					else
						cDigNosso := BradMod11(Alltrim(aDadosBanco[6]) + cNroDoc)
					endif

				elseIf SEE->EE_CODIGO $ '033'	// Santander nosso nr tem o tamanho fixo 12 + digito
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),12)
					cDigNosso := Dig11Santander(@cNroDoc)

				elseIf SEE->EE_CODIGO $ '756'	// SICOOB nosso nr tem o tamanho fixo 07
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),7)
					//					cDigNosso := SiCoobMod11(cNroDoc)
					cDigNosso := DigNNSicoob(cNroDoc,AllTrim(SEE->EE_CODEMP),AllTrim(SEE->EE_AGENCIA))
				Else
					cNroDoc := '9999999999'
				EndIf

				RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := cNroDoc //aNossoN   // Nosso número (Ver fórmula para calculo)
				//SE1->E1_XDVNNUM := cDigNosso // incluída para gravar digito verificador do nosso número
				SE1->( MsUnlock() )

				// atuliza a faixa atual do parametro banco
				RecLock("SEE",.F.)
				SEE->EE_FAXATU := cNroDoc
				SEE->( MsUnlock() )
				//fim

			Endif

			//
			//Monta codigo de barras
			//
			aCB_RN_NN    := Ret_cBarra(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,TSE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4] ,aDadosBanco[5],;
				cNroDoc,(TSE1->E1_SALDO - nVlrAbat)	, aDadosBanco[6] ,"9"	) // Ajustado para pegar o saldo do título e não o valor (Jesus)
			//							cNroDoc,(TSE1->E1_VLCRUZ - nVlrAbat)	, aDadosBanco[6] ,"9"	)
			dEmissao := StoD(TSE1->E1_EMISSAO )
			cVencRea := StoD(TSE1->E1_VENCREA )
			aDadosTit	:= {  	TSE1->E1_NUM + AllTrim(TSE1->E1_PARCELA)	,;  // [1] Número do título
			dEmissao                         	,; 	// [2] Data da emissão do título
			dDataBase          							,;	// [3] Data da emissão do boleto
			cVencRea                          	,; 	// [4] Data do vencimento
			(TSE1->E1_SALDO - nVlrAbat)  				,;  // [5] Valor do título
			aCB_RN_NN[3]                       			,;  // [6] Nosso número (Ver fórmula para calculo) // de 3 coloquei 9
			TSE1->E1_PREFIXO							,;  // [7] Prefixo da NF
			"DM"										,;	// [8] Tipo do Titulo
			TSE1->E1_SALDO * (TSE1->E1_DESCFIN/100)  }		// [9] Desconto financeiro


			//------------------------------------------------------------------------------------------------------------------------------
			//				TEXTO PADRAO PARA MSG NO CORPO DO BOLETO
			//------------------------------------------------------------------------------------------------------------------------------

			aBolText[1] := iif( Empty(aBolText[1]),"PROTESTO AUTOMÁTICO APÓS 05 DIAS DE VENCIMENTO.", aBolText[1])

			aBolText[2] := "ATENÇÃO SR. CAIXA: "

			if GetMV("MV_LJMULTA") > 0
				aBolText[3] := "Após Vencimento, Multa de "+ Transform(GetMV("MV_LJMULTA"),"@E 99.99%") +" no Valor de R$ "+AllTrim(Transform((TSE1->E1_SALDO*GetMV("MV_LJMULTA")/100),"@E 99,999.99"))
			endif

			if GetMV("MV_TXPER") > 0 .and. GetMV("MV_LJMULTA") > 0
				aBolText[4] := "Mora Diária de "+ Transform(GetMV("MV_TXPER"),"@E 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( TSE1->E1_SALDO*GetMV("MV_TXPER") )/100),"@E 99,999.99"))+"."

			elseif GetMV("MV_TXPER") > 0
				aBolText[3] := "Mora Diária de "+ Transform(GetMV("MV_TXPER"),"@E 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( TSE1->E1_SALDO*GetMV("MV_TXPER") )/100),"@E 99,999.99"))

			endif

			if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
				aBolText[5] := "Desconto concedido de R$ "+AllTrim(Transform(aDadosTit[9] ,"@E 99,999.99"))+" para pagamento até a data de vencimento."
			else
				aBolText[5] := ""
			endif

			//------------------------------------------------------------------------------------------------------------------------------

			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
			// nX := nX + 1

		EndIf

		TSE1->( dbSkip() )
		IncProc()
		nI += 1

	Enddo

	oPrint:Preview()		// Visualiza antes de imprimir
	Ms_Flush()
Return .T.

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³  Impress ³ Autor ³ Kesley M Martins      ³ Data ³ 19/07/07 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ TOTVS                                                      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,aNossoN)
	LOCAL oFont8
	LOCAL oFont11c
	LOCAL oFont10
	LOCAL oFont14
	LOCAL oFont16n
	LOCAL oFont15
	LOCAL oFont14n
	LOCAL oFont24
	LOCAL nI := 0
	Local nColEnd := 570

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)

	oFont8   := TFont():New("Arial",9,-8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,-10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10n := TFont():New("Arial",9,-10,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12n := TFont():New("Arial",9,12,.T.,.f.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,-20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/
	nRow1 := 0

	oPrint:Line (nRow1+0037,0125,nRow1+0017, 0125)
	oPrint:Line (nRow1+0037,0177,nRow1+0017, 0177)

	oPrint:Say  (nRow1+0032,0025,aDadosBanco[2],oFont12 )						// [2]Nome do Banco
	oPrint:Say  (nRow1+0032,0128,aDadosBanco[1]+"-"+aDadosBanco[7] ,oFont20 )	// [1]Numero do Banco   + [7] DV Banco

	oPrint:Say  (nRow1+0032,0475,"Comprovante de Entrega",oFont10n)
	oPrint:Line (nRow1+0037,0025,nRow1+0037,nColEnd)

	oPrint:Say  (nRow1+0037+7,0025 ,"Cedente",oFont8)
	oPrint:Say  (nRow1+0050+7,0025 ,aDadosEmp[1],oFont10n)				//Nome + CNPJ

	oPrint:Say  (nRow1+0037+7,0265,"Agência/Código Cedente",oFont8)
	oPrint:Say  (nRow1+0050+7,0265,aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]).OR.aDadosBanco[1]=="001",aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]) ,oFont10n)

	oPrint:Say  (nRow1+0037+7,0377,"Nro.Documento",oFont8)
	oPrint:Say  (nRow1+0050+7,0377,aDadosTit[7]+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow1+0062+7,0025 ,"Sacado",oFont8)
	oPrint:Say  (nRow1+0075+7,0025 ,aDatSacado[1],oFont10n)				//Nome

	oPrint:Say  (nRow1+0062+7,0265,"Vencimento",oFont8)
	oPrint:Say  (nRow1+0075+7,0265,StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4),oFont10n)

	oPrint:Say  (nRow1+0062+7,0377,"Valor do Documento",oFont8)
	oPrint:Say  (nRow1+0075+7,0387,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10n)

	oPrint:Say  (nRow1+0100+7,0025,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say  (nRow1+0112+7,0025,"com as características acima.",oFont10)
	oPrint:Say  (nRow1+0087+7,0265,"Data",oFont8)
	oPrint:Say  (nRow1+0087+7,0352,"Assinatura",oFont8)
	oPrint:Say  (nRow1+0112+7,0265,"Data",oFont8)
	oPrint:Say  (nRow1+0112+7,0352,"Entregador",oFont8)

	oPrint:Line (nRow1+0062, 0025,nRow1+0062,0475 )
	oPrint:Line (nRow1+0087, 0025,nRow1+0087,0475 )
	oPrint:Line (nRow1+0112, 0262,nRow1+0112,0475 ) //---
	oPrint:Line (nRow1+0137, 0025,nRow1+0137,nColEnd )

	oPrint:Line (nRow1+0137,0262,nRow1+0037,0262 )
	oPrint:Line (nRow1+0137,0350,nRow1+0087,0350 )
	oPrint:Line (nRow1+0087,0375,nRow1+0037,0375 ) //--
	oPrint:Line (nRow1+0137,0475,nRow1+0037,0475 )

	oPrint:Say  (nRow1+0041+7,0477,"(  )Mudou-se"                                	,oFont8)
	oPrint:Say  (nRow1+0051+7,0477,"(  )Ausente"                                  ,oFont8)
	oPrint:Say  (nRow1+0061+7,0477,"(  )Não existe nº indicado"                  	,oFont8)
	oPrint:Say  (nRow1+0071+7,0477,"(  )Recusado"                                	,oFont8)
	oPrint:Say  (nRow1+0081+7,0477,"(  )Não procurado"                            ,oFont8)
	oPrint:Say  (nRow1+0091+7,0477,"(  )Endereço insuficiente"                  	,oFont8)
	oPrint:Say  (nRow1+0101+7,0477,"(  )Desconhecido"                            	,oFont8)
	oPrint:Say  (nRow1+0111+7,0477,"(  )Falecido"                                 ,oFont8)
	oPrint:Say  (nRow1+0121+7,0477,"(  )Outros(anotar no verso)"                  ,oFont8)


/*****************/
/* SEGUNDA PARTE */
/*****************/
	nRow2 := 0

//Pontilhado separador
	For nI := 25 to nColEnd step 12
		oPrint:Line(nRow2+0145, nI,nRow2+0145, nI+7)
	Next nI

	oPrint:Line (nRow2+0177,0025,nRow2+0177,nColEnd)
	oPrint:Line (nRow2+0177,0125,nRow2+0157,0125)
	oPrint:Line (nRow2+0177,0177,nRow2+0157,0177)

	oPrint:Say  (nRow2+0165+7,0025,aDadosBanco[2],oFont12 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0165+7,0128,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// [1]Numero do Banco
	oPrint:Say  (nRow2+0165+7,0450,"Recibo do Sacado",oFont10n)

	oPrint:Line (nRow2+0202,0025,nRow2+0202,nColEnd )
	oPrint:Line (nRow2+0227,0025,nRow2+0227,nColEnd )
	oPrint:Line (nRow2+0245,0025,nRow2+0245,nColEnd )
	oPrint:Line (nRow2+0262,0025,nRow2+0262,nColEnd )

	oPrint:Line (nRow2+0227,0125,nRow2+0262,0125)
	oPrint:Line (nRow2+0245,0187,nRow2+0262,0187)
	oPrint:Line (nRow2+0227,0250,nRow2+0262,0250)
	oPrint:Line (nRow2+0227,0325,nRow2+0245,0325)
	oPrint:Line (nRow2+0227,0370,nRow2+0262,0370)

	oPrint:Say  (nRow2+0177+7,0025 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow2+0181+7,0100 ,aDadosBanco[8] ,oFont10n)
	oPrint:Say  (nRow2+0191+7,0100 ,aDadosBanco[9] ,oFont10n)

	oPrint:Say  (nRow2+0177+7,0452,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
	nCol := 462+(93-(len(cString)*5))
	oPrint:Say  (nRow2+0187+7,nCol,cString,oFont12)

	oPrint:Say  (nRow2+0202+7,0025 ,"Cedente"                                        ,oFont8)
	oPrint:Say  (nRow2+0212+7,0025 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

	oPrint:Say  (nRow2+0202+7,0452,"Agência/Código Cedente",oFont8)
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]).OR.aDadosBanco[1]=="001",aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]) )
	nCol := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow2+0212+7,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0227+7,0025 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow2+0235+7,0025, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4),oFont10n)

	oPrint:Say  (nRow2+0227+7,0126 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow2+0235+7,0151 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow2+0227+7,0251,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (nRow2+0235+7,0262,aDadosTit[8]										,oFont10n) //Tipo do Titulo

	oPrint:Say  (nRow2+0227+7,0326,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow2+0235+7,0350,"N"                                             ,oFont10n)

	oPrint:Say  (nRow2+0227+7,0371,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow2+0235+7,0387,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4),oFont10n) // Data impressao

	oPrint:Say  (nRow2+0227+7,0452,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4))
	nCol := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow2+0235+7,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0245+7,0025 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow2+0245+7,0126 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow2+0252+7,0138 ,aDadosBanco[6]                                  	,oFont10n)

	oPrint:Say  (nRow2+0245+7,0188 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (nRow2+0252+7,0201 ,"R$"                                             ,oFont10n)

	oPrint:Say  (nRow2+0245+7,0251,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow2+0245+7,0371,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow2+0245+7,0452,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow2+0252+7,nCol,cString ,oFont11c)

	oPrint:Say  (nRow2+0262+7,0025 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

	oPrint:Say  (nRow2+0275+7,0025 ,aBolText[1],oFont10n)	// 1150
	oPrint:Say  (nRow2+0287+7,0025 ,aBolText[2],oFont10n)	// 1200
	oPrint:Say  (nRow2+0300+7,0025 ,aBolText[3],oFont10n)	// 1250
	oPrint:Say  (nRow2+0312+7,0025 ,aBolText[4],oFont10n)	// 1300
	oPrint:Say  (nRow2+0325+7,0025 ,aBolText[5],oFont10n)	// 1300

// MSG dos Parametros
	if !Empty(MV_PAR21)
		oPrint:Say  (nRow2+0337+7,0025, AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
	endif

	oPrint:Say  (nRow2+0262+7,0452,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow2+0280+7,0452,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow2+0297+7,0452,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow2+0315+7,0452,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow2+0332+7,0452,"(=)Valor Cobrado"                               ,oFont8)

	if aDadosTit[9] > 0 .and. aDadosTit[4] >= dDataBase
		cString := Alltrim(Transform( aDadosTit[9],"@E 999,999,999.99"))
		nCol 	 := 457+(93-(len(cString)*5))
		oPrint:Say  (nRow2+0270+7,nCol,cString,oFont11c)
	endif

	oPrint:Say  (nRow2+0350+7,0025 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (nRow2+0357+7,0100 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
	oPrint:Say  (nRow2+0370+7,0100 ,aDatSacado[3]                                    ,oFont10n)
	oPrint:Say  (nRow2+0384+7,0100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow2+0397+7,0100 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
	Else
		oPrint:Say  (nRow2+0397+7,0100 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
	EndIf

	oPrint:Say  (nRow2+0401+7,0025 ,"Sacador/Avalista",oFont8)
	oPrint:Say  (nRow2+0411+7,0375,"Autenticação Mecânica",oFont8)

	oPrint:Line (nRow2+0177,0450,nRow2+0350,0450 )
	oPrint:Line (nRow2+0280,0450,nRow2+0280,nColEnd )
	oPrint:Line (nRow2+0297,0450,nRow2+0297,nColEnd )
	oPrint:Line (nRow2+0315,0450,nRow2+0315,nColEnd )
	oPrint:Line (nRow2+0332,0450,nRow2+0332,nColEnd )
	oPrint:Line (nRow2+0350,0025,nRow2+0350,nColEnd )
	oPrint:Line (nRow2+0410,0025,nRow2+0410,nColEnd )


/******************/
/* TERCEIRA PARTE */
/******************/

	nRow3 := 0 //-150

	For nI := 25 to nColEnd step 12
		oPrint:Line(nRow3+470, nI, nRow3+470, nI+7)
	Next nI

	oPrint:Line (nRow3+0500,0025,nRow3+0500,nColEnd)
	oPrint:Line (nRow3+0500,0125,nRow3+0480,0125)
	oPrint:Line (nRow3+0500,0177,nRow3+0480,0177)

	oPrint:Say  (nRow3+0488+7,0025,aDadosBanco[2],oFont12 )		// 	[2]Nome do Banco
	oPrint:Say  (nRow3+0488+7,0128,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// 	[1]Numero do Banco
	oPrint:Say  (nRow3+0488+7,0188,aCB_RN_NN[2],oFont14n)			//	Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+0525,0025,nRow3+0525,nColEnd )
	oPrint:Line (nRow3+0550,0025,nRow3+0550,nColEnd )
	oPrint:Line (nRow3+0567,0025,nRow3+0567,nColEnd )
	oPrint:Line (nRow3+0585,0025,nRow3+0585,nColEnd )

	oPrint:Line (nRow3+0550,0125,nRow3+0585,0125 )
	oPrint:Line (nRow3+0567,0187,nRow3+0585,0187 )
	oPrint:Line (nRow3+0550,0250,nRow3+0585,0250)
	oPrint:Line (nRow3+0550,0325,nRow3+0567,0325)
	oPrint:Line (nRow3+0550,0370,nRow3+0585,0370)

	oPrint:Say  (nRow3+0500+7,0025 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow3+0503+7,0100 ,aDadosBanco[8],oFont10n)
	oPrint:Say  (nRow3+0513+7,0100 ,aDadosBanco[9],oFont10n)

	oPrint:Say  (nRow3+0500+7,0452,"Vencimento",oFont8)
	cString := StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
	nCol	 	 := 462+(93-(len(cString)*5))
	oPrint:Say  (nRow3+0510+7,nCol,cString,oFont12)

	oPrint:Say  (nRow3+0525+7,0025 ,"Cedente",oFont8)
	oPrint:Say  (nRow3+0535+7,0025 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

	oPrint:Say  (nRow3+0525+7,0452,"Agência/Código Cedente",oFont8)
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]).OR.aDadosBanco[1]=="001",aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
	nCol 	 := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow3+0535+7,nCol,cString ,oFont11c)

	oPrint:Say (nRow3+0550+7,0025 ,"Data do Documento"                              ,oFont8)
	oPrint:Say (nRow3+0557+7,0025, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4), oFont10n)


	oPrint:Say  (nRow3+0550+7,0126 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow3+0557+7,0151 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow3+0550+7,0251,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (nRow3+0557+7,0262,aDadosTit[8]										,oFont10n) //Tipo do Titulo

	oPrint:Say  (nRow3+0550+7,0326,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow3+0557+7,0350,"N"                                             ,oFont10n)

	oPrint:Say  (nRow3+0550+7,0371,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow3+0557+7,0387,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4)                               ,oFont10n) // Data impressao


	oPrint:Say  (nRow3+0550+7,0452,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4))
	nCol 	 := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow3+0557+7,nCol,cString,oFont11c)


	oPrint:Say  (nRow3+0567+7,0025 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow3+0567+7,0126 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow3+0575+7,0138 ,aDadosBanco[6]                                  	,oFont10n)

	oPrint:Say  (nRow3+0567+7,0188 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (nRow3+0575+7,0201 ,"R$"                                             ,oFont10n)

	oPrint:Say  (nRow3+0567+7,0251,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow3+0567+7,0371,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow3+0567+7,0452,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol 	 := 457+(93-(len(cString)*5))
	oPrint:Say  (nRow3+0575+7,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+0585+7,0025 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

	oPrint:Say  (nRow3+0597+7,0025 ,aBolText[1],oFont10n)
	oPrint:Say  (nRow3+0610+7,0025 ,aBolText[2],oFont10n)
	oPrint:Say  (nRow3+0622+7,0025 ,aBolText[3],oFont10n)
	oPrint:Say  (nRow3+0635+7,0025 ,aBolText[4],oFont10n)
	oPrint:Say  (nRow3+0647+7,0025 ,aBolText[5],oFont10n)

	if !Empty(MV_PAR21)
		oPrint:Say  (nRow2+0660+7,0025 ,AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
	endif

	If _cont = 1 .and. Empty(aBolText[4]+aBolText[5])
		oPrint:Say  (nRow3+0647+7,0025 ,"/////ATENÇÃO/////--> SEGUNDA VIA",oFont10n)
	EndIf

	oPrint:Say  (nRow3+0585+7,452,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow3+0602+7,452,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow3+0620+7,452,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow3+0637+7,452,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow3+0655+7,452,"(=)Valor Cobrado"                               ,oFont8)

	if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
		cString := Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99"))
		nCol 	 := 457+(93-(len(cString)*5))
		oPrint:Say  (nRow3+0592+7,nCol,cString,oFont11c)
	endif

	oPrint:Say  (nRow3+0672+7,0025 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (nRow3+0675+7,0100 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
	oPrint:Say  (nRow3+0688+7,0100 ,aDatSacado[3]                                    ,oFont10n)
	oPrint:Say  (nRow3+0701+7,0100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado

	oPrint:Say  (nRow3+0718+7,0025 ,"Sacador/Avalista"                               ,oFont8)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+0718+7,0100 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
	Else
		oPrint:Say  (nRow3+0718+7,0100 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
	EndIf

	oPrint:Line (nRow3+0500,0450,nRow3+0672,0450 )
	oPrint:Line (nRow3+0602,0450,nRow3+0602,nColEnd )
	oPrint:Line (nRow3+0620,0450,nRow3+0620,nColEnd )
	oPrint:Line (nRow3+0637,0450,nRow3+0637,nColEnd )
	oPrint:Line (nRow3+0655,0450,nRow3+0655,nColEnd )
	oPrint:Line (nRow3+0672,0025,nRow3+0672,nColEnd )

	oPrint:Line (nRow3+0730,0025,nRow3+0730,nColEnd  )
	oPrint:Say  (nRow3+0733+7,0375,"Autenticação Mecânica - Ficha de Compensação"   ,oFont8)

	_cLinBol  := 0742
	_cColBol  := 0050
	_cLargBol := 0.75
	_cAltBol  := 45
	_cMtdBarra := "Int25"
	If _cMtdBarra == "FWMSBAR"
		oPrint:FWMSBAR("INT25", 63, 2, aCB_RN_NN[1], oPrint, .F., Nil, .T., 0.035, 1.2, Nil, Nil, "A", .F.)
	ElseIf _cMtdBarra == "Int25"
		oPrint:Int25(_cLinBol,_cColBol,aCB_RN_NN[1],_cLargBol, _cAltBol,.F.,.F.)
	EndIf

	oPrint:EndPage() // Finaliza a página

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o codigo de barras.        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
		cBanco		,cAgencia	,cConta		,cDacCC	,;
		cNroDoc		,nValor		,cCart		,cMoeda	)

	Local cNosso		:= ""
// Local NNUM			:= ""
	Local cCampoL		:= ""
	Local cFatorValor	:= ""
	Local cLivre		:= ""
	Local cDigBarra		:= ""
	Local cBarra		:= ""
	Local cParte1		:= ""
	Local cDig1			:= ""
	Local cParte2		:= ""
	Local cDig2			:= ""
	Local cParte3		:= ""
	Local cDig3			:= ""
	Local cParte4		:= ""
	Local cParte5		:= ""
	Local cDigital		:= ""
	Local cTexto        := ""
	Local aRet			:= {}

//DEFAULT nValor := 0
	cAgencia   := StrZero(Val(cAgencia),4)
	cNosso     := ""


	If cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 6 	// Banco do Brasil
		//
		// CONVENIO 6 POSICOES
		//

		cConta	   := StrZero( val(cConta),8)
		cNosso     := _cConvenio + cNroDoc
		cDigNosso  := CALC_di9(cNosso)
		cCart      := cCart

		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		// campo livre
		cCampoL    := _cConvenio + cNroDoc + cAgencia + cConta + cCart

		// campo do digito verificador do codigo de barra
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		cDigBarra := CALC_5p( cLivre )

		// campo do codigo de barra
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

		// composicao da linha digitavel
		cParte1  := cBanco + cMoeda + Substr(_cConvenio,1,5)
		cDig1    := DIGIT001( cParte1 )
		cParte1  := cParte1 + cDig1

		cParte2  := SUBSTR(cCampoL,6,10)	//cNroDoc + cAgencia
		cDig2    := DIGIT001( cParte2 )
		cParte2  := cParte2 + cDig2

		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := DIGIT001( cParte3 )
		cParte3  := cParte3 + cDig3

		cParte4  := cDigBarra
		cParte5  := cFatorValor

		cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
			cParte4+" "+;
			cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)


	elseif cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 7
		//
		// CONVENIO 7 POSICOES
		//

		cNosso     := StrZero(Val(_cConvenio),7)+StrZero(Val(cNroDoc),10)
		cDigNosso  := CALC_di9(cNosso)
		cCart      := cCart

		// campo livre
		cCampoL    := StrZero(Val(_cConvenio),13)+strzero(Val(cNroDoc),10)+cCart

		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		// campo do digito verificador do codigo de barra
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		cDigBarra := CALC_5p( cLivre )

		// campo do codigo de barra
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda+Strzero(val(Substr(cBarra,4,1)),6)
		cDig1    := DIGIT001( cParte1 )

		cParte2  := SUBSTR(cCampoL,6,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
		cDig2    := DIGIT001( cParte2 )
		cParte2  := cParte2 + cDig2

		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := DIGIT001( cParte3 )
		cParte3  := cParte3 + cDig3

		cParte4  := cDigBarra
		cParte5  := cFatorValor

		cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
			cParte4+" "+;
			cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)

	ElseIf cBanco == '341' // Itau

		If cCart $ '126/131/146/150/168'
			cTexto := cCart + cNroDoc
		Else
			cTexto := cAgencia + cConta + cCart + cNroDoc
		EndIf

		cTexto2 := cAgencia + cConta

		cDigCC  := Modu10(cTexto2)

		cNosso    := cCart + '/' + cNroDoc + '-' + cDigNosso
		cCart     := cCart

		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		cValor:= StrZero(nValor * 100, 10)

	/* Calculo do codigo de barras */
		cCdBarra:= cBanco + cMoeda + cFatorValor + cCart + cNroDoc + cDigNosso +;
			cAgencia + cConta + cDigCC + "000"

		cDigCdBarra:= Modu11(cCdBarra,9)

		cCdBarra := Left(cCdBarra,4) + cDigCdBarra + Substr(cCdBarra,5,40)

	/* Calculo da representacao numerica */
//	cCampo1:= "341" + "9" + cCart + Substr(cNosso, 5, 2)
//	cCampo2:= Substr(cNosso, 7, 6) + Substr(cNosso, 14, 1) + Substr(cAgencia, 1, 3)
//	cCampo3:= Substr(cAgencia, 4, 1) + cConta + cDacCC + "000"
		cCampo1:= cBanco+cMoeda+Substr(cCdBarra,20,5)
		cCampo2:= Substr(cCdBarra,25,10)
		cCampo3:= Substr(cCdBarra,35,10)

		cCampo4:= Substr(cCdBarra, 5, 1)
		cCampo5:= cFatorValor

	/* Calculando os DACs dos campos 1, 2 e 3 */
		cCampo1:= cCampo1 + Modu10(cCampo1)
		cCampo2:= cCampo2 + Modu10(cCampo2)
		cCampo3:= cCampo3 + Modu10(cCampo3)

		cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
		cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
		cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
		cRepNum += cCampo4 + "  "
		cRepNum += cCampo5

		Aadd(aRet,cCdBarra)
		Aadd(aRet,cRepNum)
		Aadd(aRet,cNosso)

	ElseIf cBanco == '237' // Bradesco
		cNosso     := cCart + '/' + cNroDoc + '-' + cDigNosso

		// campo livre
		cCampoL    := cAgencia+cCart+cNroDoc+StrZero(Val(cConta),7)+'0'

		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		// campo do digito verificador do codigo de barra
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL

		cDigBarra := CALC_5p( cLivre )

		// campo do codigo de barra
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
		cDig1    :=  Modu10( cParte1 )
		cParte1  := cParte1 + cDig1

		cParte2  := SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
		cDig2    :=  Modu10( cParte2 )
		cParte2  := cParte2 + cDig2

		cParte3  := SUBSTR(cBarra,35,10)
		cDig3    :=  Modu10( cParte3 )
		cParte3  := cParte3 + cDig3

		cParte4  := cDigBarra
		cParte5  := cFatorValor

		cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
			cParte4+" "+;
			cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)

	ElseIf cBanco == '033' 	// Santander
		cNosso    := cNroDoc + '-' + cDigNosso

		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		cBarra := cBanco 										//Codigo do banco na camara de compensacao
		cBarra += cMoeda  										//Codigo da Moeda
		cBarra += Fator()						  	    		//Fator Vencimento
		cBarra += strzero(nValor*100,10)						//Strzero(Round(SE1->E1_SALDO,2)*100,10)		//Valor (ALTERADO PARA PEGAR O SALDO DO TITULO E NÃO O VALOR)
		cBarra += "9"                                           //Sistema - Fixo
		cBarra += _cConvenio									//Código Cedente
		cBarra += cNroDoc + cDigNosso							//Nosso numero
		cBarra += "0"											//IOS
		cBarra += _cCarteira					     			//Tipo de Cobrança

		cDigBarra := Modu11(cBarra)								//DAC codigo de barras

		cBarra := SubStr(cBarra,1,4) + cDigBarra + SubStr(cBarra,5,39)


		// composicao da linha digitavel  1 PARTE DE 1
		cParte1 := cBanco 		 				     	//Codigo do banco na camara de compensacao
		cParte1 += cMoeda								//Cod. Moeda
		cParte1 += "9"									//Fixo "9" conforme manual Santander
		cParte1 += Substr(_cConvenio,1,4)				//Código do Cedente (Posição 1 a 4)

		cDig1 := Substr(cParte1,1,9)                  //Pega variavel sem o '.'

		cParte1 += Modu10(cDig1)				  	    //Digito verificador do campo


		// composicao da linha digitavel 1 PARTE DE 2
		cParte2 := Substr(_cConvenio,5,3)			//Código do Cedente (Posição 5 a 7)
		cParte2 += Substr(cNroDoc + cDigNosso,1,7)			//Nosso Numero (Posição 1 a 7)

		cDig2 := Substr(cParte2,1,10)					//Pega variavel sem o '.'

		cParte2 += Modu10(cDig2)					    //Digito verificador do campo


		// composicao da linha digitavel 2 PARTE DE 1
		cParte3 := SubStr(cNroDoc + cDigNosso,8,6)  		//Nosso Numero (Posição 8 a 13)
		cParte3 +="0"									//IOS (Fixo "0")
		cParte3 +=_cCarteira							//Tipo Cobrança (101-Cobrança Simples Rápida Com Registro)

		cDig3 := Substr(cParte3,1,10) 			        //Pega variavel sem o '.'

		cParte3 += Modu10(cDig3)				     	//Digito verificador do campo


		// composicao da linha digitavel 4 PARTE
		cParte4 := SubStr(cBarra,5,1)				//Digito Verificador do Código de Barras


		// composicao da linha digitavel 5 PARTE
		cParte5 := Fator()							//Fator de vencimento
		cParte5 += strzero(nValor*100,10)			//Valor do titulo (Saldo no E1)

		cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
			cParte4+" "+cParte5


		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)


	ElseIf cBanco == '756' // Sicoob

		cConta	   := StrZero( val(cConta),8)
		cNosso    := cNroDoc + '-' + cDigNosso
		cCart      := cCart

		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
		Endif

		// campo livre
		//cCampoL    := Left(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(_cConvenio),7) + cNroDoc + cDigNosso + StrZero( Val(se1->e1_parcela),3)
		cCampoL    := Left(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(_cConvenio),7) + cNroDoc + cDigNosso + IIF( StrZero( Val(se1->e1_parcela),3) == "000", "001", StrZero( Val(se1->e1_parcela),3) )	// Gianluka Moraes

		// campo do digito verificador do codigo de barra
		cLivre := cBanco + cMoeda + cFatorValor + cCampoL
		cDigBarra := CALC_5p( cLivre )

		// campo do codigo de barra
		cBarra    := SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)

		// composicao da linha digitavel
		cParte1  := cBanco + cMoeda + Left(cCart,1) + cAgencia
		cDig1    := DIGIT001( cParte1 )
		cParte1  := cParte1 + cDig1

		cParte2  := Right(cCart,2) + StrZero( Val(see->ee_codemp), 7) +	Left(cNroDoc,1)
		cDig2    := DIGIT001( cParte2 )
		cParte2  := cParte2 + cDig2

//	cParte3  := Right(cNroDoc,6) + cDigNosso + 	StrZero( Val(se1->e1_parcela),3)
		cParte3  := Right(cNroDoc,6) + cDigNosso + IIF( StrZero( Val(se1->e1_parcela),3) == "000", "001", StrZero( Val(se1->e1_parcela),3) ) // Gianluka Moraes
		cDig3    := DIGIT001( cParte3 )		//DigitoLinhaDigitavel(cParte3)	//
		cParte3  := cParte3 + cDig3

		cParte4  := cDigBarra
		cParte5  := cFatorValor

		cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
			cParte4+" "+;
			cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)


	EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di9  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do banco do brasil             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_di9(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 9
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base == 1
			base := 9
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base - 1
		iDig   := iDig-1
	EndDo
	auxi := mod(Sumdig,11)
	If auxi == 10
		auxi := "X"
	Else
		auxi := str(auxi,1,0)
	EndIf
Return(auxi)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ Modulo11 ³ Autor ³ RAIMUNDO PEREIRA      ³ Data ³ 01/08/02 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Modulo11(cData)
	Local L, D, P := 0

	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End

	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)




/******************************************************************************************************************/
//CONVENIO COM 6 POSICOES BB
/******************************************************************************************************************/
Static Function Dig11BB(cData)
	Local Auxi := 0, sumdig := 0

	cbase  := cData
	lbase  := LEN(cBase)
	base   := 9	//7
	sumdig := 0
	Auxi   := 0
	iDig   := lBase

	while iDig >= 1
		If base == 1
			base := 9
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base - 1
		iDig   := iDig-1
	endDo

	auxi := mod(Sumdig,11)
	If auxi == 10
		auxi := "X"
	Else
		auxi := str(auxi,1,0)
	EndIf

Return(auxi)








/******************************************************************************************************************/
Static Function DigitoBB(cData)
	Local Auxi := 0, sumdig := 0
	cbase  := cData
	lbase  := LEN(cBase)
	base   := 9
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base == 1
			base := 9
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base - 1
		iDig   := iDig-1
	EndDo
	auxi := mod(Sumdig,11)
	If auxi == 10
		auxi := "X"
	Else
		auxi := str(auxi,1,0)
	EndIf

Return(auxi)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT001  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Banco do Brasil          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIGIT001(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	umdois := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		auxi   := Val(SubStr(cBase, idig, 1)) * umdois
		sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
		umdois := 3 - umdois
		iDig:=iDig-1
	EndDo
	cValor:=AllTrim(STR(sumdig,12))
	nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
	auxi := nDezena - sumdig

	If auxi >= 10
		auxi := 0
	EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Fator()
	Local cFator  As cString
	Local dBase   As Date
	Local dAux    As Date
	Local dVencto As Date


/*
If Len( AllTrim( DToS(TSE1->E1_VENCREA) ) ) == 8
	dVencto := TSE1->E1_VENCREA
Else
	dVencto := SToD( "20" + DToS(TSE1->E1_VENCREA) ) 
EndIf
*/
	dVencto :=  StoD(TSE1->E1_VENCREA)
	If dVencto < SToD("19971007")
		cFator := "0000"
	ElseIf dVencto < SToD("20000703")
		cFator := Str(dVencto-SToD("19971007"),4)
	Else
		dBase := SToD("20000703")
		While .T.
			dAux := dBase + 9000
			If dAux > dVencto
				cFator := STR(1000+(dVencto-dBase),4)
				Exit
			Else
				dBase := dAux
			EndIf
		End
	EndIf

Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_5p   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_5p(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base >= 10
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base + 1
		iDig   := iDig-1
	EndDo
	auxi := mod(sumdig,11)
	If auxi == 0 .or. auxi == 1 .or. auxi >= 10
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf
Return(str(auxi,1,0))


/******************************************************************************************************************/
/******************************************************************************************************************/
Static Function CdBarra_Itau()
/******************************************************************************************************************/
	Local cDigCdBarra
	Local cFatVencto:= ""
	Local cValor
	Local nValor
	Local cCampo1:= ""
	Local cCampo2:= ""
	Local cCampo3:= ""
	Local cCampo4:= ""
	Local cCampo5:= ""

	cFatVencto:= StrZero(FatVencto(SEE->EE_CODIGO), 4)
	nValor:= Valliq()
	cValor:= StrZero(nValor * 100, 10)

/* Calculo do codigo de barras */
	cCdBarra:= SEE->EE_CODIGO + "9" + cFatVencto + cValor + cCartEmp + Substr(cNossoNum, 5, 8) + Substr(cNossoNum, 14, 1) +;
		cAgeEmp + cCtaEmp + cDigEmp + "000"

	cDigCdBarra:= Modu11(cCdBarra,9)

	cCdBarra:= SEE->EE_CODIGO + "9" + cDigCdBarra + StrZero(FatVencto(SEE->EE_CODIGO), 4) + StrZero(Int(nValor * 100), 10) + cCartEmp + ;
		Substr(cNossoNum, 5, 8) + Substr(cNossoNum, 14, 1) + cAgeEmp + cCtaEmp + cDigEmp + "000"

/* Calculo da representacao numerica */
	cCampo1:= "341" + "9" + cCartEmp + Substr(cNossoNum, 5, 2)
	cCampo2:= Substr(cNossoNum, 7, 6) + Substr(cNossoNum, 14, 1) + Substr(cAgeEmp, 1, 3)
	cCampo3:= Substr(cAgeEmp, 4, 1) + cCtaEmp + cDigEmp + "000"
	cCampo4:= Substr(cCdBarra, 5, 1)
	cCampo5:= cFatVencto + cValor

/* Calculando os DACs dos campos 1, 2 e 3 */
	cCampo1:= cCampo1 + Modu10(cCampo1)
	cCampo2:= cCampo2 + Modu10(cCampo2)
	cCampo3:= cCampo3 + Modu10(cCampo3)

	cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
	cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
	cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
	cRepNum += cCampo4 + "  "
	cRepNum += cCampo5
Return


Static Function Modu10(cLinha)
/******************************************************************************************************************/
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local cDigRet
	Local nResult
	Local lDobra:= .f.
	Local cValor
	Local nAux

	For nCont:= Len(cLinha) To 1 Step -1
		lDobra:= !lDobra

		If lDobra
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1)) * 2))
		Else
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1))))
		EndIf

		For nAux:= 1 To Len(cValor)
			nSoma += Val(Substr(cValor, nAux, 1))
		Next n
	Next nCont

	nResto:= MOD(nSoma, 10)

	nResult:= 10 - nResto

	If nResult == 10
		cDigRet:= "0"
	Else
		cDigRet:= StrZero(10 - nResto, 1)
	EndIf
Return cDigRet


/******************************************************************************************************************/
Static Function Modu11(cLinha,cBase,cTipo)
/******************************************************************************************************************/
	Local cDigRet
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local nFator:= 9
	Local nResult
	Local _cBase := If( cBase = Nil , 9 , cBase )
	Local _cTipo := If( cTipo = Nil , '' , cTipo )
//alert(cLinha) 

	For nCont:= Len(cLinha) TO 1 Step -1
		nFator++
		If nFator > _cBase
			nFator:= 2
		EndIf

		nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
	Next nCont

	nResto:= Mod(nSoma, 11)

	nResult:= 11 - nResto

	If _cTipo = 'P'   // Bradesco
		If nResto == 0
			cDigRet:= "0"
		ElseIf  nResto == 1
			cDigRet:= "P"
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	Else
		If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
			cDigRet:= "1"
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	EndIf
Return cDigRet



	Static Procedure NrBordero()
	Local nBordero := ""
	Local aBanco := { {"001","B"}, {"237","R"},{"033","S"},{"756","C"},{"341","I"} }
	Local lFindSEA := .F.
	Local nPos := 0
	Local _nSEE := SuperGetMv ( "MV_XSEE", .F., 0 )

	SEE->( DbGoTo(_nSEE) )
	nPos := AScan ( aBanco, {|x| x[1] == SEE->EE_CODIGO } )

	if nPos == 0 .or. _nSEE == 0
		Return .F.
	ElseIf !Empty(SE1->E1_TITPAI) //Titulo de impostos não entra no bordero.
		Return .T.
	elseif !Empty(SE1->E1_PORTADO)
		//Verifia se tem bordero
		SEA->( dbSetOrder( 1 ) )
		lFindSEA := SEA->( DbSeek( xFilial( "SEA" )+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,.F. ) )
		If lFindSEA
			Return .T.
		EndIf
	endif

// X - Codigo Banco 
// XX - Ano Bordero
// X - Codigo Mes
// XX - Dias

	nBordero := aBanco[nPos,2] + StrZero( day( dDataBase ),2 ) + Upper(chr( 64+Month( dDataBase ) ) ) + Right( Str( Year( date() ),4 ), 2 )

//Posiciona na Agencia/Conta e Configuracoes bancarias
	SA6->( DbSeek( xFilial("SA6")+SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA) )

	RecLock("SE1")

	SE1->E1_PORTADO := SEE->EE_CODIGO
	SE1->E1_AGEDEP	:= SEE->EE_AGENCIA
	SE1->E1_CONTA	:= SEE->EE_CONTA
	SE1->E1_SITUACA	:= '1'
	SE1->E1_OCORREN	:= '01'
	SE1->E1_NUMBOR	:= M->nBordero
	SE1->E1_DATABOR	:= dDataBase

	SE1->( MsUnlock() )
	SE1->( DbCommit() )

//
//	Coloca o titulo no bordero
//
	SEA->( dbSetOrder( 1 ) )

	lFindSEA := SEA->( DbSeek( xFilial( "SEA" )+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,.F. ) )

	RecLock( "SEA",!lFindSEA )

	if !lFindSEA

		SEA->EA_FILIAL  := xFilial( "SEA" )
		SEA->EA_PREFIXO := SE1->E1_PREFIXO
		SEA->EA_NUM     := SE1->E1_NUM
		SEA->EA_PARCELA := SE1->E1_PARCELA
		SEA->EA_FILORIG := cFilAnt

	endif

	SEA->EA_NUMBOR  := SE1->E1_NUMBOR
	SEA->EA_TIPO    := SE1->E1_TIPO
	SEA->EA_CART    := "R"
	SEA->EA_PORTADO := SE1->E1_PORTADO
	SEA->EA_AGEDEP  := SE1->E1_AGEDEP
	SEA->EA_DATABOR := SE1->E1_DATABOR
	SEA->EA_NUMCON  := SE1->E1_CONTA
	SEA->EA_SITUACA := SE1->E1_SITUACA
	SEA->EA_TRANSF  := ' '
	SEA->EA_SITUANT := '0'
	SEA->EA_BORAPI  := 'S'
	SEA->EA_SUBCTA  := '001'
	SEA->EA_ESPECIE := '01'
	SEA->EA_ORIGEM  := 'FINA060'

	SEA->( msUnLock() )
	SEA->( dbCommit() )
Return .T.


Static Function BradMod11(NumBoleta)
	Local Modulo   := 11
	Local strmult  := "2765432765432"
	Local BaseDac  := M->NumBoleta  //Carteira + N Nro
	Local VarDac   := 0, idac := 0

// Calculo do numero bancario + digito e valor do juros

	For idac := 1 To 13
		VarDac := VarDac + Val(Subs(BaseDac, idac, 1)) * Val (Subs (strmult, idac, 1))
	Next idac

	VarDac  := Modulo - VarDac % Modulo
	VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))
Return VarDac



//
// Função para Colocar o Dígito no Código de Barras - SICOOB
//
Static Function DigBarSiCoob(CodigoBarra)
// Local Indice := '43290876543298765432987654329876543298765432'
	Local somax := 0, contador := 0, digito := 0

	for contador:=1 to 44

		if contador <> 5
			somax += ( val( Substr(CodigoBarra,contador,1) ) * Val( Substr(CodigoBarra,contador,1) ) )
			digito := 11 - Mod(SomaX,11)
		endif

		if (digito <= 1) .or. (digito > 9)
			digito := 1
		endif

	next contador

//Colocar o digito no codigo barra
//codigobarra[5] := inttostr(digito)[1];
return digito



//
// Função para Validação do Código de Barras - SICOOB
//
Static Function ValidaCodigoBarra(codigobarra)
	Local Indice := '43290876543298765432987654329876543298765432'
	Local somax := 0, contador := 0, digito := 0

	for contador:=1 to 44

		if contador <> 5
			somax += Val( Substr(codigobarra,contador,1) ) * Val( Substr(indice,contador,1) )
			digito := 11 - Mod(SomaX,11)
		endif

		if (digito <= 1) .or. (digito > 9)
			digito := 1
		endif

	next contador
Return digito


//
//Função para Definir o Próximo Múltiplo de 10 - SICOOB
//
Static Function Multiplo10(numero)
	Local result := 0

	while Mod(numero,10) <> 0
		numero += 1
		result := numero
	enddo
Return result


//   GIAN CONSERTA NOSSO BOLETO AÍ HOMI
//Função para Definir Digito Nosso Numero  - SICOOB
//
Static Function SiCoobMod11(NumBoleta)
	Local Modulo   := 11
	Local strmult  := "319731973197319731973"
//Local strmult  := "1973197319731973"
	Local BaseDac  := M->NumBoleta  //Carteira + N Nro
	Local VarDac   := 0, idac := 0

// Calculo do numero bancario + digito e valor do juros
	For idac := 1 To len(NumBoleta)
		VarDac += Val(Subs(BaseDac, idac, 1)) * Val (Subs (strmult, idac, 1))
	Next idac

	VarDac  := Modulo - VarDac % Modulo
	VarDac  := Iif (VarDac < 2 .or. VarDac >= 10, "0", Str(VarDac) )
Return VarDac


Static Function DigNNSicoob(cNNum,cCodEmp,cCodCoop,cParcela)
	Local cCoop   := cCodCoop
	Local cClie   := StrZero(Val(cCodEmp),10)
	Local nMod    := 11
	Local nSoma   := 0
	Local nI

	Default cNNum 	:= '0000001'
	Default cParcela:= '001'

	aCons := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3}


	cSeq := cCoop+cClie+cNNum
	For nI := 1 to Len(cSeq)
		nSoma += Val(SubStr(cSeq,nI,1))*aCons[nI]
	Next

	nDigit := (nSoma % nMod)
//cDigit := AllTrim(Str( iif( nDigit <= 1,0, iif(nDigit >= 10,1,nDigit)) ) )

	if nDigit <= 1
		cDigit := '0'
	else
		cDigit := AllTrim(Str(nMod - nDigit))
	endif

Return cDigit


//
// Função para Definir Linha Digital - SICOOB
//
Static Function DigitoLinhaDigitavel(linhadigitavel)
	Local Indice := '2121212120121212121201212121212'
	Local digito :=0, soma:=0, mult:=0, contador:=0
	Local codigobarra := ""
	Local nResult := ""

//cálculo do primeiro dígito
	soma := 0

	for contador := 10 to 1 Step -1

		mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
		if mult >= 10
			nResult := StrZero(mult,2)
			soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
		else
			soma += mult
		endif

	next contador

	digito := multiplo10(soma) - soma

//Coloca o primeiro digito na linha digitável
	linhadigitavel := Left(linhadigitavel,9) + Str(digito,1) + Substr(linhadigitavel,11,40)

//cálculo do segundo dígito
	soma := 0

	for contador:=11 to 20

		mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
		if mult >= 10
			nResult := StrZero(mult,2)
			soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
		else
			soma += mult
		endif

	next contador

	digito := multiplo10(soma) - soma

//Coloca o segundo digito na linha digitável
	linhadigitavel := Left( linhadigitavel,20) + Str(digito,1) + Substr(linhadigitavel,22,40)

//cálculo do terceiro dígito
	soma := 0

	for contador:=22 to 31

		mult := Val( Substr(linhadigitavel,contador,1) ) * Val( Substr(indice,contador,1) )
		if mult >= 10
			nResult := StrZero(mult,2)
			soma += Val( Left(nResult,1) ) + Val( Right(nResult,2) )
		else
			soma += mult
		endif

	next contador

//digito := multiplo10(soma) – soma

//Coloca o terceiro digito na linha digitável
	linhadigitavel := Left( linhadigitavel,31) + Str(digito,1) + Substr(linhadigitavel,33,40)

//Monta o codigo de barra para verificar o último dígito


	codigobarra := SubStr(linhadigitavel, 01, 03) //Código do Banco
	codigobarra += SubStr(linhadigitavel, 04, 01) //Moeda
	codigobarra += SubStr(linhadigitavel, 33, 01) //Digito Verificador
	codigobarra += SubStr(linhadigitavel, 34, 04) //fator de vencimento
	codigobarra += SubStr(linhadigitavel, 38, 10) //valor do documento
	codigobarra += SubStr(linhadigitavel, 05, 01) //Carteira
	codigobarra += SubStr(linhadigitavel, 06, 04) //Agencia
	codigobarra += SubStr(linhadigitavel, 11, 02) //Modalidade Cobranca
	codigobarra += SubStr(linhadigitavel, 13, 07) //Código do Cliente
	codigobarra += SubStr(linhadigitavel, 20, 01) + SubStr(linhadigitavel, 22, 7)//Nosso Numero
	codigobarra += SubStr(linhadigitavel, 29, 03) //Parcela

	codigobarra := DigitoCodigoBarra(codigobarra);
//Coloca o primeiro digito na linha digitável
		linhadigitavel := Left(linhadigitavel,32) + Substr(codigobarra,5,1) + Substr(linhadigitavel,32)
Return {linhadigitavel,codigobarra}




/******************************************************************************************************************/
//CONVENIO SANTANDER
/******************************************************************************************************************/
Static Function Dig11Santander(cData)
	Local cBase   := cData
	Local lBase   := Len(cBase)
	Local nAuxi   := 0
	Local nSumDig := 0
	Local nBase   := 2
	Local iDig

// cbase  := cData
// lbase  := Len(cBase)
// base   := 2

// sumdig := 0
// Auxi   := 0
// iDig   := lBase

	For iDig:=lBase To 1 Step -1

		If nBase == 9
			nBase := 2
		EndIf

		nAuxi   := Val(SubStr(cBase, iDig, 1)) * nBase
		nSumDig := nSumDig+nAuxi
		nBase   += 1

	Next iDig

	nAuxi := mod(nSumDig,11)
	If nAuxi == 10
		nAuxi := "1"
	ElseIf nAuxi == 1 .Or. nAuxi == 0
		nAuxi := "0"
	Else
		nAuxi := Str(11-nAuxi,1,0)
	EndIf

Return(nAuxi)


/*User Function SICOOBR(_nFuncao)

	Local nFuncao := _nFuncao
	Local cRet := ""    

	If nFuncao = 1
		cRet := IIF( StrZero( Val(SE1->E1_PARCELA),2) == "00", "01", StrZero( Val(SE1->E1_PARCELA),2) )
	EndIf

Return(cRet)*/
