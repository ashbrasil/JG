#Include "Totvs.ch"
#Include "Protheus.ch"

User Function ZSC5VEIC()

    Local aArea    := GetArea()
    Local nRecSC5  := 0

    Local nPesol   := 0          // C5_PESOL
    Local nPBruto  := 0          // C5_PBRUTO
    Local nVol1    := 0          // C5_VOLUME1
    Local cEsp1    := ""         // C5_ESPECI1

    Local oDlg     := Nil
    Local lOk      := .F.

    // 1) SC5 posicionada
    If Select("SC5") <= 0 .Or. SC5->(Eof())
        MsgStop("Nenhum pedido posicionado na SC5.", "Atenção")
        RestArea(aArea)
        Return .F.
    EndIf

    nRecSC5 := SC5->(RecNo())

    // Valores atuais
    If Type("SC5->C5_PESOL") == "N"
        nPesol := SC5->C5_PESOL
    EndIf

    If Type("SC5->C5_PBRUTO") == "N"
        nPBruto := SC5->C5_PBRUTO
    EndIf

    If Type("SC5->C5_VOLUME1") == "N"
        nVol1 := SC5->C5_VOLUME1
    EndIf

    If Type("SC5->C5_ESPECI1") == "C"
        cEsp1 := SC5->C5_ESPECI1
    Else
        cEsp1 := Space(TamSX3("C5_ESPECI1")[1])
    EndIf

    // ==============================
    // TELA
    // ==============================

    // DEFINE MSDIALOG oDlg TITLE "Informar dados do Pedido de venda (SC5)" FROM 0,0 TO 480,1350 PIXEL
    DEFINE MSDIALOG oDlg TITLE "Informar dados do Pedido de venda (SC5)" FROM 0,0 TO 480,510 PIXEL

        @ 15, 10 SAY "Peso Líquido (C5_PESOL):" OF oDlg PIXEL
        @ 28, 10 GET nPesol PICTURE "@E 9,999,999.9999" SIZE 240, 14 OF oDlg PIXEL

        @ 55, 10 SAY "Peso Bruto (C5_PBRUTO):" OF oDlg PIXEL
        @ 68, 10 GET nPBruto PICTURE "@E 9,999,999.9999" SIZE 240, 14 OF oDlg PIXEL

        @ 95, 10 SAY "Volume (C5_VOLUME1):" OF oDlg PIXEL
        @ 108, 10 GET nVol1 PICTURE "@E 99999" SIZE 140, 14 OF oDlg PIXEL

        @ 135, 10 SAY "Espécie (C5_ESPECI1):" OF oDlg PIXEL
        @ 148, 10 GET cEsp1 PICTURE "@X!" SIZE 200, 14 OF oDlg PIXEL

        @ 195, 40 BUTTON "OK" SIZE 90, 20 OF oDlg PIXEL ;
            ACTION ( lOk := .T., oDlg:End() )

        @ 195, 145 BUTTON "Cancelar" SIZE 90, 20 OF oDlg PIXEL ;
            ACTION ( lOk := .F., oDlg:End() )

    ACTIVATE MSDIALOG oDlg CENTERED

    If !lOk
        RestArea(aArea)
        Return .F.
    EndIf

    // Segurança extra
    cEsp1 := Left(AllTrim(cEsp1)+Space(TamSX3("C5_ESPECI1")[1]), TamSX3("C5_ESPECI1")[1])

    // ==============================
    // VOLTA PARA O REGISTRO ORIGINAL
    // ==============================

    dbSelectArea("SC5")
    SC5->(DbGoTo(nRecSC5))

    If SC5->(Eof()) .Or. SC5->(Deleted())
        MsgStop("Não consegui reposicionar no registro.", "Erro")
        RestArea(aArea)
        Return .F.
    EndIf

    // ==============================
    // GRAVA
    // ==============================

    If SC5->(RecLock("SC5", .F.))

        SC5->C5_PESOL   := nPesol
        SC5->C5_PBRUTO  := nPBruto
        SC5->C5_VOLUME1 := nVol1
        SC5->C5_ESPECI1 := cEsp1

        MsUnlock()
        dbCommit()

    Else
        MsgStop("Não foi possível travar o registro da SC5.", "Erro")
        RestArea(aArea)
        Return .F.
    EndIf

    // ==============================
    // CONFIRMAÇÃO
    // ==============================

    dbSelectArea("SC5")
    SC5->(DbGoTo(nRecSC5))

    MsgInfo(;
        "Gravou assim:" + CRLF + ;
        "C5_PESOL   = " + Transform(SC5->C5_PESOL,  "@E 9,999,999.9999") + CRLF + ;
        "C5_PBRUTO  = " + Transform(SC5->C5_PBRUTO, "@E 9,999,999.9999") + CRLF + ;
        "C5_VOLUME1 = " + Transform(SC5->C5_VOLUME1, "@E 99999") + CRLF + ;
        "C5_ESPECI1 = " + AllTrim(SC5->C5_ESPECI1), ;
        "Debug - Retorno")

    RestArea(aArea)
Return .T.
