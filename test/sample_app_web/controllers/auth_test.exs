defmodule SampleAppWeb.AuthTest do
  use SampleAppWeb.ConnCase, async: true

  alias SampleAppWeb.Auth

  @token Pbkdf2.Base.gen_salt(format: :django, salt_len: 22)

  setup %{conn: conn} do
    conn = conn
    |> bypass_through(SampleAppWeb.Router, :browser)
    |> get("/")

    {:ok, %{conn: conn}}
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn = conn
    |> Auth.login(%SampleApp.Account.User{id: 123})
    |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "login puts the user in the session and cookies with remember_me", %{conn: conn} do
    login_conn = conn
    |> Auth.login(%SampleApp.Account.User{id: 123}, true, @token)
    |> send_resp(:ok, "")

    next_conn = get(login_conn, "/") |> fetch_cookies(signed: ["user_id"], encrypted: ["remember_token"])
    assert get_session(next_conn, :user_id) == 123
    assert next_conn.cookies["user_id"] == 123
    assert next_conn.cookies["remember_token"] == @token
  end

  test "logout removes the user from the session and cookies", %{conn: conn} do
    logout_conn = conn
    |> Auth.logout()
    |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/") |> fetch_cookies(signed: ["user_id"], encrypted: ["remember_token"])
    refute get_session(next_conn, :user_id)
    refute next_conn.cookies["user_id"]
    refute next_conn.cookies["remember_token"]
  end

  test "call places user from session to assigns", %{conn: conn} do
    user = user_fixture()
    conn = conn
    |> put_session(:user_id, user.id)
    |> Auth.call([])

    assert conn.assigns.current_user.id == user.id
  end

  test "call sets current_user to nil if no session is found", %{conn: conn} do
    conn = Auth.call(conn, [])

    refute conn.assigns.current_user
  end
end
