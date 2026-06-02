//Bibliotecas
#INCLUDE "TOTVS.CH"
// #INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MTA010MNU

	Ponto de Entrada para adicionar opções ao menu do cadastro de produtos (MATA010).

@type function
@version 1.0
@author Jesus Ramos
@since 01/06/2026
@return Nil
/*/
User Function MTA010MNU()
	
	/* Rotina de atualização de preços */
    If FWIsAdmin()
	    AAdd(aRotina, {OemToAnsi("Atualiza Preços"), "U_JGATUPRE", 0, 2, 0, NIL})
	EndIf

Return(Nil)
