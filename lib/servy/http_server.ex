# server() ->
#   {ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
#                                       {active, false}]),
#   {ok, Sock} = gen_tcp:accept(LSock),
#   {ok, Bin} = do_recv(Sock, []),
#   ok = gen_tcp:close(Sock),
#   ok = gen_tcp:close(LSock),
#   Bin.

# client() ->
#   SomeHostInNet = "localhost", % to make it runnable on one machine
#   {ok, Sock} = gen_tcp:connect(SomeHostInNet, 5678,
#                                [binary, {packet, 0}]),
#   ok = gen_tcp:send(Sock, "Some Data"),
#   ok = gen_tcp:close(Sock).

# transformando em Elixir lang
defmodule Servy.HttpServer do

  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do

    # Creates a socket to listen for client connections.
    # `listen_socket` is bound to the listening socket.
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # Socket options (don't worry about these details):
    # `:binary` - open the socket in "binary" mode and deliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes

    IO.puts "\n🎧  Listening for connection requests on port #{port}...\n"

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`.
  """
  def accept_loop(listen_socket) do
    IO.puts "⌛️  Waiting to accept a client connection...\n"

    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts "⚡️  Connection accepted!\n"

    # Receives the request and sends a response over the client socket.
    spawn(fn -> serve(client_socket) end) # Usando o spawn apra ser um processo paralelo

    # Loop back to wait and accept the next connection.
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket) do
    IO.puts("#{inspect self()}: Work on it") # Aqui para ver o processo que esta responsável

    client_socket
    |> read_request
    |> Servy.Handler.handle() #Aqui esta lendo todo o código com os request que foram criados.
    #|> generate_response Uma resposta generica, somente para saber se esta funcionando
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the `client_socket`.
  """
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0) # all available bytes

    IO.puts "➡️  Received request:\n"
    IO.puts request

    request
  end

  @doc """
  Returns a generic HTTP response.
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  Sends the `response` over the `client_socket`.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "⬅️  Sent response:\n"
    IO.puts response

    # Closes the client socket, ending the connection.
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end

end
