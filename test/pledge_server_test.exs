defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "Create a new pledges and show the recent" do
    PledgeServer.start()

    PledgeServer.create_pledge("alan", 26)
    PledgeServer.create_pledge("natalia", 26)
    PledgeServer.create_pledge("biel", 24)
    PledgeServer.create_pledge("davida", 12)
    PledgeServer.create_pledge("gaby", 18)

    most_recent = [{"gaby", 18}, {"davida", 12}, {"biel", 24}]

    assert PledgeServer.recent_pledges() == most_recent

    assert PledgeServer.total_pledges() == 54

  end



end
