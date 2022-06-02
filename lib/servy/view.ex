defmodule Servy.View do
  alias Servy.Conv
  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, path, binding) do
    content =
      @templates_path
      |> Path.join(path)
      |> EEx.eval_file(binding)

    %Conv{conv | resp_body: content, status: 200}
  end

end
