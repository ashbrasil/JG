#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JGRT002    ºAutor  ³Jesus Ramos         º Data ³ 12/01/26   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para consulta de pedidos que estao reservando o       º±±
±±º          ³ produto informado                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function JGRT002(cProduto)
Local oGet1
Private cGetProduto	:= Space(6)
Private aBrowse 	:= ""
Private aDados		:= {{,,,,,,,,,,}}
Private aStatus		:= {}

Private aLegStPed	:= {LoadBitmap(GetResources(), "BR_VERDE"),;	// 1 - Pedido Normal
						LoadBitmap(GetResources(), "BR_MARROM"),;	// 2 - Pedido com Adiantamento
						LoadBitmap(GetResources(), "BR_BRANCO"),;	// 3 - Pedido com Adiantamento, já recebido
						LoadBitmap(GetResources(), "BR_AMARELO"),;	// 4 - Pedido com reserva em outra filial
						LoadBitmap(GetResources(), "BR_LARANJA"),;	// 5 - Pedido com reserva em outra filial, já recebido
						LoadBitmap(GetResources(), "BR_VERMELHO"),;	// 6 - Pedido já finalizado, sem baixa da reserva
						LoadBitmap(GetResources(), "BR_PRETO")}		// 7 - Pedido cancelado, sem baixa da reserva

DEFAULT cProduto := ""

If !EMPTY( cProduto )
	cGetProduto := cProduto
EndIf

oFont10A:= TFont():New("Arial", , 10, .F.)
oFont10B:= TFont():New("Arial", , 16, .F.)
oFont10B:Bold := .T.

DEFINE DIALOG oDlg TITLE "Consulta de Reservas" FROM 0,0 TO 450,1250 PIXEL //815 PIXEL
//oBrowse := TWBrowse():New( 22 , 03, 497, 177,,{'','Filial','Fil.Origem','Local','Tipo','Pedido','Qtde','Emissao','Vendedor','Cliente','Montagem'},;

oBrowse := TWBrowse():New( 22 ,03, 620, 166, ,{'','Filial','Fil.Origem','Local','Tipo','Pedido','Atendimento','Qtde','Emissao','Vendedor','Cliente','Montagem'},;
							{6,16,32,18,17,65,40,20,30,145,145,40},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
if Empty(aBrowse)
	aBrowse := aDados
	AAdd(aStatus,1)
endif
oBrowse:SetArray(aBrowse)

// Troca a imagem no duplo click do mouse
//	IIf(Len(aDados>1),aLegStPed[aDados[2][oBrowse:nAt]],;
oBrowse:bLine := {||{aLegStPed[aStatus[oBrowse:nAt]],;
	aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05],;
	aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,07], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11] } }

oBrowse:bLDblClick := {|| VerResPed()}

@ 007,007 Say "Produto:" Size 030,008 COLOR CLR_BLACK PIXEL OF oDlg
@ 005,030 MSGET oGet1 VAR cGetProduto F3 "SB1" Valid(RefreshBrw())SIZE 45,9 PIXEL OF oDlg
@ 007,090 Say POSICIONE("SB1",1,xFilial("SB1")+cGetProduto,"B1_DESC") Size 200,008 Font oFont10B COLOR CLR_BLACK PIXEL OF oDlg
@ 003,003 TO 19,623 LABEL "" OF oDlg PIXEL

//@ 190,003 TO 220,499 LABEL "" OF oDlg PIXEL

oPanel:= tPanel():New(190,003,,oDlg,oFont10A,.F.,,CLR_BLACK,CLR_WHITE,620,032,.T.,.T.)
//oGroup:= tGroup():New(190,003,222,499,"Legendas",oDlg,,,.T.)

