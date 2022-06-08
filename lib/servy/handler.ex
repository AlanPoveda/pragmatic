defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests
  """

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_read: 2]

  alias Servy.Conv, as: Conv
  alias Servy.BearController
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
    |> put_content_length()
    |> format_response()
  end

  # Uma rota para dormir
  def route(%Conv{method: "GET", path: "/hibernating/" <> timer} = conv) do
    timer |> String.to_integer() |> :timer.sleep()
    %Conv{ conv | status: 200, resp_body: "Awake!"}
  end

  # Nesse caso daqui é para se tiver esses dados de wildtings ele entra aqui
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    # Uma forma elegante e simples e modificar o map
    %Conv{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  # Rota da api, para retornar a lista em formato de json
  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  # Rota da api, para criar um urso, parando os parâmetros
  def route(%Conv{method: "POST", path: "/api/bears", params: params} = conv) do
    Servy.Api.BearController.create(conv, params)
  end


  # Nesse caso daqui é para se tiver esses dados de bears ele entra aqui
  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end



  # Nesse caso daqui bears/1 que seria o id, só que usa o pattern maching com concatenação
  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # Aqui é feito o método para criação de um urso
  def route(%Conv{method: "POST", path: "/bears", params: params} = conv) do
    BearController.create(conv, params)
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

  # Pegar markdown e transformar em HTML
  def route(%Conv{method: "GET", path: "/pages" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}/#{name}.md")
    |> File.read
    |> handle_read(conv)
    |> markdown_to_html
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html!(conv.resp_body) }
  end

  def markdown_to_html(%Conv{} = conv), do: conv

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

  # def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
  #   Path.expand("../../pages", __DIR__)
  #   |> Path.join("form.html")
  #   |> File.read()
  #   |> handle_read(conv)
  # end



  # Este daqui é o delete
  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, id)
    # Logger.info("Tou can't delete a bear")
    #%Conv{conv | resp_body: "You can't delete a bear #{id}", status: 403}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | resp_body: "Not found a #{path}", status: 404}
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %Conv{ conv | resp_headers: headers}
  end

  defp format_response_headers(conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end

  # def format_response(%Conv{} = conv) do
  #   # Aqui mostra como contatenar a string de forma dinâmica! até podeno usar funções para isso
  #   # Outra coisa é o uso de funções estabelecidas no struc para poder criar a resposta
  #   # Tudo de form dinâmica
  #   """
  #   HTTP/1.1 #{Conv.full_status(conv)}\r
  #   Content-Type: #{conv.resp_headers["Content-Type"]}\r
  #   Content-Length: #{conv.resp_headers["Content-Length"]}\r
  #   \r
  #   #{conv.resp_body}
  #   """
  # end

  def format_response(%Conv{} = conv) do
    # Aqui mostra como contatenar a string de forma dinâmica! até podeno usar funções para isso
    # Outra coisa é o uso de funções estabelecidas no struc para poder criar a resposta
    # Tudo de form dinâmica
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end


end
