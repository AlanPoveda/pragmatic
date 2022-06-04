defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  import Servy.View, only: [render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.sort_by_name(&1, &2))

    render(conv, "index.eex", bears: bears)
  end

  # Nesse caso esta pegando somente o que vem com id, mas da para fazer de mais formas
  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  # Aqui pega as informações para o post e usa pattern macht para estrair melhor
  def create(conv, %{"name" => name, "type" => type} = _params) do
    %Conv{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def delete(conv, id) do
    bear = Wildthings.get_bear(id)
    %Conv{conv | resp_body: "You can't delete a bear #{bear.id}", status: 403}
  end
end
