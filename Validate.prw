#Include 'Protheus.ch'

/*------------------------------------------------------------------------------+
| CLASSE : Validate         |AUTHOR: FERNANDO BARBOSA        | DATA:12/05/2016  |
+-------------------------------------------------------------------------------+
| DESCRICAO | CLASSE RESPONSAVEL POR VALIDAR VARIOS TIPOS DE VALIDACOES         |
|           | VALIDA MACRO, CAMPOS REQUIRIDO NO OBJETO, SE A QUERY ESTA CORRETA |
|           | TIPAGEM DE VARIAVIES ETC... TUDO EM UMA CLASSE SÓ                 |
|           |                                                                   |
+-------------------------------------------------------------------------------+
|ALTERACOES |                                                                   |
|           |                                                                   |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+*/

#Define CLRF     CHR(13)+CHR(10)
#Define MAXQUERY 15980           // QUANTIDADE MAXIMA DE CARACTER NA QUERY -- http://tdn.totvs.com/display/tec/Query+greater+than+15980+bytes

Class Validate
**************
	Data ret
	Data fault
	Data macros
	Data required
	Data object
    
	Method New(oObj,aRequired,cMacro)  /* METHOD CONSTRUTOR                       */
	Method Macro()                     /* METHOD VALIDADOR DE MACROS              */
	Method Required()                  /* METHOD VALIDADOR DE COMPOS OBRIGATORIOS */
	Method Query(cQuery,lExibeFail)    /* METHDO PARA VALIDAR SE A QUERY ESTA OK  */
	Method ClearCom(cQuery)            /* REMOVE OS COMENTARIOS DA QUERY          */
	Method TypeVal(xParam,cType,cLocal)/* VALIDAR SE A VARIAVEL ESTA NO TIPO CERTO*/
    
	Method SetMacro(cMacro)            /* METHOD PARA SETAR A VARIAVEL MACRO       */
	Method SetRequired(aRequired)      /* METHOD PARA SETAR A VARIAVEL REQUIRED    */
	Method SetObject(oObj)             /* METHOD PARA SETAR O VALOR VALIDADO       */
    
	Method GetWarning()                /* METHOD PARA RETORNAR A MENSAGEM FAULT    */
	Method GetMacro()			/* METHOD PARA PEGAR A MACRO EM EXECUÇÃO 	  */

End Class

/*------------------+
| METHOD CONSTRUTOR |
+-------------------+*/
Method New(oObj,aRequired,cMacro) Class Validate
************************************************
	Default oObj      := Nil
	Default cMacro    := ""
	Default aRequired := {}

	::ret       := .F.
	::fault     := ""
	::required  := aRequired
	::macros    := cMacro
	::object    := oObj
Return Self

/*---------------------------+
| METHOD VALIDADOR DE MACROS |
+----------------------------+*/
Method Macro() Class Validate
*****************************
	Local xResult
	Local bBlock       := ErrorBlock(), bErro := ErrorBlock( { |e| IIF(e:gencode > 0,(cDescBlock := e:Description,lRet := .F.),.T.) } )

	Private lRet       := .T.
	Private cDescBlock := ""

	::ret := .F.

	If !Empty(::macros)

		Begin Sequence
			xResult := &(::macros)
		End Sequence

		ErrorBlock(bBlock)
	
		::ret   := lRet
		::fault := AllTrim(cDescBlock) + IIF(!Empty(cDescBlock) , " [Validate] " + AllTrim(::macros) , "" )

	Else
		::fault := "Macro não foi informada [Validate]"
	EndIf

Return ::ret

/* VALIDAR SE A VARIAVEL ESTA NO TIPO CERTO*/
Method TypeVal(xParam,cType,cLocal) Class Validate
**************************************************
	Local cReturn  := ""
	Private xValue

	Default cType  := ""
	Default cLocal := ""

	::ret 		:= .T.
	::fault 	:= ""

	/*-----------------------------+
	| VALIDA SE O TIPO FOI PASSADO |
	+------------------------------+*/
	If !Empty(cType)
		xValue  := xParam
	
		cReturn := Type("xValue")

		If cReturn != AllTrim(cType)
			::ret 		:= .F.
			::fault 	:= "O dados informados no " + cLocal + " não retornou um valor do tipo " + GetTipoVar(cType) + ". Tipo do retorno: " + GetTipoVar(cReturn) + " [TYPEVAL] "
		EndIf
	EndIf

Return ::ret

/*----------------------------------------+
| METHOD VALIDADOR DE COMPOS OBRIGATORIOS |
+-----------------------------------------+*/
Method Required() Class Validate
********************************
	Local nCont := 0

	Private oObjVal

	If ::object != Nil
		::ret   := .T.
		::fault := ""
		nCont   := Len(::required)

		If nCont > 0
		        /*---------------------------------------------------------------+
		        | VALIDA SE TEM TODOS OS PARAMETROS NECESSARIOS DENTRO DO OBJETO |
		        +----------------------------------------------------------------+*/
			oObjVal := ::object
			For i := 1 To nCont
				::SetMacro('oObjVal:' + AllTrim(::required[i]))
				If !(::Macro())
					exit
				EndIf
			Next i

		EndIf

	Else
		::ret   := .F.
		::fault := "Objeto não foi informado [Validate]"
	EndIf

Return ::ret

/*-----------------------------------+
| METHOD PARA SETAR A VARIAVEL MACRO |
+------------------------------------+*/
Method SetMacro(cMacro) Class Validate
**************************************
Default cMacro := "" 
::macros := StrTran(cMacro,CLRF,' ') // REMOVE AS QUEBRAS DE LINHA DA MACRO DEVIDO ERRO NO IF
Return

