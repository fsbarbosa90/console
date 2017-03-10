#Include 'Protheus.ch'

/*------------------------------------------------------------------------------+
| CLASSE : Company          |AUTHOR: FERNANDO BARBOSA        | DATA:12/05/2016  |
+-------------------------------------------------------------------------------+
| DESCRICAO | CLASSE RESPONSAVEL POR VALIDOR AS EMPRESA E CRIAR AMBIENTES       |
|           | RPC NO PROTHUEUS                                                  |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+
|ALTERACOES |                                                                   |
|           |                                                                   |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+*/

Class Company
*************
	
	/*-----------------------+
	| PROPRIEDADES DA CLASSE |
	+------------------------+*/
	Data empresa
	Data filial
	Data Ret
	Data fault
	Data instance
	
	/*--------------------+
	| CRIACAO DOS METODOS |
	+---------------------+*/
	Method New(cEmpIbx,cFilIbx)         /* METODO UTILIZADO PARA CRIAR O OBJETO                                                                         */ 
	Method Validate(lInstance)          /* METODO UTILIZADO PARA VALIDAR A EMPRESA                                                                      */
	Method Instance()                   /* METODO UTILIZADO PARA CRIAR O RPC                                                                            */
	Method Destruct()                   /* METODO UTILIZADO PARA DESTRUIR A CONEXAO RPC                                                                 */
	
	/*------------------+
	| METODO DE ROTORNO |
	+-------------------+*/
	Method GetWarning()	 /* PEGA A MESAGEM DE ERRO */
	Method GetEmpresa()   /* PEGA A EMPRESA LOGADA  */
	Method GetFilial()    /* PEGA A FILIAL LOGADA   */

End Class

/*-------------------------------------+
| METODO UTILIZADO PARA CRIAR O OBJETO |
+--------------------------------------+*/
Method New(cEmpIbx,cFilIbx) Class Company
******************************************
Default cEmpIbx := "01"
Default cFilIbx := "010101"

::empresa := cEmpIbx
::filial  := cFilIbx 
::Ret     := .F.
::fault   := ""
::instance:= .F.

Return Self

/*----------------------------------------+
| METODO UTILIZADO PARA VALIDAR A EMPRESA |
| LINSTACE SE JA DESEJA CRIAR O RPC       |
+-----------------------------------------+*/
Method Validate(lInstance) Class Company
*****************************************
Default lInstance := .F.

::ret  := .F.
::fault:= "Empresa ou Filial não foi localizada" 

If FWFilExist(::empresa,::filial)
    ::ret  := .T.
    ::fault:= ""
    
    /*-------------------------------------+
    | VERIFICA SE JÁ CRIARA A INSTACIA RCP |
    +--------------------------------------+*/
    If lInstance
		::Instance()
    EndIf
	
EndIf	

Return ::Ret

/*-----------------------------------+
| METODO UTILIZADO PARA CRIAR O RPC  |
+------------------------------------+*/
Method Instance() Class Company
*******************************
If ::ret
	::Destruct() /* VERIFICA SE NÃO TEM INSTACIA ABERTA */
    RpcSetType(3)
    RpcSetEnv(::empresa,::filial)   
    ::instance := .T.
EndIf
Return

/*---------------------------------------------+
| METODO UTILIZADO PARA DESTRUIR A CONEXAO RPC |
+----------------------------------------------+*/
Method Destruct() Class Company
*******************************
If ::instance
    RpcClearEnv()  
    ::instance := .F.
EndIf	
Return

/*-----------------------+
| PEGA A MESAGEM DE ERRO |
+------------------------+*/
Method GetWarning() Class Company
*********************************
Return IIF(!(::ret) .And. ::fault != Nil,::fault,"")

/*-----------------------+
| PEGA A EMPRESA LOGADA  |
+------------------------+*/
Method GetEmpresa() Class Company
**********************************
Return IIF(::ret .And. ::instance,::empresa,"")

/*---------------------+
| PEGA A FILIAL LOGADA |
+----------------------+*/
Method GetFilial() Class Company
********************************
Return IIF(::ret .And. ::instance,::filial,"")