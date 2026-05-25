#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} User Function JGRT012

    Job
    Rotina responsável por processar rotinas automáticas das notas fiscais de transferência.
    A rotina fica sempre ativa quando o xIntervalo é maior que ZERO, dispara um job secundário somente para filiais que têm registros a processar

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
// User Function JGRT012(aParam)
User Function JGRT012(uParam, _cFiliais, xIntervalo)

    Local cFil          := "" 
    Local aFilial       := {}  
    Local cSemaforo     := ""
    Local cIdSemaforo   := "JGRT012"    //Identificação do Semaforo para controle do Job no Monitor.
    Local nSleep	    := 0            // Utilizado para atribuicao na variavel xIntervalo
    Local cAliasProc 	:= ""
    Local cQry          := ""
    Local dDtStart      := Date()
    Local bBlock        := Nil
    Local cListaFil     := ""
    Local aFilProc      := {}
    Local nA

	Local cEmp	        := ""
    Local cListFil      := ""
    Local lOriSched     := .T.

    Private __cErr 	 	:= "" //ErrorBlock
    Private __cStack 	:= "" //ErrorBlock

    // Default _cFiliais   := ""
    // Default xIntervalo  := 30 // Intervalo para o Loop(Em segundos) -> Conteudo do terceiro parametro (Parm3 do appserver.ini)

    // Realiza o bloqueio de um identificador Semaforo.
    If !GlbNmLock(cIdSemaforo)
        Return()
    EndIf

    If ValType(uParam) == "A" .And. Len(uParam) >= 2 .And. _cFiliais = Nil .And. xIntervalo = Nil
        cEmp := uParam[1]
        cListFil := uParam[2]
        xIntervalo := 30
        lOriSched := .T.

        U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] - Parâmetros: "+;
                    VarInfo("Array uParam", uParam))

    Else
        cEmp := uParam
        cListFil := _cFiliais
        If xIntervalo = Nil
            xIntervalo := 30
        EndIf
        lOriSched := .F.

        U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] - Parâmetros: "+;
                    "Assinatura da função: uParam: " + uParam + ", _cFiliais: " + _cFiliais + ", xIntervalo: " + IIf(ValType(xIntervalo)=="N", cValToChar(xIntervalo), xIntervalo) )

    EndIf

    If Empty(cEmp)
        U_FLOGJG("Informe o parametro >>parm1=01<< com a empresa de uso!")
        GlbNmUnlock(cIdSemaforo)
        Return()  
    EndIf

    If Empty(cListFil)
        U_FLOGJG("Informe o parametro >>parm2=0101,0102<< da lista das filiais de uso!")
        GlbNmUnlock(cIdSemaforo)
        Return()
    EndIf

    //Tratamento caso o terceiro parametro seja passado ou nao
    If !(ValType(xIntervalo) == "N")
        nSleep := Val(xIntervalo)
    Else
        nSleep := xIntervalo
    Endif

    //Converte o intervalo de segundos para Milissegundo, função Sleep() trabalha em Milissegundo
    nSleep := nSleep*1000

    aFilial := StrTokArr2( Alltrim(cListFil), "," )

    If Len(aFilial)==0
        U_FLOGJG("Informe o parametro >>parm2=0101,0102<< da lista das filiais de uso!")
        GlbNmUnlock(cIdSemaforo)
        Return()
    EndIf

    cFil := aFilial[1]
    cListaFil := FormatIn(Alltrim(cListFil),",")

    U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] - Parâmetros: "+;
            "cEmp: "+IIf(ValType(cEmp)=="C",cEmp,"Null")+;
            ", cListFil: "+IIf(ValType(cListFil)=="C",cListFil,"Null")+;
            ", cListaFil: "+IIf(ValType(cListaFil)=="C",cListaFil,"Null")+;
            ", cFil: "+IIf(ValType(cFil)=="C",cFil,"Null")+;
            ", xIntervalo: "+IIf(ValType(xIntervalo)=="C",xIntervalo,IIf(ValType(xIntervalo)=="N",cValToChar(xIntervalo),"Null"))+" segundos." )

    If IsBlind()
        RPCSetType(3) //Nao consome licenca 
        If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT", "U_JGRT012", {'SC6','SC5','SL1'} )
            U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
            GlbNmUnlock(cIdSemaforo)
            Return()
        EndIf
        //inicializa as variaveis publicas
        InitPublic()
    Else
        cEmpAnt := cEmp
        cFilAnt := cFil
        U_JGRT11_F()
    EndIf

    If lOriSched
        cListFil := GetNewPar("JG_FILTRFA","")

        U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] - Parâmetros: "+;
                "cEmp: "+IIf(ValType(cEmp)=="C",cEmp,"Null")+;
                ", cListFil: "+IIf(ValType(cListFil)=="C",cListFil,"Null") )

        If Empty(cListFil)
            U_FLOGJG("Configure o parâmetro JG_FILTRFA com a lista das filiais para processamento das transferências!")
            GlbNmUnlock(cIdSemaforo)
            Return()
        EndIf

        aFilial := StrTokArr2( Alltrim(cListFil), "," )

        If Len(aFilial)==0
            U_FLOGJG("Configure o parâmetro JG_FILTRFA com a lista das filiais para processamento das transferências!")
            GlbNmUnlock(cIdSemaforo)
            Return()
        EndIf

        cListaFil := FormatIn(Alltrim(cListFil),",")
    EndIf

    bBlock := ErrorBlock() 

    BEGIN SEQUENCE

        ErrorBlock( { |oError| __cErr:=oError:Description , __cStack:=oError:ErrorStack , Break(oError) } )

        While !KillApp()

            //Quando mudar a data o Job finaliza, evita que a rotina rode mais de um dia com a mesma Thread.
            If dDtStart<>Date()
                U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] FINALIZADA COM A MUDANCA DE DATA" )
                Exit
            EndIf

            If IsBlind()
                FWMonitorMsg( 'JOB( ' + cIdSemaforo + ' ) - *STARTED '+TIME() )	// Imprime no monitor a Identificacao da Thread          
            Else
                U_FLOGJG( 'JOB( ' + cIdSemaforo + ' ) - *STARTED '+TIME() )
            EndIf

            //Rotina específica para a transferência imediata da Matriz para a filial 0104.
            //Processa os orçamentos com status JGTrOrIni (Transferência iniciada), 
            //  gerando o pedido de venda e ajustando o orçamento para JGTrOrPPF (Pedido de Venda Pendente de Faturamento).

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     L1_XFILTRF AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SL1")+" SL1 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SL1.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND L1_XFILTRF IN "+cListaFil+" " + CRLF
            // cQry += "     AND L1_FILIAL  IN "+cListaFil+" " + CRLF
            // cQry += "     AND L1_XFILTRF = '0101' " + CRLF
            cQry += "     AND L1_XPEDTRF = ' ' " + CRLF
            cQry += "     AND L1_XMOVTRF = "+ValToSql(JGTrOrIni)+" " + CRLF
            cQry += "     AND L1_DOC = ' ' " + CRLF

            cQry += "     AND NOT EXISTS(" + CRLF
            cQry += "         SELECT DISTINCT " + CRLF
            cQry += "             1 " + CRLF
            cQry += "         FROM " + CRLF
            cQry += "             "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += "         WHERE " + CRLF
            cQry += "             SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "             AND C5_FILIAL = L1_XFILTRF AND C5_XFILTRF = L1_FILIAL AND C5_XORCTRF = L1_NUM AND C5_XMOVTRF <> ' ' " + CRLF
            cQry += "     ) " + CRLF

            cQry += " ORDER BY " + CRLF
            cQry += "     L1_XFILTRF " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT012A_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT012A", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT012A( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            //[Melhoria de Performance] Executa somente para filiais que tem registros a processar
            //Processa os pedidos com status JGTrPVPSp  (Pedido de Venda Pendente de Separação),
            //  ajustando o pedido para JGTrPVPFt (Pedido de Venda Pendente de Faturamento), caso a separação já tenha sido finalizada.

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     C5_FILIAL AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND C5_FILIAL IN "+cListaFil+" " + CRLF
            cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPSp)+" " + CRLF
            cQry += "     AND C5_NOTA = ' ' " + CRLF
            cQry += " ORDER BY " + CRLF
            cQry += "     C5_FILIAL " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT012B_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT012B", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT012B( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            //[Melhoria de Performance] Executa somente para filiais que tem registros a processar
            //Processa os pedidos com status JGTrPVPFt (Pedido de Venda Pendente de Faturamento), 
            //  preparando o documento de saída e alterando o pedido para JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização).

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     C5_FILIAL AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND C5_FILIAL IN "+cListaFil+" " + CRLF
            cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPFt)+" " + CRLF
            cQry += "     AND C5_NOTA = ' ' " + CRLF
            cQry += " ORDER BY " + CRLF
            cQry += "     C5_FILIAL " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT12C1_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT12C1", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT12C1( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            //[Melhoria de Performance] Executa somente para filiais que tem registros a processar
            //Processa os pedidos com status JGTrPVPFt (Pedido de Venda Pendente de Faturamento), 
            //  mas que já estejam faturados e com status ATRASADO.
            //  Será realizada apenas a atualização do status.

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     C5_FILIAL AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND C5_FILIAL IN "+cListaFil+" " + CRLF
            cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPFt)+" " + CRLF
            cQry += "     AND C5_NOTA <> ' ' " + CRLF
            cQry += " ORDER BY " + CRLF
            cQry += "     C5_FILIAL " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT12C2_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT12C2", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT12C2( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            //[Melhoria de Performance] Executa somente para filiais que tem registros a processar
            //Processa os pedidos com status JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização), 
            //  atualizando o status da NFe caso tenha mudado e alterando o pedido para JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante).

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     C5_FILIAL AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND C5_FILIAL IN "+cListaFil+" " + CRLF
            cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVNPA)+" " + CRLF
            cQry += "     AND C5_NOTA <> ' ' " + CRLF
            cQry += " ORDER BY " + CRLF
            cQry += "     C5_FILIAL " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT012D_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT012D", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT012D( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            //[Melhoria de Performance] Executa somente para filiais que tem registros a processar
            //Processa os pedidos com status JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante), 
            //  efetuando a entrada na filial de destino e alterando o pedido para JGTrPVOK (Transferência Concluída).

            cQry := " SELECT DISTINCT " + CRLF
            cQry += "     C5_FILIAL AS FILIAL " + CRLF
            cQry += " FROM " + CRLF
            cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
            cQry += " WHERE " + CRLF
            cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
            cQry += "     AND C5_FILIAL IN "+cListaFil+" " + CRLF
            cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVNPE)+" " + CRLF
            cQry += "     AND C5_NOTA <> ' ' " + CRLF
            cQry += " ORDER BY " + CRLF
            cQry += "     C5_FILIAL " + CRLF

            cAliasProc := MPSysOpenQuery( cQry )

            aFilProc := {}
            While (cAliasProc)->(!Eof())
                AAdd( aFilProc, { (cAliasProc)->FILIAL } )
                (cAliasProc)->(DbSkip())
            EndDo
            (cAliasProc)->(DbCloseArea())

            For nA:=1 To Len(aFilProc)

                cSemaforo := "JGRT012E_"+aFilProc[nA][1]
                If GlbNmLock(cSemaforo) //Verifica se o identificador Semaforo esta em uso.
                    GlbNmUnlock(cSemaforo) //Libera o bloqueio o identificador Semaforo para uso do job
                    If IsBlind()
                        StartJob( "U_JGRT012E", GetEnvServer(), .F., { cEmp, aFilProc[nA][1], cSemaforo } )
                    Else
                        U_JGRT012E( { cEmp, aFilProc[nA][1], cSemaforo } )
                    EndIf
                EndIf

            Next nA

            If nSleep > 0
                If IsBlind()
                    FWMonitorMsg( 'JOB(' + cIdSemaforo + ') - *STANDBY '+TIME() )	// Imprime no monitor a Identificacao da Thread
                Else
                    U_FLOGJG( 'JOB(' + cIdSemaforo + ') - *STANDBY '+TIME() )	// Imprime no monitor a Identificacao da Thread
                EndIf
                Sleep(nSleep) // Quantidade de milissegundos no qual a thread irá ficar sem executar.
            Else
                //U_FLOGJG("JOB#" + cIdSemaforo + "# Thread ["+cValToChar(ThreadID())+"] FINALIZADA(Sem Sleep)." )
                Exit
            EndIf        

        End
    
        ErrorBlock(bBlock)

    RECOVER
        //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
        //fluxo de execução será desviado após a execução de um comando BREAK.

        U_FLOGJG('O seguinte erro ocorreu: ' + __cErr+__cStack)

        U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cIdSemaforo + ' )' )

        ErrorBlock(bBlock)

    END SEQUENCE  

    If IsBlind()
        RpcClearEnv()   //Libera o Ambiente
    EndIf

    GlbNmUnlock(cIdSemaforo) //Libera o bloqueio o identificador Semaforo para uso

