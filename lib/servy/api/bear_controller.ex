defmodule Servy.Api.BearController do
  alias Servy.Conv

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()
    %Conv{ conv | status: 200, resp_body: json, resp_content_type: "application/json"}
  end
end
