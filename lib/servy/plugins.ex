defmodule Servy.Plugins do
  require Logger
  @doc "Logs a emojis in status 200"
  def emojify(%{status: 200, resp_body: resp_body} = conv) do
    emojis = String.duplicate("🐻", 5)
    %{conv | resp_body: emojis <> resp_body <> emojis}
  end

  def emojify(conv), do: conv

  # Fazer o traking e visualizar qual path que esta se perdendo
  @doc "Logs 404 request"
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
end
