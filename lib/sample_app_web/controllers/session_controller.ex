defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _) do
    render(conn, "new.html")
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{
        "session" =>
          %{"email" => email, "password" => password, "remember_me" => remember_me} = attrs
      }) do
    case SampleApp.Account.authenticate(email, password) do
      {:ok, user} ->
        remember_me = String.to_atom(remember_me)

        case SampleApp.Account.remember_user(user, %{attrs | "remember_me" => remember_me}) do
          {:ok, _, token} ->
            conn
            |> SampleAppWeb.Auth.login(user, remember_me, token)
            |> put_flash(:info, "Welcome back!")
            |> redirect(to: Routes.static_pages_path(conn, :home))

          {:error, _, _} ->
            conn
            |> put_flash(:error, "Failed to remember user.")
            |> render("new.html")
        end

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
