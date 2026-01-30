#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  JGRT004  บAutor  ณJesus Ramos         บ Data ณ  12/01/2026   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta Fornecedor - Qualquer m๓dulo                		 บฑฑ
ฑฑบ          ณDepende da Consulta Padrใo    	                    	 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ			                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function JGRT004(_cCodFor)     
                   
Local oButton1
Local oGet1
Local cGet1 := Space(50)//TamSX3('A2_NOME')[1]                  
Local oGet2
Local cGet2 := Space(50)//TamSX3('A2_NREDUZ')[1]
Local oGet3
Local cGet3 := Space(18)
Local oGet4
Local cGet4 := Space(TamSX3('A2_COD')[1])
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local aButtons := {}
Local _x

Private _cRet        := ""
Private _aFornecedor := {}
Private _aFor        := {}
Private _aTitulos    := {}
Private oWBrowse1    := {}
Private _aLegenda    := {}

Static oDlg

	Default _cCodFor := &(ReadVar())

	AAdd(_aTitulos, {"","C๓digo","Lj.For","Nome","Fantasia","CNPJ/CPF","UF","Municipio","Bairro","Endere็o"})
	AAdd(_aTitulos, {10,30,15,120,90,60,15,40,40,50})
	For _x:=1 To Len(_aTitulos[1])
		AAdd(_aFor, "" )
	Next _x
	AAdd(_aFornecedor, Aclone(_aFor) )
	
	AADD(aButtons,{"S4WB010N",	{|| FVERFOR(_aFornecedor[oWBrowse1:nAt,2],_aFornecedor[oWBrowse1:nAt,3]) }, "Visualizar","Visualizar"})
	//AADD(aButtons,{"S4WB010N",	{|| FCADFOR() 													   }, "Incluir","Incluir"})
	AADD(aButtons,{"S4WB010N",	{|| BrwLegenda("Legenda","Legenda",_aLegenda)					   }, "Legenda","Legenda"})

	// Adiciona as opcoes de legenda do programa
	AAdd(_aLegenda, {"BR_VERDE"     ,"Pessoa Juridica"    } )
	AAdd(_aLegenda, {"BR_AMARELO"   ,"Pessoa Fisica"      } )
	AAdd(_aLegenda, {"BR_VERMELHO"  ,"Fornecedor Inativo" } )

  DEFINE MSDIALOG oDlg TITLE "Consulta de Fornecedores" FROM 000, 000  TO 510, 1000 COLORS 0, 16777215 PIXEL

    @ 036, 005 SAY oSay1 PROMPT "Nome" SIZE 022, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 029 MSGET oGet1 VAR cGet1 SIZE 133, 010 OF oDlg COLORS 0, 16777215 Picture "@!" PIXEL
       
    @ 036, 174 SAY oSay3 PROMPT "CNPJ/CPF" SIZE 029, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 203 MSGET oGet3 VAR cGet3 SIZE 082, 010 OF oDlg COLORS 0, 16777215 Picture "@!" PIXEL

    @ 034, 292 BUTTON oButton1 PROMPT "Pesquisar (F5)" SIZE 049, 026 OF oDlg PIXEL ACTION(fBusca(cGet1,cGet2,cGet3,cGet4))
        
    @ 050, 005 SAY oSay2 PROMPT "Fantasia" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 048, 029 MSGET oGet2 VAR cGet2 SIZE 092, 010 OF oDlg COLORS 0, 16777215 Picture "@!" PIXEL
    
    @ 050, 174 SAY oSay4 PROMPT "Codigo" SIZE 029, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 048, 203 MSGET oGet4 VAR cGet4 SIZE 082, 010 OF oDlg COLORS 0, 16777215 Picture "@!" PIXEL
    
    fWBrowse1()
    
    //Atalho F5
    SetKey( VK_F5,  {|| fBusca(cGet1,cGet2,cGet3,cGet4)  } )
  
  	If _cCodFor <> Nil
		If !Empty(_cCodFor)
			IF IsDigit( _cCodFor )
				fBusca("","","",_cCodFor) //Busca por codigo
			Else
				fBusca(_cCodFor,"","","") //Busca por Nome
			EndIf
		EndIf
	EndIf
    
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| PosFor(_aFornecedor[oWBrowse1:nAt,2],_aFornecedor[oWBrowse1:nAt,3]) , oDlg:END() }, {|| /*IIF(Empty(_cCodFor),PosFor("XXXXXXXXXX","",2),PosFor(_cCodFor)),*/ oDlg:END() },,aButtons)  CENTERED

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek( xFilial("SA2")+_cRet )

