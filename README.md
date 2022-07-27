# Servy
O servy é um clone do phoenix bem simples, usando o gen_tcp para poder executar o servidor e 
para entender como funciona as requisições web.

Ele é feito para entender tanto a parte do Endpoint até a view.

Tem testes unitários em cada request que é feita.


## Installation
Para instalação, somente clonar e executar, não faz uso de banco de dados esta aplicação

ˋˋˋ
 
mix deps.gets 

ˋˋˋ

Para executar o servidor

ˋˋˋ
 
iex -S mix

Servy.HttpServer.start(4000)

ˋˋˋ

As rotas que existem

GET /pledges
POST /pledges

GET /kaboom

GET /bears
GET /bears/:id
POST /bears

GET /snapshots

GET /hibernating/:time

GET /wildthings
POST /wildthings

GET /api/bears
POST /api/bears




