#include "totvs.ch"

User Function MA410COR
    Local aCores    := paramixb
    Local aCoresRet := {}
    Local nLoop     := 1

    aAdd(aCoresRet, {" u_PEDPARCIAL()", "BR_VERDE_ESCURO", "Teste 01"})

    For nLoop := 1 To Len(aCores)
        aAdd(aCoresRet, aCores[nLoop]) // Adiciona as condições de cores recebidas por parâmetro ao array de retorno.
    Next    
Return aCoresRet
