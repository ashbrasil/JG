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
    Local lGeraBol  := SuperGetMv("MV_XBOLETO",,.T.)
    Local cCondPag  := SF2->F2_COND
    Local cFormaPg  := ""
    

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
    If lGeraBol .And. cFormaPg == "BOL"
    
        // Pergunta ao usuário
        If MsgYesNo("A Nota Fiscal <b>" + cNota + "</b> foi emitida." + CRLF + CRLF + "Deseja imprimir o Boleto agora?", "Emissão Boleto (M460FIM)")
            DbSelectArea("SA3")
            DbSelectArea("SED")
            DbSelectArea("SEE")
            DbSelectArea("SE1")
            DbSelectArea("SEA")

            //Impressão de Boletos
            Processa({|| U_JG05A002(cNota, cSerie, cCliente, cLoja) }, "Processando Boletos...")
            
        EndIf
    
    EndIf

    RestArea(aArea)

Return .T.
