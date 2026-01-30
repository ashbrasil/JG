#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  JGRT003  บAutor  ณJesus Ramos         บ Data ณ  12/01/2026   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta Cliente - Qualquer m๓dulo                		 บฑฑ
ฑฑบ          ณDepende da Consulta Padrใo    	                    	 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function JGRT003(_cCodCli)     
                   
Local oButton1
Local oGet1
Local cGet1 := Space(50)//TamSX3('A1_NOME')[1]                  
Local oGet2
Local cGet2 := Space(50)//TamSX3('A1_NREDUZ')[1]
Local oGet3
Local cGet3 := Space(18)
Local oGet4
Local cGet4 := Space(TamSX3('A1_COD')[1])
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local aButtons := {}
Local _x

Private _cRet     := ""
Private _aCliente := {}
Private _aCli	  := {}
Private _aTitulos := {}
Private oWBrowse1 := {}
Private _aLegenda := {}

Static oDlg

	Default _cCodCli := &(ReadVar())

	AAdd(_aTitulos, {"","C๓digo","Lj.Cli","Nome","Fantasia","CNPJ/CPF","UF","Municipio","Bairro","Endere็o"})
	AAdd(_aTitulos, {10,30,15,120,90,60,15,40,40,50})
	For _x:=1 To Len(_aTitulos[1])
		AAdd(_aCli, "" )
	Next _x
	AAdd(_aCliente, Aclone(_aCli) )
	
	AADD(aButtons,{"S4WB010N",	{|| FVERCLI(_aCliente[oWBrowse1:nAt,2],_aCliente[oWBrowse1:nAt,3]) }, "Visualizar","Visualizar"})
	//AADD(aButtons,{"S4WB010N",	{|| FCADCLI() 													   }, "Incluir","Incluir"})
	AADD(aButtons,{"S4WB010N",	{|| BrwLegenda("Legenda","Legenda",_aLegenda)					   }, "Legenda","Legenda"})

	// Adiciona as opcoes de legenda do programa
	AAdd(_aLegenda, {"BR_VERDE"     ,"Pessoa Juridica"    } )
	AAdd(_aLegenda, {"BR_AMARELO"   ,"Pessoa Fisica"      } )
	AAdd(_aLegenda, {"BR_VERMELHO"  ,"Cliente Inativo"    } )

  DEFINE MSDIALOG oDlg TITLE "Consulta de Clientes" FROM 000, 000  TO 510, 1000 COLORS 0, 16777215 PIXEL

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
  
  	If _cCodCli <> Nil
		If !Empty(_cCodCli)
			IF IsDigit( _cCodCli )
				fBusca("","","",_cCodCli) //Busca por codigo
			Else
				fBusca(_cCodCli,"","","") //Busca por Nome
			EndIf
		EndIf
	EndIf
    
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| PosCli(_aCliente[oWBrowse1:nAt,2],_aCliente[oWBrowse1:nAt,3]) , oDlg:END() }, {|| /*IIF(Empty(_cCodCli),PosCli("XXXXXXXXXX","",2),PosCli(_cCodCli)),*/ oDlg:END() },,aButtons)  CENTERED

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek( xFilial("SA1")+_cRet )

_auxRet:= .T.

If Empty(_cRet)
	_auxRet:= .f.
EndIf

Return _auxRet

