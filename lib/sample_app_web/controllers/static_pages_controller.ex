defmodule SampleAppWeb.StaticPagesController do
  use SampleAppWeb, :controller

  @base_title "Programming Phoenix Sample App"

  @spec home(Plug.Conn.t(), any) :: Plug.Conn.t()
  def home(conn, _params), do: render(conn, "home.html", base_title: @base_title)

  @spec help(Plug.Conn.t(), any) :: Plug.Conn.t()
  def help(conn, _params), do: render(conn, "help.html", base_title: @base_title)

  @spec about(Plug.Conn.t(), any) :: Plug.Conn.t()
  def about(conn, _params), do: render(conn, "about.html", base_title: @base_title)

  @spec contact(Plug.Conn.t(), any) :: Plug.Conn.t()
  def contact(conn, _params), do: render(conn, "contact.html", base_title: @base_title)
end
