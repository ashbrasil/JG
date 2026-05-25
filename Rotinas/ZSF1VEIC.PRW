#Include "Totvs.ch"
#Include "Protheus.ch"

User Function ZSF1VEIC()

    Local aArea    := GetArea()
    Local nRecSF1  := 0

    Local cChave   := ""
    Local cVeic1   := ""
    Local nPBruto  := 0
    Local nPLiqui  := 0

    // Tamanhos fixos (sem SX3)
    Local nTamCh   := 44
    Local nTamV1   := 7

    Local oDlg     := Nil
    Local lOk      := .F.

    // 1) SF1 posicionada
    If Select("SF1") <= 0 .Or. SF1->(Eof())
        MsgStop("Nenhuma nota posicionada na SF1.", "Atenção")
        RestArea(aArea)
        Return .F.
    EndIf

/*/
    // 2) Só status A (se quiser reativar, ajuste conforme sua regra)
    If Upper(AllTrim(SF1->F1_STATUS)) <> "A"
        MsgStop("Não é permitido alterar. Status diferente de 'A'.", "Bloqueado")
        RestArea(aArea)
        Return .F.
    EndIf
/*/

    nRecSF1 := SF1->(RecNo())

    // Valores atuais
    If Type("SF1->F1_CHVNFE") == "C"
        cChave := SF1->F1_CHVNFE
    Else
        cChave := Space(nTamCh)
    EndIf

    If Type("SF1->F1_VEICUL1") == "C"
        cVeic1 := Left(SF1->F1_VEICUL1, nTamV1) 
    Else 
        cVeic1 := Space(nTamV1)
    EndIf

    If Type("SF1->F1_PBRUTO") == "N"
        nPBruto := SF1->F1_PBRUTO
    EndIf

    If Type("SF1->F1_PLIQUI") == "N"
        nPLiqui := SF1->F1_PLIQUI
    EndIf

    // ==============================
    // TELA (MAIOR + LIMITA TAMANHO NO PICTURE)
    // ==============================

    DEFINE MSDIALOG oDlg TITLE "Informar dados da SF1" FROM 0,0 TO 480,510 PIXEL

        @ 15, 10 SAY "Chave (F1_CHVNFE):" OF oDlg PIXEL
        // @S44 limita e permite digitar
        @ 28, 10 GET cChave PICTURE "@S44" SIZE 610, 14 OF oDlg PIXEL

        @ 55, 10 SAY "Veículo (F1_VEICUL1):" OF oDlg PIXEL
        // @S6 limita e permite digitar
        @ 68, 10 GET cVeic1 PICTURE "@R! AAA-9N99" SIZE 140, 14 OF oDlg PIXEL

        @ 95, 10 SAY "Peso Bruto (F1_PBRUTO):" OF oDlg PIXEL
        @ 108, 10 GET nPBruto PICTURE "@E 9,999,999.9999" SIZE 220, 14 OF oDlg PIXEL

        @ 135, 10 SAY "Peso Líquido (F1_PLIQUI):" OF oDlg PIXEL
        @ 148, 10 GET nPLiqui PICTURE "@E 9,999,999.9999" SIZE 220, 14 OF oDlg PIXEL

        @ 195, 40 BUTTON "OK" SIZE 90, 20 OF oDlg PIXEL ;
            ACTION ( lOk := .T., oDlg:End() )

        @ 195, 145 BUTTON "Cancelar" SIZE 90, 20 OF oDlg PIXEL ;
            ACTION ( lOk := .F., oDlg:End() )

    ACTIVATE MSDIALOG oDlg CENTERED

    If !lOk
        RestArea(aArea)
        Return .F.
    EndIf

    // Segurança extra (garante tamanho)
    cChave := Left(AllTrim(cChave)+Space(nTamCh), nTamCh)
    cVeic1 := Left(AllTrim(cVeic1)+Space(nTamV1), nTamV1)

    // ==============================
    // VOLTA PARA O REGISTRO ORIGINAL
    // ==============================

    dbSelectArea("SF1")
    SF1->(DbGoTo(nRecSF1))

    If SF1->(Eof()) .Or. SF1->(Deleted())
        MsgStop("Não consegui reposicionar no registro.", "Erro")
        RestArea(aArea)
        Return .F.
    EndIf

    // ==============================
    // GRAVA
    // ==============================

    If SF1->(RecLock("SF1", .F.))

        SF1->F1_CHVNFE  := cChave
        SF1->F1_VEICUL1 := cVeic1
        SF1->F1_PBRUTO  := nPBruto
        SF1->F1_PLIQUI  := nPLiqui

        MsUnlock()
        dbCommit()

    Else
        MsgStop("Não foi possível travar o registro da SF1.", "Erro")
        RestArea(aArea)
        Return .F.
    EndIf

    // ==============================
    // CONFIRMAÇÃO
    // ==============================

    dbSelectArea("SF1")
    SF1->(DbGoTo(nRecSF1))

    MsgInfo(;
        "Gravou assim:" + CRLF + ;
        "F1_CHVNFE = " + AllTrim(SF1->F1_CHVNFE) + CRLF + ;
        "F1_VEICUL1 = " + AllTrim(SF1->F1_VEICUL1) + CRLF + ;
        "F1_PBRUTO = " + Transform(SF1->F1_PBRUTO, "@E 9,999,999.9999") + CRLF + ;
        "F1_PLIQUI = " + Transform(SF1->F1_PLIQUI, "@E 9,999,999.9999"), ;
        "Debug - Retorno")

    RestArea(aArea)
Return .T.
