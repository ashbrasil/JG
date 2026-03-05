#Include 'Protheus.ch'
#Include 'FWPrintSetup.ch'
#Include 'RPTDef.ch'
#Include 'TopConn.ch'

User Function JG05A004()
	Local aArea  := GetArea()
	Local cPedido  := SC5->C5_NUM
	Local cClient  := SC5->C5_CLIENTE
	Local cloja    := SC5->C5_LOJACLI
	Local cNota    := ""
	Local cSerie   := ""
	Local cAliasSD2 := GetNextAlias()
	Local cIdEnt	:= ""
	local cFil := SC5->C5_FILIAL
	Local aDanfe := {}
	Local cDirPDF := SuperGetMV('MV_RELT',,"\SPOOL\")
	Local i := 0
	Local cErro := ""
	local oDanfe := nil
	local oSetup := nil
	local aAttach := ""
	local lRet := .T.
	cQuery := " SELECT D2_FILIAL,D2_DOC, D2_SERIE FROM " + RetSqlName("SD2") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND D2_PEDIDO = '" + cPedido + "'"
	cQuery += " AND D2_FILIAL = '" + cFil + "'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasSD2)


	cNota   := (cAliasSD2)->D2_DOC
	cSerie  := (cAliasSD2)->D2_SERIE

	SF2->(DbSetOrder(1))
	SF2->(DbSeek(cFil+cNota+cSerie))

	cIdEnt := GetCfgEntidade(@cErro)
	cFilePrint := "JGDANFE_"+"_"+alltrim(cFil)+alltrim(cSerie)+"_"+alltrim(cNota)

	Pergunte("NFSIGW",.F.)

	SetMVValue("NFSIGW","MV_PAR01",cNota)
	SetMVValue("NFSIGW","MV_PAR02",cNota)
	SetMVValue("NFSIGW","MV_PAR03",cSerie)
	SetMVValue("NFSIGW","MV_PAR04",2)
	SetMVValue("NFSIGW","MV_PAR06",2)
	SetMVValue("NFSIGW","MV_PAR07",STOD('20000101'))
	SetMVValue("NFSIGW","MV_PAR08",STOD('20991231'))

	lAdjustToLegacy := .F.
	// F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
	oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy,cDirPDF, .T.) //alterado para tratamento automatico
	oDanfe:SetViewPDF(.F.)
	oDanfe:SetPortrait()
	oDanfe:nDevice := IMP_PDF
	oDanfe:cPathPDF := cDirPDF	//alterado para tratamento automatico
	oDanfe:lInJob := .T. 	//alterado para tratamento automatico
	oDanfe:lServer:=.T.		//alterado para tratamento automatico

	cSession := GetPrinterSession()
	fwWriteProfString( cSession, "LOCAL"      , "SERVER"	, .T. )
	fwWriteProfString( cSession, "PRINTTYPE"  , "SPOOL"		, .T. ) // "PDF"
	fwWriteProfString( cSession, "ORIENTATION", "PORTRAIT"  , .T. )

	oDanfe:setCopies( 1 )


	IIF(findfunction("u_PrtNfeSef"), u_PrtNfeSef(cIdEnt,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup,cFilePrint ,/*lIsLoja*/, /*nTipo*/ ),)

	// PrtNfeSef(cIdEnt,cVal1,cVal2,oDanfe,oSetup,cFilePrint,lIsLoja,nTipo,cNomDanfe,MV_PAR001,MV_PAR002,MV_PAR003,MV_PAR004,MV_PAR005,_aXML,_aNotas,_lImpSpool) //#Customizado.

	aFile := {}

	aDir(cDirPDF+"JGDANFE_*.PDF",aFile)

	If Len(aFile) == 0
		cMsgErro := "Erro na geracao do PDF."
		lRet := .F.
	EndIf
	aAttach := ""
	If lRet
		
		For i := 1 to Len(aFile)
			aAttach += cDirPDF+aFile[i]
		Next

		if File(Lower("\spool\boleto_bancario_"+cNota+".pdf"))
			lRet := .t.
			aAttach += ";\spool\boleto_bancario_"+cNota+".pdf"
		else
			u_JG05A002(cNota, cSerie, cClient, cLoja)
			if File(Lower("\spool\boleto_bancario_"+cNota+".pdf"))
				lRet := .t.
				aAttach += ";\spool\boleto_bancario_"+cNota+".pdf"
			else
				lRet := .f.
				cMsgErro:= "Boleto bancário não encontrado."
			endIf
		endIf

		// Envia E-mail com Boleto e Danfe
		if empty(aAttach)
			if !empty(cMsgErro)
				msgInfo(cMsgErro)
			else
				msgInfo("Nenhum arquivo para anexar.")
			endIf
		else
			cAssunto := "Envio de Danfe e Boleto - Pedido "+cPedido
			cCorpo := "Segue em anexo o Danfe e o Boleto referente ao Pedido "+cPedido
			cEmail  := POSICIONE("SA1",1, xFilial("SA1")+cClient,"A1_EMAIL")
			// cEmail := AllTrim("lucas.santos@ashbrasil.com")
			// lEnvio := u_FSENVM(cAssunto, cCorpo, cEmail,aAttach,cMailConta,cUsuario,cMailServer,cMailSenha,lMailAuth,lUseSSL,lUseTLS,cCopia,cCopiaOculta)
			lEnvio := u_FSENVM(cAssunto, cCorpo, cEmail,aAttach,,,,,,,,"","")
			if lEnvio
				msgInfo("E-mail enviado com sucesso.")
			else
				msgInfo("Falha ao enviar e-mail.")
			endIf
		endIf

		// For i := 1 to Len(aDanfe)
		// 	FErase(cDirPDF+aDanfe[i])
		// Next
	endIf
	restArea(aArea)
