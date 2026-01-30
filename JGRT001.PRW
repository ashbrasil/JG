#include "totvs.ch"
#Include "TopConn.Ch"
#Include "tbiconn.ch"

#Define nPEmpresa 3
#Define nPFilial  2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ JGRT001  บAutor  ณ Jesus Ramos        บ Data ณ  12/01/26   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta aos dados dos produtos                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ JG                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function JGRT001(_cCodProd)
	Local _cChave     := Space(TamSX3("B1_COD")[1])
	Local _cChvBar    := Space(TamSX3("B1_CODBAR")[1])
	Local _cChvRFor   := Space(TamSX3("A5_CODPRF")[1])
	Local _cDesc	  := Space(TamSX3("B1_DESC")[1])
	Local _cChvGr	  := Space(TamSX3("B1_GRUPO")[1]) //chave para grupo produto
	Local _cChvFab	  := Space(TamSX3("B1_FABRIC")[1]) //chave para fabricante/marca
	Local _cChvCA	  := Space(TamSX3("B1_XCA")[1]) //chave para C.A.
	Local _aTitulos   := {}
	Local cEmpBkp     := ""
	Local cFilBkp     := ""
	Local _cUFFil     := ""
	Local aSM0Lista   := {}
	Local ainfSM0     := {}
	Local nF

	Local _aArea      := FWGetArea()
	Local _aSM0       := SM0->( FWGetArea() )
	Local _aDA1       := DA1->( FWGetArea() )
	Local _aSF4       := SF4->( FWGetArea() )
	Local _aSB5       := SB5->( FWGetArea() )
	Local _aSA1       := SA1->( FWGetArea() )
	Local _aSA2       := SA2->( FWGetArea() )
	Local _aSY1       := SY1->( FWGetArea() )

	Private _cFiliais := ""
	Private _cRet     := ""
	Private _oBar
	Private _oLbl1
	Private _oLbl2
	Private _oLbl3
	Private _oLbl4
	Private _oSldB2
	Private _oSay11
	Private _oSay12
	Private _oSay21
	Private _oSay22
	Private _oSay31
	Private _oSay32
	Private _oSay41
	Private _oSay42
	Private _oSay51
	Private _oSay52
	Private _oSay61
	Private _oSay62
	Private _oSay63
	Private _oSay71
	Private _oSay72
	Private _oSay81
	Private _oSay82
	Private _oFonte1
	Private _nSld1    := 0
	Private _nSld2    := 0
	Private _nSld3    := 0
	Private _nSld4    := 0
	Private _nPrcVnd  := 0
	Private _nDescon  := 0
	Private _nPrcFab  := 0
	Private _nPrcMax  := 0
	Private _cTitulo  := "Consulta de produtos"
	Private _aLegenda := {}
	Private _aFiliais := {}
	Private _aSldB2   := {}
	Private _aSldFil  := {}
	Private _aProduto := {}
	Private _aPreco	  := {}
	Private nAcrecimo := 1
	// Private aAreaSE4  := SE4->(FWGetArea())
	//Private _aNotas		:={}
	Private _aItens	  :={}
	Private _oChave
	Private _oDesc
	Private oBut2
	//Private oProd	:= SLR->LR_PRODUTO
	Private _nEmpAtu  := 0 
	Private lCheck1   := .F. 
	Private lPromo    := .F.
	Private aBUTTONS

	Static _oDlg //Antes era private, esta ficando fora do foco do objeto, Esta focando no BROWSE

	Default _cCodProd := Space(TamSX3("B1_COD")[1])

	// Cria a fonte para ser usada na montagenm da tela
	_oFonte1  := TFont():New( "Arial",,14,,.T.)

	// Guarda da empresa e filial corrente
	cEmpBkp := cEmpAnt
	cFilBkp := cFilAnt
	// Guarda a UF da filial logada
	aInfSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt, { "M0_ESTENT" } )
	_cUFFil := aInfSM0[1][2]
	ASize(aInfSM0,0)
	// Cria uma lista com as filiais de mesma UF que a filial logada
	_cFiliais := ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega filiais da empresa corrente                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSM0Lista := FWLoadSM0()

	For nF:=1 To Len(aSM0Lista) 

	If aSM0Lista[nF][nPEmpresa] == cEmpBkp

		aInfSM0 := FWSM0Util():GetSM0Data( cEmpBkp, aSM0Lista[nF][nPFilial], { "M0_ESTENT" } )

		If aInfSM0[1][2] == _cUFFil
			If !Empty(_cFiliais)
				_cFiliais += ","
			EndIf
			_cFiliais += ValToSql(aSM0Lista[nF][nPFilial])
		EndIf
		ASize(aInfSM0,0)

	EndIf

	Next nF
	ASize(aSM0Lista,0)

	// Restaura็ใo da empresa e filial corrente
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp
	FWSM0Util():setSM0PositionBycFilant()

	//dbSelectArea("DA1")
	DA1->( dbSetOrder(2) )

	//alert(len(_aFiliais))
	// Adiciona as opcoes de legenda do programa
	AAdd(_aLegenda, {"BR_VERDE"   ,"Alto Giro"   } )
	AAdd(_aLegenda, {"BR_AMARELO" ,"M้dio Giro"  } )
	AAdd(_aLegenda, {"BR_LARANJA" ,"Baixo Giro"  } )
	AAdd(_aLegenda, {"BR_PRETO"   ,"Produto Novo"} )
	AAdd(_aLegenda, {"BR_VERMELHO","Sem Giro"    } )
	aBUTTONS := {}

	AADD(aBUTTONS,{"S4WB010N",	{||U_ESPECIF_PROD(_aProduto[_oListBox:nAT][02])}     , "Especifica็ใo"         ,"Especifica็ใo"         } )
	AADD(aBUTTONS,{"S4WB010N",	{||U_JGRT002(_aProduto[_oListBox:nAT][02]+SPACE(10))}, "Consulta Reservas(F11)","Consulta Reservas(F11)"} )
	
	// Cria a tela principal
	DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 0,0 TO 570,1000 OF oMainWnd PIXEL //Modificado GetWndDefault() para oMainWnd, estava abrindo na browse
	
	@ 014+25,002 Say "Descri็ใo:" Size 040,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 013+25,030 MSGET _oDesc VAR _cDesc VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 150,9 PIXEL

	DEFINE SBUTTON oBut2 FROM 013+25,180 TYPE 1 ACTION (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) ENABLE of _oDlg

	SetKey(VK_F12,{||,_cChave:=SPACE(TAMSX3("B1_COD")[1]+20),_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor),_oDesc:SetFocus()})       // fernando
	SetKey(VK_F11,{||,U_JGRT002(_aProduto[_oListBox:nAT][02]+SPACE(10))})       // Consulta Reserva
	// Desabilita as teclas F4, F5, F6, F7 na tela de vendas
	//LjTeclas( .F., .F., .F., .F. )

	// Cria listbox com os dados dos produtos conforme a tabela temporaria criada 
	// IF CNIVEL > 5
		AAdd(_aProduto, {"","","","","","","","","","","","",""} )
		// AAdd(_aTitulos, {"","Codigo","Descri็ใo","Tipo","UM","Pre็o","Custo","Grupo","Sub-Grupo","Classe", "Fabricante","Grupo Trib.","Modelo"})
		AAdd(_aTitulos, {"","Codigo","Descri็ใo","Tipo","UM","Pre็o","Custo","Marca","Grupo","CA","Gr Trib","Modelo"})
		AAdd(_aTitulos, {06,50,      150,        12,    12,  35,     35,     60,      20,    35,  25,       30})
	// ELSE
	// 	AAdd(_aProduto, {"","","","","","","","","","","",""} )
	// 	AAdd(_aTitulos, {"","Codigo","Descri็ใo","Tipo","UM","Pre็o","Grupo","Sub-Grupo","Classe", "Fabricante","Grupo Trib.","Modelo"})
	// 	AAdd(_aTitulos, {10,50,100,20,20,30,30,35,50})
	// ENDIF

	_oListBox := TWBrowse():New(040+25,001,500,120,,_aTitulos[1],_aTitulos[2],_oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	_oListBox:bChange    := {|| _oChgProd("T", FWxFilial("SB2")) }
	_oListBox:blDblClick := {|| PosProd(_aProduto[_oListBox:nAT][02] ), _oDlg:End() }
	_oListBox:SetArray(_aProduto)

	// IF CNIVEL > 5
		_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
		_aProduto[_oListBox:nAT][01]),;
		_aProduto[_oListBox:nAT][02] ,;
		_aProduto[_oListBox:nAT][03] ,;
		_aProduto[_oListBox:nAT][04] ,;
		_aProduto[_oListBox:nAT][05] ,;
		_aProduto[_oListBox:nAT][06] ,;
		_aProduto[_oListBox:nAT][07] ,;
		_aProduto[_oListBox:nAT][08] ,;
		_aProduto[_oListBox:nAT][09] ,;
		_aProduto[_oListBox:nAT][10], ;
		_aProduto[_oListBox:nAT][11], ;
		_aProduto[_oListBox:nAT][12], ;						  
		_aProduto[_oListBox:nAT][13] } }
	// ELSE
	// 	_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
	// 	_aProduto[_oListBox:nAT][01]),;
	// 	_aProduto[_oListBox:nAT][02] ,;
	// 	_aProduto[_oListBox:nAT][03] ,;
	// 	_aProduto[_oListBox:nAT][04] ,;
	// 	_aProduto[_oListBox:nAT][05] ,;
	// 	_aProduto[_oListBox:nAT][06] ,;
	// 	_aProduto[_oListBox:nAT][07] ,;
	// 	_aProduto[_oListBox:nAT][08] ,;
	// 	_aProduto[_oListBox:nAT][09] ,;
	// 	_aProduto[_oListBox:nAT][10], ;
	// 	_aProduto[_oListBox:nAT][11], ;
	// 	_aProduto[_oListBox:nAT][12] } }
	// ENDIF                                                   

	@ 014+25,215 Say "C๓digo:" Size 030,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 013+25,235 MSGET _oChave VAR _cChave F3 "SB1" VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 60,9 PIXEL

	@ 014+25,300 Say "C๓d. barras:" Size 045,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 013+25,335 MSGET _cChvBar VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 55,9 PIXEL

	@ 014+25,395 Say "Ref. Fornec.:" Size 045,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 013+25,430 MSGET _cChvRFor F3 "XSA5" VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 70,9 PIXEL

	@ 029+25,215 Say "Marca:" Size 030,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 028+25,235 MSGET _cChvFab VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 80,9 PIXEL

	@ 029+25,320 Say "C.A.:" Size 030,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 028+25,335 MSGET _cChvCA F3 "ZCA" VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 50,9 PIXEL 

	@ 029+25,390 Say "Grupo:" Size 030,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 028+25,410 MSGET _cChvGr F3 "SBM" VALID (_oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)) SIZE 30,9 PIXEL 

	oCheck1 := TCheckBox():New(30+25,008,"Mostrar produtos sem estoque",,_oDlg,100,300,,,,,,,,.T.,,,)
	oCheck1:bSetGet := {|| lCheck1 }
	oCheck1:bLClicked := {|| lCheck1:=!lCheck1, _oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor) }
	oCheck1:bWhen := {|| .T. }                                      

	AAdd(_aSldB2, {"", Transform(0,"@E 999,999.99")} )
	AAdd(_aPreco, {"", Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99")} )

	_oLbl1  := tGroup():New(  163+25,002,263+20,355,"ESTOQUE POR FILIAL",_oDlg,,,.T.)
	_oSldFil := TWBrowse():New(170+25,006,345,090,,{"Filial"+Space(05),"Armazem","Qtde. Atual","Qtde. Disponํvel","Reservado","Qtde. Prevista"},{10,50,50},_oLbl1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	//_oSldFil:bChange := {|| _oChgProd("T", _aSldFil[_oSldFil:nAt][1]) }
	_oSldFil:SetArray(_aSldFil)
	_oSldFil:bLine := { || { _aSldFil[_oSldFil:nAt][1], _aSldFil[_oSldFil:nAt][2], _aSldFil[_oSldFil:nAt][3],_aSldFil[_oSldFil:nAt][4],_aSldFil[_oSldFil:nAt][5],_aSldFil[_oSldFil:nAt][6] } }

	//Jerry
	//IMAGEM
	_oLbl4  := tGroup():New(163+25,360,263+20,500,"IMAGEM",_oDlg,,,.T.)
	oTBitmap2 := TBitmap():Create(_oDlg,169,365,130,099,,,.T.,;
	{||U_ESPECIF_PROD(_aProduto[_oListBox:nAT][02])},,.F.,.F.,,,.F.,,.T.,,.F.)
	//oTBitmap2:lAutoSize := .T.

	// Recupera os parametros passados pela chamada do programa
	fGetPar(@_cDesc,@_cChave,@_cChvBar,@_cChvRFor,@_cChvFab,@_cChvCA,@_cChvGr) //,@lCheck1)

	If !Empty(_cCodProd)
		_oPesqSB1(.T.,_cCodProd)
	Else
		Processa({|| _oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor) },"Pesquisando produto...")
	EndIf

	// If !Empty(mv_par60)
	// 	Processa({|| _oPesqSB1(,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)},"Pesquisando produto...")
	// EndIf

	//ACTIVATE MSDIALOG _oDlg CENTER
	//ACTIVATE MsDIALOG _oDlg ON INIT ENCHOICEBAR(_oDlg,{|| PosProd(_aProduto[_oListBox:nAT][02]),_oDlg:END()},{|| IIF(Empty(_cCodProd),PosProd("XXXXXXXXXX",2),PosProd(_cCodProd)),_oDlg:END()},,aBUTTONS) CENTERED
	ACTIVATE MsDIALOG _oDlg ON INIT ENCHOICEBAR(_oDlg,{|| PosProd(_aProduto[_oListBox:nAT][02]),_oDlg:END()},{|| /*IIF(Empty(_cCodProd),PosProd("XXXXXXXXXX",2),PosProd(_cCodProd)),*/ _oDlg:END()},,aBUTTONS) CENTERED

	// Desabilita as teclas F4, F5, F6, F7
	//LjTeclas( .T., .T., .T., .T. )

	FWRestArea(_aSM0)
	FWRestArea(_aDA1)
	FWRestArea(_aSF4)
	FWRestArea(_aSB5)
	FWRestArea(_aSA1)
	FWRestArea(_aSA2)
	FWRestArea(_aSY1)
	FWRestArea(_aArea)

	_auxRet := .F.

	If !Empty(_cRet)

		//dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( FWxFilial("SB1")+_cRet ) )

		_auxRet:= .T.	//""

	Endif

	/*-------------------------------------- Alterado por Rony Alves - 06/11/2013
	_auxRet:= .T.

	If Empty(_cRet) // <> "XXXXXXXXXX"
	_auxRet:= .T.	//""
	EndIf
	--------------------------------------*/

Return (_auxRet)

Static Function fGetPar(_cDesc, _cChave, _cChvBar, _cChvRFor, _cChvFab, _cChvCA, _cChvGr) //, lCheck1)
	Local aPropParams  := {}
	Local ojsParams    := Nil
	Local nPar
	Local cParser
	Local lInicializar := .T.

	If !Empty(mv_par60)

		oJsParams := JsonObject():New()
		cParser := ojsParams:FromJson(mv_par60)
	    If cParser == Nil
			aPropParams := ojsParams:GetNames()
			For nPar := 1 to Len(aPropParams)
				&(aPropParams[nPar]) := oJsParams[aPropParams[nPar]]
			Next nPar
			lInicializar := .F.
		EndIf

		FWFreeObj(oJsParams)

	EndIf

	If lInicializar

		mv_par60 := space(50)

		_cChave   := Space(TamSX3("B1_COD")[1])
		_cChvBar  := Space(TamSX3("B1_CODBAR")[1])
		_cChvRFor := Space(TamSX3("A5_CODPRF")[1])
		_cDesc    := Space(TamSX3("B1_DESC")[1])
		_cChvGr	  := Space(TamSX3("B1_GRUPO")[1]) //chave para grupo produto
		_cChvFab  := Space(TamSX3("B1_FABRIC")[1]) //chave para fabricante/marca
		_cChvCA	  := Space(TamSX3("B1_XCA")[1]) //chave para C.A.
		// lCheck1   := .F.

	EndIf

Return

Static Function fSetPar(_cDesc, _cChave, _cChvBar, _cChvRFor, _cChvFab, _cChvCA, _cChvGr) //, lCheck1)
	Local oJsParams

	oJsParams := JsonObject():New()
	oJsParams["_cDesc"   ] := _cDesc
	oJsParams["_cChave"  ] := _cChave
	oJsParams["_cChvBar" ] := _cChvBar
	oJsParams["_cChvRFor"] := _cChvRFor
	oJsParams["_cChvFab" ] := _cChvFab
	oJsParams["_cChvCA"	 ] := _cChvCA
	oJsParams["_cChvGr"	 ] := _cChvGr
	// oJsParams["lCheck1"  ] := lCheck1

	mv_par60 := oJsParams:ToJson()

	FWFreeObj(oJsParams)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTC001  บAutor  ณMicrosiga           บ Data ณ  12/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPESQUISA DO PRODUTO POR DESCRIวรO, GRUPO, SUB-GRUPO, CLASSE,บฑฑ
ฑฑบ          ณFABRICANTE                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _oPesqSB1(lInicio,_cChave,_cChvGr,_cDesc,_cChvFab,_cChvCA,_cChvBar,_cChvRFor)
	Local _cQuery   := ""
	Local _cLegenda
	Local cAlias      := ""
	Local _xcChave    := ""
	Local _xcChvGr    := ""
	Local _xcDesc     := ""
	Local _xcChvFab   := ""
	Local _xcChvCA    := ""
  	Local _cDescAux   := ""

	Default lInicio    := .F.
	Default _cChave    := Space(TamSx3("B1_COD")[1])
	Default _cChvBar   := Space(TamSx3("B1_CODBAR")[1])
	Default _cChvRFor  := Space(TamSx3("A5_CODPRF")[1])
	Default _cChvGr    := Space(TamSx3("B1_GRUPO")[1])
	Default _cDesc     := Space(TamSx3("B1_DESC")[1])
	Default _cChvFab   := Space(TamSx3("B1_FABRIC")[1])
	Default _cChvCA    := Space(TamSx3("B1_XCA")[1])

	_xcChave   := Upper(AllTrim( StrTran(_cChave ,"'","") ))
	_xcChvBar  := Upper(AllTrim( StrTran(_cChvBar,"'","") ))
	_xcChvRFor := Upper(AllTrim( StrTran(_cChvRFor,"'","") ))
	_xcChvGr   := Upper(AllTrim( StrTran(_cChvGr ,"'","") ))
	_xcDesc    := Upper(AllTrim( StrTran(_cDesc  ,"'","''") ))
	_xcChvFab  := Upper(AllTrim( StrTran(_cChvFab,"'","") ))
	_xcChvCA   := Upper(AllTrim( StrTran(_cChvCA ,"'","") ))

	// mv_par60 := _cDesc  // Fernando - guarda o conteudo digitado no campo utilizado para pesquisa
	fSetPar(_cDesc, _cChave, _cChvBar, _cChvRFor, _cChvFab, _cChvCA, _cChvGr) //, lCheck1)

	// Zera o array com os dados dos produtos
	_aProduto := {}

	// Cria tabela temporaria com os dados dos produtos 

	_cQuery := " SELECT DS.* FROM ( " + CRLF

	If lCheck1 .Or. lInicio // caso seja marcado o checkbox para consultar, inclusive, produtos sem estoque ou se for o inํcio da pesquisa

		_cQuery += " SELECT " + CRLF
		_cQuery += "     B1_FILIAL, B1_COD CODIGO, B1_DESC DESCRICAO, B1_UM UNIDADE, B1_SEGUM UNID2, B1_MODELO, B1_PRV1 AS PRECOV, B1_CUSTD AS CUSTO " + CRLF
		_cQuery += "     , B1_GRUPO GRUPO, B1_CODBAR CODBAR, B1_MSBLQL, B1_CONV CONV, B1_TIPCONV TPCONV, B1_GRTRIB GRTRIB " + CRLF
		_cQuery += "     , B1_TIPO AS TIPO, B1_XCA AS CA, B1_FABRIC MARCA " + CRLF
		_cQuery += " FROM " + CRLF
		_cQuery += "     "+RetSqlName("SB1")+" SB1 " + CRLF
		IF !Empty(_xcChvRFor)
		_cQuery += "     INNER JOIN "+RetSqlName("SA5")+" SA5 ON SA5.D_E_L_E_T_ = ' ' AND SA5.A5_FILIAL = "+ValToSql(FWxFilial("SA5")) + CRLF
		_cQuery += "         AND A5_CODPRF = "+ValToSql(_xcChvRFor)+" AND SA5.A5_PRODUTO = SB1.B1_COD " + CRLF
		EndIf
		_cQuery += " WHERE " + CRLF
		_cQuery += "     SB1.D_E_L_E_T_ = ' ' " + CRLF
		_cQuery += "     AND B1_FILIAL = "+ValToSql(FWxFilial('SB1')) + CRLF
		_cQuery += "     AND B1_MSBLQL <> '1' " + CRLF
		If fTipoDb() == "ORACLE"
			_cQuery += "     AND ( LENGTH(RTRIM(B1_COD)) = 6 AND B1_COD LIKE 'P_____%' ) " + CRLF // Retirar antes de entrar em produ็ใo
		Else
			_cQuery += "     AND ( LEN(RTRIM(B1_COD)) = 6 AND B1_COD LIKE 'P_____%' ) " + CRLF // Retirar antes de entrar em produ็ใo
		EndIf

	Else

		_cQuery += " SELECT DISTINCT " + CRLF
		_cQuery += "     B1_FILIAL, B1_COD CODIGO, B1_DESC DESCRICAO, B1_UM UNIDADE, B1_SEGUM UNID2, B1_MODELO, B1_PRV1 AS PRECOV, B1_CUSTD AS CUSTO " + CRLF
		_cQuery += "     , B1_GRUPO GRUPO, B1_CODBAR CODBAR, B1_MSBLQL, B1_CONV CONV, B1_TIPCONV TPCONV, B1_GRTRIB GRTRIB " + CRLF
		_cQuery += "     , B1_TIPO AS TIPO, B1_XCA AS CA, B1_FABRIC MARCA " + CRLF
		_cQuery += " FROM " + CRLF
		_cQuery += "     "+RetSqlName("SB1")+" SB1 " + CRLF
		IF !Empty(_xcChvRFor)
		_cQuery += "     INNER JOIN "+RetSqlName("SA5")+" SA5 ON SA5.D_E_L_E_T_ = ' ' AND SA5.A5_FILIAL = "+ValToSql(FWxFilial("SA5")) + CRLF
		_cQuery += "         AND A5_CODPRF = "+ValToSql(_xcChvRFor)+" AND SA5.A5_PRODUTO = SB1.B1_COD " + CRLF
		EndIf
		_cQuery += "     LEFT JOIN  "+RetSqlName("SB2")+" SB2 ON SB2.D_E_L_E_T_ = ' ' AND SB2.B2_COD = SB1.B1_COD " + CRLF
		_cQuery += " WHERE " + CRLF
		_cQuery += "     SB1.D_E_L_E_T_ = ' ' " + CRLF
		_cQuery += "     AND B1_FILIAL = "+ValToSql(FWxFilial('SB1')) + CRLF
		_cQuery += "     AND B1_MSBLQL <> '1' " + CRLF
		_cQuery += "     AND COALESCE(SB2.D_E_L_E_T_,' ') = ' ' " + CRLF
		_cQuery += "     AND ( SB2.B2_FILIAL IS NOT NULL AND ( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP ) >= 1 ) " + CRLF
		If fTipoDb() == "ORACLE"
			_cQuery += "     AND ( LENGTH(RTRIM(B1_COD)) = 6 AND B1_COD LIKE 'P_____%' ) " + CRLF // Retirar antes de entrar em produ็ใo
		Else
			_cQuery += "     AND ( LEN(RTRIM(B1_COD)) = 6 AND B1_COD LIKE 'P_____%' ) " + CRLF // Retirar antes de entrar em produ็ใo
		EndIf

	EndIf

	//codigo do produto/barras
	If lInicio
		_cQuery += "     AND (B1_COD   = '"+_xcChave+"' ) "
	Else
		If !Empty(_xcChave) .Or. !Empty(_xcChvBar)
			If Empty(_xcChvBar)
				_cQuery += "     AND (B1_COD   LIKE '%"+_xcChave+"%' ) "
			ElseIf Empty(_xcChave)
				_cQuery += "     AND (B1_CODBAR LIKE '%"+_xcChvBar+"%' ) "
			Else
				_cQuery += "     AND (B1_COD   LIKE '%"+_xcChave+"%' OR B1_CODBAR LIKE '%"+_xcChvBar+"%' ) "
			EndIf
		EndIf

		If !Empty(_xcDesc)
			_cDescAux := AllTrim(_xcDesc)
			While Len(_cDescAux) > 0 .And. At(_cDescAux,"  ") > 0
				_cDescAux := StrTran(_cDescAux,"  "," ")
			EndDo
			_cDescAux := StrTran(_cDescAux,"%","\%")
			_cDescAux := StrTran(_cDescAux," ","%")
			_cQuery += "     AND ( B1_DESC    LIKE '%"+_cDescAux+"%' ) "
		EndIf

		//GRUPO
		IF !Empty(_xcChvGr)
			_cQuery += "     AND (B1_GRUPO   LIKE '%"+_xcChvGr+"%' ) "
		EndIf

		//FABRICANTE/MARCA
		IF !Empty(_xcChvFab)
			_cQuery += "     AND (B1_FABRIC   LIKE '%"+_xcChvFab+"%' ) "
		EndIf

		//Certificado de Aprova็ใo - EPI - MTE
		IF !Empty(_xcChvCA)
			_cQuery += "     AND (B1_XCA   = "+ValToSql(_xcChvCA)+" ) "
		EndIf

	EndIf

	_cQuery += " FETCH FIRST 2000 ROW ONLY " + CRLF
	_cQuery += " )DS " + CRLF
	_cQuery += " ORDER BY DESCRICAO " + CRLF

	//memowrit("c:\temp\cons_prod.txt",_cQuery)
	// dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QRY",.F.,.T.)
	cAlias := MPSysOpenQuery(_cQuery)

	_PRC2UM:= 0

	//	(DbSelectArea("SE4"))
	// SE4->(DbSetOrder(1))
	// if SE4->( DbSeek(FWxFilial("SE4")+UA_CONDPG ) )	
	// 	nAcrescimo := SE4->E4_XTXOPER / 100
	// endif

	// FWRestArea (aAreaSE4)

	While (cAlias)->(!Eof())

		//	IF (cAlias)->B1_X_CURVA == "1" //alto giro
		_cLegenda	:= "BR_VERDE"
		//	ELSEIF (cAlias)->B1_X_CURVA == "2" //medio giro
		//		_cLegenda	:= "BR_AMARELO"
		//	ELSEIF (cAlias)->B1_X_CURVA == "3" //baixo giro
		//		_cLegenda	:= "BR_LARANJA" //"BR_AZUL"
		//	ELSEIF (cAlias)->B1_X_CURVA == "4" //Produto novo
		//		_cLegenda	:= "BR_PRETO"  //"BR_VERMELHO"
		//	ELSEIF (cAlias)->B1_X_CURVA == "5" //sem giro
		//		_cLegenda	:= "BR_VERMELHO" //"BR_PRETO"
		//	ENDIF

		//	dbSelectArea("QRY")
		//	If (cAlias)->TPCONV = 'D'
		//_PRC2UM:= (cAlias)->PRC* (cAlias)->CONV //CONVUM((cAlias)->CODIGO,1,0,2)
		_PRC2UM:= 0
		//		_PRC2UM:= CONVUM((cAlias)->CODIGO,(cAlias)->PRC,0,2)
		//		_PRC2UM:= CONVUM((cAlias)->CODIGO,(cAlias)->PRC,0,2)
		//	Else
		//		_PRC2UM:= (cAlias)->PRC/(cAlias)->CONV 
		//	EndIf
		//	AAdd(_aProduto, { _cLegenda, (cAlias)->CODIGO, (cAlias)->DESCRICAO,(cAlias)->UNIDADE,(cAlias)->UNID2,(cAlias)->GRUPO,Transform((cAlias)->PRC,"@E 999,999.99"), (cAlias)->B1_X_REFER } )


		IF UPPER(FUNNAME()) == "LOJA701"
			_CTABELA := M->LR_TABELA
		ELSE                            
			IF UPPER(FUNNAME()) == "MATA410"
				_CTABELA := M->C5_TABELA	
			ELSE
				_CTABELA := M->L1_TABELA			
			ENDIF
		ENDIF

		// _npreco := Round(POSICIONE("DA1",1,FWxFilial("DA1")+_CTABELA+(cAlias)->CODIGO,"DA1_PRCVEN") + (POSICIONE("DA1",1,FWxFilial("DA1")+_CTABELA+(cAlias)->CODIGO,"DA1_PRCVEN")*nAcrescimo),2)
		// _npreco := POSICIONE("SB0",1,FWxFilial("SB0")+(cAlias)->CODIGO,"B0_PRV1")
		_npreco := (cAlias)->PRECOV

		// _cPromo := POSICIONE("SB1",1,FWxFilial("SB1")+(cAlias)->CODIGO,"B1_XPROMO")

		// If Alltrim((cAlias)->CODIGO) == "S"
		// 	_cLegenda	:= "BR_VERMELHO"		
		// Else
			_cLegenda	:= "BR_VERDE"		
		// EndIf

		// IF CNIVEL > 5 
			// _CCUSTO := 0//POSICIONE("SB1",1,FWxFilial("SB1")+(cAlias)->CODIGO,"B1_CUSTD")
			// AAdd(_aProduto, { _cLegenda, (cAlias)->CODIGO, (cAlias)->DESCRICAO, (cAlias)->TIPO,(cAlias)->UNIDADE,Transform(_npreco,"@E 999,999.99"),Transform(_CCUSTO,"@E 999,999.99"),(cAlias)->GRUPO,(cAlias)->SUBGRUPO,(cAlias)->CLASSE,(cAlias)->FABRIC,(cAlias)->GRTRIB, (cAlias)->B1_MODELO } )
			_CCUSTO := (cAlias)->CUSTO //POSICIONE("SB1",1,FWxFilial("SB1")+(cAlias)->CODIGO,"B1_CUSTD")
  		// AAdd(_aTitulos, {"",         "Codigo",         "Descri็ใo",         "Tipo",         "UM",              "Pre็o",                            "Custo",                            "Marca",         "Grupo",         "CA",         "Grupo Trib.",    "Modelo"})
			AAdd(_aProduto, { _cLegenda, (cAlias)->CODIGO, (cAlias)->DESCRICAO, (cAlias)->TIPO, (cAlias)->UNIDADE, Transform(_npreco,"@E 999,999.99"), Transform(_CCUSTO,"@E 999,999.99"), (cAlias)->MARCA, (cAlias)->GRUPO, (cAlias)->CA, (cAlias)->GRTRIB, (cAlias)->B1_MODELO } )
		// ELSE
			// AAdd(_aProduto, { _cLegenda, (cAlias)->CODIGO, (cAlias)->DESCRICAO, (cAlias)->TIPO,(cAlias)->UNIDADE,Transform(_npreco,"@E 999,999.99"),(cAlias)->GRUPO,(cAlias)->SUBGRUPO,(cAlias)->CLASSE,(cAlias)->FABRIC,(cAlias)->GRTRIB, (cAlias)->B1_MODELO } )
		// ENDIF

		(cAlias)->( dbSkip() )

	EndDo
	(cAlias)->( dbCloseArea() )

	_oListBox:nAT := 1 //teste

	If !(Len(_aProduto) > 0)
		_aProduto := {} //adicionado leonardo dia 04/01 - melhorar seguranca 
		// IF CNIVEL > 5
			AAdd(_aProduto, {"","","","","","","","","","","",""} )
		// ELSE
		// 	AAdd(_aProduto, {"","","","","","","","","","","","",""} )
		// ENDIF
	EndIf             

	_bAux := _oListBox:bLine
	_oListBox:SetArray(_aProduto)
	// IF CNIVEL > 5
		_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
		_aProduto[_oListBox:nAT][01]),;
		_aProduto[_oListBox:nAT][02] ,;
		_aProduto[_oListBox:nAT][03] ,;
		_aProduto[_oListBox:nAT][04] ,;
		_aProduto[_oListBox:nAT][05] ,;
		_aProduto[_oListBox:nAT][06] ,;
		_aProduto[_oListBox:nAT][07] ,;
		_aProduto[_oListBox:nAT][08] ,;
		_aProduto[_oListBox:nAT][09] ,;
		_aProduto[_oListBox:nAT][10], ;
		_aProduto[_oListBox:nAT][11] } }
	// ELSE
	// 	_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
	// 	_aProduto[_oListBox:nAT][01]),;
	// 	_aProduto[_oListBox:nAT][02] ,;
	// 	_aProduto[_oListBox:nAT][03] ,;
	// 	_aProduto[_oListBox:nAT][04] ,;
	// 	_aProduto[_oListBox:nAT][05] ,;
	// 	_aProduto[_oListBox:nAT][06] ,;
	// 	_aProduto[_oListBox:nAT][07] ,;
	// 	_aProduto[_oListBox:nAT][08] ,;
	// 	_aProduto[_oListBox:nAT][09] ,;
	// 	_aProduto[_oListBox:nAT][10], ;
	// 	_aProduto[_oListBox:nAT][11], ;
	// 	_aProduto[_oListBox:nAT][12] } }
	// ENDIF 

	_oListBox:Refresh()

	_oChgProd("T", FWxFilial("SB2"))

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_oVerSB1  บAutor  ณ Nelson             บ Data ณ  02/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre a tela de visualizacao do produto                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function _oVerSB1(_cCodVer)
	cCadastro := "Produto"
	If !Empty(_cCodVer)
		//	dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek(FWxFilial()+_cCodVer) )
		SB1->( AxVisual("SB1",SB1->(Recno()),1) )
		_oListBox:Refresh()
	EndIf