TBtnBmp2():New( 006,010,26,26,'BR_VERDE'   ,,,,,oPanel,"Pedidos normais",,.T. )
TBtnBmp2():New( 022,010,26,26,'BR_MARROM'  ,,,,,oPanel,"Pedidos com adiantamento",,.T. )
TBtnBmp2():New( 038,010,26,26,'BR_BRANCO'  ,,,,,oPanel,"Pedidos com adiantamento, já recebidos",,.T. )
TBtnBmp2():New( 006,350,26,26,'BR_AMARELO' ,,,,,oPanel,"Pedidos com reserva em outra filial",,.T. )
TBtnBmp2():New( 022,350,26,26,'BR_LARANJA' ,,,,,oPanel,"Pedidos com reserva em outra filial, já recebidos",,.T. )
TBtnBmp2():New( 038,350,26,26,'BR_VERMELHO',,,,,oPanel,"Pedidos encerrados, cuja reserva não foi baixada",,.T. )
TBtnBmp2():New( 006,690,26,26,'BR_PRETO'   ,,,,,oPanel,"Pedidos cancelados, cuja reserva não foi baixada",,.T. )
/*
oBtnNormal := TBtnBmp2():New( 006,010,26,26,'BR_VERDE'   ,,,,,oPanel,"Pedidos normais",,.T. )
oBtnAdiant := TBtnBmp2():New( 022,010,26,26,'BR_MARROM'  ,,,,,oPanel,"Pedidos com adiantamento",,.T. )
oBtnAdiRec := TBtnBmp2():New( 038,010,26,26,'BR_BRANCO'  ,,,,,oPanel,"Pedidos com adiantamento, já recebidos",,.T. )
oBtnOutFil := TBtnBmp2():New( 006,350,26,26,'BR_AMARELO' ,,,,,oPanel,"Pedidos com reserva em outra filial",,.T. )
oBtnFilRec := TBtnBmp2():New( 022,350,26,26,'BR_LARANJA' ,,,,,oPanel,"Pedidos com reserva em outra filial, já recebidos",,.T. )
oBtnFimRes := TBtnBmp2():New( 038,350,26,26,'BR_VERMELHO',,,,,oPanel,"Pedidos encerrados, cuja reserva não foi baixada",,.T. )
oBtnCanRes := TBtnBmp2():New( 006,690,26,26,'BR_PRETO'   ,,,,,oPanel,"Pedidos cancelados, cuja reserva não foi baixada",,.T. )
*/
@ 006,020 Say "Pedidos normais" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 014,020 Say "Pedidos com adiantamento" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 022,020 Say "Pedidos com adiantamento, já recebidos" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 006,190 Say "Pedidos com reserva em outra filial" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 014,190 Say "Pedidos com reserva em outra filial, já recebidos" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 022,190 Say "Pedidos encerrados, cuja reserva não foi baixada" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel
@ 006,360 Say "Pedidos cancelados, cuja reserva não foi baixada" Size 150,008 COLOR CLR_BLACK PIXEL OF oPanel

//Lorran Ferreira - 02/03/2020
IF !EMPTY( cGetProduto )
	RefreshBrw()
ENDIF

ACTIVATE DIALOG oDlg CENTERED

Return()

//Função para preencher o listbox
Static Function RefreshBrw()

Local cQry     := ""
Local lSelSB1  := (Select("SB1") > 0)
Local lProdOk  := .F.
Local aArea    := GetArea()

dbSelectArea("SB1")
dbSetOrder(1)

lProdOk := MsSeek(xFilial("SB1")+cGetProduto)

If !lSelSB1
	SB1->(dbCloseArea())
EndIf
RestArea(aArea)

If !lProdOk
	MsgInfo("Produto não cadastrado. Favor informar um produto válido.","Consulta e validação do produto")
	Return()
EndIf

