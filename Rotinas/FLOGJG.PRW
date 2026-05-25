#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FLOGJG
FLOGJG - Nova função para substituir de forma rápida a 
função padrão "Conout" dos fontes do projeto, como a função foi descontinuada pela TOTVS.
Até ser definido o que fazer com os textos de log vamos manter o conout dentro da função.
@type function
@version 
@author Jesus Ramos
@since 23/02/2026
@return return_type, return_description
/*/
User Function FLOGJG(_LOG)
    Conout(_LOG)
Return
