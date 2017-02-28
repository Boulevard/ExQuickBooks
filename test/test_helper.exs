ExUnit.start

support_path = "./test/support"

for file <- File.ls!(support_path) do
  Code.require_file(file, support_path)
end

Application.put_env(:quickbooks, :backend, TestSupport.MockBackend)