aDados  := {}
aStatus := {}

	// Script de pesquisa das reservas
	cQry := "SELECT "+CRLF
	cQry += "	CASE WHEN RES_FILIAL = '"+cFilAnt+"' THEN 1 ELSE 2 END RES_ORDEM, "+CRLF
	cQry += "	RES_PRODUT, RES_LOCAL, RES_STATUS, RES_FILIAL, RES_FILORI, RES_TIPO, RES_PEDIDO, RES_NUMATEN, RES_EMISSA, RES_QUANT, "+CRLF
	cQry += "	CASE "+CRLF
	cQry += "		WHEN RES_VEND IS NULL THEN '' "+CRLF
	cQry += "		ELSE RES_VEND || "+CRLF
	cQry += "			CASE WHEN A3_NOME IS NULL THEN '' ELSE ' - ' || RTRIM(A3_NOME) END "+CRLF
	cQry += "	END AS RES_VEND, "+CRLF
	cQry += "	CASE "+CRLF
	cQry += "		WHEN COALESCE(RES_CLIENT,'') = ' ' THEN RES_CLIONL "+CRLF
	cQry += "		ELSE RES_CLIENT || '-' || RES_LOJA || "+CRLF
	cQry += "			CASE WHEN A1_NOME IS NULL THEN '' ELSE ' - ' || RTRIM(A1_NOME) END "+CRLF
	cQry += "	END AS RES_CLIENT, "+CRLF
	// cQry += "	CASE "+CRLF
	// cQry += "		WHEN RES_MONTAG = 'A' THEN 'ABERTO' "+CRLF
	// cQry += "		WHEN RES_MONTAG = 'M' THEN 'MONTAGEM' "+CRLF
	// cQry += "		WHEN RES_MONTAG = 'E' THEN 'ENCERRADO' "+CRLF
	// cQry += "		ELSE ' ' "+CRLF
	// cQry += "	END AS RES_MONTAG "+CRLF
	cQry += "	' ' AS RES_MONTAG "+CRLF
	cQry += "FROM ( "+CRLF
	cQry += "	SELECT "+CRLF
	cQry += "		CASE "+CRLF
	cQry += "			WHEN C5_FILIAL IS NULL THEN 7 "+CRLF
	cQry += "			WHEN C5_ORCRES = '' THEN 1 "+CRLF
	cQry += "			ELSE 3 "+CRLF
	cQry += "		END RES_STATUS, "+CRLF
	cQry += "		C0_FILIAL AS RES_FILIAL, "+CRLF
	cQry += "		C0_NUM AS RES_NUMRES, "+CRLF
	cQry += "		CASE "+CRLF
	cQry += "			WHEN C0_FILRES = ' ' OR C0_FILRES = C0_FILIAL THEN RPAD('',LENGTH(C0_FILIAL),' ') "+CRLF
	cQry += "			ELSE C0_FILRES "+CRLF
	cQry += "		END AS RES_FILORI, "+CRLF
	cQry += "		'FAT' AS RES_TIPO, "+CRLF
	cQry += "		C0_DOCRES AS RES_PEDIDO, "+CRLF

	// cQry += "		CASE "+CRLF
	// cQry += "			WHEN C5_XORCAM <> '' THEN "+CRLF
	// cQry += "				(	SELECT "+CRLF
	// cQry += "						TOP 1 UA_NUM "+CRLF
	// cQry += "					FROM "+CRLF
	// cQry += "						" + RetSqlName("SUA")+CRLF
	// cQry += "					WHERE "+CRLF
	// cQry += "						UA_FILIAL = C5_FILIAL AND UA_NUMSL1 = C5_XORCAM "+CRLF
	// cQry += "					ORDER BY "+CRLF
	// cQry += "						R_E_C_N_O_ DESC) "+CRLF
	// cQry += "			WHEN C5_ORCRES <> '' THEN "+CRLF
	// cQry += "				(	SELECT "+CRLF
	// cQry += "						TOP 1 UA_NUM "+CRLF
	// cQry += "					FROM "+CRLF
	// cQry += "						" + RetSqlName("SL1") + " LX "+CRLF
	// cQry += "						LEFT JOIN " + RetSqlName("SL1") + " L1 "+CRLF
	// cQry += "							ON L1.D_E_L_E_T_ <> '*' AND L1.L1_FILIAL = LX.L1_FILIAL AND L1.L1_NUM = LX.L1_ORCRES "+CRLF
	// cQry += "						LEFT JOIN " + RetSqlName("SUA") + " UA "+CRLF
	// cQry += "							ON UA.D_E_L_E_T_ <> '*' AND UA_FILIAL = L1.L1_FILIAL AND (UA_NUM = L1.L1_NUMATEN OR UA_NUMSL1 = L1.L1_NUM) "+CRLF
	// cQry += "					WHERE "+CRLF
	// cQry += "						LX.D_E_L_E_T_ <> '*' AND LX.L1_FILIAL = C5_FILIAL AND LX.L1_NUM = C5_ORCRES "+CRLF
	// cQry += "					ORDER BY "+CRLF
	// cQry += "						UA.R_E_C_N_O_ DESC) "+CRLF 
	// cQry += "			ELSE  "+CRLF
	// cQry += "				(	SELECT UA_NUM FROM SUA010 UA WHERE UA.D_E_L_E_T_ <> '*' AND UA_FILIAL = C5_FILIAL AND UA_NUMSC5 = C5_NUM) "+CRLF 
	// cQry += "		END AS RES_NUMATEN, "+CRLF
	cQry += "		' ' AS RES_NUMATEN, "+CRLF

	cQry += "		CASE WHEN C5_EMISSAO IS NULL THEN C0_EMISSAO ELSE C5_EMISSAO END AS RES_EMISSA, "+CRLF
	cQry += "		C5_VEND1 AS RES_VEND, "+CRLF
	cQry += "		C5_CLIENTE AS RES_CLIENT, "+CRLF
	cQry += "		C5_LOJACLI AS RES_LOJA, "+CRLF
	cQry += "		' ' AS RES_CLIONL, "+CRLF
	cQry += "		C0_PRODUTO AS RES_PRODUT, "+CRLF
	cQry += "		C0_LOCAL AS RES_LOCAL, "+CRLF
	// cQry += "		C5_XMOVMON AS RES_MONTAG, "+CRLF
	cQry += "		' ' AS RES_MONTAG, "+CRLF

	cQry += "		CASE "+CRLF
	cQry += "			WHEN C0_TIPO = 'PD' THEN "+CRLF
	cQry += "				CASE WHEN C0_QUANT > 0 THEN C0_QUANT ELSE C0_QTDPED END "+CRLF
	cQry += "			ELSE "+CRLF
	cQry += "				C6_QTDVEN - C6_QTDENT "+CRLF
	cQry += "		END AS RES_QUANT, "+CRLF

	cQry += "		C0.R_E_C_N_O_ AS RECNO, "+CRLF
	cQry += "		'SC0' AS TB_RECNO "+CRLF
	cQry += "	FROM "+CRLF
	cQry += "		" + RetSqlName("SC0") + " C0 "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SC9") + " C9 "+CRLF
	cQry += "			ON C9.D_E_L_E_T_ <> '*' AND C9_FILIAL = C0_FILIAL AND C9_PEDIDO = C0_DOCRES "+CRLF
	cQry += "				AND C9_PRODUTO = C0_PRODUTO AND C9_RESERVA = C0_NUM AND C9_NFISCAL = '"+Space(TamSx3("C9_NFISCAL")[2])+"' "+CRLF
	cQry += "				AND C9_SERIENF = '"+Space(TamSx3("C9_SERIENF")[2])+"' "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SC6") + " C6 "+CRLF
	cQry += "			ON C6.D_E_L_E_T_ <> '*' AND C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SC5") + " C5 "+CRLF
	cQry += "			ON C5.D_E_L_E_T_ <> '*' AND C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "+CRLF
	cQry += "	WHERE "+CRLF
	cQry += "		C0.D_E_L_E_T_ <> '*' "+CRLF
	cQry += "		AND C0_PRODUTO = " + ValToSql(cGetProduto) + " "+CRLF
	cQry += "		AND (C0_TIPO = 'PD' AND (C0_QUANT > 0 OR C0_QUANT = 0 AND C0_QTDPED > 0) "+CRLF
	cQry += "		  OR (C0_TIPO = 'LB' AND C9_FILIAL IS NOT NULL AND (C6_QTDVEN - C6_QTDENT) > 0) ) "+CRLF

	cQry += "	UNION "+CRLF
	
	cQry += "	SELECT DISTINCT "+CRLF
	cQry += "		CASE "+CRLF
	// cQry += "			WHEN ZZA_PDMKTP IS NOT NULL AND ZZA_STAMP IN ('01','ECCC') THEN 7 "+CRLF
	// cQry += "			WHEN L2.L2_FILIAL IS NULL THEN "+CRLF
	// cQry += "				CASE "+CRLF
	// cQry += "					WHEN ZA.ZZA_FILIAL IS NULL THEN 7 "+CRLF
	// cQry += "					ELSE 1 "+CRLF
	// cQry += "				END "+CRLF
	cQry += "			WHEN COALESCE(L1.L1_DOC,'') <> ' ' OR COALESCE(LX.L1_DOC,'') <> ' ' THEN 6 "+CRLF
	cQry += "			WHEN LX.L1_ORCRES IS NULL THEN "+CRLF
	cQry += "				CASE "+CRLF
	cQry += "					WHEN L2_ENTREGA = '1'   THEN 4 "+CRLF
	cQry += "					WHEN L2_ENTREGA = '3'   THEN 2 "+CRLF
	cQry += "					ELSE 1 "+CRLF
	cQry += "				END "+CRLF
	cQry += "			ELSE "+CRLF
	cQry += "				CASE "+CRLF
	cQry += "					WHEN LX.L1_PEDRES <> '' THEN 3 "+CRLF
	cQry += "					WHEN L2_ENTREGA = '1'   THEN 5 "+CRLF
	cQry += "					ELSE 1 "+CRLF
	cQry += "				END "+CRLF
	cQry += "		END AS RES_STATUS, "+CRLF
	cQry += "		C0_FILIAL AS RES_FILIAL, "+CRLF
	cQry += "		C0_NUM AS RES_NUMRES, "+CRLF
	cQry += "		CASE "+CRLF
	cQry += "			WHEN C0_FILRES = ' ' OR C0_FILRES = C0_FILIAL THEN RPAD('',LENGTH(C0_FILIAL),' ') "+CRLF
	cQry += "			ELSE C0_FILRES "+CRLF
	cQry += "		END AS RES_FILORI, "+CRLF
	// cQry += "		CASE WHEN ZA.ZZA_FILIAL IS NOT NULL THEN 'ONL' ELSE 'LOJ' END AS RES_TIPO, "+CRLF
	cQry += "		'LOJ' AS RES_TIPO, "+CRLF
	// cQry += "		CASE "+CRLF
	// cQry += "			WHEN ZA.ZZA_PDMKTP IS NULL THEN  C0_DOCRES "+CRLF
	// cQry += "			ELSE ZA.ZZA_PDMKTP "+CRLF
	// cQry += "		END AS RES_PEDIDO, "+CRLF
	cQry += "		C0_DOCRES AS RES_PEDIDO, "+CRLF
	// cQry += "		CASE "+CRLF
	// cQry += "			WHEN L1.L1_NUMATEN <> '' THEN L1.L1_NUMATEN "+CRLF
	// cQry += "			WHEN LX.L1_NUMATEN <> '' THEN LX.L1_NUMATEN "+CRLF
	// cQry += "			WHEN ZA.ZZA_FILIAL IS NOT NULL THEN 'ONLINE' "+CRLF
	// cQry += "			ELSE '' "+CRLF
	// cQry += "		END AS RES_ATENDIMENTO, "+CRLF
	cQry += "		' ' AS RES_ATENDIMENTO, "+CRLF
	cQry += "		C0_EMISSAO AS RES_EMISSA, "+CRLF
	cQry += "		L1.L1_VEND AS RES_VEND, "+CRLF

	// cQry += "		CASE WHEN COALESCE(ZA.ZZA_CODCLI,'') <> '' THEN ZA.ZZA_CODCLI ELSE L1.L1_CLIENTE END AS RES_CLIENT, "+CRLF
	cQry += "		L1.L1_CLIENTE AS RES_CLIENT, "+CRLF
	// cQry += "		CASE WHEN COALESCE(ZA.ZZA_CODCLI,'') <> '' THEN ZA.ZZA_LJCLI ELSE L1.L1_LOJA END AS RES_LOJA, "+CRLF
	cQry += "		L1.L1_LOJA AS RES_LOJA, "+CRLF
	// cQry += "		COALESCE(ZA.ZZA_NOME,'') AS RES_CLIONL, "+CRLF
	cQry += "		' ' AS RES_CLIONL, "+CRLF
	cQry += "		C0_PRODUTO AS RES_PRODUT, "+CRLF
	cQry += "		C0_LOCAL AS RES_LOCAL, "+CRLF
	// cQry += "		CASE "+CRLF
	// cQry += "			WHEN L1.L1_XMOVMON = 'A' THEN 'ABERTO' "+CRLF
	// cQry += "			WHEN L1.L1_XMOVMON = 'M' THEN 'MONTAGEM' "+CRLF
	// cQry += "			WHEN L1.L1_XMOVMON = 'E' THEN 'ENCERRADO' "+CRLF
	// cQry += "			ELSE ' ' "+CRLF
	// cQry += "		END AS RES_MONTAG, "+CRLF
	cQry += "		' ' AS RES_MONTAG, "+CRLF
	cQry += "		C0_QUANT AS RES_QUANT, "+CRLF
	cQry += "		C0.R_E_C_N_O_ AS RECNO, "+CRLF
	cQry += "		'SC0' AS TB_RECNO "+CRLF
	cQry += "	FROM "+CRLF
	cQry += "		" + RetSqlName("SC0") + " C0 "+CRLF
	// cQry += "		LEFT JOIN " + RetSqlName("ZZA") + " ZA "+CRLF
	// cQry += "			ON ZA.D_E_L_E_T_ = ' ' AND SUBSTRING(C0.C0_OBS,1,4) = 'Ped.' AND CHARINDEX('-ZZA_PDMKTP:',C0.C0_OBS,5) > 0 "+CRLF
	// cQry += "				AND RTRIM(ZA.ZZA_PDMKTP) = RTRIM(SUBSTRING(C0.C0_OBS,CHARINDEX('-ZZA_PDMKTP:',C0.C0_OBS,5)+12,LEN(C0.C0_OBS)-(CHARINDEX('-ZZA_PDMKTP:',C0.C0_OBS,5)+11))) "+CRLF
	// // cQry += "			ON SUBSTRING(C0.C0_OBS,1,18) IN ('Ped.MP-ZZA_PDMKTP:','Ped.EC-ZZA_PDMKTP:') "+CRLF
	// // cQry += "				AND ZA.D_E_L_E_T_ <> '*' AND RTRIM(ZA.ZZA_PDMKTP) = RTRIM(SUBSTRING(C0.C0_OBS,19,LEN(C0.C0_OBS)-18)) "+CRLF
	// cQry += "		LEFT JOIN " + RetSqlName("ZZB") + " ZB "+CRLF
	// cQry += "			ON ZB.D_E_L_E_T_ <> '*' AND ZB.ZZB_FILIAL = ZA.ZZA_FILIAL AND ZB.ZZB_NUM = ZA.ZZA_NUM AND ZB.ZZB_RESERV = C0.C0_NUM "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SL2") + " L2 "+CRLF
	cQry += "			ON L2.D_E_L_E_T_ <> '*' AND L2.L2_FILIAL = C0.C0_FILRES AND L2.L2_NUM = C0.C0_DOCRES "+CRLF
	cQry += "				AND L2.L2_PRODUTO = C0.C0_PRODUTO AND L2.L2_RESERVA = C0_NUM "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SL1") + " L1 "+CRLF
	cQry += "			ON L1.D_E_L_E_T_ <> '*' AND L1.L1_FILIAL = L2.L2_FILIAL AND L1.L1_NUM = L2.L2_NUM "+CRLF
	cQry += "		LEFT JOIN " + RetSqlName("SL1") + " LX "+CRLF
	cQry += "			ON LX.D_E_L_E_T_ <> '*' AND LX.L1_FILRES = L1.L1_FILIAL AND LX.L1_ORCRES = L1.L1_NUM "+CRLF
	cQry += "	WHERE "+CRLF
	cQry += "		C0.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "		AND C0_PRODUTO = " + ValToSql(cGetProduto) + " "+CRLF
	cQry += "		AND C0_TIPO IN ('LJ','EC','MP') "+CRLF
	cQry += "		AND C0_QUANT > 0 "+CRLF

	cQry += "	UNION"+CRLF

	cQry += "	SELECT"+CRLF
	cQry += "		CASE"+CRLF
	cQry += "			WHEN C5_FILIAL IS NULL THEN 7 "+CRLF
	cQry += "			WHEN C5_ORCRES = ' ' THEN 1 "+CRLF
	cQry += "			ELSE 3 "+CRLF
	cQry += "		END RES_STATUS, "+CRLF
	cQry += "		C9_FILIAL AS RES_FILIAL, "+CRLF
	cQry += "		C9_RESERVA AS RES_NUMRES, "+CRLF
	cQry += "		'" + Space(TamSx3("C9_FILIAL")[2]) + "' AS RES_FILORI, "+CRLF
	cQry += "		'FAT' AS RES_TIPO, "+CRLF
	cQry += "		C9_PEDIDO AS RES_PEDIDO, "+CRLF

	// cQry += "		CASE "+CRLF
	// cQry += "			WHEN C5_XORCAM <> '' THEN "+CRLF
	// cQry += "				(	SELECT TOP 1 UA_NUM FROM " + RetSqlName("SUA") + " WHERE UA_FILIAL = C5_FILIAL AND UA_NUMSL1 = C5_XORCAM ORDER BY R_E_C_N_O_ DESC) "+CRLF 
	// cQry += "			WHEN C5_ORCRES <> '' THEN "+CRLF 
	// cQry += "				(	SELECT "+CRLF
	// cQry += "						TOP 1 UA_NUM "+CRLF 
	// cQry += "					FROM "+CRLF
	// cQry += "						" + RetSqlName("SL1") + " LX "+CRLF
	// cQry += "						LEFT JOIN " + RetSqlName("SL1") + " L1 "+CRLF
	// cQry += "							ON L1.D_E_L_E_T_ <> '*' AND L1.L1_FILIAL = LX.L1_FILIAL AND L1.L1_NUM = LX.L1_ORCRES "+CRLF
	// cQry += "						LEFT JOIN " + RetSqlName("SUA") + " UA "+CRLF
	// cQry += "							ON UA.D_E_L_E_T_ <> '*' AND UA_FILIAL = L1.L1_FILIAL AND (UA_NUM = L1.L1_NUMATEN OR UA_NUMSL1 = L1.L1_NUM) "+CRLF
	// cQry += "					WHERE "+CRLF
	// cQry += "						LX.D_E_L_E_T_ <> '*' AND LX.L1_FILIAL = C5_FILIAL AND LX.L1_NUM = C5_ORCRES "+CRLF
	// cQry += "					ORDER BY "+CRLF
	// cQry += "						UA.R_E_C_N_O_ DESC) "+CRLF 
	// cQry += "			ELSE  "+CRLF
	// cQry += "				(	SELECT UA_NUM FROM SUA010 UA WHERE UA.D_E_L_E_T_ <> '*' AND UA_FILIAL = C5_FILIAL AND UA_NUMSC5 = C5_NUM) "+CRLF 
	// cQry += "		END AS RES_NUMATEN, "+CRLF
	cQry += "		' ' AS RES_NUMATEN, "+CRLF

	cQry += "		CASE WHEN C5_EMISSAO IS NULL THEN C9_DATALIB ELSE C5_EMISSAO END AS RES_EMISSA, "+CRLF
	cQry += "		C5_VEND1 AS RES_VEND, "+CRLF
	cQry += "		C5_CLIENTE AS RES_CLIENT, "+CRLF
	cQry += "		C5_LOJACLI AS RES_LOJA, "+CRLF
	cQry += "		' ' AS RES_CLIONL, "+CRLF
	cQry += "		C9_PRODUTO AS RES_PRODUT, "+CRLF
	cQry += "		C9_LOCAL AS RES_LOCAL, "+CRLF
	// cQry += "		C5_XMOVMON AS RES_MONTAG, "+CRLF
	cQry += "		' ' AS RES_MONTAG, "+CRLF

	cQry += "		C9.C9_QTDLIB AS RES_QUANT, "+CRLF
	cQry += "		C9.R_E_C_N_O_ AS RECNO, "+CRLF
	cQry += "		'SC9' AS TB_RECNO "+CRLF
	cQry += "	FROM "+CRLF
	cQry += "		" + RetSqlName("SC9") + " C9 "+CRLF
	cQry += "		INNER JOIN " + RetSqlName("SC5") + " C5 "+CRLF
	cQry += "			ON C5.D_E_L_E_T_ <> '*' AND C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "+CRLF
	cQry += "		INNER JOIN " + RetSqlName("SC6") + " C6 "+CRLF
	cQry += "			ON C6.D_E_L_E_T_ = ' ' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_ITEM = C9_ITEM "+CRLF
	cQry += "		INNER JOIN " + RetSqlName("SF4") + " F4 "+CRLF
	cQry += "			ON F4.D_E_L_E_T_ = ' ' AND F4_FILIAL = F4_FILIAL AND F4_CODIGO = C6_TES "+CRLF
	cQry += "	WHERE "+CRLF
	cQry += "		C9.D_E_L_E_T_  = ' ' "+CRLF
	cQry += "		AND C9_PRODUTO = " + ValToSql(cGetProduto) + " "+CRLF
	cQry += "		AND C9_BLEST   = '" + Space(TamSx3("C9_BLEST")[2]) + "' "+CRLF
	cQry += "		AND C9_RESERVA = '" + Space(TamSx3("C9_RESERVA")[2]) + "' "+CRLF
	cQry += "		AND C9_NFISCAL = '" + Space(TamSx3("C9_NFISCAL")[2]) + "' "+CRLF
	cQry += "		AND C5_NOTA    = '" + Space(TamSx3("C5_NOTA")[2])+"' "+CRLF
	cQry += "		AND F4_ESTOQUE = 'S' "+CRLF

	cQry += "	) RES "+CRLF
	cQry += "	LEFT JOIN " + RetSqlName("SA3") + " A3 "+CRLF
	cQry += "		ON A3.D_E_L_E_T_ = ' ' AND A3_FILIAL = " + ValToSql(xFilial("SA3")) + " AND RES_VEND = A3_COD "+CRLF
	cQry += "	LEFT JOIN " + RetSqlName("SA1") + " A1 "+CRLF
	cQry += "		ON A1.D_E_L_E_T_ = ' ' AND A1_FILIAL = " + ValToSql(xFilial("SA1")) + " AND A1_COD = RES_CLIENT AND A1_LOJA = RES_LOJA "+CRLF
	cQry += "ORDER BY "+CRLF
	cQry += "	RES_ORDEM, RES_FILIAL, RES_PRODUT, RES_LOCAL, RES_EMISSA DESC, RES_PEDIDO DESC "+CRLF

