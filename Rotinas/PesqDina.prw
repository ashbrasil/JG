#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cPesquisa := ''


/*/{Protheus.doc} Função para busca dinamica por NOME, CNPJ ou CPF
Função que realiza a busca através de uma pesquisa customizada de registros de clientes.
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/
User Function PesqDina(cOrigem)
    Local oBrowse   := GetMBrowse()
    Local cFiltro   := ''


    If PergPesqu()
        If !Empty(cPesquisa)            
            If cOrigem == 'SA1'
                cFiltro     :=  "'"+cPesquisa+"' $ A1_NOME  .OR. '"+cPesquisa+"' $ A1_NREDUZ .OR. '"+cPesquisa+"' $ A1_CGC  "
            ElseIf cOrigem == 'SC5'
                cFiltro     :=  "'"+cPesquisa+"' $ C5_NUM  .OR. '"+cPesquisa+"' $ C5_CLIENTE  .OR. '"+cPesquisa+"' $ C5_XNOMCLI"
            ElseIf cOrigem == 'SF1'
                cFiltro     :=  "'"+cPesquisa+"' $ F1_DOC  .OR. '"+cPesquisa+"' $ F1_FORNECE "
            EndIf    
        else
            cFiltro     :=  ""
        EndIf
        
    EndIf    

    oBrowse:SetFilterDefault(cFiltro )
    oBrowse:Refresh()

Return

/*/{Protheus.doc} Tela para digitar a pesquisa a ser filtrada no browse
Função que cria a Tela para digitar a pesquisa a ser filtrada no browse
@type user function
@author Fernando Carvalho 
@since 08/01/2026
@version P12
/*/
Static Function PergPesqu()  
    Local lRet          := .F.

    _aRet               := {}
    _aParamBox          := {}
    cPesquisa           := Space(30)


    aAdd(_aParamBox,{;
		    1,;                                         //[1]MsGet
        'Pesquisa por CNPJ/CPF/NOME:',;                 //[2]Descrição
        cPesquisa,;                                     //[3]String contendo o inicializador do campo
        "@!",;                                          //[4]String contendo a Picture do campo
        '.T.',;                                         //[5]String contendo a validação
        '',;                                            //[6]Consulta F3
        '.T.',;                                         //[7]String contendo a validação When
        80,;                                            //[8]Tamanho do MsGet
        .F.;                                            //[9]Flag .T./.F. Parâmetro Obrigatório ?
	})

	
    If (lRet := ParamBox(_aParamBox,"PESQUISA",@_aRet, , , ,0,0))
		If Len(_aRet) > 0
			cPesquisa     := AllTrim(UPPER(_aRet[1]))
			            
		EndIf
    EndIf                

Return lRet

