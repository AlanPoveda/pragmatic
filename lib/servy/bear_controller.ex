defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.colombian_bear(&1))
      |> Enum.sort(&Bear.sort_by_name(&1,&2))
      |> Enum.reduce("", fn bear, response ->
        "<li>#{bear.name} -> #{bear.type}</li>" <> response
      end)

    # bears =
    #   Wildthings.list_bears()
    #   |> Enum.filter(fn b -> b.type == "Colombian" end)
    #   |> Enum.sort(fn b1,b2 -> b1.name <= b2.name end)
    #   |> Enum.map(fn b -> "<li>#{b.name} -> #{b.type}" end)
    #   |> Enum.join()

    %Conv{conv | resp_body: "<ul>#{bears}</ul>", status: 200}
  end

  # Nesse caso esta pegando somente o que vem com id, mas da para fazer de mais formas
  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %Conv{conv | resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>", status: 200}
  end

  # Aqui pega as informações para o post e usa pattern macht para estrair melhor
  def create(conv, %{"name" => name, "type" => type} = _params) do
    %Conv{conv | status: 200, resp_body: "Create a #{type} Bear named #{name}!"}
  end


  def delete(conv, id) do
    bear = Wildthings.get_bear(id)
    %Conv{conv | resp_body: "You can't delete a bear #{bear.id}", status: 403}
  end
end