MemoWrite("c:\temp\consultareserva.sql",cQry)
// cQry := ChangeQuery(cQry)
// MemoWrite("c:\temp\consultareserva_chgqry.sql",cQry)

If Select("QRYRES") > 0
	dbSelectArea( "QRYRES" )  
	QRYRES->(dbCloseArea())
EndIf

TcQuery cQry New Alias "QRYRES" // Cria uma nova area com o resultado do query

While  QRYRES->(!Eof())
	
	AAdd(aDados,{;
			AllTrim(QRYRES->RES_FILIAL),;
			AllTrim(QRYRES->RES_FILORI),;
			AllTrim(QRYRES->RES_LOCAL),;
			AllTrim(QRYRES->RES_TIPO),;
			AllTrim(QRYRES->RES_PEDIDO),;
			AllTrim(QRYRES->RES_NUMATEN),;
			QRYRES->RES_QUANT,;
			SToD(QRYRES->RES_EMISSA),;
			AllTrim(QRYRES->RES_VEND),;
			AllTrim(QRYRES->RES_CLIENT),;
			AllTrim(QRYRES->RES_MONTAG);
	})
	AAdd(aStatus,QRYRES->RES_STATUS)
	QRYRES->(DbSkip())
	
Enddo
      
DbSelectArea("QRYRES")
QRYRES->(DbCloseArea())