Return


/*/{Protheus.doc} User Function JGRT012A

    Job
    Rotina específica para a transferência imediata da Matriz para a filial 0104.
    Processa os orçamentos com status JGTrOrIni (Transferência iniciada), 
        gerando o pedido de venda e ajustando o orçamento para JGTrOrPPF (Pedido de Venda Pendente de Faturamento).

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
User Function JGRT012A( aParams )
Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSL1     := 0

// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT012A["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT012A["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT012A", {'SC5','SC6','SL1'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT " + CRLF
    cQry += "     L1_XFILTRF, L1_FILIAL, L1_NUM, L1_XMOVTRF " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SL1")+" SL1 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SL1.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND L1_XFILTRF = "+ValToSql(cFilAnt)+" " + CRLF
    cQry += "     AND L1_XPEDTRF = ' ' " + CRLF
    cQry += "     AND L1_XMOVTRF = "+ValToSql(JGTrOrIni)+" " + CRLF
    cQry += "     AND L1_DOC = ' ' " + CRLF

    cQry += "     AND NOT EXISTS(" + CRLF
    cQry += "         SELECT DISTINCT " + CRLF
    cQry += "             1 " + CRLF
    cQry += "         FROM " + CRLF
    cQry += "             "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += "         WHERE " + CRLF
    cQry += "             SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "             AND C5_FILIAL = L1_XFILTRF AND C5_XFILTRF = L1_FILIAL AND C5_XORCTRF = L1_NUM AND C5_XMOVTRF <> ' ' " + CRLF
    cQry += "     ) " + CRLF

    cQry += " ORDER BY " + CRLF
    cQry += "     L1_FILIAL, L1_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SL1->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        If SL1->(dbseek( (cAliasProc)->L1_FILIAL + (cAliasProc)->L1_NUM ) )

            If Alltrim(SL1->L1_XMOVTRF) <> Alltrim((cAliasProc)->L1_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSL1 := SL1->(Recno())

            If SoftLock("SL1") //Evitar de 2 usuários tentar executar no mesmo tempo

                cIdMov  := "["+(cAliasProc)->L1_XFILTRF +"-"+ (cAliasProc)->L1_FILIAL +"-"+ (cAliasProc)->L1_NUM +"]"
                
                U_FLOGJG(cIdMov+" Antes U_JGRT012A1 - Gera Pedido de Venda VAREJO"+" Time:"+TIME())

                U_JGRT12A1()

                U_FLOGJG(cIdMov+" Depois U_JGRT012A1 - Gera Pedido de Venda VAREJO"+" Time:"+TIME())

                If IsLocked("SL1", SL1->(Recno()))
                    SL1->(MsrUnlock()) //Libera o SoftLock
                EndIf

            EndIf

            nRecnoSL1 := 0

        ENDIF  

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())  

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.
    
    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSL1, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT012A["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}

/*/{Protheus.doc} U_JGRT12A1
description
    Rotina para processar o orçamento do Venda Assistida e preparar as informações para geração do pedido de venda de transferência, 
    chamada pela função U_JGRT012A, que é responsável por processar os orçamentos com status JGTrOrIni (Transferência iniciada), 
    gerando o pedido de venda e ajustando o orçamento para JGTrOrPPS (Pedido de Venda de transferência gerado).

