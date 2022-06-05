defmodule Servy.Wildthings do
  alias Servy.Bear

  @bd_json Path.expand("../../db", __DIR__)

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