If Empty(aDados)
	
	AAdd(aDados,{,,,,,,,,,,})
	AAdd(aStatus,1)
//	AAdd(_aBrowse,{{,,,,,,,,,},1})
//	AAdd(_aStatus,1)
//	AAdd(aDados,{,,,,,,,,,})
//	AAdd(aDados,{,,,,,,,,,})
	
EndIf

aBrowse := aDados
oBrowse:nAt := 1
oBrowse:SetArray(aBrowse)

oBrowse:bLine := {||{;
	aLegStPed[aStatus[oBrowse:nAt]],;
	aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],;
	aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09],aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11] } }
oBrowse:Refresh()

Return()

Static Function VerResPed()

Local cMsg := ""
Local nCol
// Local nLin := oBrowse:nAt
Local aHd  := oBrowse:aHeaders
Local aCl  := Iif(Len(aBrowse)>0,aBrowse[oBrowse:nAt],{})

//VarInfo("aHd",aHd)
//VarInfo("aCl",aCl)
//VarInfo("aBrowse",aBrowse)

If Len(aCl) == 0 .Or. ValType(aCl[1]) == "U"
	Return
EndIf

For nCol:=1 To Len(aCl)
	cMsg += aHd[nCol+1]+": "
	If ValType(aCl[nCol]) == "N"
		cMsg += CValToChar(aCl[nCol])
	ElseIf ValType(aCl[nCol]) == "D"
		cMsg += DToC(aCl[nCol])
	Else
		cMsg += aCl[nCol]
	EndIf
	cMsg += CRLF
