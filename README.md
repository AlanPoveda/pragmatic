# Servy
O servy é um clone do phoenix bem simples, usando o gen_tcp para poder executar o servidor e 
para entender como funciona as requisições web.

Ele é feito para entender tanto a parte do Endpoint até a view.

Tem testes unitários em cada request que é feita.


## Installation
Para instalação, somente clonar e executar, não faz uso de banco de dados esta aplicação

<pre><code>
 
mix deps.gets 

</code></pre>

Para executar o servidor

<pre><code>
 
iex -S mix

Servy.HttpServer.start(4000)

</code></pre>

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




