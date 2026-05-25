#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function MTA103MNU()
	Local cKey

	aAdd(aRotina,{ "#Inf. Chave NFe", { || U_ZSF1VEIC() }, 0 , 3, 0, .F.})
	cKey := SetKey(VK_F9, {|| U_PesqDina('SF1')})
    aAdd(aRotina,{"Pesquisa Dinamica","U_PesqDina('SF1')",1,0})

Return
