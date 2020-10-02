##    Exemplo prático de comandos usualmente necessário para Web Scraping     ##

#### 0. Abrindo navegador com RSelenium ####
## Limpando o R
rm(list=ls())

# Carregando pacate:
library(RSelenium)

# Criando o "driver"
# Firefox:
driver<-rsDriver(browser = "firefox", port = 4446L) # Muitas vezes basta estes dois parâmetros

# Chrome:
#driver<-rsDriver(browser = "chrome", port = 4440L, chromever = "78.0.3904.105")

remDr <- driver[["client"]] # Estabelecendo termo ("remDr") para acessar as funcionalidades do driver


# Abrir URL:
remDr$navigate("https://consultas.anvisa.gov.br/#/medicamentos/q/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")


#### 1. Interface do console ####
### Objetivo: reportar qual site a ser acessado

## Configurando diretório de trabalho
setwd("C:\\Users\\oOluc\\Dropbox\\web_scraping")

## Importando dados previamente extraídos 
df0<-read.csv("df_etapa1.csv",stringsAsFactors = FALSE)

## Criando nova variável a ser inserida no link
df0$n_processo<-gsub("[^0-9]","",df0$processo) # comando usa regex para deixar string apenas com variáveis

## Criando links para acessar as informações dos registros de medicamentos

# Pegando o número do processo
n_proc<-df0$n_processo[1] #pegando o número do processo do registro 1

