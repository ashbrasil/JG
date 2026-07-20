// #include "fileio.ch"
// #INCLUDE "APWEBSRV.CH"
// #INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
// #INCLUDE "PROTHEUS.CH"
// #INCLUDE "rwmake.ch"
#include "TOTVS.CH"

/*/{Protheus.doc} fCalcCus

	Atualiza/Grava o custo na tabela ZZ4.

@type function
@version  
@author Jesus Ramos
@since 24/06/2026
@param aProdutos, array, param_description
@param lGrvCust, logical, param_description
@param cItem, character, param_description
@param lCustoMed, logical, param_description
@return variant, return_description
/*/
User Function fCalcCus(aProdutos,lGrvCust,cItem,lCustoMed)

	// Local aProd	:= {}
	Local aRet := {.f.,{}}

	Private _MSG	 := {| cStr | oSay:cCaption := (cStr) , ProcessMessages() }

	Default aProdutos := {}
	Default lGrvCust  := .F.
	Default cItem	  := ""
	Default lCustoMed := .T.

	If !IsBlind() // Jesus Ramos - 20/09/2021 - Incluido por causar erro quando chamado fora da interface
		FWMsgRun(, {|oSay| aRet:=FPROC(aProdutos,lGrvCust,oSay,lCustoMed) }, "Custo"+IIF(!Empty(cItem)," - Item: "+cItem, "") , "Processando..." )
	Else
		aRet:=FPROC(aProdutos,lGrvCust,/*oSay*/,lCustoMed)
	EndIf

Return(aRet)

