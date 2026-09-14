#include "totvs.ch"
#Include "TopConn.Ch"
#Include "tbiconn.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ JGRT001  ºAutor  ³ ASH Tecnologia     º Data ³  01/09/26   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta da ordem de separação do pedido                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ JG                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function JGSTPED()

    local cNumped       := SC5->C5_NUM
    local cCli          := SC5->C5_CLIENTE
    local cLjcli        := SC5->C5_LOJACLI 
    local cStatusSep    := ""
    local cMsgStatus    := ""

    cStatusSep := ALLTRIM(POSICIONE("CB7",11,XFILIAL("CB7")+cNumped+cCli+cLjcli,"CB7_STATUS"))

    Do Case
        
        Case cStatusSep == "0"

            cMsgStatus := "Inicio"
        
        Case cStatusSep == "1"

           cMsgStatus := "Separando" 

        Case cStatusSep == "2"

            cMsgStatus := "Sep.Final"

        Case cStatusSep == "3"

            cMsgStatus := "Embalando"

        Case cStatusSep == "4"

            cMsgStatus := "Emb.Final"

        Case cStatusSep == "5"

            cMsgStatus := "Gera Nota"

        Case cStatusSep == "6"

            cMsgStatus := "Imp.nota"

        Case cStatusSep == "7"

            cMsgStatus := "Imp.Vol"

        Case cStatusSep == "8"

            cMsgStatus := "Embarcado"

        Case cStatusSep == "9"

            cMsgStatus := "Embarque Finalizado"
        
    EndCase

Return cMsgStatus