//------------------------------------------------ 
Static Function fWBrowse1()
//------------------------------------------------ 

	oWBrowse1 := TWBrowse():New(062,004,494,191,,_aTitulos[1],_aTitulos[2],oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	oWBrowse1:blDblClick := {|| PosCli(_aCliente[oWBrowse1:nAt,2],_aCliente[oWBrowse1:nAt,3]) , oDlg:END() }	
    oWBrowse1:SetArray(_aCliente)
    oWBrowse1:bLine := {|| {;
       LoadBitmap(GetResources(),;
      _aCliente[oWBrowse1:nAt,1]),;
      _aCliente[oWBrowse1:nAt,2],;
      _aCliente[oWBrowse1:nAt,3],;
      _aCliente[oWBrowse1:nAt,4],;
      _aCliente[oWBrowse1:nAt,5],;
      _aCliente[oWBrowse1:nAt,6],;
      _aCliente[oWBrowse1:nAt,7],;
      _aCliente[oWBrowse1:nAt,8],;
      _aCliente[oWBrowse1:nAt,9];
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
    cQry += "   A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC,A1_EST,A1_MUN,A1_BAIRRO,A1_END,A1_PESSOA,A1_MSBLQL " + CRLF
	cQry += " FROM " + CRLF
    cQry += "   " + RetSqlName("SA1") + " SA1 " + CRLF
	cQry += " WHERE " + CRLF
    cQry += "   SA1.D_E_L_E_T_ = ' ' AND A1_FILIAL = "+ValToSql(FWxFilial("SA1"))+" " + CRLF
	If !Empty(_cCod)
		If Len(AllTrim(_cCod)) > TAMSX3("A1_COD")[1] .And. Len(AllTrim(_cCod)) <= (TAMSX3("A1_COD")[1]+TAMSX3("A1_LOJA")[1]) 
			cQry += "   AND A1_COD = '"+SubStr(_cCod,1,TAMSX3("A1_COD")[1])+"' " + CRLF
			cQry += "   AND A1_LOJA = '"+SubStr(_cCod,TAMSX3("A1_COD")[1]+1,Len(AllTrim(_cCod))-TAMSX3("A1_COD")[1])+"' " + CRLF
		Else
			cQry += "   AND A1_COD = '"+_cCod+"' " + CRLF
		EndIf
	ElseIf !Empty(_cCGC)
	cQry += "   AND A1_CGC LIKE '"+_cCGC+"%' " + CRLF
	ElseIf !Empty(_cNome)
		_cNomeAux := AllTrim(_cNome)
		While Len(_cNomeAux) > 0 .And. At(_cNomeAux,"  ") > 0
			_cNomeAux := StrTran(_cNomeAux,"  "," ")
		EndDo
		_cNomeAux := StrTran(_cNomeAux,"%","\%")
		_cNomeAux := StrTran(_cNomeAux," ","%")
		cQry += "   AND A1_NOME LIKE '%"+_cNomeAux+"%' " + CRLF
	ElseIf !Empty(_cNoRed)
		_cNomeAux := AllTrim(_cNoRed)
		While Len(_cNomeAux) > 0 .And. At(_cNomeAux,"  ") > 0
			_cNomeAux := StrTran(_cNomeAux,"  "," ")
		EndDo
		_cNomeAux := StrTran(_cNomeAux,"%","\%")
		_cNomeAux := StrTran(_cNomeAux," ","%")
		cQry += "   AND A1_NREDUZ LIKE '%"+_cNomeAux+"%' " + CRLF
	EndIf
	cQry += " ORDER BY A1_NOME " + CRLF
	cQry += " FETCH FIRST 2000 ROW ONLY " + CRLF
	
	//MemoWrite( "c:\temp\testSave.txt", cQry )
	
	_aCliente := {}
	
	TcQuery cQry New Alias "TMP"

	TMP->(DbGoTop())
		
		While TMP->(!EOF())
			
			If TMP->A1_MSBLQL = '1'
		    	_cLegenda	:= "BR_VERMELHO" 
		    ElseIf TMP->A1_PESSOA = 'J'
		    	_cLegenda	:= "BR_VERDE"
		    ElseIf TMP->A1_PESSOA = 'F'
		    	_cLegenda	:= "BR_AMARELO"
		    EndIf 
			
			If Len(Alltrim(TMP->A1_CGC)) = 14
				cPicCGC := "@R 99.999.999/9999-99"     
			Else
			    cPicCGC := "@R 999.999.999-99"                
			EndIf
			
			Aadd(_aCliente, { _cLegenda ,;
				Alltrim(TMP->A1_COD) 		,;
				Alltrim(TMP->A1_LOJA) 		,;
				Alltrim(TMP->A1_NOME) 		,;
				Alltrim(TMP->A1_NREDUZ) 		,;
				Transform(Alltrim(TMP->A1_CGC),cPicCGC),;
				Alltrim(TMP->A1_EST) 		,;
				Alltrim(TMP->A1_MUN) 		,;
				Alltrim(TMP->A1_BAIRRO) 		,;
				Alltrim(TMP->A1_END) ;		
			})
					
			TMP->(DbSkip())
			
		EndDo
			
	TMP->(DbCloseArea())
	
	If Len(_aCliente) = 0
			AAdd(_aCliente, Aclone(_aCli) )
	EndIf
	
    oWBrowse1:SetArray(_aCliente)
    oWBrowse1:bLine := {|| {;
       LoadBitmap(GetResources(),;
      _aCliente[oWBrowse1:nAt,1]),;
      _aCliente[oWBrowse1:nAt,2],;
      _aCliente[oWBrowse1:nAt,3],;
      _aCliente[oWBrowse1:nAt,4],;
      _aCliente[oWBrowse1:nAt,5],;
      _aCliente[oWBrowse1:nAt,6],;
      _aCliente[oWBrowse1:nAt,7],;
      _aCliente[oWBrowse1:nAt,8],;
      _aCliente[oWBrowse1:nAt,9];
    }}
    
    oWBrowse1:Refresh()
    
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PosCli บAutor  ณ Lorran Ferreira   บ Data ณ  20/04/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta Clientes 				                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosCli(_cCli,_cLoj,_xnopc)

DEFAULT _cLoj := ""

If _xnopc = 2
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
Else
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek( FWxFilial("SA1")+_cCli+_cLoj ))
	_cRet := _cCli+_cLoj
EndIf

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVERCLI  บAutor  ณLorran Ferreira     บ Data ณ  20/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Visualizar de cadastro de Cliente  				 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVERCLI(_cA1COD,_cA1LOJA)

	Local aArea			:= GetArea()
	
	If !Empty(_cA1COD) .And. !Empty(_cA1LOJA)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek( xFilial("SA1")+_cA1COD+_cA1LOJA))
			A030Visual("SA1",SA1->(RecNo()),1)
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCADCLI  บAutor  ณLorran Ferreira     บ Data ณ  20/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de inclusao de cadastro de Cliente  				 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ														       บฑฑ
ฑฑบ          ณ								                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCALL CENTER                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FCADCLI()

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
cCadastro 	:= AllTrim(Posicione("SX2",1,"SA1","X2NOME()")) + " - Incluir"// "Incluir"


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

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

aCposInd := StrToKArr(IndexKey(),"+")

aRotAuto := Nil
A030Inclui("SA1",Nil,3)


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

MsgInfo("Cliente Cadastrado: "+cCodigo+"/"+cLoja)

Return Nil