Static Function FPROC(aProdutos,lGrvCust,oSay,lCustoMed)

	Local cFILCUSTO := SuperGetMV("JG_FCALCUS",.F.,"{'PA','0101'}")
	Local aFilCusto := Separa(cFILCUSTO,";")
	Local aFil		  := {}
	// Local cProduto  := ""
	Local nPosCOD		:= 1
	Local nPosUF		:= 2
	Local nPosCUF		:= 3
	Local nPosCTR		:= 4
	Local nPosCMSST		:= 5
	Local nPosCMCST		:= 6
	Local nPosQtdNF		:= 7
	Local nPosCMIPI		:= 8
	Local nPosCDesp		:= 9
	Local nPosCDTra		:= 10 // Custo de despesa de tranferencia entre filiais
	Local aCustMemo		:= {}
	Local lAdd := .f.
	Local cFilOld	:= cFilAnt
	Local nReg			:= 0
	// Local cArqXB		:= ""
	Local lGrv			:= .f.
	Local aDados		:= {}
	Local aRetProc		:= {}
	Local aDadRet		:= {}
	Local nPosA			:= 0
	Local nPosN			:= 0
	Local nPosVP		:= 0
	Local aCampoVP		:= {}
	Local x, y, nx, ny, P, FF

	Private lONLINE		:= .f.
	Private aFilial	:= _fRetFil()
	Private aArmaz	:= aClone(Separa(SuperGetMv("JG_ARMZZ4",,"01,02"),',',.F.))//{'01','02','03','20'}
	Private aCusZZ4 	:= {}
	Private aCusProd	:= {}
	Private _lCustoMed	:= .T.

	Default oSay 	  := Nil
	Default lCustoMed := .T.

	_lCustoMed := lCustoMed

	For x:=1 To Len(aFilCusto)
		Aadd( aFil , &(aFilCusto[x]) )
	Next x

	If !IsBlind() // Jesus Ramos - 20/09/2021 - Incluido por causar erro quando chamado fora da interface
		Eval(_MSG, "Calculando o Custo..." )
	EndIf

	For P:=1 To Len(aProdutos)

		For FF:=1 To Len(aFil)

			cFilAnt := aFil[FF,2]
			FFILSM0()

			FCALCULA( aProdutos[P] )

		Next FF

	Next P

	cFilAnt := cFilOld
	FFILSM0()

	//Adiciona o custo da ZZ4 para iniciar o custo medio do dia
	For x:=1 To Len(aCusZZ4)

		Aadd( aCustMemo, { Alltrim(aCusZZ4[x,nPosCOD]) , aCusZZ4[x,nPosUF] , aCusZZ4[x,nPosCUF] , aCusZZ4[x,nPosCTR] , aCusZZ4[x,nPosCMSST] , aCusZZ4[x,nPosCMCST] , aCusZZ4[x,nPosQtdNF] , aCusZZ4[x,nPosCMIPI] , aCusZZ4[x,nPosCDesp] , aCusZZ4[x,nPosCDTra] } )

	Next x

	For x:=1 To Len(aCusProd)

		lAdd := .t.

		for y:=1 To Len(aCustMemo)
			If Alltrim(aCustMemo[y,nPosCOD]) == Alltrim(aCusProd[x,nPosCOD]) .And. Alltrim(aCustMemo[y,nPosUF]) == Alltrim(aCusProd[x,nPosUF])

				aCustMemo[y,nPosCUF]	+= aCusProd[x,nPosCUF]
				aCustMemo[y,nPosCMSST]	+= aCusProd[x,nPosCMSST]
				aCustMemo[y,nPosCMCST]	+= aCusProd[x,nPosCMCST]
				aCustMemo[y,nPosCTR]	+= aCusProd[x,nPosCTR]
				aCustMemo[y,nPosQtdNF]	+= aCusProd[x,nPosQtdNF]
				aCustMemo[y,nPosCMIPI]	+= aCusProd[x,nPosCMIPI]
				aCustMemo[y,nPosCDesp]	+= aCusProd[x,nPosCDesp]
				aCustMemo[y,nPosCDTra]	+= aCusProd[x,nPosCDTra]

				lAdd := .f.

			EndIf
		Next y

		If lAdd
			Aadd( aCustMemo, { Alltrim(aCusProd[x,nPosCOD]) , aCusProd[x,nPosUF] , aCusProd[x,nPosCUF] , aCusProd[x,nPosCTR] , aCusProd[x,nPosCMSST] , aCusProd[x,nPosCMCST] , aCusProd[x,nPosQtdNF] , aCusProd[x,nPosCMIPI] , aCusProd[x,nPosCDesp] , aCusProd[x,nPosCDTra] } )
		EndIF

	Next x

	If lGrvCust

		lGrv := .f.

		nReg := Len(aCustMemo)
		For x:=1 To nReg

			If !IsBlind() // Jesus Ramos - 20/09/2021 - Incluido por causar erro quando chamado fora da interface
				Eval(_MSG, "Gravando Custo Tabela ZZ4: " + Rtrim(cValToChar( INT(( x * 100 )/nReg ) )) +"%")
			EndIf

			ZZ4->(DbSetOrder(1))
			If ZZ4->( DbSeek( xFilial("ZZ4") + aCustMemo[x,nPosUF] + aCustMemo[x,nPosCOD]) )

				If RecLock("ZZ4",.F.)

					If lONLINE
						aDados:={}
						Aadd( aDados , { "GRAVADO" 	  , .T. 			} )
						Aadd( aDados , { "UF"	  	  , ZZ4->ZZ4_UF		} )
						Aadd( aDados , { "CODIGO"  	  , ZZ4->ZZ4_CODIGO	} )
						Aadd( aDados , { "MRGUF_A"    , ZZ4->ZZ4_CMRUF	} )
						Aadd( aDados , { "MRGSST_A"   , ZZ4->ZZ4_CMRSST	} )
						Aadd( aDados , { "MRGCST_A"   , ZZ4->ZZ4_CMRCST	} )
						Aadd( aDados , { "MRGTRA_A"   , ZZ4->ZZ4_CTRANS	} )
						Aadd( aDados , { "MRGIPI_A"   , ZZ4->ZZ4_CMRIPI	} )
						Aadd( aDados , { "MRGCDESP_A" , ZZ4->ZZ4_CVDESP	} )
						Aadd( aDados , { "MRGCDTRA_A" , ZZ4->ZZ4_VDTRAN	} )
					EndIf

					ZZ4->ZZ4_CMRUF 		:= aCustMemo[x,nPosCUF]	  /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_CMRSST 	:= aCustMemo[x,nPosCMSST] /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_CMRCST 	:= aCustMemo[x,nPosCMCST] /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_CTRANS 	:= aCustMemo[x,nPosCTR]	  /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_CMRIPI 	:= aCustMemo[x,nPosCMIPI] /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_CVDESP		:= aCustMemo[x,nPosCDesp] /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_VDTRAN		:= aCustMemo[x,nPosCDTra] /	aCustMemo[x,nPosQtdNF]
					ZZ4->ZZ4_DTALTE		:= Date()

					If lONLINE	
						Aadd( aDados , { "MRGUF_N"   , ZZ4->ZZ4_CMRUF	} )
						Aadd( aDados , { "MRGSST_N"   , ZZ4->ZZ4_CMRSST	} )
						Aadd( aDados , { "MRGCST_N"   , ZZ4->ZZ4_CMRCST	} )
						Aadd( aDados , { "MRGTRA_N"   , ZZ4->ZZ4_CTRANS	} )
						Aadd( aDados , { "MRGIPI_N"   , ZZ4->ZZ4_CMRIPI	} )
						Aadd( aDados , { "MRGCDESP_N" , ZZ4->ZZ4_CVDESP	} )
						Aadd( aDados , { "MRGCDTRA_N" , ZZ4->ZZ4_VDTRAN	} )
						//Variação em percentual
						Aadd( aDados , { "MRGUF_VP"    , 0	} )
						Aadd( aDados , { "MRGSST_VP"   , 0	} )
						Aadd( aDados , { "MRGCST_VP"   , 0	} )
						Aadd( aDados , { "MRGIPI_VP"   , 0	} )
						Aadd( aDados , { "MRGCDESP_VP" , 0	} )
						Aadd( aDados , { "MRGCDTRA_VP" , 0	} )

						Aadd( aDadRet , aClone(aDados) )
					EndIf

					lGrv := .t.

				EndIf

				ZZ4->(MsUnlock())

			Else

				If !Empty(aCustMemo[x,nPosUF]) .And. !Empty(aCustMemo[x,nPosCOD])

					If RecLock("ZZ4",.T.)

						ZZ4->ZZ4_FILIAL 		:= xFilial("ZZ4")
						ZZ4->ZZ4_UF    		:= aCustMemo[x,nPosUF]
						ZZ4->ZZ4_CODIGO		:= aCustMemo[x,nPosCOD]
						ZZ4->ZZ4_CMRUF 		:= aCustMemo[x,nPosCUF]	  /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_CMRSST 	:= aCustMemo[x,nPosCMSST] /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_CMRCST 	:= aCustMemo[x,nPosCMCST] /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_CTRANS 	:= aCustMemo[x,nPosCTR]	  /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_CMRIPI 	:= aCustMemo[x,nPosCMIPI] /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_CVDESP		:= aCustMemo[x,nPosCDesp] /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_VDTRAN		:= aCustMemo[x,nPosCDTra] /	aCustMemo[x,nPosQtdNF]
						ZZ4->ZZ4_DTALTE		:= Date()

						If lONLINE
							aDados:={}
							Aadd( aDados , { "GRAVADO" 	 , .T. 				} )
							Aadd( aDados , { "UF"	  	 , ZZ4->ZZ4_UF		} )
							Aadd( aDados , { "CODIGO"  	 , ZZ4->ZZ4_CODIGO	} )
							Aadd( aDados , { "MRGUF_A"    , 0	} )
							Aadd( aDados , { "MRGSST_A"   , 0	} )
							Aadd( aDados , { "MRGCST_A"   , 0	} )
							Aadd( aDados , { "MRGTRA_A"   , 0	} )
							Aadd( aDados , { "MRGIPI_A"   , 0	} )
							Aadd( aDados , { "MRGCDESP_A" , 0	} )
							Aadd( aDados , { "MRGCDTRA_A" , 0	} )
							Aadd( aDados , { "MRGUF_N"    , ZZ4->ZZ4_CMRUF	} )
							Aadd( aDados , { "MRGSST_N"   , ZZ4->ZZ4_CMRSST	} )
							Aadd( aDados , { "MRGCST_N"   , ZZ4->ZZ4_CMRCST	} )
							Aadd( aDados , { "MRGTRA_N"   , ZZ4->ZZ4_CTRANS	} )
							Aadd( aDados , { "MRGIPI_N"   , ZZ4->ZZ4_CMRIPI	} )
							Aadd( aDados , { "MRGCDESP_N" , ZZ4->ZZ4_CVDESP	} )
							Aadd( aDados , { "MRGCDTRA_N" , ZZ4->ZZ4_VDTRAN	} )
							//Variação em percentual
							Aadd( aDados , { "MRGUF_VP"    , 0	} )
							Aadd( aDados , { "MRGSST_VP"   , 0	} )
							Aadd( aDados , { "MRGCST_VP"   , 0	} )
							Aadd( aDados , { "MRGIPI_VP"   , 0	} )
							Aadd( aDados , { "MRGCDESP_VP" , 0	} )
							Aadd( aDados , { "MRGCDTRA_VP" , 0	} )

							Aadd( aDadRet , aClone(aDados) )
						EndIf	

						lGrv := .t.

					EndIf

					ZZ4->(MsUnlock())

				EndIf

			EndIf

		Next x

	EndIf //lGrvCust

	//Campos para calculo da Variação em percentual
	Aadd( aCampoVP , { "MRGUF_VP" 	 , "MRGUF_A" 	 , "MRGUF_N" } )
	Aadd( aCampoVP , { "MRGSST_VP"   , "MRGSST_A" 	 , "MRGSST_N" } )
	Aadd( aCampoVP , { "MRGCST_VP" 	 , "MRGCST_A" 	 , "MRGCST_N" } )
	Aadd( aCampoVP , { "MRGIPI_VP" 	 , "MRGIPI_A" 	 , "MRGIPI_N" } )
	Aadd( aCampoVP , { "MRGCDESP_VP" , "MRGCDESP_A"  , "MRGCDESP_N" } )
	Aadd( aCampoVP , { "MRGCDTRA_VP" , "MRGCDTRA_A"  , "MRGCDTRA_N" } )

	For nx:=1 To Len(aDadRet)

		For ny:=1 To Len(aCampoVP)

			nPosVP 	:= aScan(aDadRet[nx],{|x| x[1] == aCampoVP[ny,1] }) //Variação em percentual
			nPosA 	:= aScan(aDadRet[nx],{|x| x[1] == aCampoVP[ny,2] }) //Custo Atual
			nPosN 	:= aScan(aDadRet[nx],{|x| x[1] == aCampoVP[ny,3] }) //Custo Novo

			If nPosVP > 0 .And. nPosA > 0 .And. nPosN > 0

				If aDadRet[nx][nPosA][2] > 0	
					aDadRet[nx][nPosVP][2] := NOROUND( ((aDadRet[nx][nPosN][2]-aDadRet[nx][nPosA][2])/aDadRet[nx][nPosA][2])*100 , 2)
				EndIf

			EndIf

		Next ny

	Next nx

	aRetProc := { lGrv , aClone(aDadRet) }

