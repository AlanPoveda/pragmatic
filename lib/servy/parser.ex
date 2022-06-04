defmodule Servy.Parser do

  alias Servy.Conv, as: Conv

  def parse(request) do
    # Aqui esta separando em duas partes, o request e os parametros enviados
    [top,  params_string] = String.split(request, "\r\n\r\n")
    # Aqui serpara o Tipo  de requisição e os Headers info
    [ request_line | header_lines ] = String.split(top, "\r\n")
    # Aqui já são as infmações do request!
    [method, path, _ ] = String.split(request_line, " ")

    #headers = parse_headers(header_lines, %{})
    headers = parse_headers(header_lines)

    # Nesse caso ele somente vai pegar os parâmetros desse tipo, pois é do método POST
    params = parse_params(headers["Content-Type"], params_string)

    # Isto é o retorno dessa função, um map com a arr
    %Conv{method: method, path: path, params: params, headers: headers}
  end


  # Exercício usando reduce
  def parse_headers(header_line) do
    Enum.reduce(header_line, %{}, fn (head, acc) ->
      [key, value] = String.split(head, ": ")
      Map.put(acc, key, value)
    end)
  end

  # Pegar os dados do header e transformar em map, usando recursividade
  # defp parse_headers([head | tail], headers) do
  #   # Aqui faz a separação do Key e value
  #   [key, value] = String.split(head, ": ")
  #   # Criação do map, e ele recebe o map anterior, dessa forma ele adiciona!
  #   header = Map.put(headers, key, value)
  #   # Recusividade!, chama denovo somente a tail e começa o processo novamente
  #   parse_headers(tail, header)
  # end

  # defp parse_headers([], headers), do: headers

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  defp parse_params("application/json", params_string) do
    Poison.Parser.parse!(params_string, %{})
  end

  #Essa daqui ignora tudo o resto que seja de outro método sem ser o POST e retorna um map vazio
  defp parse_params(_,_), do: %{}
end
