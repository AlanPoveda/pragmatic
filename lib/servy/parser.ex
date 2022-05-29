defmodule Servy.Parser do
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
end