Return(aRetProc)

/*--------------------------------------------------------------------------------------------------
Função: fCalcCus
Tipo: Função Estática
Descrição:
Parâmetros:
Retorno:
----------------------------------------------------------------------------------------------------
Atualizações:
--------------------------------------------------------------------------------------------------*/
Static Function FCALCULA( aProduto )

	Local _CUSTOMRG		:= 0 //Custo Fiscal da Entrada
	Local _CUSTOTRF		:= 0 //Custo Base transferencia
	Local _CUSMRGSST	:= 0 //Custo Margem sem ST
	Local _CUSMRGBST	:= 0 //Custo Margem com ST
	Local _CUSTOIPI		:= 0 //Custo Margem IPI CD
	Local nQtdEstA		:= 0 //Quantidade em estoque para calculo do custo medio
	Local _CDESPTRANSF	:= 0 // Valor de custo adicional de transferencia entre filiais
	Local aCalcEst  	:= {} //Array utilizado na função CalcEst
	//Local _UF 			:= ""
	Local lAdd := .f.
	Local nCustStTare := 0
	Local cNCMTARE		:= SuperGetMv("ES_NCMTARE",.F.,"85171231")//"85171231" //NCM tare
	Local aValPad		:= {}
	Local cFil			:= cFilAnt
	Local aArea			:= GetArea()
	Local dDtEst		:= dDataBase

	Local nPICMSMAXCR	:= 0 //Aliquota maxima credito icms
	// Local cNCMCRALQ7	:= SuperGetMv("ES_NCMCRA7",.F.,"85176239;85176241;85176249;85176254;85176255;85176259;85176277;85176294;85177010;85363090;85044029;85044021") //NCM de produtos que não podemos aproveitar mais de 7% de crédito
	Local Ny, Z, F, A
	Local lEstornarIcms := SuperGetMv("ES_ICMCUST",.F.,.T.) // Variavel para considerar o ICMS no custo
	Local nPCUSICMTR 	:= SuperGetMv("ES_PCUSTTR",.F.,0) // Percentual de custo ICMS na transferencia entre filiais

	Aadd( aValPad , { "_FILIAL"		, "cFilAnt"	})
	Aadd( aValPad , { "_D1PROD" 	, "''" } )
	Aadd( aValPad , { "_D1VUNIT" 	, "0" } )
	Aadd( aValPad , { "_D1TES" 		, "''" } )
	Aadd( aValPad , { "_D1QUANT" 	, "0" } )
	Aadd( aValPad , { "_D1CUSTO" 	, "0" } )
	Aadd( aValPad , { "_PICM" 		, "0" } )
	Aadd( aValPad , { "_D1CF" 		, "''" } )
	Aadd( aValPad , { "_D1VALDESC" 	, "0" } )
	Aadd( aValPad , { "_D1VALFRE" 	, "0" } )
	Aadd( aValPad , { "_D1DESPESA" 	, "0" } )
	Aadd( aValPad , { "_D1SEGURO" 	, "0" } )
	Aadd( aValPad , { "_D1COFINS" 	, "0" } )
	Aadd( aValPad , { "_D1PIS" 		, "0" } )
	Aadd( aValPad , { "_D1VALIPI" 	, "0" } )
	Aadd( aValPad , { "_D1VALICM" 	, "0" } )
	Aadd( aValPad , { "_D1BASEICM" 	, "0" } ) //Lorran Ferreira - 27/02/2020
	Aadd( aValPad , { "_D1ICMSRET" 	, "0" } )	
	Aadd( aValPad , { "_D1FORNECE" 	, "''" } )
	Aadd( aValPad , { "_D1LOJA" 	, "''" } )
	Aadd( aValPad , { "_A2GRPTRIB" 	, "''" } )
	Aadd( aValPad , { "_B1NCM" 		, "''" } )
	Aadd( aValPad , { "_B1GRTRIB" 	, "''" } )
	Aadd( aValPad , { "_B1ORIGEM" 	, "''" } )
	Aadd( aValPad , { "_VSERVSUP" 	, "0" } ) //Valor do custo de serviço agregados ao produto Ex.: Suporte DELL
	Aadd( aValPad , { "_UF"   		, "SuperGetMv('MV_ESTADO',,'XX')" })
	Aadd( aValPad , { "_ONLINE" 	, ".F." } )

	//###################################################################################
	//####	Zera as variaveis com valores PADRAO									####
	//###################################################################################
	For Ny:=1 To Len(aValPad)
		&(aValPad[Ny][1]) := &(aValPad[Ny][2])
	Next Ny

	//###################################################################################
	//####	Carrega as variaveis com valores do array aProduto						####
	//###################################################################################
	For Ny:=1 To Len(aProduto)
		//If aProduto[Ny][1] <> "_FILIAL" //Retirado - Lorran Ferreira 27/02/2020
			&(aProduto[Ny][1]) := aProduto[Ny][2]
		//EndIF
	Next Ny

	//Entradas de compra no CD
	//_FILIAL variavel com a filial de entrada da NF
	If _FILIAL == "0130" .Or. cFilAnt == "0130"
		nPICMSMAXCR	:= SuperGetMv("ES_ICMCRMAX",.F.,11) //Aliquota maxima credito icms dentro do CD goias
	Endif

	//If Alltrim(_B1NCM) $ Alltrim(cNCMCRALQ7)
	//Regra atualizada para buscar somente NCM do apêndice IV - 27/05/2021 - Lorran Ferreira
	If &("StaticCall( MARGEMPRIME , FAPENDICEIV , _B1NCM )") 
		nPICMSMAXCR	:= 7 //Aliquota maxima credito icms
	Endif

	//Aliquota crédito máximo de ICMS - Definido por TONI - Lorran Ferreira
	If nPICMSMAXCR > 0 
		If _PICM > nPICMSMAXCR
			_D1VALICM := _D1BASEICM * (nPICMSMAXCR/100)
		EndIf
	EndIf

	// -> Calcula Custos
	_D1VUNIT 	-= _D1VALDESC
	_CUSTOMRG 	:= _D1VUNIT
	_CUSTOTRF 	:= _D1VUNIT
	_CUSMRGSST 	:= _D1VUNIT
	_CUSMRGBST	:= _D1VUNIT
	_CUSTOIPI	:= _D1VUNIT


	//Custo base transferencia
	//_CUSTOTRF -= _D1VALICM - Definido por Toni - 05/05/017
	_CUSTOTRF += _D1SEGURO
	_CUSTOTRF += _D1DESPESA
	_CUSTOTRF += _D1VALIPI
	_CUSTOTRF += _D1VALFRE

	// Se tem custo adiciona de transferencia
	// Adiciona no custo de transferencia.
	If nPCUSICMTR > 0
		_CDESPTRANSF := _D1BASEICM * (nPCUSICMTR/100)
	Endif	

	//Custo Margem com ST
	_CUSMRGBST -= _D1PIS
	_CUSMRGBST -= _D1COFINS
	_CUSMRGBST += _D1SEGURO
	_CUSMRGBST += _D1DESPESA
	_CUSMRGBST += _D1VALIPI
	_CUSMRGBST += _D1VALFRE

	//Custo Margem sem ST
	If lEstornarIcms
	_CUSMRGSST -= _D1VALICM
	Endif
	_CUSMRGSST -= _D1PIS
	_CUSMRGSST -= _D1COFINS
	_CUSMRGSST += _D1SEGURO
	_CUSMRGSST += _D1DESPESA
	_CUSMRGSST += _D1VALIPI
	_CUSMRGSST += _D1VALFRE

	nCusST	:= fCalcST(cFilAnt, _D1PROD, _D1TES, _D1VUNIT, _D1VALIPI, _D1VALFRE, _D1DESPESA, _D1SEGURO, _D1VALICM, _PICM,_B1NCM,_A2GRPTRIB,_D1LOJA,_B1GRTRIB,_B1ORIGEM,_A2GRPTRIB)

	//Custo Fiscal
	_CUSTOMRG -= _D1PIS
	_CUSTOMRG -= _D1COFINS
	_CUSTOMRG += _D1SEGURO
	_CUSTOMRG += _D1DESPESA
	_CUSTOMRG += _D1VALIPI
	_CUSTOMRG += _D1VALFRE
	_CUSTOMRG += nCusST
	If nCusST = 0
		If lEstornarIcms
		_CUSTOMRG -= _D1VALICM
		Endif
	EndIf

	//Custo Margem IPI CD - Somente para Produtos importados diretamento
	If Alltrim(_B1ORIGEM) $ "1/6" .And. _D1VALIPI > 0 .And. ( cFilAnt == "0130" .Or. cFilAnt == "0401" )
		_CUSTOIPI -= _D1PIS
		_CUSTOIPI -= _D1COFINS
		_CUSTOIPI -= _D1VALIPI
		_CUSTOIPI += _D1SEGURO
		_CUSTOIPI += _D1DESPESA
		_CUSTOIPI += _D1VALFRE
		_CUSTOIPI += nCusST
		If nCusST = 0
			_CUSTOIPI -= _D1VALICM //ICMS Fora base IPI
		EndIf
	Else
		_CUSTOIPI := 0
	EndIf

	If Alltrim(_B1NCM) $ Alltrim(cNCMTARE) .And. cFilAnt == "0130"
		nCustStTare := fSTtare(_D1PROD,_CUSTOTRF)
		_CUSTOMRG	+= nCustStTare
	EndIF

	Aadd( aCusProd, { Alltrim(_D1PROD) , _UF , _CUSTOMRG*_D1QUANT , _CUSTOTRF*_D1QUANT , _CUSMRGSST*_D1QUANT , _CUSMRGBST*_D1QUANT , _D1QUANT , _CUSTOIPI*_D1QUANT , _VSERVSUP*_D1QUANT , _CDESPTRANSF*_D1QUANT} )

	lAdd := .t.
	For Z:=1 To Len(aCusZZ4)
		If aCusZZ4[Z,1] == _D1PROD .And. aCusZZ4[Z,2] == _UF
			lAdd := .f.
			Exit
		EndIf
	Next Z

	If lAdd

		If _ONLINE
			dDtEst := DATE() + 1
			lONLINE := .t.
		Else
			dDtEst := dDataBase
		EndIf

		ZZ4->(DbSetOrder(1))
		If ZZ4->( DbSeek( xFilial("ZZ4") + _UF + _D1PROD) ) .And. _lCustoMed

			//Como o custo medio e de todas filiais pego o estoque de todas para montar
			nQtdEstA := 0
			For F:=1 To Len(aFilial)

				cFilAnt := aFilial[F]
				For A:=1 To Len(aArmaz)

					If _ONLINE

						SB2->(dbSetOrder(1)) //B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
						If SB2->( dbSeek( cFilAnt + PADR( Alltrim(_D1PROD) , TAMSX3("B2_COD")[1] ) + PADR( Alltrim(aArmaz[A]) , TAMSX3("B2_LOCAL")[1] ) ) )

							If SB2->B2_QATU > 0
								nQtdEstA += SB2->B2_QATU
							EndIf

						EndIf

					Else

						RestArea(aArea)
						aCalcEst := CalcEst(PadR(Alltrim(_D1PROD),TamSx3("B2_COD")[1]), aArmaz[A] , dDtEst)
						nQtdEstA += Iif(aCalcEst[1]>0,aCalcEst[1],0)					

					EndIf

				Next A

			Next F

			cFilAnt := cFil

			If _ONLINE
				nQtdEstA -= _D1QUANT //Como a atualização do custo é após a gravação da NF, deve retirar a quantidade para cálculo correto do médio.
			EndIf

			Aadd( aCusZZ4, { Alltrim(ZZ4->ZZ4_CODIGO) , ZZ4->ZZ4_UF  , ZZ4->ZZ4_CMRUF*nQtdEstA  , ZZ4->ZZ4_CTRANS*nQtdEstA , ZZ4->ZZ4_CMRSST*nQtdEstA , ZZ4->ZZ4_CMRCST*nQtdEstA , nQtdEstA , ZZ4->ZZ4_CMRIPI*nQtdEstA , ZZ4->ZZ4_CVDESP*nQtdEstA , ZZ4->ZZ4_VDTRAN*nQtdEstA } )

		EndIf
	EndIf

