#Include 'Protheus.ch'

/*------------------------------------------------------------------------------+
| CLASSE : AuthLogin        |AUTHOR: FERNANDO BARBOSA        | DATA:12/05/2016  |
+-------------------------------------------------------------------------------+
| DESCRICAO | CLASSE RESPONSAVEL POR VALIDOR O LOGIN COM O USUARIO DO           |
|           | PROTHUEUS                                                         |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+
|ALTERACOES |                                                                   |
|           |                                                                   |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+*/

Class AuthLogin
***************
	
	Data ret
	Data fault 

	Data codigo
	Data nome
	Data departamento
	Data cargo
	Data email    
	Data dia
	Data hora
	
	Method New()                                    
	Method Validate(cUser,cSenha,cGroup) 	/* METHOD QUE VALIDA SE O USUARIO É VALIDO */
	
	/*-------------------+
	| METODOS DE RETORNO |
	+--------------------+*/
	Method GetCodigo()     /* PEGA O CODIGO DO USUARIO           */    
	Method GetNome()       /* PEGA O NOME DO USUARIO             */
	Method GetDepart()     /* PEGA O DEPARTAMENTO DO USUARIO     */
	Method GetCargo()      /* PEGA O CARGO DO USUARO             */
	Method GetMail()       /* PEGA O E-MAIL DO USUARIO           */
	Method GetUser()       /* ARRAY COM OS DADOS DO USUARIO      */ 
	Method GetDia()        /* PEGA O DIA DO LOGIN                */
	Method GetHora()       /* PEGA A HORA DO LOGIN               */ 
	
	Method GetWarning()    /* ROTORNA A MESAGEM DE PARA USUARIO  */
	
End Class

/*----------------------------+
| MOTEDO CONSTRUTOR DA CLASSE |
+-----------------------------+*/
Method New() Class AuthLogin
****************************
	::fault := ""
	::ret   := .F.
Return Self

/*----------------------------------+ 
| ROTORNA A MESAGEM DE PARA USUARIO |     
+-----------------------------------+*/
Method GetWarning() Class AuthLogin
************************************
Return ::fault                   

/*----------------------------------------+
| METHOD QUE VALIDA SE O USUARIO É VALIDO |
+-----------------------------------------+*/
Method Validate(cUser,cSenha,cGroup) Class AuthLogin
*****************************************************
Local lAdmim	 := .F. 
Local lLogou	 := .F.

Private aDateUser  := {}

Default cUser   := ""
Default cSenha  := ""
Default cGroup  := ""

::fault := ""
::ret   := .F.

lAdmim := (Upper(cUser)=="ADMINISTRADOR" .Or. Upper(cUser)=="ADMIN" .Or. cUser=="000000")

If Empty(cUser) .Or. Empty(cSenha) .Or. Empty(cGroup)
	::fault := "Favor informar todos os campos corretamente."
		
// +---------------------------------------------------------+
// | AJUSTE PARA BUSCAR TANTO PELO CODIGO, QUANTO PELO LOGIN |
// +---------------------------------------------------------+	
Else	


	// +--------------------+
	// | BUSCA PELO USUARIO |
	// +--------------------+
	PswOrder(2)
	If PswSeek(cUser,.T.) .And. PswName(cSenha)
		lLogou := .T.
	
	// +-------------------------------+
	// | VALIDA SE LOGOU PELO USUARIO? |
	// +-------------------------------+
	Else		
		// +-------------------+
		// | BUSCA PELO CODIGO |
		// +-------------------+
		PswOrder(1)
		If PswSeek(cUser,.T.) .And. PswName(cSenha)
			lLogou := .T.
		EndIf
			
	EndIf		

	// +-----------------+
	// | VALIDA SE LOGOU |
	// +-----------------+
	If !lLogou
		::fault := "Usuário ou senha inválido."
	Else

		aDateUser := PswRet()
	
		If UserMsBlq() 
		   ::fault := "Usuário bloqueado para acessar o sistema."
		
		ElseIf !lAdmim .And. !(AllTrim(cGroup)$GroupsUser())
		   ::fault := "Usuário sem permissão para acessar o sistema."
			
		Else
		    
			::codigo       := aDateUser[1,1] 
			::dia          := Date()
			::hora         := Time()			
			::nome         := aDateUser[1,4] 
			::departamento := aDateUser[1,12]
			::cargo        := aDateUser[1,13]
			::email        := aDateUser[1,14]   
			::ret          := .T.
			
		EndIf
	
	EndIf
	
EndIf

Return ::ret 

/*-------------------------------+
| ARRAY COM OS DADOS DO USUARIO  |
+--------------------------------+*/  
Method GetUser() Class AuthLogin
********************************* 
Return IIF(::ret ,{::codigo,::nome,::departamento,::cargo,::email},{})

/*-------------------------+
| PEGA O CODIGO DO USUARIO |
+--------------------------+*/  
Method GetCodigo() Class AuthLogin
*********************************** 
Return IIF(::ret .And. ::codigo != Nil,::codigo,"")

/*-----------------------+ 
| PEGA O NOME DO USUARIO |
+------------------------+*/
Method GetNome() Class AuthLogin
*********************************    
Return IIF(::ret .And. ::nome != Nil,::nome,"")   

/*-------------------------------+
| PEGA O DEPARTAMENTO DO USUARIO |
+--------------------------------+*/ 
Method GetDepart() Class AuthLogin
***********************************  
Return IIF(::ret .And. ::departamento != Nil,::departamento,"")   

/*-----------------------+
| PEGA O CARGO DO USUARO |
+------------------------+*/
Method GetCargo() Class AuthLogin
*********************************    
Return IIF(::ret .And. ::cargo != Nil,::cargo,"")   

/*-------------------------+
| PEGA O E-MAIL DO USUARIO |
+--------------------------+*/
Method GetMail() Class AuthLogin
*********************************  
Return IIF(::ret .And. ::email != Nil,::email,"")  

/*--------------------+
| PEGA O DIA DO LOGIN |
+---------------------+*/ 
Method GetDia() Class AuthLogin
********************************  
Return IIF(::ret .And. ::dia != Nil,::dia,cTod(" / / "))        

/*---------------------+
| PEGA A HORA DO LOGIN |
+----------------------+*/
Method GetHora() Class AuthLogin
********************************  
Return IIF(::ret .And. ::hora != Nil,::hora,"")        
  
/*-------------------------------+
|  FUNCAO PARA RETORNAR TODOS OS |
|  GRUPOS DO USUARIO FORMATADO   |
| COMO STRING E SEPARADOS POR    | 
+--------------------------------+*/
Static Function GroupsUser()
***************************
Local cGroups := "" 
Local aGrupos := aDateUser[1][10]

For i := 1 To Len(aGrupos)
   cGroups += Iif(!Empty(cGroups),"/","") + AllTrim(aGrupos[i])
Next i		    

Return cGroups

/*-----------------------------------------+
| VERIFICA SE O USUARIO NÃO ESTA BLOQUEADO |
+------------------------------------------+*/
Static Function UserMsBlq()
***************************
Return aDateUser[1][17] 

 