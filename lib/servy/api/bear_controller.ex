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

  def create(conv, %{"name" => name, "type" => type}) do
    %Conv{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end


end
