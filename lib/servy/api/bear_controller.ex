defmodule Servy.Api.BearController do
  alias Servy.Conv

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    conv = put_resp_content_type(conv, "application/json")
    %Conv{ conv | status: 200, resp_body: json}
  end

  defp put_resp_content_type(conv, app) do
    new_header = Map.put(conv.resp_headers, "Content-Type", app)
    %Conv{ conv | resp_headers: new_header}
  end

end
