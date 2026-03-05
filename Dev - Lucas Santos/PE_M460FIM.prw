#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#Include 'TopConn.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#include "RPTDEF.CH"
#include "FWPRINTSETUP.CH"
/*/{Protheus.doc} M460FIM
Ponto de entrada após a gravação da Nota Fiscal de Saída.
Questiona geração de boleto e borderô.
@author Brunno Alves
@since 04/02/2026
/*/
User Function M460FIM()
    Local aArea     := GetArea()
    Local cNota     := SF2->F2_DOC
    Local cSerie    := SF2->F2_SERIE
    Local cCliente  := SF2->F2_CLIENTE
    Local cLoja     := SF2->F2_LOJA
    Local lGeraBol  := .T.//SuperGetMv("MV_XBOLETO",,.T.)
    Local cCondPag  := SF2->F2_COND
    Local cFormaPg  := ""
//    Local cBolNew   := 1  // 1 =M460
    //Leo
   	Local cAreaAnt := Alias()
	Local aAreaSD2 := SD2->(getArea())
	Local aAreaSF2 := SF2->(getArea())
	Local aAreaSC5 := SC5->(getArea())
	Local aAreaSC9 := SC9->(getArea())
	Local aAreaSE1 := SE1->(getArea())   
	Local aAreaSE4 := SE4->(getArea())   
	Local aAreaSA1 := SA1->(getArea())
    //Leo  
    DbSelectArea("SE4")
    SE4->(DbSetOrder(1))
    
    If SE4->( DbSeek( xFilial("SE4") + cCondPag ) )
        cFormaPg := AllTrim( SE4->E4_FORMA )
    EndIf

    // Se for PIX ou Dinheiro, não gera a Nota Promissória
    If ! cFormaPg $ "PX|R$|CC|CD"
        Processa({|| U_JG05A001(cNota, cSerie) }, "Processando Nota Promissória...")
    EndIf

    //Geração de boleto, conforma a forma de pagamento no cadastro da condição de pagamento
    If lGeraBol .And. ALLTRIM(cFormaPg) == "BOL" //"BOL   "
    
        // Pergunta ao usuário
        If MsgYesNo("A Nota Fiscal <b>" + cNota + "</b> foi emitida." + CRLF + CRLF + "Deseja imprimir o Boleto agora?", "Emissão Boleto (M460FIM)")
            DbSelectArea("SA3")
            DbSelectArea("SED")
            DbSelectArea("SEE")
            DbSelectArea("SE1")
            DbSelectArea("SEA")

            //Impressão de Boletos
//            Processa({|| U_JG05A002(cNota, cSerie, cCliente, cLoja, cBolNew) }, "Processando Boletos...")
            Processa({|| U_JG05A002(cNota, cSerie, cCliente, cLoja) }, "Processando Boletos...")
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
                endIf
        EndIf
    
    EndIf

    RestArea(aArea)
    //Leo
	// Restaura ambiente
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aAreaSC5)
	RestArea(aAreaSC9)   
	RestArea(aAreaSE1)
	RestArea(aAreaSE4)
	RestArea(aAreaSA1)  
	dbSelectArea(cAreaAnt)
    //Leo

Return .T.
