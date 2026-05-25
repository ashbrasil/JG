#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} User Function JGRT010
    Rotina para liberar/iniciar o processamento da transferência de estoque, quando exigido.
    @type  Function
    @author Lorran Ferreira
    @since 06/05/2024
    /*/
User Function JGRT010()

	Local aArea       := FwGetArea()
	Local aAreaSL1    := SL1->(FwGetArea())
	Local lLjEmitNFCe := LjEmitNFCe()	//Verifica se NFC-e Habilitado na estação 
	Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local lLiberado   := .F.
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cNomVndOrc  := POSICIONE("SA3",1,FWXFILIAL("SA3")+SL1->L1_VEND,"A3_NOME")
	Local lEhCaixa    := U_xDfPerCx(3) // Verifica se o usuário é caixa

    If SL1->L1_XMOVTRF == JGTrOrNSA
        FwAlertError("As regras para a transferência imediata não se aplicam a esta filial e orçamento."+CRLF+CRLF+;
                        "A liberação não será processada.", "Liberação para transferência")
        Return
    ElseIf !(SL1->L1_XMOVTRF == JGTrOrEAb)
        FwAlertError("A liberação somente é possível quando o status do orçamento para a transferência é igual a <b>"+U_fDsStTrf("O",JGTrOrEAb)+"</b>."+CRLF+CRLF+;
                        "Porém, o orçamento encontra-se com o seguinte status:"+CRLF+;
                        "<strong>"+U_fDsStTrf("O",SL1->L1_XMOVTRF)+"</strong>"+CRLF+CRLF+;
                        U_fDsStTrf("O",SL1->L1_XMOVTRF,.T.), "Liberação para transferência")
        Return
    ElseIf (!lLjEmitNFCe .Or. !lEhCaixa) // Melhorar a validação, separando caixa de vendedor
        If SL1->L1_VEND <> cCodVndLog .And. !(cCodVndLog $ cJGGERLOJ) // Vendedor referente ao gerente da loja - Melhorar a validação
            FwAlertError("Este orçamento pertentece ao(à) vendedor(a) "+SL1->L1_VEND+"-"+AllTrim(cNomVndOrc)+"."+CRLF+;
                            "Somente ele(ela), seu superior (gerente, supervisor) ou algum agente administrativo superior, poderão liberá-lo.", "Liberação para transferência")
            Return
        EndIf
    EndIf

    If !Empty(SL1->L1_DOC) // Orçamento já finalizado não entra na regra
        FwAlertError("Há alguma falha no processo, pois o orçamento entra na regra mas consta como finalizado antes da liberação."+CRLF+CRLF+;
                        "A liberação não será processada.", "Liberação para transferência")
        Return
    EndIf

    If !MsgYesNo("Ao liberar a transferência de estoque para este orçamento, o mesmo não mais poderá ser alterado."+CRLF+CRLF+;
                 "Certifique-se de que não será necessário alterar a negociação."+CRLF+CRLF+;
                 "Logo após a liberação, o sistema, de forma automática, processará a transferênca da(s) mercadoria(s)."+CRLF+CRLF+;
                 "O orçamento somente poderá ser finalizado/recebido após o término do processo de transferência.";
                ,"Prosseguir com a Liberação?")
        Return
    EndIf

    Begin Transaction
        If RecLock("SL1",.F.)
            If !(SL1->L1_XMOVTRF == JGTrOrEAb) // O status para transferência deve ser "Orç. Em Aberto"
                FwAlertError("O status do orçamento foi alterado durante a confirmação de liberação."+CRLF+CRLF+;
                                "Neste momento o status é <B>"+U_fDsStTrf("O",SL1->L1_XMOVTRF)+"</B>."+CRLF+CRLF+;
                                "A liberação foi abortada.", "Liberação para transferência")
            ElseIf !Empty(SL1->L1_DOC) // Orçamento já finalizado não entra na regra
                FwAlertError("O orçamento foi finalizado durante a confirmação de liberação."+CRLF+;
                                "Há alguma falha no processo, pois o orçamento entra na regra mas foi finalizado antes da liberação."+CRLF+;
                                "A liberação não será processada.", "Liberação para transferência")
            Else
                SL1->L1_XMOVTRF := JGTrOrIni
                lLiberado := .T.
            EndIf
            SL1->(MsUnLock())
        Else
            FwAlertError("O orçamento encontra-se bloqueado por outro usuário, não sendo possível sua liberação."+CRLF+CRLF+;
                            "A liberação foi abortada.", "Liberação para transferência")
            Return
        EndIf
    End Transaction

    If lLiberado
        FWAlertSuccess("Orçamento "+SL1->L1_FILIAL+'-'+SL1->L1_NUM+" LIBERADO para transferência!"+CRLF+CRLF+;
                        "Favor aguardar o término do processo de transferência para finalizar o orçamento.", "Liberação bem sucedida")
    EndIf

	RestArea(aAreaSL1)
	RestArea(aArea)

Return
