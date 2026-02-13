//Bibliotecas
#Include 'Totvs.ch'
 
/*/{Protheus.doc} Ponto de entrada MA410MNU
Acrescentar botões no browse de pedidos de vendas.
@type    User function
@author  Fernando Carvalho 
@since   08/01/2026
@version P12
@Obs        Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.  
            Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
            https://tdn.totvs.com/display/public/PROT/MA410MNU
@Contributors Alfredo, Lucas Santos
/*/
User Function MA410MNU()
    Local aArea := FWGetArea()
    Local cKey
    
    cKey := SetKey(VK_F8, {|| U_ImpOrcPed()})    
    //08/01/2026 - Fernando Carvalho - Inclusão da opção para impressão personalizada do orçamento/pedido.
    aAdd(aRotina,{'Impressão JG'            , 'U_ImpOrcPed()'  , 0 , 1, 0 , Nil} )
    //11/02/2026 - Alfredo - Inclusão da opção de menu para execução da rotina para informação do peso, volume e espécie no pedido de venda.
    //Merge do fonte do Alfredo com o fonte do Fernando, visto que ambos acrescentam opções no mesmo menu.
	aAdd(aRotina,{ "#Inf. Peso"             , "U_ZSC5VEIC()"   , 0 , 3, 0 , Nil} ) //Ajustada a chamada para texto. O original do Alfredo trazia um bloco de código.
    //12/02/2026 - Lucas Santos - Inclusão de opções para impressão de promissória e boleto a partir da rotina pedido de venda (MATA410).
    //Adicionando função de vincular
    aAdd(aRotina,{"* Imprimir Promissória"  , "U_JG05A003('1')", 0 , 4, 0 , Nil} )
    aAdd(aRotina,{"* Imprimir Boleto"       , "U_JG05A003('2')", 0 , 4, 0 , Nil} )
    // aadd(aRotina,{"* Envia E-mail com Boleto e Danfe"       , "U_JG05A004()", 0 , 4, 0 , Nil})
     
    FWRestArea(aArea)
Return