# Reportando link:
print(paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31"))

# Forma um pouco mais elegante:
url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")

print(paste0("Boa tarde senhor(a), acessaremos o seguinte site: ",url))


####  2. Repetição  ####
### Objetivo: fazer um loop para criar todos links dos registros de medicamento
### e dar um aviso sonoro ao terminar

## Carregando pacote de sons
library("beepr")

##Loop:
for(x in 1:10){
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  print(paste0("Link para o ",x,"º registro criado"))
}

beep(1)


####  3. Manipular o tempo ####
### Objetivo: loop para acessar e esperar carregar corretamente cada página

## Reabrindo navegador
remDr$open()

##Loop:
for(x in 1:10){
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  # Acessar site
  remDr$navigate(url)
  
  Sys.sleep(1) #Esperando 1 segundo
  print(paste0("Link do ",x,"º registro acessado"))
  
  beep(1)
}

### Versão contanto o ponto:
## criando data frame para registrar o tempo de acesso de cada registro
t <- data.frame( time = numeric())

##loop:

for(x in 1:10){
  # Marcando tempo inicial:
  t00<- Sys.time()
  
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  # Acessar site
  remDr$navigate(url)
  
  Sys.sleep(1) #Esperando 1 segundo
  print(paste0("Link do ",x,"º registro acessado"))
  
  # Marcando tempo final
  t01<-Sys.time() #tempo final
  
  s<-difftime(t01,t00,units = "secs") # diferença entre tempo final e inicial
  t<-rbind(t,data.frame(time=as.numeric(s)))
  
  print(paste0("Processo ",x," em (s) ",s))
  
  tempo<-((10-(x+1))*(mean(t$time))/60) # Calculando tempo final
  print(paste0("Minutos até o fim: ",tempo))
  
  beep(1)
}

rm(t)

#### 4./5. Condicional e selecionar elemento ####
### Objetivo: acessar cada registro e garantir que cada página carregou corretamente

#remDr$open()

## Data frame para marcar tempo
t <- data.frame( time = numeric())

##loop:

for(x in 1:10){
  # Marcando tempo inicial:
  t00<- Sys.time()
  
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  # Acessar site
  remDr$navigate(url)
  
  ## Garantir que a página carregou
  webElems <- NULL #Criando objeto vazio
  
  while(length(webElems)==0){
    print("esperando página carregar")
    
    Sys.sleep(1.5) # Esperando a página carregar
    
    webElems <- tryCatch({remDr$findElements(using = 'css selector', "a.btn.btn-default.no-print.ng-scope")},
                         error = function(e){NULL}) # Selecionando botão de expandir
  }
  
  print(paste0("Link do ",x,"º registro acessado"))
  
  # Marcando tempo final
  t01<-Sys.time() #tempo final
  
  s<-difftime(t01,t00,units = "secs") # diferença entre tempo final e inicial
  t<-rbind(t,data.frame(time=as.numeric(s)))
  
  print(paste0("Processo ",x," em (s) ",s))
  
  tempo<-((10-(x+1))*(mean(t$time))/60) # Calculando tempo final
  print(paste0("Minutos até o fim: ",tempo))
  
  beep(1)
}

rm(t)

#### 6. Clicar ####
### Objetivo: acessar cada registro e clicar em "Expandir Todas"

#remDr$open()

## Data frame para marcar tempo
t <- data.frame( time = numeric())

##loop:

for(x in 1:10){
  # Marcando tempo inicial:
  t00<- Sys.time()
  
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  # Acessar site
  remDr$navigate(url)
  
  ## Garantir que a página carregou
  webElems <- NULL #Criando objeto vazio
  
  while(length(webElems)==0){
    print("esperando página carregar")
    
    Sys.sleep(1.5) # Esperando a página carregar
    
    webElems <- tryCatch({remDr$findElements(using = 'css selector', "a.btn.btn-default.no-print.ng-scope")},
                         error = function(e){NULL}) # Selecionando botão de expandir
  }
  
  print("Clicando em Expandir Todas")
  webElems[[1]]$clickElement()
  
  Sys.sleep(1) #Esperando 1 segundo
  print(paste0("Link do ",x,"º registro acessado"))
  
  # Marcando tempo final
  t01<-Sys.time() #tempo final
  
  s<-difftime(t01,t00,units = "secs") # diferença entre tempo final e inicial
  t<-rbind(t,data.frame(time=as.numeric(s)))
  
  print(paste0("Processo ",x," em (s) ",s))
  
  tempo<-((10-(x+1))*(mean(t$time))/60) # Calculando tempo final
  print(paste0("Minutos até o fim: ",tempo))
  
  beep(1)
}

rm(t)


#### 7.\8. Data frames 'temporários' & extração de informação ####
### Objetivo: acessar cada registro e extrair informação de classe terapêutica e data do registro

## Data Frame desejado: 
df<-data.frame(
  nome = character(),
  api = character(),
  registro = character(),
  processo = character(),
  empresa = character(),
  situacao = character(),
  deferimento = character(),
  vencimento = character(),
  n_processo = character(),
  date_reg = character(),
  classe = character()
) #OBS.: não temos as duas últimas variáveis

## Carregando rvest
library("rvest")

## Excluindo variável inútil
df0$X<-NULL

## Data frame para marcar tempo
t <- data.frame( time = numeric())

##loop:

for(x in 1:10){
  # Marcando tempo inicial:
  t00<- Sys.time()
  
  # Pegando o número do processo
  n_proc<-df0$n_processo[x] #pegando o número do processo do registro 1
  
  # Forma um pouco mais elegante:
  url<-paste0("https://consultas.anvisa.gov.br/#/medicamentos/",n_proc,"/?periodoPublicacaoInicial=1900-01-01&periodoPublicacaoFinal=1975-12-31")
  
  # Acessar site
  remDr$navigate(url)
  
  ## Garantir que a página carregou
  webElems <- NULL #Criando objeto vazio
  
  while(length(webElems)==0){
    print("esperando página carregar")
    
    Sys.sleep(1.5) # Esperando a página carregar
    
    webElems <- tryCatch({remDr$findElements(using = 'css selector', "a.btn.btn-default.no-print.ng-scope")},
                         error = function(e){NULL}) # Selecionando botão de expandir
  }
  rm(webElems)
  print(paste0("Link do ",x,"º registro acessado"))
  
  ### Extraindo informações
  ## Selecionando data de registro
  print("Extraindo data")
  webElems <- tryCatch({remDr$findElements(using = 'css selector', "div.ng-scope form.ng-pristine.ng-valid.ng-scope div.panel.panel-default div.table-responsive table.table.table-bordered.table-static tbody tr td.ng-binding")},
                                   error = function(e){NULL}) # Selecionando botão de expandir
  
  webElems <- webElems[[6]]
  
  # Extraindo:
  date_reg0 <- webElems$getElementText()[[1]]
  rm(webElems)
  
  ## Selecionando classe terapêutica
  # Lendo a página pelo comando do rvest
  print("Extraindo classe")
  page<- read_html(remDr$getPageSource()[[1]])
  
  # Selecionando elemento
  webElems <-page %>% html_nodes("form.ng-pristine.ng-valid.ng-scope div.panel.panel-default div.table-responsive table.table.table-bordered.table-static tbody tr td")
  
  # Extraindo:
  classe0 <- html_text(webElems[[12]])
  rm(webElems)
  
  ## Data frame temporário:
  df1<-data.frame(
    nome = df0$nome[x],
    api = df0$api[x],
    registro = df0$registro[x],
    processo = df0$processo[x],
    empresa = df0$empresa[x],
    situacao = df0$situacao[x],
    deferimento = df0$deferimento[x],
    vencimento = df0$deferimento[x],
    n_processo = df0$n_processo[x],
    date_reg = date_reg0,
    classe = classe0
  )
  rm(date_reg0,classe0)
  
  # Unindo com data frame:
  df<-rbind(df,df1)
  
  rm(df1)
  
  # Marcando tempo final
  t01<-Sys.time() #tempo final
  
  s<-difftime(t01,t00,units = "secs") # diferença entre tempo final e inicial
  t<-rbind(t,data.frame(time=as.numeric(s)))
  
  print(paste0("Processo ",x," em (s) ",s))
  
  tempo<-((10-(x+1))*(mean(t$time))/60) # Calculando tempo final
  print(paste0("Minutos até o fim: ",tempo))
  
  beep(1)
}

rm(t)
