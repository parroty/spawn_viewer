defmodule SpawnViewer.Controllers.Pages do
  use Phoenix.Controller

  def index(conn, _params) do
    template = SpawnViewer.Templates.index(Config.target_modules)
    html conn, template
  end

  def analyze(conn, %{"id" => id}) do
    records = SpawnViewer.run(id)
    items = Parser.parse(records)

    data = [{"cols", [[type: "string", id: "Position"],
                      [type: "string", id: "Name"],
                      [type: "date", id: "Start"],
                      [type: "date", id: "End"]]},
            {"rows", items},
            {"p", nil}]

    json conn, 200, [counts: Parser.count_row(records), data: data] |> JSEX.encode!
  end

  def code(conn, %{"id" => id}) do
    code = SpawnViewer.get_code(id)
    text conn, 200, code
  end
end
