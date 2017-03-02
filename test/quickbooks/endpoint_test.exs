defmodule QuickBooks.EndpointTest do
  use ExUnit.Case, async: false
  alias QuickBooks.Endpoint
  alias QuickBooks.MockBackend

  doctest Endpoint

  defmodule TestEndpoint do
    use Endpoint, base_url: "http://localhost/"
  end

  setup do
    Application.put_env(:quickbooks, :consumer_key, "key")
    Application.put_env(:quickbooks, :consumer_secret, "secret")
  end

  test "request/5 prepends the base URL" do
    TestEndpoint.request(:get, "foo")

    assert %{
      url: "http://localhost/" <> _
    } = MockBackend.take_request
  end

  test "request/5 signs the request" do
    TestEndpoint.request(:get, "foo")

    assert %{
      headers: [{"Authorization", "OAuth " <> _}]
    } = MockBackend.take_request
  end

  test "request/5 preserves body" do
    TestEndpoint.request(:post, "foo", "bar")

    assert %{
      body: "bar"
    } = MockBackend.take_request
  end

  test "request/5 preserves options" do
    options = [
      params: [{"foo", "bar"}]
    ]

    TestEndpoint.request(:get, "foo", nil, nil, options)

    assert %{
      options: ^options
    } = MockBackend.take_request
  end

  test "request/5 preserves extra headers" do
    extra_headers = [{"X-Leo", "is handsome and cool"}]

    TestEndpoint.request(:get, "foo", nil, extra_headers)

    assert %{
      headers: [_ | ^extra_headers]
    } = MockBackend.take_request
  end
end
