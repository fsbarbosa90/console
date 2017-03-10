#Include 'Protheus.ch'

/*------------------------------------------------------------------------------+
| CLASSE : LOGINSYS         |AUTHOR: FERNANDO BARBOSA        | DATA:12/05/2016  |
+-------------------------------------------------------------------------------+
| DESCRICAO | VALIDA SE O LOGIN E SENHA DO USUARIO ESTA CORRETO		   	|
|           | MONTA UMA TELA DE LOGIN, E VALIDA SE LOGIN ESTA CERTO, E SE O     |
|           | O USUARIO ESTA NO MESMO GRUPO QUE FOI PASSADO POR PARAMETRO       |
|           |                                                                   |
+-------------------------------------------------------------------------------+
|ALTERACOES |                                                                   |
|           |                                                                   |
|           |                                                                   |
|           |                                                                   |
+-------------------------------------------------------------------------------+*/

User Function LOGINSYS(cGrupo,aData)
************************************
Local lConfirm	:= .F.
Local bBlockOk	:= {|| lConfirm := ValAcess(cGrupo), IIF(lConfirm,oDlgSen:End(),.F.)}

Private cUser		:= Space(50)
Private cSenhaLog	:= Space(20)
Private oLogin  	:= AuthLogin():New()   
Private cMsgLog		:= ""
Private aUser		:= {}
Private oSayMsg	
Private oDlgSen

Default cGrupo		:= "000018" // GRUPO DO TI
Default aData		:= {}


	
oDlgSen := MsDialog():New(1,1,150,200,OemToAnsi("Controle de acesso"),,,.F.,DS_MODALFRAME,,,,,.T.,,,.F.)
oDlgSen:lEscClose := .F.
				
TSay():New(008,05,{|| "Usuário: " },oDlgSen,,,,,,.T.,,,50,10)
TGet():New(017,05,bSetGet(cUser),oDlgSen,92,08,,/*{|| NaoVazio(cUser) }*/,,,,,,.T.,,,,,,,,,"")

TSay():New(030,05,{|| "Senha: " },oDlgSen,,,,,,.T.,,,50,10)
TGet():New(039,05,bSetGet(cSenhaLog),oDlgSen,92,08,,/*{||NaoVazio(cSenhaLog) }*/,,,,,,.T.,,,,,,bBlockOk,,.T.,"")
		
oSayMsg := TSay():New(051,05,{|| cMsgLog },oDlgSen,,,,,,.T.,CLR_RED,,200,10)

TBtnBmp2():New(123,130,25,25,"OK" ,,,,bBlockOk, oDlgSen, "Confirmar")
TBtnBmp2():New(123,170,25,25,"CANCEL",,,,{|| lConfirm := .F., oDlgSen:End()}, oDlgSen, "Sair")		

oDlgSen:lCentered := .T.
oDlgSen:Activate()

aData := aUser

FreeObj(oLogin)

Return lConfirm

/*---------------+
| VALIDA A SENHA |
+----------------+*/
Static Function ValAcess(cGrupo)
********************************
Local lRet 	:= .F.

aUser := {}

if Empty(cUser) .Or.  Empty(cSenhaLog) 
	cMsgLog := "Favor informar todos os campos"
	
Else
	If(oLogin:Validate(AllTrim(cUser), AllTrim(cSenhaLog), cGrupo,"IT", "USR", .F.))
		lRet := .T.
		aUser := aClone(oLogin:GetUser()) 
	Else
		cMsgLog := oLogin:GetWarning()
	EndIf
EndIf 

oSayMsg:Refresh()
oDlgSen:Refresh()

Return lRet
 















