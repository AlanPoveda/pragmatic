defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears do
    [
      %Bear{id: 1, name: "Pequena", type: "Japanese", hibernating: true},
      %Bear{id: 2, name: "David", type: "Colombian", hibernating: true},
      %Bear{id: 3, name: "Luz", type: "Colombian", hibernating: true},
      %Bear{id: 4, name: "Gaby", type: "Colombian", hibernating: true},
      %Bear{id: 5, name: "Alan", type: "Brazilian", hibernating: true},
      %Bear{id: 6, name: "Adma", type: "Brazilian", hibernating: true},
      %Bear{id: 7, name: "Neomax", type: "Colombian", hibernating: true},
    ]
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear()
  end


end