_auxRet:= .T.

If Empty(_cRet)
	_auxRet:= .f.
EndIf

Return _auxRet

//------------------------------------------------ 
Static Function fWBrowse1()
//------------------------------------------------ 

	oWBrowse1 := TWBrowse():New(062,004,494,191,,_aTitulos[1],_aTitulos[2],oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	oWBrowse1:blDblClick := {|| PosFor(_aFornecedor[oWBrowse1:nAt,2],_aFornecedor[oWBrowse1:nAt,3]) , oDlg:END() }	
    oWBrowse1:SetArray(_aFornecedor)
    oWBrowse1:bLine := {|| {;
       LoadBitmap(GetResources(),;
      _aFornecedor[oWBrowse1:nAt,1]),;
      _aFornecedor[oWBrowse1:nAt,2],;
      _aFornecedor[oWBrowse1:nAt,3],;
      _aFornecedor[oWBrowse1:nAt,4],;
      _aFornecedor[oWBrowse1:nAt,5],;
      _aFornecedor[oWBrowse1:nAt,6],;
      _aFornecedor[oWBrowse1:nAt,7],;
      _aFornecedor[oWBrowse1:nAt,8],;
      _aFornecedor[oWBrowse1:nAt,9];
    }}
    
Return

Static Function fBusca(_cNome,_cNoRed,_cCGC,_cCod)

	Local cQry      := ""
	Local _cLegenda := ""
	Local cPicCGC   := ""
	Local _cNomeAux := ""

	_cNome 	:= Alltrim(_cNome)
	_cNoRed := Alltrim(_cNoRed)
	_cCGC 	:= Alltrim(_cCGC)
	_cCGC 	:= StrTran(_cCGC,'.','')
	_cCGC 	:= StrTran(_cCGC,'/','')
	_cCGC 	:= StrTran(_cCGC,'-','')
	_cCod 	:= Alltrim(_cCod)
	
	//Validacoes
	DO CASE
		CASE !Empty(_cNome) .And. ( !Empty(_cNoRed) .Or. !Empty(_cCGC) .Or. !Empty(_cCod))
			MsgStop("Aten็ใo! Voc๊ deve informar somente um campo para pesquisa!!")
			Return()
		CASE !Empty(_cNoRed) .And. ( !Empty(_cNome) .Or. !Empty(_cCGC) .Or. !Empty(_cCod))
			MsgStop("Aten็ใo! Voc๊ deve informar somente um campo para pesquisa!!")
			Return()
		CASE !Empty(_cCGC) .And. ( !Empty(_cNome) .Or. !Empty(_cNoRed) .Or. !Empty(_cCod))
			MsgStop("Aten็ใo! Voc๊ deve informar somente um campo para pesquisa!!")		
			Return()		
		CASE !Empty(_cCod) .And. ( !Empty(_cNome) .Or. !Empty(_cNoRed) .Or. !Empty(_cCGC))
			MsgStop("Aten็ใo! Voc๊ deve informar somente um campo para pesquisa!!")		
			Return()
		CASE Empty(_cCod) .And. Empty(_cNome) .And. Empty(_cNoRed) .And. Empty(_cCGC)
			MsgStop("Aten็ใo! Voc๊ deve informar um campo para pesquisa!!")		
			Return()							
	OTHERWISE

	ENDCASE

	cQry += " SELECT " + CRLF
    cQry += "   A2_COD,A2_LOJA,A2_NOME,A2_NREDUZ,A2_CGC,A2_EST,A2_MUN,A2_BAIRRO,A2_END,A2_TIPO,A2_MSBLQL " + CRLF
	cQry += " FROM " + CRLF
    cQry += "   " + RetSqlName("SA2") + " SA2 " + CRLF
	cQry += " WHERE " + CRLF
    cQry += "   SA2.D_E_L_E_T_ = ' ' AND A2_FILIAL = "+ValToSql(FWxFilial("SA2"))+" " + CRLF
	If !Empty(_cCod)
		If Len(AllTrim(_cCod)) > TAMSX3("A2_COD")[1] .And. Len(AllTrim(_cCod)) <= (TAMSX3("A2_COD")[1]+TAMSX3("A2_LOJA")[1]) 
			cQry += "   AND A2_COD = '"+SubStr(_cCod,1,TAMSX3("A2_COD")[1])+"' " + CRLF
			cQry += "   AND A2_LOJA = '"+SubStr(_cCod,TAMSX3("A2_COD")[1]+1,Len(AllTrim(_cCod))-TAMSX3("A2_COD")[1])+"' " + CRLF
		Else
			cQry += "   AND A2_COD = '"+_cCod+"' " + CRLF
		EndIf
	ElseIf !Empty(_cCGC)
		cQry += "   AND A2_CGC LIKE '"+_cCGC+"%' " + CRLF
	ElseIf !Empty(_cNome)
		_cNomeAux := AllTrim(_cNome)
		While Len(_cNomeAux) > 0 .And. At(_cNomeAux,"  ") > 0
			_cNomeAux := StrTran(_cNomeAux,"  "," ")
		EndDo
		_cNomeAux := StrTran(_cNomeAux,"%","\%")
		_cNomeAux := StrTran(_cNomeAux," ","%")
		cQry += "   AND A2_NOME LIKE '%"+_cNomeAux+"%' " + CRLF
	ElseIf !Empty(_cNoRed)
		_cNomeAux := AllTrim(_cNoRed)
		While Len(_cNomeAux) > 0 .And. At(_cNomeAux,"  ") > 0
			_cNomeAux := StrTran(_cNomeAux,"  "," ")
		EndDo
		_cNomeAux := StrTran(_cNomeAux,"%","\%")
		_cNomeAux := StrTran(_cNomeAux," ","%")
		cQry += "   AND A2_NREDUZ LIKE '%"+_cNomeAux+"%' " + CRLF
	EndIf
	cQry += " ORDER BY A2_NOME " + CRLF
	cQry += " FETCH FIRST 2000 ROW ONLY " + CRLF
	
	//MemoWrite( "c:\temp\testSave.txt", cQry )
	
	_aFornecedor := {}
	
	TcQuery cQry New Alias "TMP"

	TMP->(DbGoTop())
		
		While TMP->(!EOF())
			
			If TMP->A2_MSBLQL = '1'
		    	_cLegenda	:= "BR_VERMELHO" 
		    ElseIf TMP->A2_TIPO = 'J'
		    	_cLegenda	:= "BR_VERDE"
		    ElseIf TMP->A2_TIPO = 'F'
		    	_cLegenda	:= "BR_AMARELO"
		    EndIf 
			
			If Len(Alltrim(TMP->A2_CGC)) = 14
				cPicCGC := "@R 99.999.999/9999-99"     
			Else
			    cPicCGC := "@R 999.999.999-99"                
			EndIf
			
			Aadd(_aFornecedor, { _cLegenda ,;
				Alltrim(TMP->A2_COD) 		,;
				Alltrim(TMP->A2_LOJA) 		,;
				Alltrim(TMP->A2_NOME) 		,;
				Alltrim(TMP->A2_NREDUZ) 		,;
				Transform(Alltrim(TMP->A2_CGC),cPicCGC),;
				Alltrim(TMP->A2_EST) 		,;
				Alltrim(TMP->A2_MUN) 		,;
				Alltrim(TMP->A2_BAIRRO) 		,;
				Alltrim(TMP->A2_END) ;		
			})
					
			TMP->(DbSkip())
			
		EndDo
			
	TMP->(DbCloseArea())
	
	If Len(_aFornecedor) == 0
		AAdd(_aFornecedor, Aclone(_aFor) )
	EndIf
	
    oWBrowse1:SetArray(_aFornecedor)
    oWBrowse1:bLine := {|| {;
       LoadBitmap(GetResources(),;
      _aFornecedor[oWBrowse1:nAt,1]),;
      _aFornecedor[oWBrowse1:nAt,2],;
      _aFornecedor[oWBrowse1:nAt,3],;
      _aFornecedor[oWBrowse1:nAt,4],;
      _aFornecedor[oWBrowse1:nAt,5],;
      _aFornecedor[oWBrowse1:nAt,6],;
      _aFornecedor[oWBrowse1:nAt,7],;
      _aFornecedor[oWBrowse1:nAt,8],;
      _aFornecedor[oWBrowse1:nAt,9];
    }}
    
    oWBrowse1:Refresh()
    
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PosFor บAutor  ณ Lorran Ferreira   บ Data ณ  20/04/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta Fornecedores			                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosFor(_cFor,_cLoj,_xnopc)

DEFAULT _cLoj := ""

If _xnopc = 2
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(dbGoTop())
Else
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(dbSeek( FWxFilial("SA2")+_cFor+_cLoj ))
	_cRet := _cFor+_cLoj
EndIf

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVERFOR  บAutor  ณLorran Ferreira     บ Data ณ  20/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Visualizar de cadastro de Fornecedor			 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVERFOR(_cA2COD,_cA2LOJA)

	Local aArea			:= GetArea()
	
	If !Empty(_cA2COD) .And. !Empty(_cA2LOJA)
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek( xFilial("SA2")+_cA2COD+_cA2LOJA))
			A030Visual("SA2",SA2->(RecNo()),1)
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCADFOR  บAutor  ณLorran Ferreira     บ Data ณ  20/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de inclusao de cadastro de Fornecedor 				 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FCADFOR()

