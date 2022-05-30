defmodule Servy.Conv do
  defstruct path: "", status: nil, resp_body: "", method: "", params: %{}, headers: %{}

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
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