@type function
@version 1.0 
@author Jesus Ramos
@since 09/03/2026
@return variant, return_description
/*/
User Function JGRT12A1()

	Local lGera 	 := .T.
	Local cMsg 		 := ""
	// Local nQuant 	:= 0
	Local aDoc
	Local aSC5 		 := {}
	Local aSC6 		 := {}
    Local aLinha     := {}
    Local cQry       := ""
    Local cPedDoOrc  := ""
	// Local x

	Local _cFilO 	 := SL1->L1_XFILTRF
	Local _cFilD	 := SL1->L1_FILIAL
	Local _cCliente  := Space(TamSx3("C5_CLIENTE")[1] + TamSx3("C5_LOJACLI")[1])
	Local _cFornec	 := Space(TamSx3("F1_FORNECE")[1] + TamSx3("F1_LOJA")[1])
	Local cARMF		 := "01"
	Local cARMO 	 := "01"
	Local cARMD 	 := "01"
    Local cTes       := ""
    Local nCusto     := 0
    Local cProduto   := ""
    Local cObser     := ""
    Local cSolicit   := "Varejo: "+SL1->L1_FILIAL+"-"+SL1->L1_NUM
    Local nRecnoSL1  := SL1->(Recno())

    ValidFil(@_cFilO, _cFilD, "O")
    ValidFil(@_cFilD, _cFilO, "D")

    If Empty(_cFilO) .Or. Empty(_cFilD)
        Return(.F.)
    EndIf

    fCliFor("F", _cFilO, @_cFornec)
    fCliFor("C", _cFilD, @_cCliente)

	// If cFilAnt <> _cFilO
		// cFilAnt := _cFilO
		U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL
	// EndIf

    DbSelectArea("SL2")
    SL2->(DbSetOrder(1))
    If !(SL2->(DbSeek(SL1->(L1_FILIAL+L1_NUM))) .And. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM))
        Return(.F.)
    EndIf

    //Montagem do Array contendo os campos e valores do cabeçalho (SC5) para ExecAuto MATA410
    aSC5 := {}

    aAdd(aSC5, {"C5_TIPO"			, "N"					, Nil} )
    aAdd(aSC5, {"C5_CLIENTE"		, Substr(_cCliente,1,6)	, Nil} )
    aAdd(aSC5, {"C5_LOJACLI"		, Substr(_cCliente,7,4)	, Nil} )
    aAdd(aSC5, {"C5_CONDPAG"		, "001"					, Nil} )
    Aadd(aSC5, {"C5_XFILTRF"        , SL1->L1_FILIAL        , Nil} )
    Aadd(aSC5, {"C5_XORCTRF"        , SL1->L1_NUM           , Nil} )
    Aadd(aSC5, {"C5_XLOCDES"        , cARMD                 , Nil} )
    Aadd(aSC5, {"C5_XLOCFIN"        , cARMF                 , Nil} )

	//Monta o Array contendo os campos dos itens (SC6) para ExecAuto MATA410
    aSC6 := {}

	While SL2->(!Eof()) .And. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM)

        cProduto := SL2->L2_PRODUTO
        nCusto   := ROUND(Posicione("SB2", 1, FWxFilial("SB2") + cProduto + cARMO, "B2_CM1"), 2)

        If nCusto = 0
            nCusto := ROUND(Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_CUSTD"), 2)
            If nCusto = 0
                nCusto := ROUND(Posicione("SB1", 1, FWxFilial("SB1") + cProduto, "B1_PRV1"), 2)
            EndIf
        EndIf

        cTes := MaTesInt(	2, ;
                            '04', ;
                            Substr(_cCliente,1,6), ;
                            Substr(_cCliente,7,4), ;
                            "C", ;
                            cProduto ;
                        )

        aLinha := {}

        Aadd(aLinha, { "C6_ITEM"    , SL2->L2_ITEM      , Nil} )
        Aadd(aLinha, { "C6_PRODUTO" , SL2->L2_PRODUTO   , Nil} )
        Aadd(aLinha, { "C6_QTDVEN"  , SL2->L2_QUANT     , Nil} )
        Aadd(aLinha, { "C6_QTDLIB"  , SL2->L2_QUANT     , Nil} )
        Aadd(aLinha, { "C6_PRCVEN"  , nCusto            , Nil} )
        Aadd(aLinha, { "C6_PRUNIT"  , 0                 , Nil} )
        Aadd(aLinha, { "C6_LOCAL"   , cARMO             , Nil} )
        Aadd(aLinha, { "C6_TES"     , cTes              , Nil} )
        Aadd(aLinha, { "C6_LOTECTL" , SL2->L2_LOTECTL   , Nil} )
        Aadd(aLinha, { "C6_NUMLOTE" , SL2->L2_NLOTE     , Nil} )
        Aadd(aLinha, { "C6_DTVALID" , SL2->L2_DTVALID   , Nil} )

        AAdd(aSC6, aLinha)

        SL2->(DbSkip())

	EndDo

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

	// If Empty(_cFilO)
	// 	lGera := .f.
	// 	cMsg += ">>O Cliente da filial do origem não foi informado!"+Chr(13)+Chr(10)
	// EndIf
	// If Empty(_cCliente)
	// 	lGera := .f.
	// 	cMsg += ">>O Cliente da filial do origem não foi informado!"+Chr(13)+Chr(10)
	// EndIf
	// If Empty(cARMO)
	// 	lGera := .f.
	// 	cMsg += ">>O Armazem de origem não foi informado!"+Chr(13)+Chr(10)
	// EndIf
	// If Empty(cARMD)
	// 	lGera := .f.
	// 	cMsg += ">>O Armazem de destino não foi informado!"+Chr(13)+Chr(10)
	// EndIf
	// If Empty(cARMF)
	// 	lGera := .f.
	// 	cMsg += ">>O Armazem FINAL para liberação não foi informado!"+Chr(13)+Chr(10)	
	// EndIf
	// If Empty(cSolicit)
	// 	lGera := .f.
	// 	cMsg += ">>Informe o Solicitante da Transferência!"+Chr(13)+Chr(10)
	// EndIf
	// If Len(aHeader) = 0
	// 	lGera := .f.
	// EndIf
	// If Len(aCols) = 0
	// 	lGera := .f.
	// 	aCols := aColsAx
	// 	cMsg += ">>Não a itens para gerar a Transferência!"+Chr(13)+Chr(10)
	// EndIf

    cQry := " SELECT DISTINCT " + CRLF
    cQry += "     C5_NUM AS PEDIDO " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL = "+ValToSql(SL1->L1_XFILTRF)+" AND C5_XFILTRF = "+ValToSql(SL1->L1_FILIAL)+" AND C5_XORCTRF = "+ValToSql(SL1->L1_NUM)+" AND C5_XMOVTRF <> ' ' " + CRLF

    cPedDoOrc := MpSysExecScalar(cQry, "PEDIDO")

    If !Empty(cPedDoOrc)
        lGera := .F.
        cMsg += "Já existe o pedido de transferência de número "+cPedDoOrc+" vinculado este orçamento!"+CRLF
    EndIf

	If lGera

        cObser += CRLF+"Solicitante: "+cSolicit
        cObser += CRLF+"Usuario: "+Upper(cUserName)

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³                 		            Gera Pedido         					  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

        aDoc := U_JGRT011B( 0, _cCliente, cARMO, cARMD, cObser, aSC5, aSC6 )
        MsUnLockAll()

        If cFilAnt <> _cFilO
            // cFilAnt := _cFilO
            U_JGRT11_F(_cFilO) //Ajuste cFilAnt <> M0_CODFIL
        EndIf

        If Len(aDoc) >= 6
            If !Empty(aDoc[4])
                If RecLock("SL1", .F.)
                    SL1->L1_XPEDTRF := aDoc[4] //Atualiza o número do pedido de transferência no campo L1_XPEDTRF para controle
                    SL1->(MsUnlock())
                EndIf
                U_JGRT11_E(aDoc[5], JGTrPVPFt, JGTrOrPPF)//Grava Status no Pedido
            ElseIf !Empty(aDoc[6])
                cMsg += aDoc[6]
            EndIf
        Else
            cMsg := "Ocorreu alguma falha sistêmica na tentativa de gerar o pedido de venda de transferência."
        EndIf

        // /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        // ³                 		Envia e valida nfe no sefaz				              ³
        // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        // FWMsgRun(, {|oSay| lGeraNfe := U_RFATA25D(@oSay,aDoc[1],aDoc[2],"1") }, "Processando - Nota de Saida NFESEFAZ", "Aguarde, processando a rotina" )
        // MsUnLockAll()
        // U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

        // /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        // ³                 Gera Nota Fiscal de entrada na filial de destino			     ³
        // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        // If !Empty(aDoc[1]) .And. lGeraNfe
        // 	U_RFATA25C(aDoc[1],aDoc[2],DtoS(dDataBase))
        // EndIf

	Else

        If IsBlind()
		    U_FLOGJG(OemToAnsi(cMsg))
        Else
    		FWAlertWarning(OemToAnsi(cMsg), OemToAnsi("Atenção"))
        EndIf

	EndIf

    If !Empty(cMsg)
        U_JGRT11_D("O", nRecnoSL1, cMsg)//Grava Log de Erro
    EndIf

	U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

Return lGera


/*/{Protheus.doc} User Function JGRT012B

    Job
    Processa os pedidos com status JGTrPVPSp (Pedido de Venda Pendente de Separação), 
     ajustando o pedido para JGTrPVPFt (Pedido de Venda Pendente de Faturamento), caso a separação já tenha sido finalizada.

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
User Function JGRT012B( aParams )
Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSC5     := 0

// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT012B["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT012B["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT012B", {'SC5','SC6'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT DISTINCT " + CRLF
    cQry += "     C5_FILIAL, C5_NUM, C5_XMOVTRF, " + CRLF
    cQry += "     COALESCE( (   SELECT " + CRLF
    cQry += "                       COUNT(*) " + CRLF
    cQry += "                   FROM " + CRLF
    cQry += "                       "+RetSqlName("SC6")+" SC6 " + CRLF
    cQry += "                   WHERE " + CRLF
    cQry += "                       SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM " + CRLF
    cQry += "     ), 0) AS NRITENS, " + CRLF
    cQry += "     COALESCE( (   SELECT " + CRLF
    cQry += "                       COUNT(*) " + CRLF
    cQry += "                   FROM " + CRLF
    cQry += "                       "+RetSqlName("SC6")+" SC6 " + CRLF
    cQry += "                   WHERE " + CRLF
    cQry += "                       SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM " + CRLF
    cQry += "                       AND NOT EXISTS(" + CRLF
    cQry += "                           SELECT DISTINCT " + CRLF
    cQry += "                               1 " + CRLF
    cQry += "                           FROM " + CRLF
    cQry += "                               "+RetSqlName("CB8")+" CB8 " + CRLF
    cQry += "                               INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "                                   AND CB7.CB7_FILIAL = CB8.CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7.CB7_PEDIDO = CB8.CB8_PEDIDO AND CB7.CB7_STATUS = '9' " + CRLF
    cQry += "                           WHERE " + CRLF
    cQry += "                               CB8.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "                               AND CB8.CB8_FILIAL = SC6.C6_FILIAL AND CB8.CB8_PEDIDO = SC6.C6_NUM AND CB8.CB8_ITEM = SC6.C6_ITEM " + CRLF
    cQry += "                       ) " + CRLF
    cQry += "     ), 0) AS NRITNAOFIN " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL  = "+ValToSql(cFilAnt)+" " + CRLF
    cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPSp)+" " + CRLF
    cQry += "     AND C5_NOTA = ' ' " + CRLF
    cQry += " ORDER BY " + CRLF
    cQry += "     C5_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SC5->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        If SC5->(dbseek( (cAliasProc)->C5_FILIAL + (cAliasProc)->C5_NUM ) )

            If Alltrim(SC5->C5_XMOVTRF) <> Alltrim((cAliasProc)->C5_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSC5 := SC5->(Recno())

            // If (cAliasProc)->NRITENS = (cAliasProc)->NRITNAOFIN
            If (cAliasProc)->NRITNAOFIN = 0 //Se não existe item pendente de finalização de separação, atualiza o status para Pendente de Faturamento

                If SoftLock("SC5") //Evitar de 2 usuários tentar executar no mesmo tempo

                    cIdMov  := "["+(cAliasProc)->C5_FILIAL +"-"+ (cAliasProc)->C5_NUM +"]"
                    
                    U_FLOGJG(cIdMov+" Antes U_JGRT012B - Atualiza Separação"+" Time:"+TIME())

            		U_JGRT11_E(SC5->(Recno()), JGTrPVPFt, JGTrOrPPF)//Grava Status no Pedido

                    U_FLOGJG(cIdMov+" Depois U_JGRT012B - Atualiza Separação"+" Time:"+TIME())

                    If IsLocked("SC5", SC5->(Recno()))
                        SC5->(MsrUnlock()) //Libera o SoftLock
                    EndIf

                EndIf

                nRecnoSC5 := 0

            EndIf
                
        EndIf  

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())  

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.
    
    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT012B["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc}User Function JGRT12C1

    Job
    Processa os pedidos com status JGTrPVPFt (Pedido de Venda Pendente de Faturamento), 
    preparando o documento de saída e alterando o pedido para JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização).

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
User Function JGRT12C1( aParams )

Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSC5     := 0
Local cMsgErro      := ""

// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT12C1["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT12C1["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT12C1", {'SC5','SC6'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT DISTINCT " + CRLF
    cQry += "     C5_FILIAL, C5_NUM, C5_XMOVTRF " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL  = "+ValToSql(cFilAnt)+" " + CRLF
    cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPFt)+" " + CRLF
    cQry += "     AND C5_NOTA = ' ' " + CRLF
    cQry += " ORDER BY " + CRLF
    cQry += "     C5_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SC5->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        cMsgErro := ""

        If SC5->(dbseek( (cAliasProc)->C5_FILIAL + (cAliasProc)->C5_NUM ) )

            If Alltrim(SC5->C5_XMOVTRF) <> Alltrim((cAliasProc)->C5_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSC5 := SC5->(Recno())

            If SoftLock("SC5") //Evitar de 2 usuários tentar executar no mesmo tempo

                cIdMov  := "["+(cAliasProc)->C5_FILIAL +"-"+ (cAliasProc)->C5_NUM +"]"

                U_FLOGJG(cIdMov+" Antes JGRT12C1 - Gera Nota Fiscal"+" Time:"+TIME())

                U_JGRT11_F()

                /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³                 		Gera Pedido e Nota fiscal de saida					  ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
                aDoc := U_JGRT011B(SC5->(Recno()))
                // MsUnLockAll()

                U_JGRT11_F()

                U_FLOGJG(cIdMov+" Depois JGRT12C1 - Gera Nota Fiscal"+" Time:"+TIME())

                If Len(aDoc) >= 6
                    If !Empty(aDoc[1])
                        U_JGRT11_E(aDoc[5], JGTrPVNPA, JGTrOrNPA)//Grava Status no Pedido
                    ElseIf !Empty(aDoc[6])
                        cMsgErro += aDoc[6]
                    EndIf
                Else
                    cMsgErro := "Ocorreu alguma falha sistêmica na tentativa de preparar o documento de saída."
                EndIf

                If IsLocked("SC5",SC5->(Recno()))
                    SC5->(MsrUnlock()) //Libera o SoftLock
                EndIf
            EndIf
            If !Empty(cMsgErro)
                U_JGRT11_D("O", nRecnoSC5, cMsgErro)//Grava Log de Erro
            EndIf

            nRecnoSC5 := 0

        EndIf

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())  

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.

    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT12C1["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc}User Function JGRT12C2

    Job
    Processa os pedidos com status JGTrPVPFt (Pedido de Venda Pendente de Faturamento),
    mas que já estejam faturados (com nota fiscal gerada), indicando que o status está ATRASADO.
    Será realizada apenas a atualização do status do pedido/orçamento.

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
User Function JGRT12C2( aParams )

Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSC5     := 0
Local cMsgErro      := ""

// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT12C2["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT12C2["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT12C2", {'SC5','SC6'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT DISTINCT " + CRLF
    cQry += "     C5_FILIAL, C5_NUM, C5_XMOVTRF " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL  = "+ValToSql(cFilAnt)+" " + CRLF
    cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVPFt)+" " + CRLF
    cQry += "     AND C5_NOTA <> ' ' " + CRLF
    cQry += " ORDER BY " + CRLF
    cQry += "     C5_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SC5->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        cMsgErro := ""

        If SC5->(dbseek( (cAliasProc)->C5_FILIAL + (cAliasProc)->C5_NUM ) )

            If Alltrim(SC5->C5_XMOVTRF) <> Alltrim((cAliasProc)->C5_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSC5 := SC5->(Recno())

            If SoftLock("SC5") //Evitar de 2 usuários tentar executar no mesmo tempo

                cIdMov  := "["+(cAliasProc)->C5_FILIAL +"-"+ (cAliasProc)->C5_NUM +"]"

                U_FLOGJG(cIdMov+" Antes JGRT12C2 - Ajusta status após geração da Nota Fiscal"+" Time:"+TIME())
                U_JGRT11_E(SC5->(Recno()), JGTrPVNPA, JGTrOrNPA)//Grava Status no Pedido e do Orçamento
                U_FLOGJG(cIdMov+" Depois JGRT12C2 - Ajusta status após geração da Nota Fiscal"+" Time:"+TIME())

                If IsLocked("SC5",SC5->(Recno()))
                    SC5->(MsrUnlock()) //Libera o SoftLock
                EndIf
            EndIf

        EndIf

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())  

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.

    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT12C2["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc} JGRT12C1

    Rotina para processar o pedido de venda já separado e preparar as informações para geração da nota fiscal de transferência, 
    chamada pela função U_JGRT012C, que é responsável por processar os pedidos com status JGTrPVPFt (Pedido de Venda Pendente de Faturamento), 
    preparando o documento de saída e alterando o pedido para JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização).

