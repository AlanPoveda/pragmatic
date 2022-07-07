defmodule Servy.PledgeServer do
  # Aqui guarda o número do PID em um atomo para dps ser usado
  @process_name :pledge_server

  # Inicia o processo e ainda salva num atom o nome do processo
  def start() do
    IO.puts("Start the Pledge Server")
    pid = spawn(__MODULE__, :listen_loop, [[]])

    # Aqui onde é registrado o PID a essa atributo de módulo
    Process.register(pid, @process_name)
    pid
  end

  def create_pledge(name, amount) do
    call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    # Aqui é para enviar as infromações para o processo atual
    call(@process_name, :recent_pledges)
  end

  def total_pledges() do
    call(@process_name, :total_pledges)
  end

  # Este é uma forma generica e assincrona de fazer as chamadas são chamadas lá encima
  def call(pid, message) do
    send(pid, {self(), message})

    # Aqui ele responde o que ele recebe do lado do server. A resposta, conforme a mensagem enviada
    receive do
      {:response, response} -> response
    end
  end

  # # Informações vindas do client
  # def create_pledge(name, amount) do
  #   send(@process_name , {self(), :create_pledge, name, amount})
  #   # Guardado no cache
  #   receive do {:response, status} -> status end
  # end

  # def recent_pledges() do
  #   # Aqui é para enviar as infromações para o processo atual
  #   send(@process_name , {self(), :recent_pledges})

  #   # Aqui esta retornando as mensages
  #   receive do {:response, pledges} -> pledges end
  # end

  # def total_pledges() do
  #   send(@process_name, {self(), :total_pledges})
  #   receive do {:response, total} -> total end
  # end

  defp send_pledge_to_server(_name, _amount) do
    # Este é o código que vai enviar para o serviço externo
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  # Informações vindas do server
  def listen_loop(state) do
    # Aqui parece que trava o processo, e fica esperando receber a mensagem. Wait for condition
    receive do
      # Aqui entra quando for criar
      {sender, {:create_pledge, name, amount}} ->
        {:ok, id} = send_pledge_to_server(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        # Aqui é a recursividade para ser chamado novamente
        listen_loop(new_state)

      # Aqui entra para mostrar os recentes
      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      # Aqui entra para mostrar todos
      {sender, :total_pledges} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      # Aqui entra quando é enviada uma mensagem que não é esperada
      unexpected ->
        IO.puts("Unexpected message #{inspect(unexpected)}")
        listen_loop(state)
    end
  end
end

alias Servy.PledgeServer

PledgeServer.start()

IO.inspect(PledgeServer.create_pledge("alan", 26))
IO.inspect(PledgeServer.create_pledge("natalia", 26))
IO.inspect(PledgeServer.create_pledge("biel", 24))
IO.inspect(PledgeServer.create_pledge("davida", 12))
IO.inspect(PledgeServer.create_pledge("gaby", 18))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledges())
