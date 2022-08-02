defmodule SampleAppWeb.HelloController do
  use SampleAppWeb, :controller

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    render(conn, "hello.html")
  end
end
