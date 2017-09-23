defmodule RumblWeb.Auth do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  # This plugin only tries to get a user_id from the session and
  # add the user to "assigns". It then passes through. The real
  # authentication happens when an action tries to get the user_id
  # from the session.
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(RumblWeb.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end
end
