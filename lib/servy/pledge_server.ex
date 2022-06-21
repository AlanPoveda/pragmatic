defmodule Servy.PledgeServer do

  @process_name :pledge_server

  def start() do
    IO.puts("Start the Pledge Server")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name )
  end

  def listen_loop(state) do

    # Aqui parece que trava o processo, e fica esperando receber a mensagem. Wait for condition
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id } = send_pledge_to_server(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [ {name, amount} | most_recent_pledges ]
        send(sender, {:response, id})
        # Aqui é a recursividade para ser chamado novamente
        listen_loop(new_state)
      {sender, :recent_pledges } ->
        send(sender, {:response, state})
        listen_loop(state)
    end

  end

  def create_pledge(name, amount) do
    send(@process_name , {self(), :create_pledge, name, amount})
    # Guardado no cache
    receive do {:response, status} -> status end
  end

  def recent_pledges() do
    # Aqui é para enviar as infromações para o processo atual
    send(@process_name , {self(), :recent_pledges})

    # Aqui esta retornando as mensages
    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_server(_name, _amount) do
    # Este é o código que vai enviar para o serviço externo
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end



# alias Servy.PledgeServer

# PledgeServer.start()

# IO.inspect PledgeServer.create_pledge("alan", 26)
# IO.inspect PledgeServer.create_pledge("natalia", 26)
# IO.inspect PledgeServer.create_pledge("biel", 24)
# IO.inspect PledgeServer.create_pledge("davida", 12)
# IO.inspect PledgeServer.create_pledge("gaby", 18)


# IO.inspect(PledgeServer.recent_pledges())