@type function
@version 1.0 
@author Jesus Ramos
@since 09/03/2026
@return variant, return_description
/*/

// User Function JGRT12C1()

//     U_JGRT11_F()

//     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//     ³                 		Gera Pedido e Nota fiscal de saida					  ³
//     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//     aDoc := U_JGRT011B(SC5->(Recno()))
//     MsUnLockAll()

//     U_JGRT11_F()

//     // U_JGRT11_E(aDoc[4], JGTrPVNPA, JGTrOrNPA)//Grava Status no Pedido e do Orçamento

// 		// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// 		// ³                 		Envia e valida nfe no sefaz				              ³
// 		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
// 		// FWMsgRun(, {|oSay| lGeraNfe := U_RFATA25D(@oSay,aDoc[1],aDoc[2],"1") }, "Processando - Nota de Saida NFESEFAZ", "Aguarde, processando a rotina" )
// 		// MsUnLockAll()
// 		// U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

// 		// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// 		// ³                 Gera Nota Fiscal de entrada na filial de destino			     ³
// 		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
// 		// If !Empty(aDoc[1]) .And. lGeraNfe
// 		// 	U_RFATA25C(aDoc[1],aDoc[2],DtoS(dDataBase))
// 		// EndIf

// 	// U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

// Return lGera


/*/{Protheus.doc} User Function JGRT012D

    Job
    Responsável por processar os pedidos com status JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização), 
    atualizando o status da NFe caso tenha mudado e alterando o pedido para JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante).

