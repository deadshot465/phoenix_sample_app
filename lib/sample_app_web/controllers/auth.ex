defmodule SampleAppWeb.Auth do
  import Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && SampleApp.Account.find_user(user_id)
    assign(conn, :current_user, user)
  end

  @spec login(Plug.Conn.t(), atom | %{:id => any, optional(any) => any}) :: Plug.Conn.t()
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
