#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  M410FSQL   ºAutor  ³JESUS RAMOS         º Data ³  08/02/26   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada que permite filtrar os pedidos de venda     ±±
±±º          ³exibidos na FWMBrowse, em que deve ser informada uma         ±±
±±º          ³expressão ADVPL para a realização do filtro.                 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ M410FSQL()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M410FSQL()
    Local cFiltro     := ""
    Local cEquipe     := ""
	// Local cJGGERLOJ   := SuperGetMV("JG_GERLOJ", .F., "XYZXYZ;") //Código do gerente da loja
	Local cCodVndLog  := POSICIONE("SA3",7,FWXFILIAL("SA3")+__CUSERID,"A3_COD")
	Local cCarVndLog  := POSICIONE("SA3",1,FWXFILIAL("SA3")+cCodVndLog,"A3_CARGO")

    If !FwIsAdmin() .And. !(cCarVndLog $ "000001;000002;") // Diretor e Supervisor/Gerente Geral
        If cCarVndLog == "000003" // Gerente de loja
            DbSelectArea("SA3")
            SA3->(DbSetOrder(4)) //A3_FILIAL+A3_GEREN
            SA3->(DbGoTop())
            SA3->(DbSeek(FWxFilial("SA3")+cCodVndLog))
            cEquipe := cCodVndLog + ";"
            While !SA3->(Eof()) .And. SA3->(A3_FILIAL+A3_GEREN) == FWxFilial("SA3")+cCodVndLog
                If !(SA3->A3_MSBLQL == "1")
                    cEquipe += SA3->A3_COD + ";"
                EndIf
                SA3->(DbSkip())
            EndDo
            cFiltro := " C5_VEND1 $ " + ValToSql(cEquipe) + " " 
        ElseIf cCarVndLog == "000004" // Vendedor
            cFiltro := " C5_VEND1 == " + ValToSql(cCodVndLog) + " " 
        EndIf
    EndIf

Return cFiltro