@type  Function
@author Jesus Ramos
@since 09/03/2026
/*/
User Function JGRT012D( aParams )

Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSC5     := 0

// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT012D["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT012D["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT012D", {'SC5','SC6'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT " + CRLF
    cQry += "     C5_FILIAL, C5_NUM, C5_NOTA, C5_SERIE, C5_XMOVTRF " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL = "+cValToChar(cFilAnt)+" " + CRLF
    cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVNPA)+" " + CRLF
    cQry += "     AND C5_NOTA <> ' ' " + CRLF
    cQry += " ORDER BY " + CRLF
    cQry += "     C5_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SC5->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        If SC5->(dbseek( (cAliasProc)->C5_FILIAL + (cAliasProc)->C5_NUM ) )

            If Alltrim(SC5->C5_XMOVTRF) <> Alltrim((cAliasProc)->C5_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSC5 := SC5->(Recno())

            If SoftLock("SC5") //Evitar de 2 usuários tentar executar no mesmo tempo

                cIdMov  := "["+(cAliasProc)->C5_FILIAL +"-"+ (cAliasProc)->C5_NUM +"] - ["+(cAliasProc)->C5_NOTA +"-"+ (cAliasProc)->C5_SERIE +"]"
                
                U_FLOGJG(cIdMov+" Antes U_JGRT012D - Atualiza o status do pedido quanto à autorização da Nota Fiscal."+" Time:"+TIME())
                U_JGRT12D1(cSemaforo)
                U_FLOGJG(cIdMov+" Depois U_JGRT012D - Atualiza o status do pedido quanto à autorização da Nota Fiscal."+" Time:"+TIME())

                If IsLocked("SC5",SC5->(Recno()))
                    SC5->(MsrUnlock()) //Libera o SoftLock
                EndIf
            EndIf

            nRecnoSC5 := 0

        EndIf  

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())   

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.
    
    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT012D["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc} JGRT12D1

    Responsável por processar os pedidos com status JGTrPVNPA (Nota Fiscal de Saída Pendente de Autorização), 
    atualizando o status da NFe caso tenha mudado e alterando o pedido para JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante).

@type function
@version 1.0 
@author Jesus Ramos
@since 09/03/2026
@return variant, return_description
/*/
User Function JGRT12D1(cSemaforo)

    Local cAliasAnt := Alias()
    Local aArea     := FWGetArea()
    Local aAreaSF2  := FWGetArea("SF2")
    Local cChaveDoc := ""
    Local bBlock    := ErrorBlock()
    Local nRecnoSC5 := SC5->(Recno())

    // Local cResErro      := "" //Resumo do erro
    // Local cDetErro      := "" //Detalhe do erro

    Private __cErrX     := "" //ErrorBlock
    Private __cStackX   := "" //ErrorBlock

    Default cSemaforo := ""

    BEGIN SEQUENCE

        ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

        U_JGRT11_F()

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³                 		Gera Pedido e Nota fiscal de saida					  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

        cChaveDoc := SC5->(C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI+Space(TamSx3("F2_FORMUL")[1])+C5_TIPO)

        DbSelectArea("SF2")
        SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        If SF2->(DbSeek(cChaveDoc)) //Busca o documento de saída relacionado ao pedido
            If SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO) == cChaveDoc //Valida se o documento de saída encontrado é referente ao pedido
                If SF2->F2_FIMP == "S" //Valida se a NFe já está autorizada
                    U_JGRT11_E(SC5->(Recno()), JGTrPVNPE, JGTrOrNPE)//Grava Status no Pedido e do Orçamento
                EndIf
            EndIf
        EndIf

        FWRestArea(aAreaSF2)
        FWRestArea(aArea)
        DbSelectArea(cAliasAnt)

        U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

        ErrorBlock(bBlock)

    RECOVER
        //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
        //fluxo de execução será desviado após a execução de um comando BREAK.

        // cResErro := __cErrX   //Resumo do erro
        // cDetErro := __cStackX //Detalhe do erro

        U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
        // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

        U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

        U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

        ErrorBlock(bBlock)

    END SEQUENCE

    __cErrX   := Nil
    __cStackX := Nil

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc} User Function JGRT012E

    Job
    Responsável por processar os pedidos com status JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante), 
     efetuando a entrada na filial de destino e alterando o pedido para JGTrPVOK (Transferência Concluída).

@type  Function
@author Jesus Ramos
@since 10/03/2026
/*/
User Function JGRT012E( aParams )

Local cEmp		    := aParams[1]
Local cFil		    := aParams[2]
Local cSemaforo     := aParams[3]
Local cAliasProc 	:= ""//GetNextAlias()
Local cQry          := ""
Local cIdMov        := ""
Local bBlock        := ErrorBlock()
Local nRecnoSC5     := 0
// Local cResErro      := "" //Resumo do erro
// Local cDetErro      := "" //Detalhe do erro

Private __cErrX     := "" //ErrorBlock
Private __cStackX   := "" //ErrorBlock

//Realiza o bloqueio de um identificador Semaforo.
If !GlbNmLock(cSemaforo)
    Return
EndIf

U_FLOGJG("Starting Job JGRT012E["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"]" )

If IsBlind()
    FWMonitorMsg( "JOB JGRT012E["+cSemaforo+"]*STARTED: "+TIME() )	// Imprime no monitor a Identificacao da Thread

    RPCSetType(3) //Nao consome licenca 
    If !RpcSetEnv(cEmp , cFil, Nil, Nil, "FAT","U_JGRT012E", {'SC5','SC6'} )
        U_FLOGJG("JOB#" + cSemaforo + "# Thread ["+cValToChar(ThreadID())+"] RPCSetEnv: FALHA AO INICIAR AMBIENTE" )
        GlbNmUnlock(cSemaforo)
        Return()
    EndIf
    //inicializa as variaveis publicas
    InitPublic()
EndIf

cEmpAnt := cEmp
cFilAnt := cFil
U_JGRT11_F()

BEGIN SEQUENCE

    ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

    cIdMov := ""

    cQry := " SELECT " + CRLF
    cQry += "     C5_FILIAL, C5_NUM, C5_NOTA, C5_SERIE, C5_XMOVTRF " + CRLF
    cQry += " FROM " + CRLF
    cQry += "     "+RetSqlName("SC5")+" SC5 " + CRLF
    cQry += " WHERE " + CRLF
    cQry += "     SC5.D_E_L_E_T_ <> '*' " + CRLF
    cQry += "     AND C5_FILIAL = "+cValToChar(cFilAnt)+" " + CRLF
    cQry += "     AND C5_XMOVTRF = "+ValToSql(JGTrPVNPE)+" " + CRLF
    cQry += "     AND C5_NOTA <> ' ' " + CRLF
    cQry += " ORDER BY " + CRLF
    cQry += "     C5_NUM " + CRLF

    cAliasProc  := MPSysOpenQuery( cQry )

    SC5->(DbSetOrder(1))
    While (cAliasProc)->(!Eof())

        If SC5->(DbSeek( (cAliasProc)->C5_FILIAL + (cAliasProc)->C5_NUM ) )

            If Alltrim(SC5->C5_XMOVTRF) <> Alltrim((cAliasProc)->C5_XMOVTRF)
                (cAliasProc)->(DbSkip())
                Loop
            EndIf

            nRecnoSC5 := SC5->(Recno())

            If SoftLock("SC5") //Evitar de 2 usuários tentar executar no mesmo tempo

                cIdMov  := "["+(cAliasProc)->C5_FILIAL +"-"+ (cAliasProc)->C5_NUM +"] - ["+(cAliasProc)->C5_NOTA +"-"+ (cAliasProc)->C5_SERIE +"]"
                
                U_FLOGJG(cIdMov+" Antes U_JGRT012E - Efetua a entrada da nota fiscal na filial solicitante."+" Time:"+TIME())
                U_JGRT12E1(cSemaforo)
                U_FLOGJG(cIdMov+" Depois U_JGRT012E - Efetua a entrada da nota fiscal na filial solicitante."+" Time:"+TIME())

                If IsLocked("SC5",SC5->(Recno()))
                    SC5->(MsrUnlock()) //Libera o SoftLock
                EndIf
            EndIf

            nRecnoSC5 := 0

        EndIf  

        (cAliasProc)->(DbSkip())
    EndDo
    (cAliasProc)->(DbCloseArea())

    ErrorBlock(bBlock)

RECOVER
    //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
    //fluxo de execução será desviado após a execução de um comando BREAK.
    
    // cResErro := __cErrX   //Resumo do erro
    // cDetErro := __cStackX //Detalhe do erro

    U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
    // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

    U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

    U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

    ErrorBlock(bBlock)

END SEQUENCE

__cErrX   := Nil
__cStackX := Nil

U_FLOGJG("Job JGRT012E["+cSemaforo+"] Thread ["+cValToChar(ThreadID())+"] TERMINO DO PROCESSAMENTO" )

If IsBlind()
    RPCClearEnv()
EndIf

//Libera o bloqueio de um identificador nomeado.
GlbNmUnlock(cSemaforo)

Return
// Return {cResErro,cDetErro}


/*/{Protheus.doc} JGRT12E1

    Responsável por processar os pedidos com status JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante/destino),
    atualizando o status da NFe caso tenha mudado e alterando o pedido para JGTrPVNPE (Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante).