Return 


/*--------------------------------------------------------------------------------------------------
Função: fCalcST
Tipo: Função Estática
Descrição: Calcula ST
Parâmetros:
Retorno:
----------------------------------------------------------------------------------------------------
Atualizações:
- 14/01/2016 - Lorran Ferreira
--------------------------------------------------------------------------------------------------*/

Static Function fCalcST(cFil, _D1PROD, _D1TES, _D1VUNIT, _D1VALIPI, _D1VALFRE, _D1DESPESA, _D1SEGURO, _D1VALICM, _PICM,_B1NCM,_D1FORNECE,_D1LOJA,_B1GRTRIB,_B1ORIGEM,_A2GRPTRIB)

	Local xFilAnt		:= cFilAnt
	Local nPICMUF 		:= ""
	Local cEstado		:= ""
	Local nICMSST
	// Local lFind			:= .F.
	Local nPMVA			:= 0

	/**********************************
	** ALTERA A FILIAL PRA BUSCAR O  **
	** PARAMETRO MV_ICMPAD			 **
	**********************************/

	cFilAnt := cFil
	nPICMUF := SuperGetMv("MV_ICMPAD",,"17")
	cEstado := SuperGetMv("MV_ESTADO",,"GO")
	cFilAnt := xFilAnt

	/*********************************/


	/*SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+PadR(Alltrim(_D1FORNECE),TamSx3("A2_COD")[1])+PadR(Alltrim(_D1LOJA),TamSx3("A2_COD")[1])))

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+_D1PROD))*/

	// -> Busca Exceção Fiscal
	cQry := " SELECT * "
	cQry += " FROM " + RetSqlName("SF7")
	cQry += " WHERE "
	cQry += " F7_GRTRIB = '" + Alltrim(_B1GRTRIB) + "' "
	cQry += " AND F7_ORIGEM = '" + Alltrim(_B1ORIGEM) + "' "
	cQry += " AND F7_FILIAL = '" + cFil + "' "
	cQry += " AND F7_EST = '" + cEstado + "' "
	cQry += " AND F7_UFBUSCA = '1' "
	cQry += " AND F7_GRPCLI = '" + Alltrim(_A2GRPTRIB) + "' "
	cQry += " AND D_E_L_E_T_ <> '*' "

	cQry := ChangeQuery(cQry)

	If Select("TMP1") > 0
		TMP1->( DbCloseArea() )
	EndIf

	TcQuery cQry New Alias "TMP1"

	nRegistros := Contar("TMP1", "!EOF()")

	If nRegistros > 0
		TMP1->( DbGoTop() )

		nRedBase	:= TMP1->F7_BSICMST
		nPMVA	  	:= TMP1->F7_MARGEM

		/*******************************************
		*** 		CALCULO DE ST  		 		***
		*******************************************/
		nTotal 	:= 	_D1VUNIT+_D1VALIPI+_D1VALFRE+_D1DESPESA+_D1SEGURO 	// -> Monta o Total dos Produtos

		If _D1VALICM = 0
			_D1VALICM := ( _D1VUNIT * (_PICM/100) )
		EndIf

		If	nRedBase > 0
			nBase 	:= (nTotal * (nRedBase/100) )    	// -> Aplica % Redução da Base do ICMS-ST
		Else
			nBase 	:= nTotal
		EndIf
		nVlMVA 		:=	(nBase * (nPMVA/100) )			// -> Aplica o MVA no total do Produto
		nBaseST		:=	nBase + nVlMVA  				// -> Monta a Base do ICMS Subs.Trib.
		nICMSTBr		:=	nBaseST * (nPICMUF/100)    		// -> Monta o valor de ICMS Subs.Trib. BRUTO
		nICMSST		:=	nICMSTBr - _D1VALICM			// -> Monta o valor de ICMS Subs.Trib. Liquido

	Else
		nICMSST := 0
	EndIf

	//SA2->( DbCloseArea() )
	//SB1->( DbCloseArea() )
	TMP1->( DbCloseArea() )

