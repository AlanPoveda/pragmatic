defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> route()
    |> format_response()
  end

  def parse(request) do
    # Aqui estou pegando a primeira linha do texto que estou pegando.
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Isto é o retorno dessa função
    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # Uma forma elegante e simples e modificar o map
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    # Aqui mostra como contatenar a string de forma dinâmica! até podeno usar funções para isso
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-lenght: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings http/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
