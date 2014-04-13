defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn.fetch([:cookies, :params])
  end

  # It is common to break your Dynamo into many
  # routers, forwarding the requests between them:
  # forward "/posts", to: PostsRouter

  get "/" do
    conn = conn.assign(:functions, Config.target_modules)
    render conn, "index.html"
  end

  get "/analyze/:id" do
    records = SpawnViewer.run(conn.params[:id])
    items = Parser.parse(records)

    data = [{"cols", [[type: "string", id: "Position"],
                      [type: "string", id: "Name"],
                      [type: "date", id: "Start"],
                      [type: "date", id: "End"]]},
            {"rows", items},
            {"p", nil}]

    conn.resp 200, data |> JSEX.encode!
  end

  get "/code/:id" do
    code = SpawnViewer.get_code(conn.params[:id])
    conn.resp 200, code
  end
end