/*-----------------------------------+
| METHOD PARA PEGAR A VARIAVEL MACRO |
+------------------------------------+*/
Method GetMacro() Class Validate
******************************** 
Return IIF(::macros != Nil , ::macros , "")

/*--------------------------------------+
| METHOD PARA SETAR A VARIAVEL REQUIRED |
+---------------------------------------+*/
Method SetRequired(aRequired) Class Validate
********************************************
	Default aRequired := {}
	::required := aRequired
Return

/*------------------------+
| PEGA A MENSAGEM DE ERRO |
+-------------------------+*/ 	    
Method GetWarning() Class Validate
**********************************   
Return IIF(::fault != Nil , ::fault , "")

/*-----------------------------------+
| METHOD PARA SETAR O VALOR VALIDADO |
+------------------------------------+*/
Method SetObject(oObj) Class Validate
**************************************
	Default oObj := Nil
	::object     := oObj
Return

/*----------------------------------------+
| METHDO PARA VALIDAR SE A QUERY ESTA OK  |
+-----------------------------------------+*/
Method Query(cQuery,lExibeFail,cFuncaoPar) Class  Validate
**********************************************************
	Local nPosSel      := 0
	Local cFailQry     := ""
	Local nQuery       := 0

	Default cQuery     := ""
	Default lExibeFail := .T.

	::ret    := .T.
	::fault  := ""
 
	nQuery := ChangeQuery(cQuery)

	If Empty(cQuery)
		::fault  := "Query em branco [VALIDATE] "
		::ret    := .F.
    
	ElseIf nQuery > MAXQUERY
		::fault := "Não é possível solicitar a abertura de uma query com mais que " + cValToChar(MAXQUERY) + " bytes. Verifique a query e reduza a mesma. Tamanho da sua query " + cValToChar(nQuery) + " bytes   [VALIDATE] "
		::ret   := .F.

	ElseIf 'DELETE'$UPPER(cQuery)
		::fault := "Não é permitido utilizar a sintaxe DELETE  [VALIDATE] "
		::ret   := .F.
    
	ElseIf 'UPDATE'$UPPER(cQuery)
		::fault := "Não é permitido utilizar a sintaxe UPDATE  [VALIDATE] "
		::ret   := .F.
    
	ElseIf 'CREATE'$UPPER(cQuery)
		::fault := "Não é permitido utilizar a sintaxe CREATE  [VALIDATE] "
		::ret   := .F.
    
	ElseIf 'INSERT'$UPPER(cQuery)
		::fault := "Não é permitido utilizar a sintaxe INSERT  [VALIDATE] "
		::ret   := .F.
    
	ElseIf 'DROP'$UPPER(cQuery)
		::fault := "Não é permitido utilizar a sintaxe DROP  [VALIDATE]  "
		::ret   := .F.
    
	Else

		Begin Transaction
 
			cQuery := ChangeQuery(cQuery)
 
			If (TCSQLExec(cQuery) < 0)
               
				If lExibeFail
					cFailQry := AllTrim(TCSQLError())
					nPosSel  := At(Upper("TCBuild"),Upper(cFailQry))
					nPosSel  := IIF( nPosSel <= 0 , Len(cFailQry) , nPosSel - 1)
					::fault  := "DEBUG: Query apresentou problemas:" + CLRF + CLRF + SubStr(cFailQry,1,nPosSel) + "   QUERY =    " + AllTrim(cQuery)
				Else
					::fault := "Desculpe o Transtorno. Mas sua query apresentou algum problema. Favor verificar ou contatar a equipe de TI. [VALIDATE]"
				EndIf
	         
				::ret   := .F.
	                
			EndIf
			
			If .T.
				DisarmTransaction()
				Return  ::ret
			EndIf
   
		End Transaction
   
	EndIf
 
Return  ::ret

/*---------------------------+
| REMOVE OS SPACOS DA QUERY  |
+----------------------------+*/
Method ClearCom(cQuery) Class Validate
**************************************
	Local aQuery  := {}
	Local cQry    := ""
	Local nPos    := 0
	Local nLinQry := 0

	aQuery  := Separa(AllTrim(cQuery),CLRF) // QUEBRA POR LINHAS
	nLinQry := Len(aQuery)

	For s := 1 To nLinQry

		If  ("--"$AllTrim(aQuery[s]))
			nPos := At("--",aQuery[s])
			If nPos > 1
				cQry += SubStr(aQuery[s],1,nPos-1) + CLRF
			EndIf
		Else
			cQry += aQuery[s] + CLRF
		EndIf
    
	Next s
 
Return cQry

/*---------------------------------------+
| RETORNA O TIPO DA VARIAVEL POR EXTENCO |
+----------------------------------------+*/
Static Function GetTipoVar(cType)
*********************************
Local cTipo   := ""

Default cType := ""

	If !Empty(cType)
	
		cType := AllTrim(Upper(cType))
	
		Do Case
		Case cType == "A"
			cTipo := "Array"
			
		
		Case cType == "B"
			cTipo := "Bloco de código"
			
		
		Case cType == "C"
			cTipo := "Caracter"
			
		
		Case cType == "D"
			cTipo := "Data"
			
		
		Case cType == "L"
			cTipo := "Lógico"
			
		
		Case cType == "N"
			cTipo := "Numérico"
			
		
		Case cType == "F"
			cTipo := "Decimal de ponto fixo"
			
		
		Case cType == "O"
			cTipo := "Objeto"
			
		
		Case cType == "U"
			cTipo := "Nil (Nulo)"
			
		
		Case cType == "UI"
			cTipo := "Função"
		
		EndCase

	EndIf

Return cTipo