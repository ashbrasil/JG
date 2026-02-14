#Include "Protheus.ch"

/*______________________________________________________________________
   ¦Autor     ¦ Alfredo Sueira                      ¦ Data ¦ 12/02/26 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Bloqueia Emissão de Nota sem peso                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function M410PVNF()

    Local lRet := .T.

    // Só valida quando tipo = N
    If AllTrim(SC5->C5_TIPO) == "N"

        If SC5->C5_PESOL   <= 0 .Or. ;
           SC5->C5_PBRUTO  <= 0 .Or. ;
           SC5->C5_VOLUME1 <= 0 .Or. ;
           Empty(AllTrim(SC5->C5_ESPECI1))

            MsgStop("Os campos de peso, volume e espécia não foram preenchidos corretamente.", "Atenção")
            lRet := .F.

        EndIf

    EndIf

Return lRet
