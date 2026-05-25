#include "totvs.ch"

User Function MA410LEG()
    Local aLegenda    := paramixb
    Local aLegendaRet := {}
    Local nLoop       := 1

    aAdd(aLegendaRet, {"BR_VERDE_ESCURO", "Liberado Parcial"})

    For nLoop := 1 To Len(aLegenda)
        aAdd(aLegendaRet, aLegenda[nLoop]) // Adiciona as condições de cores recebidas por parâmetro ao array de retorno.
    Next
    
Return aLegendaRet
