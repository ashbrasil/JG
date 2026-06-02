#Include "Totvs.ch"
#Include "Fileio.ch"

/*/{Protheus.doc} JGATUPRE

    Atualização dos preços a partir do cadastro de produtos.

  @type  Function
  @author Jesus Ramos
  @since 01/06/2026
  @version 1.0
  @see (links_or_references)
  /*/
User Function JGATUPRE(cEmp, cFil)
	Local aArea       As Array
	Local aAreaSB1    As Array
    Local aTables     As Array
    Local lTodos      As Logical

	Private nStart    As Numeric
	Private cSemaforo As String
	Private cThreadID As String
	Private _MSG	  As CodeBlock

	aTables   := {'SB0','SB1','DA0','DA1'}
	nStart    := Seconds()
	cSemaforo := "JGATUPRE"//Semaforo de controle
	cThreadID := cValtoChar(ThreadID())

	Default cEmp := "01"
	Default cFil := "0101"

    If Select("SX2") == 0
        RpcClearEnv() 
		RPCSetType(3)  //Nao consome licensas
		If !RpcSetEnv( cEmp, cFil, Nil, Nil, "COM", "U_JGATUPRE", aTables )
			If IsBlind()
				FwLogMsg("INFO", cThreadID, "JGATUPRE", cSemaforo, "", "01", "FALHA AO INICIAR A FILIAL: "+cFil, 0, (nStart - Seconds()), {})
			EndIf
			Return()
		EndIf
		//Define o módulo
        SetModulo("SIGAFAT","FAT")
		//inicializa as variaveis publicas
		InitPublic()
        SetsDefault()
        SET DATE BRITISH
        SET CENTURY ON
    EndIf

    If !FWIsAdmin()
        If IsBlind()
            RpcClearEnv() 
        Else
            FWAlertInfo("Usuário sem permissão para executar esta rotina.","Permissão Negada")
        EndIf
        Return
    EndIf

    aArea    := FWGetArea()
    aAreaSB1 := SB1->(FWGetArea())

    If !IsBlind()
        If FWAlertNoYes(OemToAnsi("Deseja realmente atualizar os preços dos produtos?"+CRLF+CRLF+;
                        "Esta rotina realiza a atualização dos preços dos produtos nas tabelas de preços, a partir do preço de venda apontado no cadastro do produto."+CRLF+;
                        "Atualmente, são atualizadas as tabelas de preços do Atacado e do Varejo com o mesmo preço."),;
                        OemToAnsi("Confirmação"))

            lTodos := !FWAlertNoYes(OemToAnsi("Devo atualizar apenas o produto atualmente posicionado ou devo avaliar todos os produtos?"+CRLF+CRLF+;
                                    "Caso responda <b>SIM</b>, apenas o produto <b>"+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"</b> será avaliado."+CRLF+;
                                    "Caso responda <b>NÃO</b>, todos os produtos serão avaliados."),;
                                    OemToAnsi("Confirmação"))

            _MSG := {| cStr | IIf(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), ) } 
            FWMsgRun(, {|oSay| fProcPre(oSay, lTodos) }, "Processando...", "Aguarde, processando a rotina" ) 

            FWAlertSuccess("Processamento concluído com sucesso!", "Sucesso")
        Else
            FWAlertInfo("O usuário não confirmou o processamento!", "Não confirmado")
        EndIf

    Else

        _MSG := {| cStr | IIf(ValType(oSay)=="O", (oSay:cCaption := (cStr) , ProcessMessages()), ) } 
        fProcPre()

        RpcClearEnv() 

    EndIf

    FWRestArea(aAreaSB1)
    FWRestArea(aArea)

Return

