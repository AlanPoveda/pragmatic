defmodule HandlerTest do
  use ExUnit.Case

  import Servy.Handler, only: [handle: 1]

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 60\r
           \r
           🐻🐻🐻🐻🐻Bears, Lions, Tigers🐻🐻🐻🐻🐻
           """
  end

  test "GET /bears" do
    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 357\r
    \r
    🐻🐻🐻🐻🐻<h1>All The Bears!</h1>

    <ul>
      <li>Pequena - Japanese</li>
      <li>Neomax - Colombian</li>
      <li>Luz - Colombian</li>
      <li>Gaby - Colombian</li>
      <li>David - Colombian</li>
      <li>Alan - Brazilian</li>
      <li>Adma - Brazilian</li>
    </ul>🐻🐻🐻🐻🐻
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 404 Not Found\r
           Content-Type: text/html\r
           Content-Length: 20\r
           \r
           Not found a /bigfoot
           """
  end

  test "GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 113\r
    \r
    🐻🐻🐻🐻🐻<h1>Show Bear</h1>
    <p>
    Is Pequena hibernating? <strong>true</strong>
    </p>🐻🐻🐻🐻🐻
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 60\r
           \r
           🐻🐻🐻🐻🐻Bears, Lions, Tigers🐻🐻🐻🐻🐻
           """
  end

  test "GET /about" do
    request = """
    GET /about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 359\r
    \r
    🐻🐻🐻🐻🐻<h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe as one great dewdrop,
    striped and dotted with continents and islands, flying
    through space with other stars all singing and shining
    together as one, the whole universe appears as an infinite
    storm of beauty. -- John Muir
    </blockquote>🐻🐻🐻🐻🐻
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 201 Created\r
           Content-Type: text/html\r
           Content-Length: 33\r
           \r
           Created a Brown bear named Baloo!
           """
  end

  test "POST /api/bears" do
    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 21\r
    \r
    {"name": "Breezly", "type": "Polar"}
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 201 Created\r
           Content-Type: text/html\r
           Content-Length: 35\r
           \r
           Created a Polar bear named Breezly!
           """
  end

  test "DELETE /bears" do
    request = """
    DELETE /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 403 Forbidden\r
           Content-Type: text/html\r
           Content-Length: 25\r
           \r
           You can't delete a bear 1
           """
  end

  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type:application/json\r
    Content-Length:472\r
    \r
    🐻🐻🐻🐻🐻[{"type":"Japanese","name":"Pequena","id":1,"hibernating":true},
    {"type":"Colombian","name":"David","id":2,"hibernating":true},
    {"type":"Colombian","name":"Luz","id":3,"hibernating":true},
    {"type":"Colombian","name":"Gaby","id":4,"hibernating":true},
    {"type":"Brazilian","name":"Alan","id":5,"hibernating":true},
    {"type":"Brazilian","name":"Adma","id":6,"hibernating":true},
    {"type":"Colombian","name":"Neomax","id":7,"hibernating":true}]🐻🐻🐻🐻🐻
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
