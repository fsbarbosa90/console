#Console
  Console em ADVPL para poder testar e executar comandos em ADVPL, sem precisar estar com o cliente aberto.

# Aplicação
  Para o console funcionar corretamente, tem que compilar todos os fontes .prw no rpo.
  
# Objetivo
  
   Executar comandos e chamadas de procedimento de forma simples e fácil. Exemplo, digamos que não saiba como se comporta uma determinada função da totvs, ou o que ela vai trazer de retorno, basta colocar no console e executar, que o mesmo ira trazer as informações e exibir em tela, não importante o tipo de retorno do mesmo. Ex: <b>PswRet()</b>, ou <b>GetMv("MV_ESTNEG")</b>.
  
# Comandos reservados
 
  * <b>CLEAR ou CLS</b> = Limpar tudo que está escrito no console.
  * <b>EXIT, CLOSE ou :Q</b> = Fechar o console
  * <b>INFOUSER, USERINFO, INFO ou USER</b> = Exibe os dados do usuário que está conectado ao console!
  * <b>LOGOFF, SAIR ou DESCONECTAR</b> = Voltar à tela de login.
  * <b>RESET, SHUTDOWN ou REINICIAR</b> = Reinicia o console, e abre novamente sem precisar de login.
  
  
  
#cuidados
  
  Para o login funcionar corretamente, tem que ajustar a constante (<b>GRUPOPRD</b>) no início do fonte <b>Consolee.prw</b>, com o grupo de usuário que poderão realizar login no console. Pois igual ao formulas não pode ficar aberto, pois um comando errado, por danificar muita coisa!
  
  E no mesmo fonte <b>Consolee.prw</b>, ajustar as outras duas constantes (<b>EMPLOG</b>,<b>FILLOG</b>), com os códigos da empresa e filial, que ira executar o console.

# Atalhos Teclado
  <b>[F2]</b> Retorna os comandos executados de forma decrescente(Ultimo para o primeiro) =  Ao pressionar a tecla F2, o console preenche automaticamente o ultimo comando executado, e cada vez que a mesma é pressionada ele ira retornando os comandos executados, até chegar no primeiro comando em tela, o console volta a trazer o ultimo executado.

  <b>[F4]</b> Retorna os comandos executados de forma crescente(primeiro para o Ultimo) =  Ao pressionar a tecla F4, o console preenche automaticamente o primeiro comando executado, e cada vez que a mesma é pressionada ele ira avançando os comandos executados, até chegar no ultimo comando em tela, o console volta a trazer o primeiro executado, retornando assim o processo.
  

# Executar o console 
  
    Para abrir o console, basta abri o seu SmartClient do prothues, e digitar na opção Programa inicial o seguinte comando <b>U_Consolee()</b>. A comunicação e o ambiente vão depender da configuração de seu ambiente! No meu caso Comunicação TCP, ambiente Producao
  
  
# Melhorias futuras
  
    1) Criar uma opção aonde seja possível escolher a empresa/filial que deseja logar.
    2) Criar logs dos comandos executados, e dados de quando e quem executou.
        
  
# <i>IMPORTANTE</i>
  
  * Cuidado ao executar qualquer comando no console, vai ter o mesmo efeito se tivesse executado no Client, então muito cuidado ao realizar comandos, pois isso pode gerar problemas gigantescos.
  
  * NÃO ME RESPONSABILIZO POR QUALQUER COMANDO EXECUTADO DE FORMA ERRADA, POR ISSO NÃO DISPONIBILIZE ESSA FUNÇÃO PARA QUALQUER USUÁRIO, SOMENTE PARA QUER SABER TRABALHAER COM A LIGUAGEM ADVPL, E FUNÇÕES TOTVS.
 
