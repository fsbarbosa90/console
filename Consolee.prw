#Include 'Protheus.ch'
#Include 'vkey.ch'

/*------------------------------------------------------------------------------+
| CLASSE : Consolee         |AUTHOR: FERNANDO BARBOSA        | DATA:12/05/2016  |
+-------------------------------------------------------------------------------+
| DESCRICAO | CONSOLE DE EXECUCAO PARA PEGAR VALORES, executar funcoes etc...   |
|           | E como estar executando isso no advpl comandos. EX digite assim   |
|           | GetMv("MV_ESTNEG"), ira ver que retornara o valor do campo        |
|           |                                                                   |
+-------------------------------------------------------------------------------+
|ALTERACOES |                                                                   |
|           |                                                                   |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+*/


#Define EMPLOG		"01"		// EMPRESA
#Define FILLOG 		"010101"	// FILIAL 
#Define TAMCOM 		1024		// TAMANHO MAXIMO DO COMANDO
#Define CLRF   		CHR(13)+CHR(10)	// QUEBRA DE LINHA
#Define TIMESHUT	"01:00:00"	// TEMPO DE INATIVIDADE PARA REALIZAR PARA FECHAR O CONSOLHE AUTOMATICAMENTE
#Define TIMEWARN	"00:57:00"	// TEMPO QUE INICIA O AVISO NO CONSOLE QUE O MESMO SERA FECHADO POR INATIVIDADE

User Function Consolee()
************************
Local oCompany

Private oDlgCon

Private oPanTop
Private oPanBot
Private oGetCom
Private oMultExe
Private aOpcFilt	:= {}
Private nOpcFilt	:= 0
Private nKeyOld	:= 0

Private cComando   	:= Space(TAMCOM)
Private cResult    	:= ""

Private oFontCode20 
Private oFontxxx 

Private cStyleMGet  	:= "QTextEdit { background-color: #3F3F3F; color:#FFFFFF; border-radius: 5px;border: 4px solid #FCF8E3;padding:10px;};"
Private cStyleGet  	:= "QLineEdit { background-color: #3F3F3F; color:#FFFFFF; border-radius: 5px;border: 4px solid #FCF8E3;padding:10px;};"

Private oValidate 
Private xValue 
Private nRows        	:= 0   

Private aVars		:= {}
Private aDataUser	:= {}
Private lLogoff 	:= .T.
Private lRestart	:= .T.
Private cTimeExc	:= ""
Private oTimer

