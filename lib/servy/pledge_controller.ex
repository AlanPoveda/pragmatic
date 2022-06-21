defmodule Servy.PledgeController do


  def create(conv, %{"name" => name, "amount" => amount}) do
    # Esta função vai ser pega do ache
    Servy.PladgeServer.create_pledge(name, String.to_integer(amount))
    %{ conv | status: 201, resp_body: "#{name} pledge #{amount}"}
  end

  def index(conv) do
    # Vai pegar do cache quais foram as mais recentes
    pledges = Servy.PladgeServer.recent_pledges()

    %{ conv | status: 200, resp_body: (inspect pledges)}
  end

end