Return ( nICMSST )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetFil  ºAutor  ³Lorran Gomes      º Data ³  06/03/17	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a lista de Filiais  						     º±±
±±º          ³ 					                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRetFil()

	Local aArea := SM0->(GetArea())
	Local nRegSM0 := SM0->(RECNO())
	Local cFilNot	:= '0105;0106'
	Local aRet		:= {}

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre as Filiais 											         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	SM0->(dbGoTop())
	While SM0->(!Eof()) .And. SM0->M0_CODIGO = '01'

		IF !Alltrim(SM0->M0_CODFIL) $ cFilNot
			Aadd(aRet, Alltrim(SM0->M0_CODFIL) )
		EndIF

		SM0->(dbSkip())

	Enddo

	//MSGINFO(cRet)
	RestArea(aArea)
	SM0->(dbGoto(nRegSM0))

Return(aRet)


//Calculo da ST de transferencia saindo do CD (tare)
Static Function fSTtare(_cProduto,_nValor)

	Local nRet := 0
	Local lNf := .T. //.F. Cupom | .T. Nota Fiscal
	Local _cTes := ""
	//Para simular o valor da ST no tare vamos utilizar a filial 0101
	Local _cCliente := "00000006"
	Local _cLoja	:= "0001"

	_cTes := MaTesInt(2,'08',_cCliente,_cLoja,"C",_cProduto)

	MaFisSave()
	MaFisEnd()

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja))

	MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "N", SA1->A1_TIPO,,,,,"MATA461",,,,,,,,,lNf)

	MaFisAdd(_cProduto, _cTes, 1, _nValor, 0, Nil, Nil, Nil, 0, 0, 0, 0, _nValor, 0, 0, 0)

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+_cProduto))
	MaFisAlt("IT_PESO"   ,SB1->B1_PESO,1)
	MaFisAlt("IT_PRCUNI" ,_nValor   ,1)
	MaFisAlt("IT_VALMERC",_nValor   ,1)

	MaFisAlt("NF_FRETE"   ,0)
	MaFisAlt("NF_SEGURO"  ,0)
	MaFisAlt("NF_AUTONOMO",0)
	MaFisAlt("NF_DESPESA" ,0)

	nRet := MaFisRet(1,"IT_BASESOL") * ( SuperGetMv("MV_ICMPAD",,"17") / 100 )
	MaFisEnd()

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetFil  ºAutor  ³Lorran Gomes      º Data ³  06/03/17	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a lista de Filiais  						     º±±
±±º          ³ 					                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _fRetFil()

	// Local aArea := SM0->(GetArea())
	// Local nRegSM0 := SM0->(RECNO())
	// Local cFilNot	:= '0105;0106'
	Local aRet		:= {'0101','0103','0104'}

	// /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³             Abre as Filiais 											         ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	// SM0->(dbGoTop())
	// While SM0->(!Eof()) .And. SM0->M0_CODIGO = '01'

	// 	IF !Alltrim(SM0->M0_CODFIL) $ cFilNot
	// 		Aadd(aRet, Alltrim(SM0->M0_CODFIL) )
	// 	EndIF

	// 	SM0->(dbSkip())

	// Enddo

	// //MSGINFO(cRet)
	// RestArea(aArea)
	// SM0->(dbGoto(nRegSM0))

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±tcloud
±±ºDescricao ³ Verifica o cFilAnt x SM0									   º±±
±±º          ³                                  						   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FFILSM0()

	Local nRegSM0 := SM0->(RECNO())
	Local cSM0OLD := ""

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³             Abre as Filiais 											         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If Alltrim(SM0->M0_CODFIL) <> cFilAnt

		cSM0OLD := Alltrim(SM0->M0_CODFIL)

		SM0->(dbGoTop())
		While SM0->(!Eof())

			IF Alltrim(SM0->M0_CODFIL) == cFilAnt

				nRegSM0 := SM0->(RECNO())

				Exit

			EndIF

			SM0->(dbSkip())

		Enddo

		SM0->(dbGoto(nRegSM0))
		//U_FLOGPRIME(ProcName(1) +">"+ ProcName(0) + " - SM0 POSICIONADA CONFORME CFILANT >>> SM0:"+Alltrim(SM0->M0_CODFIL)+" cFilAnt: "+cFilAnt +" -->SM0_OLD: "+cSM0OLD)

	EndIf

Return()
