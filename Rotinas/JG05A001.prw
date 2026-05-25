#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#include "rwmake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.ch"
#include "ap5mail.ch"
#Include 'TopConn.ch' 
// Necessário para manipulação de Query
/*/{Protheus.doc} JG05A001
Função para impressão de Nota Promissória (uma por parcela).
Verifica se a condição de pagamento tem forma pgto BOL, nova regra trocando pela regra antiga //é diferente de 001.
Utiliza Query SQL para buscar parcelas na SE1.
@author Gemini AI
@since 05/02/2026
/*/
User Function JG05A001(cNota, cSerie)
    Local oPrinter
    Local oFont12, oFont12b, oFont10, oFont08
    //Local cCondPg   := ""
    Local cNomCli   := ""
    Local cCgcCli   := ""
    Local cEndCli   := ""
    Local cCidCli   := ""
    Local cUfCli    := ""
    Local cCepCli   := ""
    Local nValor    := 0
    Local dVencto   := CtoD("")
    Local cExtenso  := ""
    Local vHP05A001 := GetMV("JG_HP05A01") // Parâmetro para tratar pergunta Habilitar 
    //Local cTexto    := ""
    Local cTexto1, cTexto2, cTexto3 := ""
    Local lEncontrou := .F.
    Local cQuery    := ""
    Local cAliasSE1 := GetNextAlias() // Gera um nome aleatório para a tabela temporária
    Local nSlot     := 0    // Contador de notas na página atual (0, 1 ou 2)
    Local nBaseY    := 0    // Posição Y inicial da nota atual
    Local nStepY    := 275  // Altura total de cada nota (pixels) para pular para a próxima
    Local nMrgTop   := 20   // Margem superior inicial
    Local vFWMSP    := 0
    Local cPrinterP := 'Microsoft Print to PDF'
    Local aArea := GetArea()
    Local cStartPath := GetTempPath(.T.)+"totvsprinter\"
    // --- BUSCA DADOS DO CLIENTE (SEU TRECHO) ---
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
        cNomCli := AllTrim( SA1->A1_NOME )
        cCgcCli := IIF( SA1->A1_PESSOA == "F", Transform(SA1->A1_CGC, "@R 999.999.999-99"), Transform(SA1->A1_CGC, "@R 99.999.999/9999-99") )
        cEndCli := AllTrim(SA1->A1_END) + ", " + AllTrim(SA1->A1_BAIRRO)
        cCidCli := AllTrim(SA1->A1_MUN)
        cUfCli  := AllTrim(SA1->A1_EST)
        cCepCli := Transform(SA1->A1_CEP, "@R 99.999-999")
    EndIf
 
//  TESTAR 1 SEM MOSTRAR
    cNomeRel :=  "NP_" + Alltrim(cNota)+'.rel'    
    cNomeArq :=  "NP_" + Alltrim(cNota)+'.pdf'    

    If vHP05A001 == 'S'
    
    	If  MsgBox("Deseja visualizar a Nota Promissória em geração? "+ "   "+cNota,"Confirma?","YESNO")
            //Definindo o diretório como a temporária do S.O.
            cCaminho  := GetTempPath()
            //Criando o objeto do FMSPrinter                    1      2        3    4   5   6    7        8  910 11 12
            If  MsgBox("Deseja abrir os parâmetros para Impressão? "+ "   "+cNota,"Confirma?","YESNO")
                oPrinter := FWMSPrinter():New("NP_" + AllTrim(cNota), IMP_PDF, .F., "",.F. , , @oPrinter, "", , , , .T.)
                oPrinter:cPrinter := cPrinterP
                vFWMSP := 3
            Else
                oPrinter := FWMSPrinter():New("NP_" + AllTrim(cNota), IMP_PDF, .F., "",.T., , @oPrinter, "", , , , .T.)
                oPrinter:cPrinter := cPrinterP
                vFWMSP := 2
            EndIf
        Else
            cCaminho := "\spool\"
            //Se não existir a pasta na Protheus Data, cria ela
            If ! ExistDir(cCaminho)
                MakeDir(cCaminho)
            EndIf
            oPrinter := FWMSPrinter():New("NP_" + Alltrim(cNota), IMP_PDF,.F.,cStartPath,.T.,.F., @oPrinter, cPrinterP,,,,.F.)
            oPrinter:cPathPDF := "\spool\" //cCaminho
            vFWMSP := 1
        EndIf
    
    Else
        cCaminho := "\spool\"
        //Se não existir a pasta na Protheus Data, cria ela
        If ! ExistDir(cCaminho)
            MakeDir(cCaminho)
        EndIf
        oPrinter := FWMSPrinter():New("NP_" + Alltrim(cNota), IMP_PDF,.F.,cStartPath,.T.,.F., @oPrinter, cPrinterP,,,,.F.)
        oPrinter:cPathPDF := "\spool\" //cCaminho
        vFWMSP := 1
    EndIf

	If oPrinter:nModalResult <> 1 .AND. vFWMSP == 3
    	  Return(.T.)
	EndIf


    oPrinter:SetResolution(72)
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4)
    oPrinter:SetMargin(10, 10, 10, 10)
    oPrinter:nDevice  := 6

    // Definição de Fontes
    oFont12  := TFont():New("Arial",,12,,.F.,,,,,.F.,.F.)
    oFont12b := TFont():New("Arial",,12,,.T.,,,,,.F.,.F.)
    oFont10  := TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)
    oFont08  := TFont():New("Arial",,08,,.F.,,,,,.F.,.F.)
    
    // --- QUERY NO FINANCEIRO (SE1) ---
    // Montagem da Query SQL
    cQuery := "SELECT E1_PARCELA, E1_VALOR, E1_VENCTO "
    cQuery += "FROM " + RetSQLName("SE1") + " SE1 "
    cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
    cQuery += "AND SE1.E1_PREFIXO = '" + SF2->F2_SERIE + "' "
    cQuery += "AND SE1.E1_NUM = '" + SF2->F2_DOC + "' "
    //cQuery += "AND SE1.E1_TIPO = 'NF' " // Apenas Notas
    // Filtros de segurança padrão
    cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY E1_PARCELA "
    
    // Ajusta query para o banco de dados atual
    cQuery := ChangeQuery(cQuery)
    
    // Executa a Query e joga no Alias temporário
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE1, .F., .T.)
    