Return


	#Include 'Protheus.ch'
	#Include 'tbiconn.ch'
/*
{Protheus.doc} FSENVMAIL()
Envia email
@Author     Fernando Carvalho
@Since      16/08/2017
@Version    P12.7
@Project    Portal Protheus
@Param		 cAssunto
@Param		 cBody
@Param		 cEmail
*/
User Function FSENVM(cAssunto, cBody, cEmail,cAttach,cMailConta,cUsuario,cMailServer,cMailSenha,lMailAuth,lUseSSL,lUseTLS,cCopia,cCopiaOculta)
	Local nMailPort		:= 0
	Local nAt			:= ""
	Local lRet 			:= .T.
	Local oServer		:= TMailManager():New()
	// Local aAttach		:= {}
	Local nLoop			:= 0
	//Local cEmail		:= "ricardogaguiar@yahoo.com.br"  // para teste
	
	Default cAttach		:= ''
	Default cMailConta	:= SuperGetMV("MV_RELACNT",.F.)
	Default cUsuario	:= SubStr(cMailConta,1,At("@",cMailConta)-1)
	Default cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV",.F.))
	Default cMailSenha	:= SuperGetMV("MV_RELPSW",.F.)
	Default lMailAuth	:= SuperGetMV("MV_RELAUTH",.F.)
	Default lUseSSL		:= SuperGetMV("MV_RELSSL",.F.)
	Default lUseTLS		:= SuperGetMV("MV_RELTLS",.F.)

	
	nAt			:= At(":",cMailServer)
	
	oServer:SetUseSSL(lUseSSL)
	oServer:SetUseTLS(lUseTLS)
	
	
	// Tratamento para usar a porta quando informada no mailserver
	If nAt > 0
		nMailPort	:= VAL(SUBSTR(ALLTRIM(cMailServer),At(":",cMailServer) + 1,Len(ALLTRIM(cMailServer)) - nAt))
		cMailServer	:= SUBSTR(ALLTRIM(cMailServer),1,At(":",cMailServer)-1)
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	Else
		oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPort)
	EndIf
	
	If oServer:SMTPConnect() != 0
		lRet := .F.
	EndIf
	
	If lRet
		If lMailAuth
			
			//Tentar com conta e senha
			If oServer:SMTPAuth(cMailConta, cMailSenha) != 0
				
				//Tentar com usuário e senha
				If oServer:SMTPAuth(cUsuario, cMailSenha) != 0
					lRet := .F.
				EndIf
				
			EndIf
			
		EndIf
	EndIf
	
	If lRet
		
		oMessage				:= TMailMessage():New()
		
		oMessage:Clear()
		oMessage:cFrom		:= cMailConta
		oMessage:cTo			:= cEmail
		oMessage:cCc			:= cCopia
		oMessage:cBCC			:= cCopiaOculta
		oMessage:cSubject		:= cAssunto
		oMessage:cBody			:= cBody
		
		//oMessage:AttachFile( cAttach )
		aAttach	:= StrTokArr(cAttach, ';')
		
		For nLoop := 1 To Len(aAttach)
			oMessage:AttachFile( aAttach[nLoop] )
		Next
		//Envia o e-mail
		
		nErro := oMessage:Send( oServer )
  		If( nErro != 0 )
   			 conout( "Não enviou o e-mail.", oServer:GetErrorString( nErro ) )
    		Return
  		EndIf
		
	EndIf
	 
	//Desconecta do servidor
	oServer:SMTPDisconnect()
	
Return lRet
