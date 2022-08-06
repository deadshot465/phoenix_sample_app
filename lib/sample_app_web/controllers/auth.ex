defmodule SampleAppWeb.Auth do
  import Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id != nil do
      user = SampleApp.Account.find_user(user_id)
      assign(conn, :current_user, user)
    else
      conn = fetch_cookies(conn, signed: ["user_id"], encrypted: ["remember_token"])
      IO.inspect(conn.cookies)

      user = case Map.fetch(conn.cookies, "user_id") do
        {:ok, user_id} -> case SampleApp.Account.authenticated?(user_id, conn.cookies["remember_token"]) do
          {:ok, user} -> user
          {:error, _} -> nil
        end

        _ -> nil
      end

      assign(conn, :current_user, user)
    end
  end

  @spec login(Plug.Conn.t(), atom | %{:id => any, optional(any) => any}, boolean(), String.t()) :: Plug.Conn.t()
  def login(conn, user, remember_me \\ false, token \\ "") do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
    |> then(fn c ->
      if remember_me do
        max_age = div(:timer.hours(175200), 1000)

        c
        |> put_resp_cookie("user_id", user.id, sign: true, max_age: max_age)
        |> put_resp_cookie("remember_token", token, encrypt: true, max_age: max_age)
      else
        c
      end
    end)
  end

  @spec logout(Plug.Conn.t()) :: Plug.Conn.t()
  def logout(conn) do
    configure_session(conn, drop: true)
    |> delete_resp_cookie("user_id", sign: true)
    |> delete_resp_cookie("remember_token", encrypt: true)
  end
end
