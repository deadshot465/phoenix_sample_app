defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _params) do
    render(conn, "new.html")
  end
end
