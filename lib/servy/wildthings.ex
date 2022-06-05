defmodule Servy.Wildthings do
  alias Servy.Bear

  @bd_json Path.expand("../../db", __DIR__)

  # def list_bears do
  #   [
  #     %Bear{id: 1, name: "Pequena", type: "Japanese", hibernating: true},
  #     %Bear{id: 2, name: "David", type: "Colombian", hibernating: true},
  #     %Bear{id: 3, name: "Luz", type: "Colombian", hibernating: true},
  #     %Bear{id: 4, name: "Gaby", type: "Colombian", hibernating: true},
  #     %Bear{id: 5, name: "Alan", type: "Brazilian", hibernating: true},
  #     %Bear{id: 6, name: "Adma", type: "Brazilian", hibernating: true},
  #     %Bear{id: 7, name: "Neomax", type: "Colombian", hibernating: true},
  #   ]
  # end

  def list_bears do
    @bd_json
    |> Path.join("bears.json")
    |> read_json()
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  defp read_json(source) do
    case File.read(source) do
      {:ok, contents} -> contents
      {:error, reason} -> IO.inspect("Error to read file #{source}, reason #{reason}")
    end
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear()
  end
end
