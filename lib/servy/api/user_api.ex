defmodule Servy.Api.UserApi do
  #Aqui esta fazendo a busca do id quando passar pela url
  def query(id) do
    api_url(id)
    |> HTTPoison.get()
    |> handle_response()
  end

  # Aqui ele pega os parâmetros que são enviado e tranforma em string para pode fazer a busca
  defp api_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  # Aqui já é os cases e retornar numa tupla a resposta
  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    city =
      Poison.Parser.parse!(body, %{})
      |> get_in(["address", "city"])

    {:ok, city}
  end

  defp handle_response({:ok, %{status_code: _status, body: body}}) do
    message =
      Poison.Parser.parse!(body, %{})
      |> get_in(["message"])

    {:error, message}
  end

  defp handle_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
