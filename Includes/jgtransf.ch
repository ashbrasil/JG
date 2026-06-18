/* Status da transferência imediata no SIGALOJA - SL1/SLQ - Campo LQ_XMOVTRF/L1_XMOVTRF */
#Define JGTrOrNSA  " " // Não se aplica - A filial tem estoque próprio, não exigindo composição de estoque imediata. O orçamento pode ser manipulado pelo vendedor e seus superiores e, inclusive, finalizado pelo caixa.
// A partir daqui, os status indicam que a filial não estoque próprio e exige a transferência imediata para composição do estoque.

#Define JGTrOrEAb  "1" // Orçamento em Aberto - A confecção do orçamento ainda está em andamento pelo vendedor. O orçamento pode ser editado normalmente pelo vendedor e seus superiores.
#Define JGTrOrIni  "2" // Transferência iniciada - O orçamento foi liberado pelo vendedor e marcado para iniciar o processo de transferência. O orçamento não pode ser manipulado.
#Define JGTrOrPPS  "3" // Pedido de venda Pendente de Separação - O pedido de transferência foi gerado, mas ainda não foi foi realizada a separação dos itens pela Logística. O orçamento não pode ser manipulado.
#Define JGTrOrPPF  "4" // Pedido de Venda Pendente de Faturamento - O pedido de transferência foi separado, mas ainda não foi gerada a NF de saída. O orçamento não pode ser manipulado.
#Define JGTrOrNPA  "5" // NF de Saída Gerada e Pendente de Autorização - A NF de saída foi gerada, mas ainda não foi autorizada pela SEFAZ. O orçamento não pode ser manipulado.
#Define JGTrOrNPE  "6" // NF de Saída Autorizada e Pendente de Entrada na Filial de Destino - A NF de saída foi autorizada pela SEFAZ, mas a NF de entrada ainda não foi lançada na filial solicitante. O orçamento não pode ser manipulado.
#Define JGTrOrOK   "7" // Transferência Concluída - A NF de entrada foi lançada na filial solicitante e o estoque está disponível para baixa. Somente o caixa poderá finalizar o orçamento solicitante.
#Define JGTrOrExD  "8" // A NF de entrada foi excluída.
#Define JGTrOrExO  "9" // A NF de saída foi excluída.
#Define JGTrOrOS   "A" // PV não cancelado - Ordens de Montagem.
#Define JGTrOrCan  "X" // Transferência Cancelada - O processo de transferência foi cancelado. O orçamento pode ser editado normalmente pelo vendedor e seus superiores ou pode ser excluído.

// #Define JGTrOrEAb  "1" // Orçamento em Aberto - A confecção do orçamento ainda está em andamento pelo vendedor. O orçamento pode ser editado normalmente pelo vendedor e seus superiores.
// #Define JGTrOrIni  "2" // Transferência iniciada - O orçamento foi liberado pelo vendedor e marcado para iniciar o processo de transferência. O orçamento não pode ser manipulado.
// #Define JGTrOrPGe  "3" // Pedido de Venda de transferência gerado - O pedido de transferência foi gerado, mas ainda não foi foi realizada a separação dos itens pela Logística. O orçamento não pode ser manipulado.
// #Define JGTrOrPVS  "4" // Pedido de Venda de transferência separado - O pedido de transferência foi separado, mas ainda não foi gerada a NF de saída. O orçamento não pode ser manipulado.
// #Define JGTrOrNGe  "5" // NF de Saída Gerada - A NF de saída foi gerada, mas ainda não foi autorizada pela SEFAZ. O orçamento não pode ser manipulado.
// #Define JGTrOrNAu  "6" // NF de Saída Autorizada - A NF de saída foi autorizada pela SEFAZ, mas a NF de entrada ainda não foi lançada na filial solicitante. O orçamento não pode ser manipulado.
// #Define JGTrOrOK   "7" // Transferência Concluída - A NF de entrada foi lançada na filial solicitante e o estoque está disponível para baixa. Somente o caixa poderá finalizar o orçamento solicitante.

/* Status da transferência - SC5 - Campo C5_XMOVTRF */
#Define JGTrPVNor  " " // Pedido de Venda Normal - Não entra no processo de Transferência.
#Define JGTrPVPSp  "1" // Pedido de Venda Pendente de Separação - O pedido de venda foi gerado, mas ainda não foi separado. O processo de transferência foi iniciado.
#Define JGTrPVPFt  "2" // Pedido de Venda Pendente de Faturamento - O pedido de venda foi separado, mas ainda não foi faturado.
#Define JGTrPVNPA  "3" // Nota Fiscal de Saída Pendente de Autorização - A NF de saída foi gerada, mas ainda não foi autorizada pela SEFAZ. O processo de transferência está em andamento.
#Define JGTrPVNPE  "4" // Nota Fiscal de Saída Autorizada, Pendente de Entrada na filial solicitante - A NF de saída foi autorizada pela SEFAZ, mas a NF de entrada ainda não foi lançada na filial solicitante. O processo de transferência está em andamento.
#Define JGTrPVEPL  "L" // Entrada pendente de liberação - A NF de entrada foi lançada na filial solicitante mas o estoque ainda não foi liberado para o armazém de venda.
#Define JGTrPVOK   "5" // Transferência Concluída - A NF de entrada foi lançada na filial solicitante e o estoque está disponível para baixa. O processo de transferência foi concluído.
#Define JGTrPVExD  "6" // A NF de entrada foi excluída na filial de destino.
#Define JGTrPVExO  "7" // A NF de saída foi excluída na filial de origem. O pedido deverá ser residuado.
#Define JGTrPVOS   "8" // PV não cancelado - Ordens de Montagem.
#Define JGTrPVCan  "X" // Transferência Cancelada - O processo de transferência foi cancelado. O pedido de venda foi residuado e mantido para histórico.
