defmodule Servy.Parser do

  alias Servy.Conv, as: Conv

  def parse(request) do
    # Aqui esta separando em duas partes, o request e os parametros enviados
    [top,  params_string] = String.split(request, "\n\n")
    # Aqui serpara o Tipo  de requisição e os Headers info
    [ request_line | _header_lines ] = String.split(top, "\n")
    # Aqui já são as infmações do request!
    [method, path, _ ] = String.split(request_line, " ")

    params = parse_params(params_string)

    # Isto é o retorno dessa função, um map com a arr
    %Conv{method: method, path: path, params: params}
  end

  defp parse_params(params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end
end
