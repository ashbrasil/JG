#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} MTA103MNU

	Ponto de Entrada responsável por acrescentar novas opções no array aRotina (Outras Ações) da rotina Documento de Entrada (MATA103).

@type function
@version  
@author Jesus Ramos
@since 28/05/2026
@return Array, Lista de opções em formato de array
/*/
User Function MTA103MNU()
	Local cKey

	aAdd(aRotina, { "#Inf. Chave NFe",              { || U_ZSF1VEIC() }, 0 ,3, 0})
	cKey := SetKey(VK_F9, {|| U_PesqDina('SF1')})

    aAdd(aRotina, { "Pesquisa Dinamica",            "U_PesqDina('SF1')", 0, 1, 0} )
	aAdd(aRotina, { "Libera Estoque Transferência", "U_JGRT011C()",      0, 6, 0} ) 

Return
