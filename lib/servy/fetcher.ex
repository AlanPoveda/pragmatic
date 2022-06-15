defmodule Servy.Fetcher do

  def async(fun) do
    parent = self()

    spawn(fn -> send(parent, {:result, fun.()}) end)
  end

  def get_response() do
    receive do {:result, value} -> value end
  end
end