Return
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_oVerSF2  บAutor  ณEduardo             บ Data ณ  03/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza nota fiscal.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function _oVerSF2(_cCodVer2)

	_cCodVer2:= substr(_cCodVer2,1,9)+substr(_cCodVer2,11,3)


	If !Empty(_cCodVer2)
		//	dbSelectArea("SF2")
		SF2->( dbSetOrder(1) )
		SF2->( dbSeek(FWxFilial("")+_cCodVer2) )
		SF2->( MC090Visual("SF2",SF2->(Recno()),1) )

		_oListBox:Refresh()
	EndIf
Return
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_oChgProd บAutor  ณ Jerry Ramos        บ Data ณ  17/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre a tela de visualizacao do produto                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ JG                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _oChgProd(_cOpc, _cFilial)
	Local _bAux
	Local _cQuery	:= ""
	Local _cResult	:= ""
	// Local cQry		:= ""
	// Local _TMP		:= ""
	Local oEstrut	:= nil
	// Local nATUAL	:= 1
	// Local nSALDO	:= 2
	// Local nRESERVA	:= 3
	Local cFilOld 	:= cFilAnt

	If _cOpc == "T"

		_nSld1 := 0
		_nSld2 := 0
		_nSld3 := 0
		_nSld4 := 0

		_cResult := GetNextAlias()

		_cQuery  := "SELECT "+CRLF
		_cQuery  += "     CASE "+CRLF
		_cQuery  += "                    WHEN B2_FILIAL = '"+cFilAnt+"' THEN '1' "+CRLF
		_cQuery  += "                    WHEN B2_FILIAL = '0130' THEN '2' "+CRLF
		If !Empty(_cFiliais)
			_cQuery  += "                    WHEN B2_FILIAL IN ("+_cFiliais+") THEN '3' "+CRLF
		EndIf
		_cQuery  += "                    ELSE '3' "+CRLF
		_cQuery  += "     END AS PRIORIZA_FILIAL, "+CRLF
		_cQuery  += "     B2_FILIAL AS FILIAL, B2_LOCAL AS LOCPAD, B2_QATU AS ATUAL,(B2_QATU - B2_RESERVA - B2_QEMP) AS SALDO, B2_RESERVA AS RESERVA, "+CRLF
		_cQuery  += "     B2_SALPEDI SALPED "+CRLF
		_cQuery  += "FROM "+CRLF
		_cQuery  += "     "+RetSqlName("SB2")+" SB2 "+CRLF
		_cQuery  += "WHERE "+CRLF
		_cQuery  += "     SB2.D_E_L_E_T_ <> '*' "+CRLF
		_cQuery  += "     AND B2_QATU > 0 "+CRLF
		_cQuery  += "     AND B2_COD = '"+_aProduto[_oListBox:nAT][2]+"' "+CRLF
		_cQuery  += "ORDER BY "+CRLF
		_cQuery  += "     PRIORIZA_FILIAL, FILIAL, LOCPAD "+CRLF

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),_cResult,.F.,.T.)
		//	MemoWrite("d:\temp\consulta1.sql",_cQuery)
		TcSetField(_cResult, "SALDO" , "N", 15, 2)

		_aSldFil := {}
		(_cResult)->( dbGoTop() )
		While !(_cResult)->( Eof() )

			AAdd(_aSldFil,{(_cResult)->FILIAL,(_cResult)->LOCPAD,Transform((_cResult)->ATUAL,"@E 999,999,999.99"), Transform((_cResult)->SALDO,"@E 999,999,999.99"),Transform((_cResult)->RESERVA,"@E 999,999,999.99"),Transform((_cResult)->SALPED,"@E 999,999,999.99") } )

			(_cResult)->( dbSkip() )
		EndDo
		(_cResult)->( dbCloseArea() )

		// Tratamento de erro caso nao encontre nenhum registro na tabela SB2
		If Len(_aSldFil) == 0
			AAdd(_aSldFil, {"","",Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99")} )
		EndIf	

		_bAux := _oSldFil:bLine
		_oSldFil:SetArray(_aSldFil)
		_oSldFil:bLine := _bAux	

		_oSldFil:Refresh()

		cFilAnt := cFilOld
		FWSM0Util():setSM0PositionBycFilAnt()
		FreeObj(oEstrut)//Limap o Objeto da memoria

	ENDIF

	//IMAGEM
	IF !EMPTY(_aProduto[_oListBox:nAT][2])
		_CIMAGEM := ALLTRIM(POSICIONE("SB1",1,FWxFilial("SB1")+_aProduto[_oListBox:nAT][2],"B1_BITMAP"))
		// IF oTBitmap2:Load( , _CIMAGEM)
		IF oTBitmap2:Load(_CIMAGEM)
			oTBitmap2:cResName := _CIMAGEM
		ELSEIF oTBitmap2:Load( , "\imagens\"+_CIMAGEM+".jpg")
			oTBitmap2:cBmpFile := "\imagens\"+_CIMAGEM+".jpg"
    ELSE
			oTBitmap2:SetEmpty()
		ENDIF
    oTBitmap2:lStretch := .T.
    oTBitmap2:REFRESH()
	ENDIF

	// Posiciona no cadastro de produtos
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( FWxFilial("SB1")+_aProduto[_oListBox:nAT][2] ) )
Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTC001  บAutor  ณMicrosiga           บ Data ณ  02/24/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosProd(_cProd,_xnopc)
	If _xnopc = 2
		//dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )
		SB1->( dbGoTop() )
	Else
		//dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( FWxFilial("SB1")+_cProd ) )
		_cRet := _cProd
		//	_cRet := SPACE(TAMSX3("B1_COD")[1])
	EndIf
Return
/*
USER FUNCTION GRVINF(cMemo1)
	//dbSelectArea("SB5")
	SB5->( dbSetOrder(1) )
	If SB5->( dbSeek(FWxFilial("SB5")+_aProduto[_oListBox:nAT][2]) )
		RecLock("SB5",.F.)
		SB5->B5_X_ESPEC := cMemo1
		SB5->( MsUnLock() )
	EndIf
Return
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function C(nTam)                                                         
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                                               
	//ณTratamento para tema "Flat"ณ                                               
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTC001  บAutor  ณMicrosiga           บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ESPECIF_PROD(_CCODPRO)

	LOCAL _CDESCRI := POSICIONE("SB1",1,FWxFilial("SB1")+_CCODPRO,"B1_XESPECI")
	// PRIVATE OMEM01  
	// PRIVATE OMEM02
	DEFINE DIALOG oDlg TITLE "Especifica็ใo do Produto" FROM 000, 000  TO 400, 400 PIXEL

	@ C(001),C(001) GET oMemo1 Var _CDESCRI MEMO Size C(157.5),C(155) PIXEL OF oDlg
	oMemo1:LREADONLY := .T. 

	ACTIVATE DIALOG oDlg CENTERED 
Return

#include "tbiconn.ch" // Necessแrio para constantes de banco de dados, se aplicแvel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  fTipoDb    บAutor  ณMicrosiga           บ Data ณ  08/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fTipoDb()
	// Local cEnvServer := GetEnvServer()
    Local cDBType    := Upper(GetSrvProfString("dbdataBase", ""))
	Local cRetDb     := ""

    // Ajuste o nome da se็ใo conforme configurado no seu ambiente.
    // O nome da se็ใo pode ser [MSSQL] ou [ORACLE] ou similar.

    If "ORACLE" $ cDBType
        cRetDb := "ORACLE"
    ElseIf "DB2" $ cDBType
        cRetDb := "DB2"
    ElseIf "POSTGRES" $ Upper(cDBType)
        cRetDb := "POSTGRES"
    ElseIf "INFORMIX" $ Upper(cDBType)
        cRetDb := "INFORMIX"
    ElseIf "SQLITE" $ Upper(cDBType)
        cRetDb := "SQLITE"
    ElseIf "MSSQL" $ Upper(cDBType)
        cRetDb := "MSSQL"
    Else
        cRetDb := "MSSQL"
    EndIf

Return cRetDb

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_oPesqSD2 บAutor  ณEduardo             บ Data ณ  04/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pega os itens da nota fiscal por descricao complementar.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function _oPesqSD2(_cChave)

	Local _cQuery   := ""
	// Local _cLegenda
	// Local _oDlgPesq
	// Local _oOpc
	Local _nCont 

	If Select("QRY") > 0
		//	dbSelectArea( "QRY" )  
		(cAlias)->( dbCloseArea() )
	EndIf
	// Zera o array com os dados dos itens da nota fiscal
	_aItens := {}

	// Cria tabela temporaria com os dados dos itens da nota 
	_cQuery := " SELECT " + CRLF
	_cQuery += "     D2_FILIAL, D2_COD CODIGO, D2_ITEM ITEM, D2_SERIE SERIE , D2_DOC DOC, D2_EMISSAO, D2_QUANT, D2_PRCVEN " + CRLF
	_cQuery += " FROM " + CRLF
	_cQuery += "     "+RetSqlName("SD2")+" SD2 " + CRLF
	_cQuery += "     INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = "+ValToSql(FWxFilial("SB1"))+" AND B1_COD = D2_COD " + CRLF
	_cQuery += " WHERE " + CRLF
	_cQuery += "     SD2.D_E_L_E_T_ = ' ' " + CRLF

	If FunName()=="LOJA701".OR. FunName()=="RLOJA010"
		_cQuery += "     AND D2_CLIENTE = "+ValToSql(M->LQ_CLIENTE) + CRLF
		_cQuery += "     AND D2_LOJA = "+ValToSql(M->LQ_LOJA) + CRLF
	EndIf

	//_cQuery += " AND D2_XDESC LIKE '%"+Upper(Alltrim(_cChave))+"%' "
	_cQuery += " ORDER BY " + CRLF
	_cQuery += "     D2_DOC, D2_ITEM " + CRLF

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QRY",.F.,.T.)                                 

	_nCont := 0

	While !(cAlias)->(Eof()) .And. _nCont <= 100

		//	dbSelectArea("QRY")
		//	EMISSAO | QTDE  | PRC UNIT. |  NUM NOTA  |  COD PRODUTO  | DESCRICAO 	
		//	AAdd(_aItens, { "", (cAlias)->DOC, (cAlias)->CODIGO, POSICIONE("SB1",1,FWxFilial("SB1")+(cAlias)->CODIGO,"B1_DESC"),(cAlias)->DESCRICAO } )
		AAdd(_aItens, { "", STOD((cAlias)->D2_EMISSAO), (cAlias)->D2_QUANT, (cAlias)->D2_PRCVEN, (cAlias)->DOC, (cAlias)->CODIGO, POSICIONE("SB1",1,FWxFilial("SB1")+(cAlias)->CODIGO,"B1_XDESC"),(cAlias)->DESCRICAO } )
		(cAlias)->( dbSkip() )
		_nCont ++

	EndDo

	If Len(_aItens) == 0
		AAdd(_aItens, {"","","","","","","",""} )
	EndIf             

	bAux := _oListBox1:bLine
	_oListBox1:SetArray(_aItens)
	_oListBox1:bLine := { || { LoadBitmap(GetResources(), _aItens[_oListBox1:nAT][1]), ;
	_aItens[_oListBox1:nAT][2], ;
	_aItens[_oListBox1:nAT][3], ;
	_aItens[_oListBox1:nAT][4], ;
	_aItens[_oListBox1:nAT][5], ;
	_aItens[_oListBox1:nAT][6], ;						
	_aItens[_oListBox1:nAT][7], ;						
	_aItens[_oListBox1:nAT][8] } }

	_oListBox1:Refresh()
Return
*/
/*
USER FUNCTION VERSC7(_cProd,_cSal,_cFill,_cEmp)
	Local aArea	   := FWGetArea()
	// Local nCnt     := 0
	// Local nOpcA    := 0
	// Local cVarTemp := ""
	Local oDlg     := Nil
	Local oGet     := Nil
	// Vetor com os campos que poderao ser alterados                                                                                
	Local aAlter := {""}
	Local nSuperior    	:= C(004)
	Local nEsquerda    	:= C(000)
	Local nInferior    	:= C(100)
	Local nDireita     	:= C(348)
	// Local cLinhaOk     	:= "AllwaysTrue"
	Local cTudoOk      	:= "AllwaysTrue"
	Local cLinOk       	:= "AllwaysTrue"
	// Local cTudoOk      	:= "AllwaysTrue"
	Local cIniCpos     	:= "+LR_ITEM"
	Local nFreeze      	:= 000
	Local nMax         	:= 999
	// Local cCampoOk     	:= "AllwaysTrue"
	// Local cSuperApagar 	:= ""
	// Local cApagaOk     	:= "AllwaysTrue"
	Local oWnd          	:= oDlg
	Local cFieldOk     	:= "AllwaysTrue"
	Local cSuperDel     	:= ""
	Local cDelOk        	:= "AllwaysTrue"
	Local nOpc         := GD_INSERT+GD_DELETE+GD_UPDATE
	// Local aButtons  := {}
	// Local _nTotBase := 0
	// Local _nTotOrc	:= 0
	Local _nSal		:= 0 //saldo dos pedidos
	Local _cXemp	:= _cEmp

	Private _aHead := {}
	Private _aCOLS   := {}
	Private nUsado  := 0

	//Private cFilOrc := SLQ->LQ_FILIAL
	//Private cOrcam  := SLQ->LQ_NUM

	_aHead := {}
	// Array para montar a Tabela Temporaria aHeader
	AADD(_aHead,{"Filial"	,"C7_FILIAL","",2,0,,,"C", "SC7", }) 
	AADD(_aHead,{"Num.Ped."		,"C7_NUM","@!",06,0,,,"C", "SC7", }) 
	AADD(_aHead,{"Fornec."		,"C7_FORNECE","@!",08,0,,,"C", "SC7", }) 
	AADD(_aHead,{"Desc."		,"C7_DESCRI","@!",25,0,,,"C", "SC7", }) 
	AADD(_aHead,{"Dt.Entrega" ,"C7_DATPRF","@D",08,0,,,"D", "SC7", }) 
	AADD(_aHead,{"Quant." ,"C7_QUANT","@E 999,999,999.99",14,2,,,"N", "SC7", }) 


	//Query contendo as regras a serem mostradas
	cQry := " SELECT *"
	If _cXemp <> NIL 
		cQry += " FROM SC7"+ALLTRIM(_cXemp)+"0 SC7 "
	Else
		cQry += " FROM "+RetSqlName("SC7")+" SC7 "	
	EndIf
	cQry += " WHERE SC7.D_E_L_E_T_='' "
	cQry += " AND C7_QUJE < C7_QUANT "
	cQry += " AND C7_PRODUTO = '"+_cProd+"'"
	If _cFill <> nil
		cQry += " AND C7_FILIAL = '"+_cFill+"'"
	ENdIf
	cQry += " ORDER BY C7_NUM"	

	If Select("TMP") > 0
		TMP->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)


	// Array para montar o aCols
	WHILE TMP->(!EOF())
		If TMP->C7_QUANT-TMP->C7_QUJE > 0 .AND. TMP->C7_RESIDUO <> 'S'
			_cNomFor	:= Posicione("SA2",1,FWxFilial("SA2")+TMP->(C7_FORNECE+C7_LOJA),"A2_NOME")
			AADD(_aCols,{TMP->C7_FILIAL,TMP->C7_NUM,TMP->C7_FORNECE,SUBSTR(_cNomFor,1,25),STOD(TMP->C7_DATPRF),TMP->C7_QUANT-TMP->C7_QUJE,.F.})
			_nSal+= TMP->C7_QUANT-TMP->C7_QUJE
		EndIf
		TMP->(DBSKIP())
	ENDDO

	If _cSal = nil

		If LEN(_aCols) = 0
			Aviso("Aten็ใo","Nใo existe pedido em aberto para este produto.",{"OK"})
			Return
		EndIf

		DEFINE MSDIALOG oDlg TITLE "Pedido de Compras em Aberto" FROM C(178),C(181) TO C(418),C(887) PIXEL


		DEFINE SBUTTON FROM C(105),C(320) TYPE 1 ENABLE OF oDlg ACTION (oDlg:End()) //TOOLTIP "OK"

		// Chamadas das GetDados do Sistema
		oGet:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
		aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,_aHead,_aCols)

		ACTIVATE MSDIALOG oDlg CENTERED 

	Else
		FWRestArea(aArea)
		Return(_nSal)
	EndIf

	FWRestArea(aArea)
Return
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTC001  บAutor  ณMicrosiga           บ Data ณ  08/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
USER FUNCTION _PCUS(_EMP,_PROD,_xFil,_cTinta)

	Local	_aArea 	:= FWGetArea() 
	Local	_aRet	:= {}
	Local 	_dDtEnt	:= CTOD("  /  /    ")
	Local i

	If FUNNAME() $ "RMATA005"
		_aFiliais := {}
		aAdd(_aFiliais,{SM0->M0_CODFIL,SM0->M0_FILIAL})

		_cFiliais := ''
		for i := 1 to len(_aFiliais)
			_cFiliais += "'"+_aFiliais[i,1]+"'"
			if i < len(_aFiliais)
				_cFiliais += ','
			endif
		next i	
	EndIf

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(FWxFilial("SB1")+_PROD))

	_VlrCus	:= 0
	_VlrIpi	:= 0 
	_VlrIcm	:= 0 
	_VlrDes	:= 0 
	If 0 == 1//SB1->B1_X_TINTA <> 'S' //se nao for tinta
		//notas de entrada sem tranferencia
		_cQry  := " SELECT D1_QUANT, D1_VALIPI, D1_VALICM, F1_FRETE, F1_DESPESA, D1_COD, D1_EMISSAO, D1_VUNIT, F1_EMISSAO, F1_DTDIGIT, D1_CUSTO, D1_NUMSEQ, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM "
		If _EMP = '1'
			_cQry  += " FROM SD1010 SD1, SF1010 SF1, SF4010 SF4 "
		ElseIf _EMP = '2'
			_cQry  += " FROM SD1020 SD1, SF1020 SF1, SF4010 SF4 "
		ElseIf _EMP = '3'
			_cQry  += " FROM SD1030 SD1, SF1030 SF1, SF4010 SF4 "
		Else
			_cQry += " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1, "+RetSqlName("SF4")+" SF4 "
		EndIf
		_cQry  += " WHERE SD1.D_E_L_E_T_<>'*' "
		_cQry  += " AND SF1.D_E_L_E_T_ = ' ' "
		_cQry  += " AND SF4.D_E_L_E_T_ = ' ' "
		_cQry  += " AND F1_FILIAL = D1_FILIAL "
		_cQry  += " AND F1_DOC = D1_DOC "
		_cQry  += " AND F1_SERIE = D1_SERIE "
		_cQry  += " AND F1_FORNECE = D1_FORNECE "
		_cQry  += " AND F1_LOJA = D1_LOJA "
		_cQry  += " AND D1_COD = '"+_PROD+"' "
		_cQry  += "	AND D1_TIPO 	= 'N' "
		_cQry  += "	AND D1_TES = F4_CODIGO "	
		_cQry  += "	AND D1_QUANT > 0 "	
		_cQry  += "	AND F4_DUPLIC 	= 'S' "
		_cQry  += "	AND F4_ESTOQUE 	= 'S' "	
		//	_cQry  += " AND D1_FILIAL = '"+_xFil+"' "
		_cQry  += " ORDER BY D1_DTDIGIT DESC , D1_NUMSEQ DESC "

		If Select("TMPCUS") > 0
			TMPCUS->(dbCloseArea())
		EndIf

		_cQry := ChangeQuery(_cQry)

		dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cQry), "TMPCUS", .F., .T.)

		IF !TMPCUS->(EOF()) //!Empty("TMPCUS")
			_VlrIpi	:= TMPCUS->D1_VALIPI/TMPCUS->D1_QUANT
			_VlrIcm	:= TMPCUS->D1_VALICM/TMPCUS->D1_QUANT
			_VlrDes	:= (TMPCUS->(F1_FRETE+F1_DESPESA))/TMPCUS->D1_QUANT

			_VlrCus	:= TMPCUS->D1_CUSTO/TMPCUS->D1_QUANT //TMPCUS->D1_VUNIT+_VlrIpi+_VlrIcm+_VlrDes
			_dDtEnt	:= STOD(TMPCUS->F1_DTDIGIT)
			//Verifico frete
			DbSelectArea("SF8")
			DbSetOrder(2)
			//		If DbSeek(FWxFilial("SF8")+TMPCUS->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
			If DbSeek("01"+TMPCUS->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
				DbSelectArea("SD1")
				DbSetOrder(1)
				//DbSeek(FWxFilial("SD1")+SF8->(	F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)+TMPCUS->D1_COD) //+TMPCUS->D1_ITEM)
				If DbSeek("01"+SF8->(	F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)+TMPCUS->D1_COD) //+TMPCUS->D1_ITEM)

					cGet6 := Round(SD1->D1_CUSTO,4) //VALOR TOTAL DO FRETE...

					//AGORA PRECISO DA QUANTIDADE REAL (PODE TER MAIS DE UMA NOTA EM UM UNICO CONHECIMENTO DE FRETE COM O MESMO PRODUTO) 

					_cSQLFRT := " SELECT D1_COD, SUM(D1_QUANT) AS QUANT"
					_cSQLFRT += " FROM " + RetSqlName("SD1") + " SD1 INNER JOIN " + RetSqlName("SF8") + " SF8 "
					_cSQLFRT += "     ON  D1_FILIAL = F8_FILIAL "
					_cSQLFRT += "         AND D1_DOC = F8_NFORIG "
					_cSQLFRT += "         AND D1_SERIE = F8_SERORIG "
					_cSQLFRT += "         AND D1_FORNECE = F8_FORNECE "
					_cSQLFRT += "         AND D1_LOJA = F8_LOJA "
					_cSQLFRT += " 	      AND F8_NFDIFRE = '" + SF8->F8_NFDIFRE + "' "
					_cSQLFRT += " 	      AND F8_SEDIFRE = '" + SF8->F8_SEDIFRE + "' "
					_cSQLFRT += "         AND D1_COD = '" + TMPCUS->D1_COD + "' "
					_cSQLFRT += "         AND SD1.D_E_L_E_T_ != '*' "
					_cSQLFRT += "         AND SF8.D_E_L_E_T_ != '*' "
					_cSQLFRT += "         AND SD1.D1_FILIAL IN ("+_cFiliais+")" //Atualizacao feita por Fernando Vallim para agilizar as consultas aninhadas (Melhorar o CUSTO de excecucao do SQL - 24/11/10)
					_cSQLFRT += "         AND SF8.F8_FILIAL IN ("+_cFiliais+")"
					_cSQLFRT += " GROUP BY D1_COD "

					If Select("SQLFRT") > 0
						SQLFRT->(DbCloseArea())
					EndIf

					TcQuery _cSqlFrt New Alias "SQLFRT"

					DbSelectArea("SQLFRT")
					//				SQLFRT->(DbGoTop())
					If SQLFRT->(!Eof())
						cGet6 := cGet6 / SQLFRT->QUANT
					Else
						cGet6 := 0
					EndIf
					SQLFRT->(DbCloseArea())

					_VlrCus += cGet6
				EndIf
			EndIf		
		Else
			dbSelectArea("SB9")
			dbSetOrder(1)
			If dbSeek("01"+PADR(ALLTRIM(_PROD),TAMSX3("B9_COD")[1],'')) //01 pois o custo sera o da matriz se nao tiver entrada
				_VlrCus := SB9->B9_CM1

			ElseIf dbSeek("02"+PADR(ALLTRIM(_PROD),TAMSX3("B9_COD")[1],'')) //ppg
				_VlrCus := SB9->B9_CM1
			EndIf
		ENDIF 

		//Verifico se teve transferencia

		// // If _VlrCus = 0
		// // _cSql := " SELECT 	D1_VUNIT, (D1_CUSTO/D1_QUANT) D1_CUSTO, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA,  "
		// // _cSql += " D1_ITEM, D1_QUANT, (D1_ICMSRET/D1_QUANT) D1_ICMSRET, (D1_VALICM/D1_QUANT) D1_VALICM, (D1_VALIPI/D1_QUANT) D1_VALIPI, D1_DTDIGIT "
		// // _cSql += " FROM 	" + RetSqlName("SD1") + " SD1, " + RetSqlName("SF4") + " SF4 "
		// // _cSql += " WHERE 	D1_COD 			= '" + _PROD + "' "
		// // _cSql += " 			AND D1_TIPO 	= 'N' "
		// // _cSql += " 			AND D1_QUANT 	> 0 "
		// // _cSql += " 			AND D1_TES 		= F4_CODIGO "
		// // //		_cSql += " 			AND F4_DUPLIC 	= 'S' "
		// // _cSql += " 			AND F4_ESTOQUE 	= 'S' "
		// // _cSql += " 			AND F4_TRANFIL 	= '1' "
		// // _cSql += " 			AND SF4.D_E_L_E_T_ != '*' "
		// // _cSql += " 			AND SD1.D_E_L_E_T_ != '*' "
		// // _cSql += " ORDER BY D1_DTDIGIT DESC , D1_NUMSEQ DESC "

		// // If Select("_xSD1") > 0
		// // _xSD1->(DbCloseArea())
		// // EndIf

		// //		TcQuery _cSql New Alias "_xSD1"
		// // _cSql := ChangeQuery(_cSql)

		// // dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSql), "_xSD1", .F., .T.)

		// // DbSelectArea("_xSD1")
		// // DbGoTop()	

		// // IF !_xSD1->(EOF()) //!Empty("TMPCUS")
		// // _VlrIpi	:= _xSD1->D1_VALIPI //TMPCUS->D1_VALIPI/TMPCUS->D1_QUANT
		// // _VlrIcm	:= _xSD1->D1_VALICM //D1_VALICM/TMPCUS->D1_QUANT
		// // _VlrDes	:= 0 //(TMPCUS->(F1_FRETE+F1_DESPESA))/TMPCUS->D1_QUANT

		// // _VlrCus	:= _xSD1->D1_CUSTO //TMPCUS->D1_CUSTO/TMPCUS->D1_QUANT //TMPCUS->D1_VUNIT+_VlrIpi+_VlrIcm+_VlrDes
		// // _dDtEnt	:= STOD(_xSD1->D1_DTDIGIT)
		// // EndIf
		// // EndIf
	
		//Fim transferencias
	Else

		_VlrCus := 0//U_RMATA012(SB1->B1_COD,1)
		//_VlrCus := _nCusto/TMP->B2_QATU
	EndIf

	AADD(_aRet,{_VlrCus,DTOC(_dDtEnt)})
	FWRestArea(_aArea)
RETURN _aRet //_VlrCus
*/
/*
User Function RETEND(EMP,FIL)
	Local cRet	:= ""
	Local _cArea	:= FWGetArea()
	//_XEnd	:= Transform(POSICIONE("SBZ",1,(_cResult)->FILIAL+_aProduto[_oListBox:nAT][2],"BZ_XLOCAL+BZ_XRUA+BZ_XLOTE"),"@R 9999-9999-9999") //endereco	
	xcQry  := " SELECT *"
	If EMP = '01'
		xcQry  += " FROM SBZ010 SBZ "
	ElseIf EMP = '02'
		xcQry  += " FROM SBZ020 SBZ "
	ElseIf EMP = '03'
		xcQry  += " FROM SBZ030 SBZ"
	Else
		xcQry += " FROM "+RetSqlName("SBZ")+" SBZ "
	EndIf
	xcQry  += " WHERE SBZ.D_E_L_E_T_<>'*' "
	xcQry  += " AND BZ_FILIAL = '"+FIL+"' "
	xcQry  += " AND BZ_COD = '"+_aProduto[_oListBox:nAT][2]+"' "

	If Select("TMPEND") > 0
		TMPEND->(dbCloseArea())
	EndIf

	xcQry := ChangeQuery(xcQry)

	dbUseArea(.T.,"TOPCONN", TCGenQry(,,xcQry), "TMPEND", .F., .T.)

	If !TMPEND->(EOF())
		cRet:= TMPEND->(BZ_XLOCAL+BZ_XRUA+BZ_XLOTE)
	EndIf

	cRet:= Transform(cRet,"@R 9999-9999-9999")
	FWRestArea(_cArea)
Return cRet
*/
/*
_cSql := " SELECT 	D1_VUNIT, (D1_CUSTO/D1_QUANT) D1_CUSTO, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA,  "
_cSql += " D1_ITEM, D1_QUANT, (D1_ICMSRET/D1_QUANT) D1_ICMSRET, (D1_VALICM/D1_QUANT) D1_VALICM, (D1_VALIPI/D1_QUANT) D1_VALIPI "
_cSql += " FROM 	" + RetSqlName("SD1") + " SD1, " + RetSqlName("SF4") + " SF4 "
_cSql += " WHERE 	D1_COD 			= '" + cGet1 + "' "
_cSql += " 			AND D1_TIPO 	= 'N' "
_cSql += " 			AND D1_QUANT 	> 0 "
_cSql += " 			AND D1_TES 		= F4_CODIGO "
_cSql += " 			AND F4_DUPLIC 	= 'S' "
_cSql += " 			AND F4_ESTOQUE 	= 'S' "
_cSql += " 			AND SF4.D_E_L_E_T_ != '*' "
_cSql += " 			AND SD1.D_E_L_E_T_ != '*' "
_cSql += " ORDER BY D1_DTDIGIT DESC , D1_NUMSEQ DESC "

If Select("_SD1") > 0
_SD1->(DbCloseArea())
EndIf

TcQuery _cSql New Alias "_SD1"

DbSelectArea("_SD1")
DbGoTop()

If _SD1->(!Eof())
cGet5 := _SD1->D1_VUNIT
cGet5a := StoD(_SD1->D1_DTDIGIT)

cGet7 := _SD1->D1_CUSTO

cGet14 := _SD1->D1_VALICM
cGet15 := _SD1->D1_ICMSRET
cGet16 := _SD1->D1_VALIPI
Else
dbSelectArea("SB9")
dbSetOrder(1)
If dbSeek("01"+PADR(ALLTRIM(cGet1),TAMSX3("B9_COD")[1],''))
cGet7 := SB9->B9_CM1
ElseIf dbSeek("01"+PADR(ALLTRIM(cGet1),TAMSX3("B9_COD")[1],'')) //PPG
cGet7 := SB9->B9_CM1
EndIf
EndIf
//verifico se custo esta vazio e busco notas de transferencia
If cGet7 = 0
_cSql := " SELECT 	D1_VUNIT, (D1_CUSTO/D1_QUANT) D1_CUSTO, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA,  "
_cSql += " D1_ITEM, D1_QUANT, (D1_ICMSRET/D1_QUANT) D1_ICMSRET, (D1_VALICM/D1_QUANT) D1_VALICM, (D1_VALIPI/D1_QUANT) D1_VALIPI "
_cSql += " FROM 	" + RetSqlName("SD1") + " SD1, " + RetSqlName("SF4") + " SF4 "
_cSql += " WHERE 	D1_COD 			= '" + cGet1 + "' "
_cSql += " 			AND D1_TIPO 	= 'N' "
_cSql += " 			AND D1_QUANT 	> 0 "
_cSql += " 			AND D1_TES 		= F4_CODIGO "
//		_cSql += " 			AND F4_DUPLIC 	= 'S' "
_cSql += " 			AND F4_ESTOQUE 	= 'S' "
_cSql += " 			AND F4_TRANFIL 	= '1' "
_cSql += " 			AND SF4.D_E_L_E_T_ != '*' "
_cSql += " 			AND SD1.D_E_L_E_T_ != '*' "
_cSql += " ORDER BY D1_DTDIGIT DESC , D1_NUMSEQ DESC "

If Select("_xSD1") > 0
_xSD1->(DbCloseArea())
EndIf

TcQuery _cSql New Alias "_xSD1"

DbSelectArea("_xSD1")
DbGoTop()

If _xSD1->(!Eof())
cGet5 := _xSD1->D1_VUNIT
cGet5a := StoD(_xSD1->D1_DTDIGIT)

cGet7 := _xSD1->D1_CUSTO

cGet14 := _xSD1->D1_VALICM
cGet15 := _xSD1->D1_ICMSRET
cGet16 := _xSD1->D1_VALIPI	
EndIf

EndIf


//verifico se tem nota de frete...
DbSelectArea("SF8")
DbSetOrder(2) //SO OLHA A FILIAL 01
If DbSeek("01"+_SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
DbSelectArea("SD1")                 	
DbSetOrder(1)
If DbSeek(FWxFilial("SD1")+SF8->(F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)+cGet1) //+_SD1->D1_ITEM)

cGet6 := Round(SD1->D1_CUSTO,4) //VALOR TOTAL DO FRETE...

//AGORA PRECISO DA QUANTIDADE REAL (PODE TER MAIS DE UMA NOTA EM UM UNICO CONHECIMENTO DE FRETE COM O MESMO PRODUTO) 

_cSQLFRT := " SELECT D1_COD, SUM(D1_QUANT) AS QUANT"
_cSQLFRT += " FROM " + RetSqlName("SD1") + " SD1 INNER JOIN " + RetSqlName("SF8") + " SF8 "
_cSQLFRT += "     ON  D1_FILIAL = F8_FILIAL "
_cSQLFRT += "         AND D1_DOC = F8_NFORIG "
_cSQLFRT += "         AND D1_SERIE = F8_SERORIG "
_cSQLFRT += "         AND D1_FORNECE = F8_FORNECE "
_cSQLFRT += "         AND D1_LOJA = F8_LOJA "
_cSQLFRT += " 	      AND F8_NFDIFRE = '" + SF8->F8_NFDIFRE + "' "
_cSQLFRT += " 	      AND F8_SEDIFRE = '" + SF8->F8_SEDIFRE + "' "
_cSQLFRT += "         AND D1_COD = '" + cGet1 + "' "
_cSQLFRT += "         AND SD1.D_E_L_E_T_ != '*' "
_cSQLFRT += "         AND SF8.D_E_L_E_T_ != '*' "
_cSQLFRT += " GROUP BY D1_COD "

TcQuery _cSqlFrt New Alias "SQLFRT"

DbSelectArea("SQLFRT")
SQLFRT->(DbGoTop())
If SQLFRT->(!Eof())
cGet6 := cGet6 / SQLFRT->QUANT
Else
cGet6 := 0
EndIf
SQLFRT->(DbCloseArea("SQLFRT"))

cGet7 += cGet6
EndIf
EndIf

*/
/*
Static Function Lote(_cProd,_cFil,_cEmp)

	Local aArea		:= FWGetArea()
	Local cFilOld	:= cFilant

	cFilAnt := _cFil

	u__F4Lote(,,,"ZZZ",PADR(ALLTRIM(_cProd),TAMSX3("B1_cod")[1],""),"01",.F.,,_cEmp,_cFil)

	cFilAnt := cFilOld

	FWRestArea(aArea)
Return NIL 
*/
/*
Static Function VERCOMP(_Prod)

	// Variaveis Locais da Funcao
	Local cGet1	 := ""
	Local oGet1

	// Variaveis Private da Funcao
	Private oDlg

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SY1")
	DbSetOrder(1)

	DbSelectArea("SA2")
	DbSetOrder(1)

	SB1->(DbSeek(FWxFilial("SB1")+_Prod))

	_cForn := SB1->B1_PROC
	_cLoja := SB1->B1_LOJPROC

	SA2->(DbSeek(FWxFilial("SA2")+_cForn+_cLoja))

	If cEmpAnt == '01'
		SY1->(DbSeek(FWxFilial("SY1")+SA2->A2_XCOMPRA))
		cGet1 := Alltrim(SA2->A2_XCOMPRA)+" - "+Alltrim(SY1->Y1_NOME)
	Else 
		If cEmpAnt == '02'
			SY1->(DbSeek(FWxFilial("SY1")+SA2->A2_XCOMPR2))
			cGet1 := Alltrim(SA2->A2_XCOMPR2)+" - "+Alltrim(SY1->Y1_NOME)
		Else
			SY1->(DbSeek(FWxFilial("SY1")+SA2->A2_XCOMPR3))
			cGet1 := Alltrim(SA2->A2_XCOMPR3)+" - "+Alltrim(SY1->Y1_NOME)		
		EndIf
	EndIf	

	DEFINE MSDIALOG oDlg TITLE "Comprador do Produto" FROM C(199),C(183) TO C(380),C(721) PIXEL

	// Cria as Groups do Sistema
	@ C(000),C(003) TO C(070),C(264) LABEL "Comprador" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(008),C(004) GET oGet1 Var cGet1  Size C(255),C(060)COLOR CLR_BLACK PIXEL OF oDlg 


	//	DEFINE SBUTTON FROM C(075),C(215) TYPE 1 ENABLE OF oDlg ACTION(U_GRVINF(cMemo1),oDlg:End())
	DEFINE SBUTTON FROM C(075),C(240) TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

RETURN
*/
