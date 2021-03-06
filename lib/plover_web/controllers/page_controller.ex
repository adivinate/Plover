defmodule PloverWeb.PageController do
  use PloverWeb, :controller
  alias Plover.Slack

  def index(conn, _params) do
    if conn.assigns[:user] do
      redirect(conn, to: account_path(conn, :show))
    else
      render conn, "index.html"
    end
  end

  # Used for waking up free dyno's on heroku using a scheduler
  # Could be used later for re-retrieving data from previous wake states
  def wakeup(conn, _params) do
    Slack.destroy_older_messages!
    {:ok, pull_request_urls} = Redis.get_all_keys

    unless pull_request_urls == nil do
      Enum.each(pull_request_urls, &(Github.start_process(&1)))
    end

    conn
    |> put_status(:ok)
    |> text("ok")
  end
end
