#INCLUDE "TOTVS.CH"
#INCLUDE "JGTRANSF.CH"

/*/{Protheus.doc} LJ7052

	Essa função tem como finalidade gravar arquivos adicionais ou realizar ajustes na saída do Venda Assistida.

@type function
@version  
@author Jesus Ramos
@since 08/05/2026
@param nOpcEsc, numeric, Opção escolhida no aRotina: 4-Finaliza Venda, ...
@param ntipo, numeric, Informa o tipo de movimento será gerado: 1-Orçamento, 2-Venda, 3-Pedido.
@param lGrava, logical, Indica se o atendimento será gravada ou não.
@return variant, Nil
/*/
User Function LJ7052(nOpcEsc,ntipo,lGrava)

    If !(Type("__bkKCtrlL") == "U")
        SetKey( K_CTRL_L, __bkKCtrlL ) //Retorna a tecla de atalho CTRL+L à configuração original.
    EndIf

Return