Next nCol

MsgInfo(cMsg,"Especificação da reserva")

/*
For nX:=2 To oBrowse:nAt])
	cMsg += oBrowse:aHeaders[nX]+": "
	If ValType(aBrowse[oBrowse:nAt,nX]) == "N"
		cMsg += CValToChar(aBrowse[oBrowse:nAt,nX])
	ElseIf ValType(aBrowse[oBrowse:nAt,nX]) == "D"
		cMsg += DToC(aBrowse[oBrowse:nAt,nX])
	Else
		cMsg += aBrowse[oBrowse:nAt,nX]
	EndIf
Next nX

MsgInfo("","Especificação da reserva")
*/
/*oBrowse
oBrowse := TWBrowse():New( 22 ,03, 597, 166,,{'','Filial','Fil.Origem','Local','Tipo','Pedido','Atendimento','Qtde','Emissao','Vendedor','Cliente','Montagem'},;
							{6,16,32,18,17,25,40,20,30,135,135,40},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
if Empty(aBrowse)
	aBrowse := aDados
	AAdd(aStatus,1)
endif
oBrowse:SetArray(aBrowse)

// Troca a imagem no duplo click do mouse
//	IIf(Len(aDados>1),aLegStPed[aDados[2][oBrowse:nAt]],;
oBrowse:bLine := {||{aLegStPed[aStatus[oBrowse:nAt]],;
	aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05],;
	aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,07], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11] } }

oBrowse:bLDblClick := {|| VerResPed(aBrowse[oBrowse:nAt])}
*/
Return()
