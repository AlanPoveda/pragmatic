defmodule Servy.Parser do

  alias Servy.Conv, as: Conv

  def parse(request) do
    # Aqui estou pegando a primeira linha do texto que estou pegando.
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Isto é o retorno dessa função, um map com a arr
    %Conv{method: method, path: path}
  end
end
