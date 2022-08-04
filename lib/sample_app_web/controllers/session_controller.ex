defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _) do
    render(conn, "new.html")
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case SampleApp.Account.authenticate(email, password) do
      {:ok, user} ->
        conn
        |> SampleAppWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.static_pages_path(conn, :home))

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid email/password combination.")
        |> render("new.html")
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _) do
    SampleAppWeb.Auth.logout(conn)
    |> redirect(to: Routes.static_pages_path(conn, :home))
  end
end
