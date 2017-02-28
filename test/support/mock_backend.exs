defmodule TestSupport.MockBackend do
  defmacro __using__(_) do
    quote do
      use HTTPoison.Base

      def request(method, url, body, headers, options) do
        send self(), {:mocked_request, %{
          method: method,
          url: url,
          body: body,
          headers: headers,
          options: options
        }}

        %HTTPoison.Response{
          body: "",
          headers: [],
          status_code: 200
        }
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
