#Include "Totvs.ch"
#Include "Protheus.ch"

User Function JGALTCOND()

    Local aArea    := GetArea()
    Local nRecSC5  := 0

    Local cCond    := ""         // C5_CONDPAG

    Local aParamBox := {}
    Local aRet      := {}

    // 1) SC5 posicionada
    If Select("SC5") <= 0 .Or. SC5->(Eof())
        MsgStop("Nenhum pedido posicionado na SC5.", "Atenção")
        RestArea(aArea)
        Return .F.
    EndIf

    nRecSC5 := SC5->(RecNo())

    // Valor atual
    If Type("SC5->C5_CONDPAG") == "C"
        cCond := SC5->C5_CONDPAG
    Else
        cCond := Space(TamSX3("C5_CONDPAG")[1])
    EndIf

    // ==============================
    // TELA
    // ==============================

    aAdd(aParamBox,{;
		    1,;                                         //[1]MsGet
        'Nova Condição:',;                                  //[2]Descrição
        cCond,;                                       //[3]String contendo o inicializador do campo
        "",;                                            //[4]String contendo a Picture do campo
        '.T.',;                                         //[5]String contendo a validação
        'SE4',;                                         //[6]Consulta F3
        '.T.',;                                         //[7]String contendo a validação When
        80,;                                            //[8]Tamanho do MsGet
        .F.;                                            //[9]Flag .T./.F. Parâmetro Obrigatório ?
	})

    If !ParamBox(aParamBox, "Alterar Condição de Pagamento", @aRet)
        RestArea(aArea)
        Return .F.
    EndIf

    cCond := PadR(aRet[1], TamSX3("C5_CONDPAG")[1])

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

        SC5->C5_CONDPAG := cCond

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
        "C5_CONDPAG = " + AllTrim(SC5->C5_CONDPAG), ;
        "Debug - Retorno")

    RestArea(aArea)
Return .T.