oCompany := Company():New(EMPLOG,FILLOG)	 
If oCompany:Validate(.T.)
	
	oValidate 	:= Validate():New() 
	oFontCode20 	:= TFont():New("code",,18,,.F.,,,,,.F.) 
	oFontxxx    	:= TFont():New("code",,38,,.F.,,,,,.F.) 

	While lLogoff	
		
		lLogoff 	:= .F.
		lRestart	:= .T.
		aDataUser	:= {}
	
		If U_LOGINSYS("000018",@aDataUser)     			
		
			While lRestart
				cTimeExc := Time()
				lRestart := .F.
			
				oDlgCon := MSDialog():New(000,000,600,1000,"Console ADVPL VRS 1.9.5 - " + AllTrim(GetComputerName()) + "@" + AllTrim(GetClientIP()) + " | " + dToc(Date()) + " " + Time() + " $ " + AllTrim(aDataUser[2]),,,.F.,DS_MODALFRAME,,,,,.T.,,,.T.)	  
				oDlgCon:lEscClose  := .F.  
				
				oPanTop       := TPanel():New(000,000,,oDlgCon,,.T.,.F.,CLR_BLACK,CLR_BLACK,10,30) 
				oPanTop:align := CONTROL_ALIGN_TOP
				  
				oPanBot       := TPanel():New(000,000,,oDlgCon,,.T.,.F.,CLR_BLUE,CLR_BLUE,10,10) 
				oPanBot:align := CONTROL_ALIGN_ALLCLIENT  
				
				oGetCom := TGet():New(000,000,bSetGet(cComando),oPanTop,501,30,,{|| ExecConsole() },,,oFontxxx,,,.T.,,,{|| .T. })	
				oGetCom:SetCss(cStyleGet) 
				 	
				oMultExe          := TMultiGet():New(000,000, bSetGet(cResult),oPanBot,001,65,oFontCode20,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
				oMultExe:align    := CONTROL_ALIGN_ALLCLIENT  
				oMultExe:SetCss(cStyleMGet)   	 	
					
				oTimer := TTimer():New(60000, {|| ShutAuto() }, oDlgCon )    // DISPARA A CADA 1 MINUTO
				oTimer:Activate()    			
				
				SetKey(VK_F2,	{|| CmdOldKey(1)} )
				SetKey(VK_F4,	{|| CmdOldKey(2)} )					
					
				oDlgCon:lCentered := .T. 
				oDlgCon:Activate()
			
			EndDo
		
		EndIf
	
	EndDo
	
	oCompany:Destruct() 
	         
EndIf 

Return

// +----------------------------------------+
// | FUNCAO QUE AJUSTES OS COMANDOS ANTIGOS |
// +----------------------------------------+
Static Function CmdOldKey(nKey)
*******************************

If Len(aOpcFilt) > 0
		
	cComando := PadR(aOpcFilt[nOpcFilt],TAMCOM)
	oGetCom:SetFocus()					
					
	If nOpcFilt >= 1 .And. nOpcFilt <= Len(aOpcFilt)
				
		// +----+
		// | UP |
		// +----+
		If nKey == 1		
			nOpcFilt--
							
		// +------+
		// | DOWN |
		// +------+
		ElseIf nKey == 2			
			nOpcFilt++
						
		EndIf
	
	EndIf
	
	If nOpcFilt <= 0 
		nOpcFilt := Len(aOpcFilt)
		
	ElseIf nOpcFilt > Len(aOpcFilt)
		nOpcFilt := 1
		
	EndIf
	
	nKeyOld := nKey	
		
EndIf

Return


/*------------------+
| EXECUTA O CONSOLE |
+-------------------+*/
Static Function ExecConsole()
*****************************
Local cRet := ""

cComando := AllTrim(cComando)

cTimeExc := Time()

// +---------------------------------------+
// | REALIZA O CONTROLE DE ITENS DIGITADOS |
// +---------------------------------------+
If !Empty(cComando) 
	
	If Len(aOpcFilt) == 0 .Or. AllTrim(aOpcFilt[Len(aOpcFilt)]) != AllTrim(cComando)
		aAdd(aOpcFilt,cComando)
	EndIf
	
	nOpcFilt := Len(aOpcFilt)
EndIf

/*---------------------------------+
| VERIFICA SE DIGITOU ALGUMA COISA |
+----------------------------------+*/
If !Empty(cComando) .And. !ReservWord()
	
	oValidate:SetMacro(cComando)
	If oValidate:Macro()    
		                       
       	xValue := &(cComando)
       	
       	/*------------------+
       	| CONVERTE OS DADOS |
       	+-------------------+*/   
       	If Type("xValue") == "D"
       		xValue := dToc(xValue)
       	
       	ElseIf Type("xValue") == "N"
       		xValue := cValToChar(xValue)
       		
       	ElseIf Type("xValue") == "L"
       		xValue := IIF(xValue,"True","False")
       	
       	ElseIf Type("xValue") == "A" .Or. Type("xValue") == "O" 
       		xValue := FormatObj(xValue)
       	
       	EndIf	  
       	
       	/*-------------------------------+
       	| VALIDA PARA VER SE FICOU CERTO |
       	+--------------------------------+*/  
       	If Type("xValue") == "C" 
       		cRet 	:= xValue
       		
       	ElseIf xValue == Nil
       		cRet 	:= "Nil"
       		
       	ElseIf Type("xValue") == "U"
       		cRet 	:= "Undefined"
       		
       	Else
       	       cRet 	:= "Error in the execution of the formula. Type Return " + Type("xValue")
       	       
       	EndIf
       	                                
	Else
      		cRet := oValidate:GetWarning()                                     
	EndIf  

	AddRes(cComando,cRet) 

EndIf

cComando := Space(TAMCOM)
oGetCom:SetFocus()

Return

/*------------------+
| PALAVRA RESERVADA |
+-------------------+*/
Static Function ReservWord()
****************************
Local lRet 	:= .F.
Local cWord 	:= ""
Local nSpace	:= 8

cWord := Upper(cComando)

/*------------+
| LIMPAR TELA |
+-------------+*/
If cWord == "CLEAR" .Or. cWord == "CLS"
	cResult 	:= ""
	nRows		:= 0
	lRet 		:= .T.
	Refresh()
	
/*----------------+
| FECHA APLICACAO |
+-----------------+*/
ElseIf  cWord == "EXIT" .Or. cWord == "CLOSE" .Or. cWord == ":Q"
	lRet := .T.
	oDlgCon:End()

/*-----------------------------+
| PEGA OS DADOS DO USER LOGADO |
+------------------------------+*/	
ElseIf cWord == "INFOUSER" .Or. cWord == "USERINFO" .Or. cWord == "INFO" .Or. cWord == "USER"
	lRet := .T.
	AddRes(cWord,Upper("User connected to the system( "),.F.)
	oMultExe:AppendText(Space(nSpace) + "Código: " 		+ AllTrim(aDataUser[1]) + CLRF) 
	oMultExe:AppendText(Space(nSpace) + "Nome: "   		+ AllTrim(aDataUser[2]) + CLRF) 
	oMultExe:AppendText(Space(nSpace) + "Departamento: "  	+ AllTrim(aDataUser[3]) + CLRF) 
	oMultExe:AppendText(Space(nSpace) + "Cargo: " 		+ AllTrim(aDataUser[4]) + CLRF) 
	oMultExe:AppendText(Space(nSpace) + "E-mail: " 		+ AllTrim(aDataUser[5]) + CLRF) 
	oMultExe:AppendText(Space(nSpace) + "Token: " 		+ AllTrim(aDataUser[6]) + CLRF + " )" + CLRF + CLRF) 

/*-----------+
| FAZ LOGOFF |
+------------+*/
ElseIf cWord == "LOGOFF" .Or. cWord == "SAIR" .Or. cWord == "DESCONECTAR"
	lRet := .T.
	lLogoff 	:= .T. 
	lRestart	:= .F.
	cComando   	:= Space(TAMCOM)
	cResult    	:= ""
	oDlgCon:End()
	
/*----------+
| REINICIA  |
+-----------+*/
ElseIf cWord == "RESET" .Or. cWord == "SHUTDOWN" .Or. cWord == "REINICIAR"
	lRet := .T.
	lLogoff 	:= .F. 
	lRestart	:= .T.
	cComando   	:= Space(TAMCOM)
	cResult    	:= ""
	oDlgCon:End()
	
/*----------------------------------------+
| VALIDA SE ESTA TENTANDO FERRAR OS DADOS |
+-----------------------------------------+*/	
ElseIf "LLOGOFF"$cWord .Or.  "LRESTART"$cWord .Or.  "CCOMANDO"$cWord .Or. "CRESULT"$cWord .Or. "LRET"$cWord .Or. "ADATAUSER"$cWord
	lRet := .T.
	AddRes(cWord,Upper("COMMAND INVALID"),.T.)	
EndIf 

Return lRet

/*----------------+
| ATUALIZA A TELA |
+-----------------+*/
Static Function Refresh()
*************************

oMultExe:Refresh() 
oDlgCon:Refresh()
SysRefresh() 

Return

/*-------------------------+
| APENDA O COMANDO NA TELA |
+--------------------------+*/
Static Function AddRes(cComando,cRet,lTwoQrb)
*********************************************
Default lTwoQrb := .T.

nRows++
oMultExe:AppendText(cValToChar(nRows) + ") " + dToc(Date()) + " - " + Time() + " : " + cComando + CLRF + Space(2) + "$ " + AllTrim(cRet) + CLRF )

/*--------------------------------------------------+
| VALIDA SE É PARA ADICIONAR DOIS QUEBRAS DE LINHAS |
+---------------------------------------------------+*/
If lTwoQrb
	oMultExe:AppendText(CLRF)
EndIf

Return 

/*----------------------------+
| VALIDA O SHUTDOW AUTOMATICO |
+-----------------------------+*/
Static Function ShutAuto()
**************************
Local cTimeStop := ElapTime (cTimeExc,Time())

If cTimeStop >= TIMESHUT
	cComando := "LOGOFF"
	ReservWord()
	
ElseIf cTimeStop > TIMEWARN
	AddRes("WARNING", Space(8) + "SEU CONSOLE SERÁ DESCONECTADO AUTOMATICAMENTE EM " + ElapTime(cTimeStop,TIMESHUT))
EndIf
 
Return


// +-------------------------------------------+
// | FORMATA O OBEJTO PARA SER EXIBIDO NA TELA |
// +-------------------------------------------+
Static Function FormatObj(oObj)
*******************************
Local cObjeto := ""
Local aTransf	:= {}
Local nSpace	:= 8

	aAdd(aTransf,{"[...]",""})
	aAdd(aTransf,{"ARRAY ","MATRIZ"})
	aAdd(aTransf,{"OBJECT ","OBJETO"})
	aAdd(aTransf,{"-> N ","-> NUMÉRICO"})
	aAdd(aTransf,{"-> C ","-> CARACTER"})
	aAdd(aTransf,{"-> D ","-> DATA"})
	aAdd(aTransf,{" :","  "})
 
// +--------------------------------------+
// | ADCIONA OS ESPACOS A SEREM REMOVIDOS |
// +--------------------------------------+
For s := nSpace To 1 Step -1
	aAdd(aTransf,{"(" + Space(s),"("})
	aAdd(aTransf,{") [" + Space(s), ") ["})
Next s

cObjeto := VarInfo("",oObj,0,.F.,.F.)

For i := 1 To Len(aTransf)
	cObjeto := StrTran(cObjeto,aTransf[i][1],aTransf[i][2])
Next i

Return "                " + SubStr(cObjeto,9)