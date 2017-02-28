defmodule QuickBooks.OAuthEndpoint do
  @moduledoc false

  use QuickBooks.Endpoint

  def process_url(url) do
    QuickBooks.oauth_api <> url
  end
end
