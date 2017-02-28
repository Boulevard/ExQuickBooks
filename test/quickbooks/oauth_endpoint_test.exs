defmodule QuickBooks.OAuthEndpointTest do
  use ExUnit.Case
  alias QuickBooks.OAuthEndpoint

  doctest OAuthEndpoint

  test "process_url/1 prepends the base URL" do
    assert OAuthEndpoint.process_url("foo") |> String.starts_with?("https")
  end
end