Local aArea		:= GetArea()			// Armazena posicionamento atual
Local lIncluiBk	:= INCLUI				// Armazena o conteudo da variavel INCLUI
Local lAlteraBk	:= ALTERA				// Armazena o conteudo da variavel INCLUI
Local aCposInd	:= {}     				// Campos que compoem o indice do alias
Local aRotBkp	:= aClone(aRotina)		// Armazena o vetor aRotina para recuperacao posterior
Local cAuxCadastro := ""				// Armazena o conteudo original de cCadastro
Local cCodigo	:= ""
Local cLoja		:= ""
         
If Type("cCadastro") == "U"
	Private cCadastro := ""
EndIf 
cAuxCadastro:= cCadastro 
cCadastro 	:= AllTrim(Posicione("SX2",1,"SA2","X2NOME()")) + " - Incluir"// "Incluir"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRecria o aRotina, para garantir a execucao correta da funcaoณ
//ณAxInclui                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina := {{""	,"AxPesqui",0,1} ,;
			{""	,"AxVisual",0,2} ,;
			{""	,"AxInclui",0,3} ,;
			{""	,"AxAltera",0,4} ,;
			{""	,"AxDeleta",0,5} }

INCLUI	:= .T.
ALTERA	:= .F.

dbSelectArea("SA2")
SA2->(dbSetOrder(1))

aCposInd := StrToKArr(IndexKey(),"+")

aRotAuto := Nil
A030Inclui("SA2",Nil,3)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche os campos codigo e loja com codigo e loja daณ
//ณentidade incluida                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodigo	:= Iif(Len(aCposInd)>=2,(cEntidade)->&(aCposInd[2]),"")
cLoja	:= Iif(Len(aCposInd)>=3,(cEntidade)->&(aCposInd[3]),"")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura situacao anteriorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina	:= aClone(aRotBkp)
ALTERA	:= lAlteraBk
INCLUI	:= lIncluiBk

cCadastro := cAuxCadastro

RestArea(aArea)

MsgInfo("Fornecedor Cadastrado: "+cCodigo+"/"+cLoja)

Return Nil