/*/{Protheus.doc} fProcPre

    Processamento da atualização de preços.
    Pega B1_PRV1 e replica para B0_PRV1 e DA1_PRCVEN.

@type function
@version 1.0
@author Jesus Ramos
@since 01/06/2026
@param oSay, object, param_description
@return Nil
/*/
Static Function fProcPre(oSay, lTodos)

    Local nHndLog     As Numeric
    Local cHoraLog    As String
    Local cArqLog     As String
    Local nX

    Local lCriarSB0   As Logical

    Local cItem       As String
    Local cTabela     As String
    Local cProduto    As String
    Local cQry        As String
    Local nTotReg     As Numeric

    // Local bBlock      As Block

    Local aGerTXT   As Array
    Local aFilProc  As Array
    Local nFil      As Numeric

	// Private __cErr 	        As String //ErrorBlock

	Private lMsHelpAuto     As Logical  //Variavel de controle interno do ExecAuto
	Private lMsErroAuto     As Logical  //Variavel que informa a ocorrência de erros no ExecAuto
	Private lAutoErrNoFile  As Logical
	Private lFTStartSilenc  As Logical  //varivel para nao apresentar mensagem de erro em tela

    Default lTodos := .T.

    // bBlock    := ErrorBlock()
    aFilProc  := { "0101", "0103", "0104" }
    nX3CODPRO := TamSX3("DA1_CODPRO")[1]
    cTabela   := "001"
    cTabela   := PadR( Alltrim(cTabela), TamSX3("DA0_CODTAB")[1] )

	aGerTXT := {}
    _cErro  := ""

    Eval(_MSG,"Lendo o arquivo selecionado...")

	Eval(_MSG,"Coletando dados SQL...")
	cQry := "   SELECT B1_COD "+CRLF
	cQry += "   FROM "+RetSqlName("SB1")+" SB1 "+CRLF
	cQry += "   WHERE SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "       AND B1_FILIAL = "+ValToSql(FWxFilial("SB1"))+" "+CRLF
	cQry += "       AND B1_PRV1 > 0 "+CRLF
    If !lTodos
    cQry += "       AND B1_COD = "+ValToSql(SB1->B1_COD)+CRLF
    EndIf
	cQry += "   ORDER BY B1_COD "+CRLF

	cAliasTemp := MpSysOpenQuery( cQry )

	nTotReg := Contar(cAliasTemp,"!Eof()")
	nCont	:= 0
	(cAliasTemp)->(DbGoTop())

	If nTotReg = 0
        (cAliasTemp)->(DbCloseArea())
        If !IsBlind()
    		FWAlertInfo("Não foram encontrados registros para processamento.","Sem registros")
        EndIf
        Return
	EndIf

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD 

    DbSelectArea("SB0")
    SB0->(DbSetOrder(1)) // B0_FILIAL + B0_COD 

    DbSelectArea("DA0")
    DA0->(DbSetOrder(1)) //DA0_FILIAL, DA0_CODTAB, R_E_C_N_O_, D_E_L_E_T_

    DbSelectArea("DA1")
    DA1->(DbSetOrder(2)) //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM

    cFilBkp := cFilAnt

    For nFil:=1 to Len(aFilProc)

        cFilAnt := aFilProc[nFil]
    	FWSM0Util():setSM0PositionBycFilant()

    	(cAliasTemp)->(DbGoTop())

        While (cAliasTemp)->(!EOF())

            Eval(_MSG,"Filial: "+cFilAnt+" - Processando o produto "+AllTrim((cAliasTemp)->B1_COD)+"...")

            If SB1->(DbSeek(FWxFilial("SB1")+(cAliasTemp)->B1_COD))

                lCriarSB0 := !SB0->(DbSeek(FWxFilial("SB0")+SB1->B1_COD))

                If !lCriarSB0 .And. !SB0->(SimpleLock())
                    AAdd(aGerTXT, "O registro de preço do produto "+SB1->B1_COD+" - "+SB1->B1_DESC+" encontra-se bloqueado por outro usuário. O processamento continuará a partir do próximo produto do arquivo")
                Else
                    If !lCriarSB0
                        SB0->(MSRUnLock())
                        If SB0->B0_PRV1 <> SB1->B1_PRV1
                            If RecLock("SB0", .F.)
                                SB0->B0_PRV1 := SB1->B1_PRV1
                                SB0->(MsUnlock())
                            EndIf
                        EndIf
                    Else
                        If RecLock("SB0", .T.)
                            SB0->B0_FILIAL := FWxFilial("SB0")
                            SB0->B0_COD    := SB1->B1_COD
                            SB0->B0_PRV1   := SB1->B1_PRV1
                            SB0->(MsUnlock())
                        EndIf
                    EndIf

                    If SB1->B1_PRV1 > 0

                        cProduto := SB1->B1_COD

                        If DA0->(DbSeek( FWxFilial("DA0") + cTabela ))

                            DA1->(DbSetOrder(2)) //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
                            If DA1->( DbSeek(FWxFilial("DA1") + cProduto + cTabela ) )
                                If DA1->DA1_PRCVEN <> SB1->B1_PRV1
                                    RecLock("DA1", .F.)
                                        DA1->DA1_PRCVEN	:= SB1->B1_PRV1
                                    DA1->(MsUnlock())
                                EndIf
                                DA1->( DbSkip() )

                                While !DA1->( Eof() ) .And. DA1->DA1_FILIAL == FWxFilial("DA1") .And. DA1->DA1_CODTAB == cTabela .And. DA1->DA1_CODPRO == cProduto
                                    If RecLock("DA1", .F.)
                                        DA1->(DbDelete())
                                        DA1->(MsUnlock())
                                    EndIf
                                    DA1->(DbSkip())
                                EndDo
                            Else
                                // obtem o ultimo item
                                DA1->(DbSetOrder(3))	// DA1_FILIAL+DA1_CODTAB+DA1_ITEM
                                DA1->(DbSeek(FWxFilial("DA1") + cTabela + "ZZZZ", .T.))
                                DA1->(DbSkip(-1))

                                cItem := Soma1(DA1->DA1_ITEM)

                                RecLock("DA1", .T.)
                                    DA1->DA1_FILIAL	:= FWxFilial("DA1")
                                    DA1->DA1_CODTAB	:= cTabela
                                    DA1->DA1_ITEM	:= cItem
                                    DA1->DA1_CODPRO	:= cProduto
                                    DA1->DA1_ATIVO	:= "1"
                                    DA1->DA1_TPOPER	:= "4" // 1=Estadual;2=InterEstadual;3=Norte/Nordeste;4=Todos
                                    DA1->DA1_QTDLOT	:= 999999.99
                                    DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT, 18, 2)
                                    DA1->DA1_MOEDA	:= 1
                                    DA1->DA1_PRCVEN	:= SB1->B1_PRV1
                                DA1->(MsUnlock())

                            EndIf

                        EndIf

                    EndIf

                EndIf
            EndIf
            (cAliasTemp)->(DbSkip())
        EndDo

        If Len(aGerTXT) > 0

            Eval(_MSG, "Filial: "+cFilAnt+" - Gerando o log do processamento...")

            cHoraLog := Time()
            cArqLog  := "c:\temp\JGATUPRE_"  + cEmpAnt +"_" + cFilAnt + "_" + DtoS(dDataBase) + '_' + SubStr(cHoraLog,1,2) + SubStr(cHoraLog,4,2) + ".TXT" 
        
            nHndLog := FCreate( cArqLog , FC_NORMAL )

            If fError() # 0
                Conout("ERRO AO CRIAR O ARQUIVO, ERRO: " + Str(fError()))
            Else
                For nX := 1 to Len( aGerTXT )
                    FWrite(nHndLog, aGerTXT[nX] + CRLF )
                    If fError() # 0
                        Conout("ERRO AO CRIAR O ARQUIVO, ERRO: " + Str(fError()))
                    EndIf
                Next nX
            EndIf

            FClose( nHndLog )
            ASize(aGerTXT, 0 )

        EndIf

    Next nFil

    (cAliasTemp)->(DbCloseArea())

    cFilAnt := cFilBkp
    FWSM0Util():setSM0PositionBycFilant()

Return