@type function
@version 1.0 
@author Jesus Ramos
@since 10/03/2026
@return variant, return_description
/*/
User Function JGRT12E1(cSemaforo)

    Local cAliasAnt := Alias()
    Local aArea     := FWGetArea()
    Local aAreaSF2  := FWGetArea("SF2")
    Local cChaveDoc := ""
    Local bBlock    := ErrorBlock()
    Local nRecnoSC5 := SC5->(Recno())

    // Local cResErro      := "" //Resumo do erro
    // Local cDetErro      := "" //Detalhe do erro

    Private __cErrX     := "" //ErrorBlock
    Private __cStackX   := "" //ErrorBlock

    Default cSemaforo := ""

    BEGIN SEQUENCE

        ErrorBlock( { |oError| __cErrX:=oError:Description , __cStackX:=oError:ErrorStack , Break(oError) } )

        U_JGRT11_F()

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³                 		Gera Pedido e Nota fiscal de saida					  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

        cChaveDoc := SC5->(C5_FILIAL+C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI+Space(TamSx3("F2_FORMUL")[1])+C5_TIPO)

        DbSelectArea("SF2")
        SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        If SF2->(DbSeek(cChaveDoc)) //Busca o documento de saída relacionado ao pedido
            If SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO) == cChaveDoc //Valida se o documento de saída encontrado é referente ao pedido
                If SF2->F2_FIMP == "S" //Valida se a NFe já está autorizada
                    If U_JGRT13A( , SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE )
                        U_JGRT11_E(SC5->(Recno()), JGTrPVOK, JGTrOrOK)//Grava Status no Pedido e do Orçamento
                    EndIf
                EndIf
            EndIf
        EndIf

        FWRestArea(aAreaSF2)
        FWRestArea(aArea)
        DbSelectArea(cAliasAnt)

        U_JGRT11_F() //Ajuste cFilAnt <> M0_CODFIL

        ErrorBlock(bBlock)

    RECOVER
        //RECOVER - Define um ponto de recuperação, dentro do bloco de sequência, para o qual o 
        //fluxo de execução será desviado após a execução de um comando BREAK.

        // cResErro := __cErrX   //Resumo do erro
        // cDetErro := __cStackX //Detalhe do erro

        U_FLOGJG('O seguinte erro ocorreu: ' + __cErrX+__cStackX)
        // U_FLOGJG('O seguinte erro ocorreu: ' + cResErro+cDetErro)

        U_FLOGJG('#BEGIN SEQUENCE->RECOVER# Desviado apos erro : ' + 'JOB( ' + cSemaforo + ' )' )

        U_JGRT11_D("O", nRecnoSC5, __cErrX+__cStackX)

        ErrorBlock(bBlock)

    END SEQUENCE

    __cErrX   := Nil
    __cStackX := Nil

Return
// Return {cResErro,cDetErro}


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction: ValidFil
>>Verifica se a filial selecionada é validada

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//--------------------------------------------------------------
Static Function ValidFil(cFilPos, cFilValid, _cTp)
	Local lRet := .T.

	If !FWFilExist(cEmpAnt,cFilPos)
		U_LOGJG("A filial informada não existe!")
		cFilPos := Space(4)
		Return(.f.)
	EndIf

	If cFilPos == cFilValid
		U_LOGJG("As filiais de origem e destino não podem ser iguais!")
		cFilPos := Space(4)
		Return(.f.)
	EndIf

	If _cTp == "O" .And. !(cFilPos == "0101")
		U_LOGJG("A filial de origem deve ser 0101!")
		cFilPos := Space(4)
		Return(.f.)
	EndIf

	If _cTp == "D" .And. !(cFilPos $ "0103;0104")
		U_LOGJG("A filial de destino deve ser 0103 ou 0104!")
		cFilPos := Space(4)
		Return(.f.)
	EndIf

Return(lRet)


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction:
>>Faz a busca do produto por codigo ou por codigo de barras.

@param
@return
@author  - Lorran Ferreira
@since 23/10/2015
/*/
//--------------------------------------------------------------
Static Function fCliFor(cTp, cFil, cCliFor)

	Local aSM0   := FWLoadSM0()
	Local _cCNPJ := ""

	If Empty(cFil)
		Return()
	EndIf

	aEval(aSM0,{|x| IIf(x[1] == cEmpAnt .And. x[2]==cFil , _cCNPJ := x[18], "") })

	If Empty(_cCNPJ)
		FWAlertWarning("O CNPJ da filial é inválido (vazio)!", "Atenção")
		Return(.F.)
	EndIf

	If cTp == "C"

		U_JGRT11_F(cFil) //Ajuste cFilAnt <> M0_CODFIL

		SA1->(dbsetOrder(3))
		If SA1->(dbSeek(xFilial("SA1")+_cCNPJ))
			cCliFor := SA1->A1_COD+SA1->A1_LOJA
		EndIf

	ElseIf cTp == "F"

		U_JGRT11_F(cFil) //Ajuste cFilAnt <> M0_CODFIL

		SA2->(dbsetOrder(3))
		If SA2->(dbSeek(xFilial("SA2")+_cCNPJ))
			cCliFor := SA2->A2_COD+SA2->A2_LOJA
		EndIf

	EndIf

Return

