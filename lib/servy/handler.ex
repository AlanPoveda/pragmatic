defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests
  """

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_read: 2]

  alias Servy.Conv, as: Conv
  @doc """
  Transform the request a response
  """
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> emojify()
    |> track()
    |> format_response()
  end

  # Nesse caso daqui é para se tiver esses dados de wildtings ele entra aqui
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  # Nesse caso daqui é para se tiver esses dados de bears ele entra aqui
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Tomato, Potato, Gabs", status: 200}
  end

  # Nesse caso daqui bears/1 que seria o id, só que usa o pattern maching com concatenação
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears #{id}", status: 200}
  end

  # # Aqui ele esta lendo o file da page, e esta retornando um status ou o conteúdo da page
  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file  =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} -> %{conv | status: 200, resp_body: content}
  #     {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found"}
  #     {:error, reason} -> %{conv | status: 500, resp_body: "File error #{reason}"}
  #   end
  # end

  # Rota da pagina About e nesse caso esta usando um Module atribute
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    # Path.expand("../../pages", __DIR__)
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_read(conv)
  end

  # Pegando a page de forma genérica
  def route(%Conv{method: "GET", path: "/about" <> page} = conv) do
    @pages_path
    |> Path.join(page)
    |> File.read()
    |> handle_read(conv)
  end

  # Exercido feito usando Case
  # def route(%{method: "GET", path: "/bears/new"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("form.html")

  #   case File.read(file) do
  #     {:ok, content} -> %{ conv | status: 200, resp_body: content}
  #     {:error, :enoent} -> %{ conv | status: 404, resp_body: "File not found"}
  #     {:error, reason} -> %{ conv | status: 500, resp_body: "File error, reason #{reason}"}
  #   end
  # end

  def route(%Conv{method: "GET", path: "/bears/new" = conv}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read()
    |> handle_read(conv)
  end



  # Este daqui é o delete
  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    # Logger.info("Tou can't delete a bear")
    %{conv | resp_body: "You can't delete a bear #{id}", status: 403}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "Not found a #{path}", status: 404}
  end

  def format_response(%Conv{} = conv) do
    # Aqui mostra como contatenar a string de forma dinâmica! até podeno usar funções para isso
    # Outra coisa é o uso de funções estabelecidas no struc para poder criar a resposta
    # Tudo de form dinâmica
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-lenght: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end


end

# Exemplo padrão agora usando outro path que vai fazer o rewrite
request = """
GET /wildlife http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exemplo padrão
request = """
GET /wildthings http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exemplo padrão
request = """
GET /bears http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exemplo de not found
request = """
GET /bigfot http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exemplo usando um id
request = """
GET /bears/1 http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Este daqui é para fazer o método delete

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exercício

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /about http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

## Exercício

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

# Exercídio pegar a página dinâmicamente
request = """
GET /about/about.html http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
