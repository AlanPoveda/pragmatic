defmodule Servy.FileHandler do
  def handle_read({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}

  def handle_read({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "File not found"}

  def handle_read({:error, reason}, conv),
    do: %{conv | status: 500, resp_body: "File error, reason #{reason}"}
end
