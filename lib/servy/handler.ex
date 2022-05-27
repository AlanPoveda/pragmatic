defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  # Fazer o traking e visualizar qual path que esta se perdendo
  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning, the path #{path} is on the lose")
    conv
  end

  # Fazendo uma padrão pois todas vai passar por aqui
  def track(conv), do: conv

  # Aqui é para sobrescrever um pacote que venha de forma diferente
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "wildthings"}
  end

  # É necessária esta validação, pois todas vao passar por este lado, então só para retornar
  def rewrite_path(conv), do: conv

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    # Aqui estou pegando a primeira linha do texto que estou pegando.
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Isto é o retorno dessa função
    %{method: method, path: path, resp_body: "", status: nil}
  end

  # Aqui é uma recursividade que irá receber o mapa, e o pacote
  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  # Nesse caso daqui é para se tiver esses dados de wildtings ele entra aqui
  def route(conv, "GET", "/wildthings") do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  # Nesse caso daqui é para se tiver esses dados de bears ele entra aqui
  def route(conv, "GET", "/bears") do
    %{conv | resp_body: "Tomato, Potato, Gabs", status: 200}
  end

  # Nesse caso daqui bears/1 que seria o id, só que usa o pattern maching com concatenação
  def route(conv, "GET", "/bears/" <> id) do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears #{id}", status: 200}
  end

  # Este daqui é o delete
  def route(conv, "DELETE", "/bears/" <> id) do
    %{conv | resp_body: "You can't delete a bear", status: 403}
  end

  def route(conv, _method, path) do
    %{conv | resp_body: "Not found a #{path}", status: 404}
  end

  def format_response(conv) do
    # Aqui mostra como contatenar a string de forma dinâmica! até podeno usar funções para isso
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-lenght: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # Esta é uma forma bem diferente de achar o value da key num map. %{}[key]
  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      204 => "Resource deleted successfully",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal server error"
    }[code]
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

request  =  """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
