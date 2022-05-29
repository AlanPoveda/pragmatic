defmodule Servy.Handler do
  require Logger

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

  def emojify(%{status: 200, resp_body: resp_body} = conv) do
    emojis = String.duplicate("🐻", 5)
    %{conv | resp_body: emojis <> resp_body <> emojis}
  end

  def emojify(conv), do: conv

  # Fazer o traking e visualizar qual path que esta se perdendo
  def track(%{status: 404, path: path} = conv) do
    Logger.warn("Warning, the path #{path} is on the lose")
    conv
  end

  # Fazendo uma padrão pois todas vai passar por aqui
  def track(conv), do: conv

  # Aqui é para sobrescrever um pacote que venha de forma diferente
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Forma feita usando regex e pegando o ID
  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  # É necessária esta validação, pois todas vao passar por este lado,
  # então só para retornar
  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    # Aqui estou pegando a primeira linha do texto que estou pegando.
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Isto é o retorno dessa função, um map com a arr
    %{method: method, path: path, resp_body: "", status: nil}
  end

  # Nesse caso daqui é para se tiver esses dados de wildtings ele entra aqui
  def route(%{method: "GET", path: "/wildthings"} = conv) do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  # Nesse caso daqui é para se tiver esses dados de bears ele entra aqui
  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Tomato, Potato, Gabs", status: 200}
  end

  # Nesse caso daqui bears/1 que seria o id, só que usa o pattern maching com concatenação
  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
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

  # Rota da pagina About
  def route(%{method: "GET", path: "/about"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
    |> File.read()
    |> handle_read(conv)
  end

  # Pegando a page de forma genérica
  def route(%{method: "GET", path: "/about" <> page} = conv) do
    Path.expand("../../pages", __DIR__)
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

  def route(%{method: "GET", path: "/bears/new" = conv}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read()
    |> handle_read(conv)
  end

  def handle_read({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}

  def handle_read({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "File not found"}

  def handle_read({:error, reason}, conv), do: %{conv | status: 500, resp_body: "File error, reason #{reason}"}





  # Este daqui é o delete
  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    # Logger.info("Tou can't delete a bear")
    %{conv | resp_body: "You can't delete a bear #{id}", status: 403}
  end

  def route(%{path: path} = conv) do
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
