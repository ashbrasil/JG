#Include "Totvs.ch"
#Include "jgtransf.ch"

/*/{Protheus.doc} LJ140VLC

Ponto de entrada para validar se a venda poderá ser cancelada/excluída.
Validações realizadas:
- Para orçamentos de filiais que não têm estoque (0104, por exemplo), permite excluir/cancelar apenas se o orçamento estiver faturado, 
	pois será realizado apenas o cancelamento junto à SEFAZ, ou se não estiver faturado e com status "Em aberto".
- Para os demais orçamentos, não tem ação.

@type    function
@version 1.0
@author  Jesus Ramos
@since   27/05/2026
@return  Logical, .T. para permitir a exclusão/cancelamento e .F. para bloquear a exclusão/cancelamento.
/*/
User Function LJ140VLC()

	Local lRet := .T.

	If Empty(SL1->L1_DOC) .And. Empty(SL1->L1_DOCPED)
		If !Empty(SL1->L1_XMOVTRF) .And. !(SL1->L1_XMOVTRF == JGTrOrEAb)
			lRet := .F.
			FWAlertWarning("Orçamento vinculado a uma transferência de estoque ativa."+CRLF+CRLF+;
							"Status atual da transferência: "+"<b>"+U_fDsStTrf("O",SL1->L1_XMOVTRF)+"</b>."+CRLF+CRLF+;
							"Sua exclusão somente será possível após desfazimento da transferência, "+;
							"quando o status da transferência deste orçamento estiver como "+"<b>"+U_fDsStTrf("O",JGTrOrEAb)+"</b>.",;
							"Exclusão do orçamento")
		EndIf
	EndIf

Return(lRet)
