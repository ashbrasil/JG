/*
Função     : fLoadSX3
Descrição  : Efetuar a leitura do dicionário de dados especificado, atendendo às novas normals do CodeAnalisys.
Autor      : Jesus Ramos - NDS - 21/11/2019
Parâmetros 
de entrada : cTable - Alias da tabela do dicionário. Ex.: SX3.
             aFields - Array dos campos dos quais se deseja recuperar as informações do dicionário.
             aFieldsSX3 - Array dos campos do dicionário, relativos a cada um dos campos contidos em aFields.
             Obs.: Caso 
*/

// Bibliotecas necessárias
#Include "TOTVS.ch"

// Utilização do dicionário de dados SX3
User Function fLoadSX3(cTable, aFields, aFieldsSX3)

    Local aSX3         := {}           // Vetor resultante para entrega ao solicitante. Produto aFields X aFieldsSX3.
    Local aAux                         // Vetor temporário, utilizado na carga da matriz resultante.
    Local cAlias                       // Alias do arquivo de trabalho.
    Local nX
    Local cFilter                      // Filtro a ser aplicado no arquivo de trabalho.

    Default cTable     := ""           // Tabela referenciada para pesquisa na SX3.
    Default aFields    := {}           // Campos da tabela referenciada, na SX3, para carga da estrutura. Se não informado, recupera todos os campos.
    Default aFieldsSX3 := GetColumns() // Lista de campos da SX3 para carga da estrutura, conforme a tabela referenciada.

    If !Empty(cTable)

        // Efetua a abertura abertura, geração e processamento do arquivo de trabalho

	    // Definição do Alias para a tabela (arquivo de trabalho)
	    cAlias := GetNextAlias()

	    // Abertura do dicionário SX3
	    OpenSXs(NIL, NIL, NIL, NIL, , cAlias, "SX3", NIL, .F.)

	    If Select(cAlias) > 0
	        DbSelectArea(cAlias)

	        // Filtra o arquivo de trabalho, usando como chave o alias passado por parâmetro.
	        cFilter := ' X3_ARQUIVO == "'+ cTable + '"'
	        DbSetFilter({|| &(cFilter)}, cFilter)
	        DbGoTop()

	        // Carga da matriz resultante com as informações dos campos solicitados (aFields X aFieldsSX3)
			While !Eof()
				If Len(aFields) = 0 .Or. aScan(aFields, {|x| X3_CAMPO = x}) > 0
					aAux := {}
					For nX := 1 To Len(aFieldsSX3)
						AAdd(aAux, &(aFieldsSX3[nX]))
					Next nX
					AAdd(aSX3, aAux)
				EndIf
            	DBSkip()
            End

            // Fecha o arquivo de trabalho
	        DbCloseArea()
	    EndIf
	    
    EndIf

Return(aSX3)

// Campos da SX3 que desejo utilizar na minha estrutura. Lista padrão, caso o solicitante não informe lista própria.
Static Function GetColumns()

    Local aFieldsSX3 := {} // VETOR DE CAMPOS

    AAdd(aFieldsSX3, "X3_CAMPO")
    AAdd(aFieldsSX3, "X3_TITULO")
    AAdd(aFieldsSX3, "X3_PICTURE")
    AAdd(aFieldsSX3, "X3_TAMANHO")
    AAdd(aFieldsSX3, "X3_DECIMAL")
    AAdd(aFieldsSX3, "X3_VALID")
    AAdd(aFieldsSX3, "X3_USADO")
    AAdd(aFieldsSX3, "X3_TIPO")
    AAdd(aFieldsSX3, "X3_F3")
    AAdd(aFieldsSX3, "X3_CONTEXT")
    AAdd(aFieldsSX3, "X3_CBOX")
    AAdd(aFieldsSX3, "X3_RELACAO")
    AAdd(aFieldsSX3, "X3_WHEN")
    AAdd(aFieldsSX3, "X3_VISUAL")
    AAdd(aFieldsSX3, "X3_VLDUSER")
    AAdd(aFieldsSX3, "X3_PROPRI")

Return(aFieldsSX3)
