defmodule Timer do

  def remind(text, second) do
    spawn(fn -> :timer.sleep(second * 1000); IO.puts text end)
  end
end