//    MEMOWRITE("C:\TEMP\queryJG05A001.TXT", cQuery)

    // Loop nos resultados da Query
    While (cAliasSE1)->(!Eof())
            
//        MEMOWRITE("C:\TEMP\cNota.TXT", "NP " + AllTrim(cNota) + "/" + AllTrim((cAliasSE1)->E1_PARCELA) )

        lEncontrou := .T.
// Se for a primeira nota da página (Slot 0), abre a página
        If nSlot == 0
            oPrinter:StartPage()
        EndIf
        
        // --- CÁLCULO DA POSIÇÃO VERTICAL ---
        // Se slot for 0 (topo), nBaseY = 20
        // Se slot for 1 (meio), nBaseY = 20 + 275 = 295
        // Se slot for 2 (baixo), nBaseY = 20 + 550 = 570
        nBaseY := nMrgTop + (nSlot * nStepY)
        
        // --- DADOS DA ITERAÇÃO ---
        nValor     := (cAliasSE1)->E1_VALOR
        dVencto    := StoD( (cAliasSE1)->E1_VENCTO )
        cExtenso   := "(" + Extenso(nValor) + ")"
        
        // --- DESENHO DA PROMISSÓRIA (USANDO nBaseY COMO REFERÊNCIA) ---
        
        // Box Principal (Altura reduzida para 260px para caber 3 na pagina)
        // Coordenadas: Topo, Esq, Base, Dir
        oPrinter:Box(nBaseY, 50, nBaseY + 260, 550)
        
        // Cabeçalho
        oPrinter:Say(nBaseY + 10, 60, "NOTA PROMISSÓRIA", oFont12b)
        oPrinter:Say(nBaseY + 10, 410, "Nº " + AllTrim(cNota) + "/" + AllTrim((cAliasSE1)->E1_PARCELA), oFont12b)
        // Vencimento e Valor
        oPrinter:Say(nBaseY + 40, 60, "Vencimento: " + DtoC(dVencto), oFont12)
        
        // Box do Valor
        //oPrinter:Box(nBaseY + 25, 400, nBaseY + 40, 530) 
        oPrinter:Say(nBaseY + 40, 410, "R$: " + AllTrim( Transform(nValor, "@E 999,999,999.99") ), oFont12b)
        
        // --- TEXTO LEGAL ---
        cTexto1 := "No dia " + DtoC(dVencto) + " pagarei por esta única via de NOTA PROMISSÓRIA"
        cTexto2 := "à empresa JG SUPRIMENTOS LTDA, CNPJ "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+" ou sua ordem"
        cTexto3 := "a quantia de R$ " + AllTrim( Transform(nValor, "@E 999,999,999.99") ) + " " + cExtenso + " "
        
        oPrinter:Say(nBaseY + 65, 60, cTexto1, oFont10)
        oPrinter:Say(nBaseY + 80, 60, cTexto2, oFont10)
        oPrinter:Say(nBaseY + 95, 60, cTexto3, oFont10)
        oPrinter:Say(nBaseY + 110, 60, "em moeda corrente deste país.", oFont10)
        oPrinter:Say(nBaseY + 125, 60, "Multa moratória de 2%,", oFont10)
        oPrinter:Say(nBaseY + 140, 60, "juros de mora de 1% ao mês, correção monetária pelo IPCA-E, a partir do vencimento.", oFont10)

        
        // --- DADOS DO EMITENTE ---
        oPrinter:Say(nBaseY + 150, 60, "EMITENTE", oFont08)
        oPrinter:Say(nBaseY + 162, 60, cNomCli, oFont10)
        
        oPrinter:Say(nBaseY + 185, 60, "CPF/CNPJ:", oFont08)
        oPrinter:Say(nBaseY + 197, 60, cCgcCli, oFont10)
        
        oPrinter:Say(nBaseY + 185, 250, "ENDEREÇO:", oFont08)
        
        // Box do Endereço
        //oPrinter:Box(nBaseY + 195, 250, nBaseY + 225, 530)
        oPrinter:Say(nBaseY + 197, 250, SubStr(cEndCli + " - " + cCidCli + " - " + cUfCli, 1, 55), oFont08) 
        oPrinter:Say(nBaseY + 209, 250, SubStr("CEP: " + cCepCli, 1, 50), oFont08)
        
        // Assinatura
        oPrinter:Line(nBaseY + 245, 60, nBaseY + 245, 300)
        oPrinter:Say(nBaseY + 250, 135, "Assinatura do Emitente", oFont08) 
        
        // Linha pontilhada de corte (opcional entre as notas, exceto na última da página)
        If nSlot < 2
             // Desenha uma linha de corte visual
             oPrinter:Say(nBaseY + 265, 50, "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -", oFont08)
        EndIf

        // Incrementa o slot e vai para o próximo registro
        nSlot++
        (cAliasSE1)->(DbSkip())
        
        // Se preencheu 3 notas (0, 1, 2), fecha a página e reseta o slot
        If nSlot > 2
            oPrinter:EndPage()
            nSlot := 0
        EndIf
        
    EndDo
    
    // Se saiu do loop e o slot ainda está aberto (ex: imprimiu 1 ou 2 notas na última página), fecha a página.
    If nSlot > 0
        oPrinter:EndPage()
    EndIf
    
    (cAliasSE1)->(DbCloseArea()) // Fecha a tabela temporária
    
    If lEncontrou .AND. vFWMSP == 2 .OR. vFWMSP == 2 
        oPrinter:Preview()
    Else
        oPrinter:Print()
    EndIf
  //  cPathPDF   := "\spool\"
    cArqTrbPDF := GetTempPath(.T.)+"totvsprinter\"+cNomeArq
    cArqTrbREL := GetTempPath(.T.)+"totvsprinter\"+cNomeRel
    cArqSrvPDF := "\spool\"+cNomeArq

    If  File(Lower(cArqTrbPDF)) .and. vFWMSP >= 2 
        If !File(Lower(cArqSrvPDF))
           If  !CpyT2S(Lower(cArqTrbPDF), "\spool\",.T.,.T. )
               MsgAlert(" cArqTrbPDF ->"+cArqTrbPDF+"  cPathPDF->"  ,"Verificar")
           EndIf
       EndIf    
    EndIf

    If  File(Lower(cArqSrvPDF)) 
        If !File(Lower("c:\temp\"+cNomeArq))
           If  !CpyS2T(Lower(cArqSrvPDF), "c:\temp\",.T.,.T. )
               MsgAlert(" cArqSrvPDF ->"+cArqSrvPDF+" c:\temp\"  ,"Verificar")
           EndIf
       EndIf    
    EndIf


    If  File(Lower(cArqTrbPDF)) 
        If  !File(Lower("c:\temp\"+cNomeArq))
            If  !__CopyFile(Lower(cArqTrbPDF), "c:\temp\"+cNomeArq)
                If  !__CopyFile(Lower(cArqSrvPDF), "c:\temp\"+cNomeArq)
                     MsgAlert(" Erro copia p/ -> "+cArqSrvPDF+" "+cArqSrvPDF+" ","Verificar")
                EndIf
            Endif       
        EndIf
    EndIf

    If  File(cArqTrbRel)   //Ambiente Servidor PathPEDF
   		fErase(cArqTrbRel)
    Else
//		    Alert('Não encontrado  -> '+cArqTrbRel) 
    EndIf


    If  File(cArqSrvPDF)  //Ambiente Servidor PathPEDF
   		fErase(cArqSrvPDF)
    Else
//		    Alert('Não encontrado  -> '+cArqSrvPDF) 
    EndIf

    If  File(cArqTrbPDF)  //Ambiente C:
   		fErase(cArqTrbPDF)
    Else
//		    Alert('Não encontrar cArqTrbPDF -> '+cArqTrbPDF) 
    EndIf


    FreeObj(oFont12)
    FreeObj(oFont12b)
    FreeObj(oFont10)
    FreeObj(oFont08)
    FreeObj(oPrinter)
    
    RestArea(aArea)    
Return
